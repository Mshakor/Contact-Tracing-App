public class CTPersonController {

	public static String getToken(String Mobile) {
		Blob value = Blob.valueOf(Mobile);
		Blob hash = Crypto.generateDigest('MD5', value);

		//get the string value
		return EncodingUtil.base64Encode(hash);


	}

	public static List<Person__c> getRecentHealthChanges() {
		List<Person__c> personList = [select
		Id,
		Name,
		Health_Status__c,
		Mobile__c,
		Status_Update_Date__c,
		Token__c
		from Person__c
		ORDER BY Status_Update_Date__c DESC NULLS LAST
		LIMIT 100];
		return personList;
	}

	public static List<Person__c> searchPeople(String searchTerm) {
		searchTerm = searchTerm + '%';
		return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c
		FROM Person__c
		WHERE Name LIKE :searchTerm
		OR Mobile__c LIKE :searchTerm
		OR Token__c LIKE :searchTerm
		ORDER BY Status_Update_Date__c DESC NULLS LAST];
	}

	public static Person__c getPersonById(String personId) {
		//This method was going to return a list so we require the list. we interested in first element.
		List<Person__c> personA = [select
		Id,
		Name,
		Health_Status__c,
		Mobile__c,
		Status_Update_Date__c,
		Token__c
		from Person__c
		WHERE Id =:personId];
		if (personA != null && personA.size() > 0) {
			return personA[0];
		}
		return null;
	}


	public static Map<String, Integer> getHealthStatusCount() {
		Map<String, Integer> mapOfHealthPersons = new Map<String, Integer>();
		for (AggregateResult person :
		[SELECT Health_Status__c,COUNT(Id) total from Person__c GROUP BY Health_Status__c]) {
			String healthStatus = String.valueOf(person.get('Health_Status__c'));
			Integer total = Integer.valueOf(person.get('total'));
			mapOfHealthPersons.put(healthStatus, total);
			//Error Error We need to type cast the object to appropriate data type:::::::::::
		}


		return mapOfHealthPersons;
	}

	public static Set<Id> getCohabitants(Set<Id>personIds, Set<Id> alreadyProcessed) {
		List<String> healthStatus = new List<String>{'Green', 'Yellow'};
		List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c
		WHERE (Person_1__c IN:personIds OR Person_2__c IN:personIds)
		AND Contact_Type__c = 'Cohabitant'
		AND(Person_1__r.Health_Status__c IN :healthStatus OR Person_2__r.Health_Status__c IN :healthStatus)];
		//here we create a set to create add person Ids if person 1 already present in list like person 1 ali second person shakoor so that it should not add it the list same person in the list
		Set<Id> cohabitants = new Set<Id>();
		for (People_Tracing__c pt : peopleTraces) {
			//Here we add the person ids in already processed set so that we dont process these ids again
			if (!alreadyProcessed.contains(pt.Person_1__c)) {
				cohabitants.add(pt.Person_1__c);
				alreadyProcessed.add(pt.Person_1__c);
			}
			if (!personIds.contains(pt.Person_2__c)) {
				cohabitants.add(pt.Person_2__c);
				alreadyProcessed.add(pt.Person_2__c);

			}
		}

		return cohabitants;
	}


	public static Set<Id> getNeighbours(Set<Id>personIds, Set<Id> alreadyProcessed) {
		List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c
		WHERE (Person_1__c IN:personIds OR Person_2__c IN:personIds)
		AND Contact_Type__c = 'Neighbour'
		AND(Person_1__r.Health_Status__c = 'Green' OR Person_2__r.Health_Status__c = 'Green')];
		//here we create a set to create add person Ids if person 1 already present in list like person 1 ali second person shakoor so that it should not add it the list same person in the list
		Set<Id> Neighbours = new Set<Id>();
		for (People_Tracing__c pt : peopleTraces) {
			if (!alreadyProcessed.contains(pt.Person_1__c)) {
				Neighbours.add(pt.Person_1__c);
				alreadyProcessed.add(pt.Person_1__c);
			}
			if (!alreadyProcessed.contains(pt.Person_2__c)) {
				Neighbours.add(pt.Person_2__c);
				alreadyProcessed.add(pt.Person_2__c);

			}
		}

		return Neighbours;
	}


	//Primary contacts are those in which two people meet in 'other' field
	public static Set<Id> getPrimaryContacts(Set<Id>personIds, Set<Id> alreadyProcessed) {
		List<String> healthStatus = new List<String>{'Green', 'Yellow'};
		List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c
		WHERE (Person_1__c IN:personIds OR Person_2__c IN:personIds)
		AND Contact_Type__c = 'Other'
		AND Contact_Date__c = LAST_N_DAYS:10
		AND(Person_1__r.Health_Status__c IN :healthStatus OR Person_2__r.Health_Status__c IN :healthStatus)];
		//here we create a set to create add person Ids if person 1 already present in list like person 1 ali second person shakoor so that it should not add it the list same person in the list
		Set<Id> PrimaryContacts = new Set<Id>();
		for (People_Tracing__c pt : peopleTraces) {
			if (!alreadyProcessed.contains(pt.Person_1__c)) {
				PrimaryContacts.add(pt.Person_1__c);
				alreadyProcessed.add(pt.Person_1__c);
			}
			if (!personIds.contains(pt.Person_2__c)) {
				PrimaryContacts.add(pt.Person_2__c);
				alreadyProcessed.add(pt.Person_2__c);

			}
		}

		return PrimaryContacts;
	}

	//Secondary contacts are for ex 'ali' meet 'dani' in other contact type and 'dani' meet 'sana' so 'sana' is secondary contact of 'ali'.
	// we will add the primary contact ids in this function because we want to find out secondary contacts.
	public static Set<Id> getSecondaryContacts(Set<Id>primaryContactIds, Set<Id> alreadyProcessed) {
		List<String> healthStatus = new List<String>{'Green', 'Yellow'};
		List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c
		WHERE (Person_1__c IN:primaryContactIds OR Person_2__c IN:primaryContactIds)
		AND Contact_Type__c = 'Other'
		AND Contact_Date__c = LAST_N_DAYS:10
		AND(Person_1__r.Health_Status__c IN :healthStatus OR Person_2__r.Health_Status__c IN :healthStatus)];
		//here we create a set to create add person Ids if person 1 already present in list like person 1 ali second person shakoor so that it should not add it the list same person in the list
		Set<Id> SecondaryContacts = new Set<Id>();
		for (People_Tracing__c pt : peopleTraces) {
			if (!alreadyProcessed.contains(pt.Person_1__c)) {
				SecondaryContacts.add(pt.Person_1__c);
				alreadyProcessed.add(pt.Person_1__c);


			}
			if (!alreadyProcessed.contains(pt.Person_2__c)) {
				SecondaryContacts.add(pt.Person_2__c);
				alreadyProcessed.add(pt.Person_2__c);

			}
		}

		return SecondaryContacts;
	}

	//for aura class health controller
	public static Map<String, Integer> getHealthStatusCountA() {
		AggregateResult[] healthCountMap = [select
		Health_Status__c,
		Count(Id) total
		from Person__c
		Group By Health_Status__c];
		if (healthCountMap != null && healthCountMap.size() > 0) {
			Map<String, Integer> result = new Map<String, Integer>();
			for (AggregateResult ar : healthCountMap) {
				result.put(String.valueOf(ar.get('Health_Status__c')), Integer.valueOf(ar.get('total')));
			}
			return result;
		}
		return null;
	}
}