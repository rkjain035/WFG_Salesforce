global class processDummyLeela implements Database.Batchable<sObject>  {
	
    public LIST<String> lstString = new LIST<String>();
    public processDummyLeela(LIST<String> lstString)
    {
        this.lstString = lstString;
    }
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        string query = 'select id from accountShare limit 10';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<accountShare> scope)
    {
       
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
    
}