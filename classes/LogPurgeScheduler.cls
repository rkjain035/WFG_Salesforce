global class LogPurgeScheduler implements Schedulable 
{
	global void execute(SchedulableContext sc) 
	{
		LogArchiver la = new LogArchiver();
		database.executebatch(la);
	}
}