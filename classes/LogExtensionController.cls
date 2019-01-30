public with sharing class LogExtensionController
{
    public Boolean renderComponent{get; set;}
        public Boolean logException{get; set;}
    public List<DLOG_Object__c> listErrors {get; set;}
    
    public LogExtensionController()
    {
        renderComponent = FALSE;
        listErrors = new List<DLOG_Object__c>();
        /*
        try
        {
             Add all queries here 
        }
        catch(Exception e)
        {
        */
            DLOG_Object__c errorLog = LogConstructorExceptionUtility.logConstructorException('Error', 'Alert', 'Visualforce Page', 'Page Name', 'logDetails', 'logMessage');
            listErrors.add(errorLog);
            renderComponent = TRUE;
            
            System.Debug('listErrors'+listErrors);
        /*
        }
        */
    }
}