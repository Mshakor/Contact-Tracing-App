public class CTPersonTriggerHandler {

	public static void beforeInsert(List<Person__c> newRecords) {
		for (Person__c person : newRecords) {
			//update person status to green
			person.Health_Status__c = 'Green';
			//generate secure token
			person.Token__c = CTPersonController.getToken(person.Mobile__c);


		}
	}

	public static void beforeUpdate(List<Person__c> newRecords, Map<Id, Person__c> oldRecords) {
		for (Person__c person : newRecords) {
			//Here compare two value of health status so if there is some change in old record to new record;)
			if (person.Health_Status__c != oldRecords.get(person.Id).Health_Status__c) {
				person.Status_Update_Date__c = Date.today();
			}
		}
	}

	//Before update operation for person __c object
	public static void afterUpdate(List<Person__c> newRecords, Map<Id, Person__c> oldRecords) {
		//Here are two sets:  one for any status change and second for red status
		Set<Id> statusChange = new Set<Id>();
		Set<Id> redStatus = new Set<Id>();

		for (Person__c person : newRecords) {
			//Here compare two value of health status so if there is some change in old record to new record;)
			if (person.Health_Status__c != oldRecords.get(person.Id).Health_Status__c) {
				statusChange.add(person.Id);
			}
			//to check if the previous version of record have health status as red or not
			if (person.Health_Status__c == 'Red' && oldRecords.get(person.Id).Health_Status__c != 'Red') {
				redStatus.add(person.Id);
			}
		}
		//Here we create a already processed set that where we add Ids that being already processed;o
		Set<Id> alreadyProcessed = new Set<Id>();
		alreadyProcessed.addAll(redStatus);

		Set<Id> orangeStatus = new Set<Id>();
		Set<Id> yellowStatus = new Set<Id>();

		//to update the records;)
		List<Person__c> personToUpdate = new List<Person__c>();

		//Lets add Cohabitants
		orangeStatus.addAll(CTPersonController.getCohabitants(redStatus, alreadyProcessed));

		 Set<Id> primaryContacts = CTPersonController.getPrimaryContacts(redStatus, alreadyProcessed);
		orangeStatus.addAll(primaryContacts);
		//lets add neighbours
		yellowStatus.addAll(CTPersonController.getNeighbours(redStatus, alreadyProcessed));
		//Lets add PrimaryContacts
		//Here is another problem that if we mark the person as yellow in get neighbour function we are going to mark it in get primary func
		 // also so to solve this we should put most vulnerable methods on top:o
		//Set<Id> primaryContacts = CTPersonController.getPrimaryContacts(redStatus, alreadyProcessed);
		//orangeStatus.addAll(primaryContacts);
		//Add secondaryContacts
		yellowStatus.addAll(CTPersonController.getSecondaryContacts(primaryContacts, alreadyProcessed));
		//Here is some problem about contact type like other cohabitant Neighbour
		//if we proceed a person Cohabitant then we should not process it in neighbour or other

		for(Id p_id: orangeStatus){
			personToUpdate.add(new Person__c(Id=p_id, Health_Status__c ='Orange'));
		}

		for(Id p_id: yellowStatus){
			personToUpdate.add(new Person__c(Id=p_id, Health_Status__c ='Yellow'));
		}

		if(personToUpdate.size()>0){
			update personToUpdate;

		}
		List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationByPersonIds(statusChange);
		if(locationTraces!=null && locationTraces.size()>0){
			Set<Id> locationIds = new Set<Id>();
			for(Location_Tracing__c trace: locationTraces){
				locationIds.add(trace.Location__c);
			}
			CTLocationController.updateRedScore(locationIds);
		}

	}
}