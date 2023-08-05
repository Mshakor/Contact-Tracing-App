public class CTLocationController {
	public static List<Location__c> getRecentStatusChanges() {
		List<Location__c> queryLocation = [select
		Id,
		Name,
		Pincode__c,
		Red_Score__c,
		Status_Update_Date__c,
		Status__c
		from Location__c
		ORDER BY Status_Update_Date__c DESC
		LIMIT 100];
		return queryLocation;
	}

	public static List<Location__c> searchLocations(String searchTerm) {
		searchTerm = searchTerm + '%';
		return [select
		Id,
		Name,
		Pincode__c,
		Red_Score__c,
		Status_Update_Date__c,
		Status__c
		from Location__c
		Where Name like :searchTerm or Pincode__c like :searchTerm or Address__c like :searchTerm
		ORDER BY Status_Update_Date__c DESC NULLS LAST];


	}

	public static Location__c getLocationById(String locationId) {
		List<Location__c> singleQuery = [select
		Id,
		Name,
		Pincode__c,
		Address__c,
		Red_Score__c,
		Status_Update_Date__c,
		Status__c
		from Location__c
		WHERE Id = :locationId];

		if (singleQuery != null && singleQuery.size() > 0) {
			return singleQuery[0];
		}
		return null;
	}

	public static Map<String, Integer> getStatusCount() {
		Map<String, Integer> noOfLocationStatus = new Map<String, Integer>();
		for (
				AggregateResult loc
				:
		[select
		COUNT(Id) countOfLoc,
		Status__c
		from Location__c
		GROUP BY Status__c]) {
			//Type casting the object to their Respective Data type according to map
			String status = String.valueOf(loc.get('Status__c'));
			Integer countOfLoc = Integer.valueOf(loc.get('countOfLoc'));
			noOfLocationStatus.put(status, countOfLoc);
		}
		return noOfLocationStatus;

	}

	public static void updateRedScore(Set<Id> locationIds) {
		List<Location__c> locationToUpdate = new List<Location__c>();
		AggregateResult[] redPeoplePerLocation = [SELECT Location__c, COUNT(Id) total From Location_Tracing__c
		WHERE Person__r.Health_Status__c = 'Red'
		AND Visit_Date__c = LAST_N_DAYS:10
		AND Location__c IN :locationIds
		GROUP BY Location__c];

		for (AggregateResult ar : redPeoplePerLocation) {
			String locationID = String.valueOf(ar.get('Location__c'));
			Integer redScoreNo = Integer.valueOf(ar.get('total'));
			String Status = getStatus(redScoreNo);
		}

		//update the location records according to given results
		if (locationToUpdate != null && locationToUpdate.size() > 0) {
			update locationToUpdate;
		}
	}

	public static String getStatus(Integer redScore) {
		if (redScore == 0) {
			return 'Green';
		} else if (redScore <= 5) {
			return 'Yellow';
		} else if (redScore <= 10) {
			return 'Orange';
		} else {
			return 'Red';
		}
	}

	public static Map<String, Integer> getHealthStatusCount() {
		AggregateResult[] healthCountMap = [select Status__c,Count(Id) total from Location__c Group By Status__c];

		if (healthCountMap != null && healthCountMap.size() > 0) {
			Map<String, Integer> result = new Map<String, Integer>();

			for (AggregateResult arr : healthCountMap) {
				result.put(String.valueOf(arr.get('Status__c')), Integer.valueOf(arr.get('total')));
			}
			return result;
		}
		return null;
	}

}