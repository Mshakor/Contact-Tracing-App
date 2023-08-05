public class CTPeopleTracingController {

	public static List<People_Tracing__c> getTraces(String personId) {
		return [
				SELECT Id,
						Contact_Date__c,
						Person_1__c,
						Person_1__r.Health_Status__c,
						Person_1__r.Token__c,
						Person_2__c,
						Person_2__r.Health_Status__c,
						Person_2__r.Token__c
				FROM People_Tracing__c
				WHERE (Person_1__c = :personId OR Person_2__c = :personId) AND Contact_Date__c = LAST_N_DAYS:30
				ORDER BY Contact_Date__c DESC
		];
	}

	public static List<People_Tracing__c> checkDuplicates(List<People_Tracing__c> peopleTraces) {
		//First we will create a set to save  respective ids here.
		Set<Id> personIds = new Set<Id>();

		//Then iterate over the given list and add values to set person 1 and person 2
		for (People_Tracing__c trace : peopleTraces) {
			personIds.add(trace.Person_1__c);
			personIds.add(trace.Person_2__c);

		}
		//Empty duplicate list
		List<People_Tracing__c> duplicates = new List<People_Tracing__c>();
		//Empty set for entering the values in map
		Map<Id, Set<Id>> mapOfExistingRecords = new Map<Id, Set<Id>>();
		// Query the existing records
		List<People_Tracing__c> existingPeopleRecord = [select Id,
		Name,
		Person_1__c,
		Person_2__c
		from People_Tracing__c
		WHERE Person_1__c IN:personIds
		AND Person_2__c IN:personIds];
		//If input records are present in the existing records
		if (existingPeopleRecord != null && existingPeopleRecord.size() > 0) {
			// iterate over the existing records and put the values in map
			for (People_Tracing__c trace : existingPeopleRecord) {
				if (!mapOfExistingRecords.containsKey(trace.Person_1__c)) {
					mapOfExistingRecords.put(trace.Person_1__c, new Set<Id>());
				}
				mapOfExistingRecords.get(trace.Person_1__c).add(trace.Person_2__c);

				//				Building map for person 2
				if (!mapOfExistingRecords.containsKey(trace.Person_2__c)) {
					mapOfExistingRecords.put(trace.Person_2__c, new Set<Id>());
				}
				mapOfExistingRecords.get(trace.Person_2__c).add(trace.Person_1__c);
			}
			for (People_Tracing__c trace : peopleTraces) {
				if (
						(mapOfExistingRecords.containsKey(trace.Person_1__c) &&
								mapOfExistingRecords.get(trace.Person_1__c).contains(trace.Person_2__c)) ||
						(mapOfExistingRecords.containsKey(trace.Person_2__c) &&
								mapOfExistingRecords.get(trace.Person_2__c).contains(trace.Person_1__c))
				) {
					duplicates.add(trace);

				}
			}

		}
		return duplicates;
	}

}