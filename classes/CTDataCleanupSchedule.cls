public class CTDataCleanupSchedule implements Schedulable{

	public static final String CRON = '0 0 2 * * ?';

	public void execute(SchedulableContext sc) {
		CTPeopleTracingDataCleanupBatch peopleTracingBatch = new CTPeopleTracingDataCleanupBatch();
		Database.executeBatch(peopleTracingBatch, 2000);

		CTLocationTracingDataCleanupBatch locationTracingBatch = new CTLocationTracingDataCleanupBatch();
		Database.executeBatch(locationTracingBatch, 2000);
	}


}

//CTDataCleanupSchedule dataCleanup = new CTDataCleanupSchedule();

//String jobId = System.schedule('Data Cleanup Job',CTDataCleanupSchedule.CRON,dataCleanup);
//String
//System.debug('Job Id: '+jobId);