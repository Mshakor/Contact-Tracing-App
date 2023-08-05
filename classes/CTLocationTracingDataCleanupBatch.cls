public class CTLocationTracingDataCleanupBatch implements Database.Batchable<Sobject> {

	public Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator('SELECT Id FROM Location_Tracing__c WHERE visit_Date__c <LAST_N_DAYS :30');
	}

	public void execute(Database.BatchableContext bc, List<Location_Tracing__c> scope) {
		delete scope;
	}

	public void finish(Database.BatchableContext bc) {
		System.debug('Batch Completed');
	}
}