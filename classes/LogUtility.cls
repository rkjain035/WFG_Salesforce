/**
* Property of Transamerica and Aegon companies. Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Nikhil More
* @date   30th Nov 2016
* @description W-000128 - Install error logging framework from Deloitte Nugget Factory
Modification Log:
------------------------------------------------------------------------------------
Developer		Mod Number		Date		Description
------------------------------------------------------------------------------------
Nikhil More     M-001			30/11/2016 	Utility class with methods for creating logs
Mruga Shastri   M-002			13/12/2016 	Enhancements to accomodate additional
											integration log related parameters
*/
public without sharing class LogUtility
{
    
    public LogUtility() 
    {
        /* Default Constructor */
    }
	
    /*
    * Property of Transamerica and Aegon companies. Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * @description: Method which creates a log based on the parameters passed by the calling function
    * @author Mruga Shastri
    * @date 13/12/2015
    * @param logType: Choose from Error / Integration / Transaction.
    * @param logSeverity: Choose from Alert / Warning / INFO / Error / Debug.
    * @param SourceObject: Enter the name of the standard or custom object on which the operation was being performed.
    * @param logSourceType: Choose from Apex Class / Apex Trigger / Batch Apex / Integration / Visualforce Page.
    * @param logSource: Enter the name of the component for which the log is created.
    * @param logDetails: Enter the high level details / header message for the log, such as name of exception or integration error code.
    * @param logMessage: Enter the detailed message about the transaction or error occured or integration process, such as stack trace.
    * @param logPayloadFile: Provide the JSON or XML message in string format so that it could be attached as a file to quarantine later.
    * @param calloutType: Enter the type of call out in integration process, such as SOAP or REST, etc.
    * @param requestResponse: Enter the type of information in the callout process, whether it is a request or response.
    * @param executeDML: Choose from True / Fales. If set to true then log is created instantly, else logs will be persisted.
	* @return : Not applicable
    */
    public static void createLogs(String logType, String logSeverity, String sourceObject,  
                                  String logSourceType, String logSource, 
                                  String logDetails, String logMessage, String logPayloadFile, 
                                  String calloutType, String requestResponse, Boolean executeDML)
    {
        Boolean createLogs;
        LogWrapper logObj = new LogWrapper();

        logObj.logType = logType;
        logObj.logSource = logSource;
        logObj.logMessage = logMessage;
        logObj.logTimeStamp = System.now();
        logObj.logSourceType = logSourceType;
        logObj.logPayloadFile = logPayloadFile;
        logObj.logDetails = LogHelper.setLogDetails(logDetails);
        logObj.logSeverity = LogHelper.setLogSeverity(logSeverity,logType);
        logObj.sourceObject = sourceObject;
        logObj.calloutType = calloutType; 
        logObj.requestResponse = requestResponse;
        
        if(executeDML)
        {
            if(String.isNotBlank(LogHelper.getLogObjectName()))
            {
                SObject dLog = LogHelper.getObjectInstance(logObj);

                if(dLog != null)
                {
                    if(logType == 'Integration')
                    {
                        createLogs = LogHelper.getIsIntegrationLoggingEnabled();
                    }
                    else
                    {
                        createLogs = LogHelper.getIsLoggingEnabled();
                    }
                    if(createLogs)
                    {
                        try
                        {
                            INSERT dLog;

                            if(String.isNotBlank(logPayloadFile))
                            {
                                LogHelper.createAttachmentFromPayload(dLog, logObj);
                            }
                            if(String.isNotBlank(logMessage) && logMessage.length() > 1000)
                            {
                                LogHelper.createAttachmentFromMessage(dLog, logMessage);
                            }
                        }
                        catch(Exception e)
                        {
                            // Capture logs if any errors here
                        }
                    }
                }
            }
        }
        else
        {
            LogHelper.lstLogWrapper.add(logObj); // This list is further used by commit method
        }
    }

    /*
    * Property of Transamerica and Aegon companies. Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * @description: Method which commits the logs to DB, developer can choose if the # of calls apply to current transaction or 
    * @author Mruga Shastri
    * @date 13/12/2015
    * @param executeNow: Chose from True / False. Logs are created in same transaction if true, else code is executed asynchronously.
    * @return : Not applicable
    */
    public static void commitLogs(Boolean executeNow)
    {
        if(executeNow)
        {
            LogHelper.commitLogsNow();
        }
        else
        {
            String lstLogWrapperJSON = LogWrapper.encodeJSON(LogHelper.lstLogWrapper); // Serialize lstLogWrapper to JSON

            LogHelper.commitLogsInFuture(lstLogWrapperJSON);
        }
    }
	
    /*
    * Property of Transamerica and Aegon companies. Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * @description: Method which return an instance of log record based on the parameters passed by the calling function
    * @author Mruga Shastri
    * @date 13/12/2015
    * @param logType: Choose from Error / Integration / Transaction.
    * @param logSeverity: Choose from Alert / Warning / INFO / Error / Debug.
    * @param SourceObject: Enter the name of the standard or custom object on which the operation was being performed.
    * @param logSourceType: Choose from Apex Class / Apex Trigger / Batch Apex / Integration / Visualforce Page.
    * @param logSource: Enter the name of the component for which the log is created.
    * @param logDetails: Enter the high level details / header message for the log, such as name of exception or integration error code.
    * @param logMessage: Enter the detailed message about the transaction or error occured or integration process, such as stack trace.
    * @param logPayloadFile: Provide the JSON or XML message in string format so that it could be attached as a file to quarantine later.
    * @param calloutType: Enter the type of call out in integration process, such as SOAP or REST, etc.
    * @param requestResponse: Enter the type of information in the callout process, whether it is a request or response.
    * @return : Not applicable
    */
    public static LogWrapper returnLogs(String logType, String logSeverity, String sourceObject, String logSourceType, String logSource, String logDetails, String logMessage, String logPayloadFile,  String calloutType, String requestResponse)
    {
        LogWrapper logObj = new LogWrapper();

        logObj.logType = logType;
        logObj.logSource = logSource;
        logObj.logDetails = LogHelper.setLogDetails(logDetails);
        logObj.logMessage = LogHelper.setLogMessage(logMessage);
        logObj.logSeverity = LogHelper.setLogSeverity(logSeverity,logType);
        logObj.logTimeStamp = System.now();
        logObj.logSourceType = logSourceType;
        logObj.logPayloadFile = logPayloadFile;
        logObj.sourceObject = sourceObject;
        logObj.calloutType = calloutType;
        logObj.requestResponse = requestResponse; 
        return logObj;
    }

    /*
    * Property of Transamerica and Aegon companies. Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * @description: Method which commits the logs to DB, developer can choose if the # of calls apply to current transaction or 
    * @author Mruga Shastri
    * @date 13/12/2015
    * @param logWrapperList: Pass the class level list variable. This list will be used to create logs in DB.
    * @return : Not applicable
    */
    public static void commitLogs(List<LogWrapper> logWrapperList)
    {
        SObject so;
        LogWrapper lw;
        Attachment attFile;
        Attachment attMess;
        Boolean allLogsCreated;
        Set<Id> successIDs = new Set<Id>();
        Set<Id> failureIDs = new Set<Id>();
        List<SObject> lstDLogs = new List<SObject>();
        List<Attachment> lstAttachments = new List<Attachment>();
        
        if(!logWrapperList.isEmpty())
        {
            if(String.isNotBlank(LogHelper.getLogObjectName()))
            {
                lstDLogs = LogHelper.getObjectInstances(logWrapperList);

                if(!lstDLogs.isEmpty())
                {
                    if(!LogHelper.getIsIntegrationLoggingEnabled())
                    {
                        for(Integer i = 0; i < lstDLogs.size(); i++)
                        {
                            if(lstDLogs[i].get('Type__c') == 'Integration')
                            {
                                lstDLogs.remove(i);
                            }
                        }
                    }
                    if(!LogHelper.getIsLoggingEnabled())
                    {
                        for(Integer i = 0; i < lstDLogs.size(); i++)
                        {
                            if(lstDLogs[i].get('Type__c') != 'Integration')
                            {
                                lstDLogs.remove(i);
                            }
                        }
                    }
                }

                if(!lstDLogs.isEmpty())
                {
                    try
                    {
                        Database.SaveResult[] srList = Database.insert(lstDLogs,false);
                        
                        System.Debug('lstDLogs'+lstDLogs);

                        for(Database.SaveResult sr : srList)
                        {
                            if (sr.isSuccess()) 
                            {
                                successIDs.add(sr.getId());
                            }
                            else 
                            {
                                for(Database.Error err : sr.getErrors()) 
                                {

                                }
                            }
                        }

                        if(!successIDs.isEmpty())
                        {
                            for(Integer i = 0; i < logWrapperList.size(); i++)
                            {
                                so = lstDLogs[i];
                                lw = logWrapperList[i];
                                attFile = new Attachment();
                                attMess = new Attachment();
                                if(successIDs.contains((Id)so.get('Id')))
                                {
                                    if((LogHelper.validateId((String)so.get('Id')) != null) && (so.get('Type__c') == 'Integration') && String.isNotBlank(lw.logPayloadFile))
                                    {
                                        attFile = LogHelper.returnAttachmentFromPayload(so, lw);
                                        lstAttachments.add(attFile);
                                    }
                                    if(String.isNotBlank(lw.logMessage) && lw.logMessage.length() > 1000)
                                    {
                                        attMess = LogHelper.returnAttachmentFromMessage(so, lw.logMessage);
                                        lstAttachments.add(attMess);
                                    }
                                }                                
                                
                            }
                            if(!lstAttachments.isEmpty())
                            {
                                    Database.SaveResult[] srAttList = Database.insert(lstAttachments,false);
                            }
                        }
                    }
                    catch(Exception e)
                    {
                        // Capture logs if any errors here
                    }
                }
            }
        }
    }
    
    /*
    * Property of Transamerica and Aegon companies. Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * @description: Method which commits the logs to DB, developer can choose if the # of calls apply to current transaction or 
    * @author Mruga Shastri
    * @date 13/12/2015
    * @param - sourceType = 'DML' or 'EXCEPTION', sourceObject = sObjectName, source = origin component, severity = 'Error',
    * message = error message, log type = 'Error'
    * @return : Not applicable
    */
    public static void createLog(String sourceType, String sourceObject, String source, String severity, String errormsg, String logType){
		
		DLOG_Object__c dlog = new DLOG_Object__c();
		dlog.Source_Type__c = String.isNotBlank(sourceType) ? sourceType : '';
        dlog.Source_Object__c = String.isNotBlank(sourceObject) ? sourceType : '';
        dlog.Source__c = String.isNotBlank(source) && source.length() <= 50 ? source : String.isNotBlank(source) && source.length() > 50 ? source.substring(0, 49) : '';
        dlog.Severity__c = String.isNotBlank(severity) ? severity : '';
        dlog.Message__c = String.isNotBlank(errormsg) && source.length() <= 1000 ? errormsg : String.isNotBlank(errormsg) && errormsg.length() > 1000 ? errormsg.substring(0, 999) : '';
        dlog.Type__c = String.isNotBlank(logType) ? logType : '';
        
        Database.insert(dlog);
	}
}