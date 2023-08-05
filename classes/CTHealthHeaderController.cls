public class CTHealthHeaderController {
	@AuraEnabled
	public static Map<String, Integer> getPersonHealthStatusCount() {
		return CTPersonController.getHealthStatusCountA();
	}

	@AuraEnabled
	public static Map<String, Integer> getLocationHealthStatusCount() {
		return CTLocationController.getHealthStatusCount();
	}

}