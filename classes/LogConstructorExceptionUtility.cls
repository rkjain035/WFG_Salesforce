public with sharing class LogConstructorExceptionUtility
{
    public Boolean logException{get; set;}
    public List<DLOG_Object__c> logObjList = new List<DLOG_Object__c>();

    public LogConstructorExceptionUtility()
    {

    }
    
    public List<DLOG_Object__c> getLogObjList()
    {
        return logObjList;
    }
    
    public void setLogObjList(List<DLOG_Object__c> logObjList) 
    {
        if(!logObjList.isEmpty())
        {
            this.logObjList = logObjList;
        }
    }
    
    public static DLOG_Object__c logConstructorException(String logType, String logSeverity, String logSourceType, String logSource, String logDetails, String logMessage)
    {
        DLOG_Object__c logObj = new DLOG_Object__c();
        logObj.Type__c = logType;
        logObj.Source__c = logSource;
        logObj.Message__c = logMessage;
        logObj.Timestamp__c = System.now();
        logObj.Source_Type__c = logSourceType;
        logObj.Details__c = LogHelper.setLogDetails(logDetails);
        logObj.Severity__c = LogHelper.setLogSeverity(logSeverity,logType);
        return logObj;
    }

    public void commitConstructorException()
    {
        Boolean createLogs;
        
        if(logException)
        {
            if(logObjList != null && !logObjList.isEmpty())
            {
                createLogs = LogHelper.getIsLoggingEnabled();
    
                if(createLogs)
                {
                    try
                    {
                        INSERT logObjList;
                    }
                    catch(Exception e)
                    {
                        
                    }
                }
            }
            logException = FALSE;
        }
    }
}