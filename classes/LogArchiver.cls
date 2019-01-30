global class LogArchiver implements Database.Batchable<sObject> 
{
	public Integer lastXDays;
	public Set<Date> lastXDaysDates;
	public Set<String> deleteSeverities;
	public Datetime deleteBeforeThisDay;
	
	global LogArchiver() 
	{
		Date tempDate;
		lastXDaysDates = new Set<Date>();
		deleteSeverities = new Set<String>();
		Archival_Settings__c defaultSetting = Archival_Settings__c.getInstance('Default');

		if(defaultSetting != null)
		{
			lastXDays = Integer.valueOf(defaultSetting.INTERVAL__c);

			if(lastXDays != null)
			{
				tempDate = System.today().addDays(-(lastXDays-1));
			}

			if(tempDate != null)
			{
				deleteBeforeThisDay = Datetime.newInstance(tempDate.year(), tempDate.month(), tempDate.day(), 0, 0, 0);
			}

			if(defaultSetting.INFO__c)
			{
				deleteSeverities.add('INFO');
			}
			if(defaultSetting.DEBUG__c)
			{
				deleteSeverities.add('Debug');
			}
			if(defaultSetting.WARNING__c)
			{
				deleteSeverities.add('Warning');
			}
			if(defaultSetting.ERROR__c)
			{
				deleteSeverities.add('Error');
			}
			if(defaultSetting.ALERT__c)
			{
				deleteSeverities.add('Alert');
			}
		}
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		return Database.getQueryLocator([SELECT CreatedDate,Id,Name,Severity__c FROM DLOG_Object__c WHERE CreatedDate < : deleteBeforeThisDay AND Severity__c IN : deleteSeverities]);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope)
   	{
		List<DLOG_Object__c> lstLogs = (List<DLOG_Object__c>) scope;

		if(!lstLogs.isEmpty())
		{
			try
			{
				Database.DeleteResult[] srList = Database.delete(lstLogs,false);
			}
			catch(Exception e)
			{

			}
		}
	}
	
	global void finish(Database.BatchableContext BC)
	{
		
	}
}