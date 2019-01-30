global class DummyBatchByLeela implements Database.Batchable<sObject> 
{
    public String blobString;
    public LIST<String> listOfRecords = new LIST<String>();
    public DummyBatchByLeela(String blobString)
    {
        this.blobString = blobString;
    }
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        string query = 'select id from accountShare limit 10';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<accountShare> scope)
    {
        String lineString = null;
        boolean danger = false;
        boolean newLine = false;
        integer count = 0;
        for(integer i=0;i<blobString.length();i++)
        {
            lineString = lineString+''+String.fromCharArray(new List<Integer> {blobString.charAt(i)});
            if(blobString.charAt(i) == 34)
            {
                if(danger)
                    danger = false;
                else 
                    danger = true;
            }
            if(blobString.charAt(i) == 10 && !danger)
            {
                count++;
                danger = false; 
                listOfRecords.add(lineString);
                lineString = null;
            }
        }
        System.debug('Count...'+listOfRecords.size());
    }
    
    global void finish(Database.BatchableContext bc)
    {
        Database.executeBatch(new processDummyLeela(listOfRecords),200);
    }
}