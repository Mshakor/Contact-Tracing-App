public class CTLocationTracingController {

	public static List<Location_Tracing__c> getVisitor(String locationId) {
		return [select
		Id,
		Location__c,
		Name,
		Person__c,
		Visit_Date__c,
		Person__r.Token__c,
		Person__r.Health_Status__c
		from Location_Tracing__c
		where Location__c = :locationId
		order by Visit_Date__c DESC];


	}

	public static List<Location_Tracing__c> getLocationByPersonIds(Set<Id> personIds) {
		return [select
		Id,
		Location__c,
		Name,
		Person__c,
		Visit_Date__c
		from Location_Tracing__c
		where Person__c = :personIds
		And Visit_Date__c =LAST_N_DAYS:10];
	}

	public static List<Location_Tracing__c> getLocationByLocationIds(Set<Id> locationIds) {
		return [select
		Id,
		Location__c,
		Name,
		Person__c,
		Visit_Date__c
		from Location_Tracing__c
		where Location__c = :locationIds
		And Person__r.Health_Status__c = 'Green'
		And Visit_Date__c = LAST_N_DAYS:10];


	}

	public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> newLocationTraces) {
		//store unique location Ids
		Set<Id> locationIds = new Set<Id>();
		//store unique person Ids
		Set<Id> personIds = new Set<Id>();

		for (Location_Tracing__c trace : newLocationTraces) {
			locationIds.add(trace.Location__c);
			personIds.add(trace.Person__c);
		}

		//map of location id and set of person Ids
		Map<Id, Set<Id>> mapOfExistingRecords = new Map<Id, Set<Id>>();

		//Location 1,[person1],[person2]
		//query existing location tracing records
		List<Location_Tracing__c> existingRecords = [SELECT Id, Person__c, Location__c
		FROM Location_Tracing__c
		WHERE Location__c IN:locationIds
		AND Person__c IN :personIds];

		//List of Duplicate Records
		List<Location_Tracing__c> duplicates = new List<Location_Tracing__c>();

		if (existingRecords != null && existingRecords.size() > 0) {
			for (Location_Tracing__c trace : existingRecords) {
				if (!mapOfExistingRecords.containsKey(trace.Location__c)) {
					mapOfExistingRecords.put(trace.Location__c, new Set<Id>());
				}
				//ad person id to map set
				mapOfExistingRecords.get(trace.Location__c).add(trace.Person__c);
			}
			//Loop over new location tracing records
			for (Location_Tracing__c trace : newLocationTraces) {
				// First check for location id
				//If item found in map, then check for person in set
				if (mapOfExistingRecords.containsKey(trace.Location__c) &&
						mapOfExistingRecords.get(trace.Location__c).contains(trace.Person__c)) {
					duplicates.add(trace);
				}

			}
		}
		return duplicates;
	}
}