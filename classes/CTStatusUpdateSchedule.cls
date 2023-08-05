public class CTStatusUpdateSchedule implements Schedulable {
	public static final String CRON = '0 0 3 * * ?';

	public void execute(SchedulableContext sc) {
		CTUpdatePersonStatusBatch updatePersonStatusBatch = new CTUpdatePersonStatusBatch();
		Database.executeBatch(updatePersonStatusBatch, 2000);

		CTLocationStatusUpdateBatch updateLocationStatusBatch = new CTLocationStatusUpdateBatch();
		Database.executeBatch(updateLocationStatusBatch, 2000);
	}

}