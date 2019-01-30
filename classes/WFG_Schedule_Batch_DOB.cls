global class WFG_Schedule_Batch_DOB implements Schedulable {
	global void execute(SchedulableContext SC)
    {
    	String q = 'select birthdate, id from Contact where Calendar_Year(Birthdate) = 1900';
		ID BatchId = Database.executeBatch(new WFG_Batch_UpdateDOB(q));
    }
}