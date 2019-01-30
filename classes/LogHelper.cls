/**
 *    @author        Deloitte Digital
 *    @date          4/11/2016
 *    @description   Helper class to take decisions based on custom settings.
 *
 *    Modification Log:
 *    ------------------------------------------------------------------------------------     
 *    Developer                       Date                Description
 *    ------------------------------------------------------------------------------------        
 *    Nikhil More                   4/11/2016          Original Version
**/
public with sharing class LogHelper 
{
    public static List<LogWrapper> lstLogWrapper = new List<LogWrapper>();
    // public static Map<String, Object_Mapping__c> mapObjMapping;
    
    public LogHelper() 
    {
        // mapObjMapping = Object_Mapping__c.getAll();
    }

    public static Boolean getIsLoggingEnabled()
    {
        Id currentUserProfileID = UserInfo.getUserId();

        Controller_Settings__c switchSetting = Controller_Settings__c.getInstance(currentUserProfileID);

        if(switchSetting == null)
        {
            switchSetting = Controller_Settings__c.getOrgDefaults();
        }

        if(switchSetting != null && switchSetting.Logs_Enabled__c)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    public static Boolean getIsIntegrationLoggingEnabled()
    {
        Id currentUserProfileID = UserInfo.getUserId();

        Controller_Settings__c switchSetting = Controller_Settings__c.getInstance(currentUserProfileID);

        if(switchSetting == null)
        {
            switchSetting = Controller_Settings__c.getOrgDefaults();
        }
        
        if(switchSetting != null && switchSetting.Log_Integration_Errors__c)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    public static String getLogObjectName()
    {
        String logObjectAPIName;

        Object_Mapping__c objMap = Object_Mapping__c.getInstance('Object Name');

        if(objMap != null)
        {
            if(!String.isBlank(objMap.API_Name__c))
            {
                logObjectAPIName = objMap.API_Name__c;
            }
        }

        return logObjectAPIName;
    }

    public static SObject getObjectInstance(LogWrapper lw)
    {
        SObject objInstance;
        Map<string, schema.sobjecttype> globDesc = Schema.getGlobalDescribe();
        Set<string> objectKeys = globDesc.keySet();
        Map<String, Object_Mapping__c> mapObjMapping = Object_Mapping__c.getAll();

        if(!String.isBlank(mapObjMapping.get('Object Name').API_Name__c))
        {
            if(objectKeys.contains(mapObjMapping.get('Object Name').API_Name__c.toLowerCase()))
            {
                objInstance = Schema.getGlobalDescribe().get(LogHelper.getLogObjectName()).newSObject();

                objInstance.put(mapObjMapping.get('Log Type').API_Name__c, lw.logType);
                objInstance.put(mapObjMapping.get('Source').API_Name__c, lw.logSource);
                objInstance.put(mapObjMapping.get('Details').API_Name__c, lw.logDetails);
                objInstance.put(mapObjMapping.get('Severity').API_Name__c, lw.logSeverity);
                objInstance.put(mapObjMapping.get('Timestamp').API_Name__c, lw.logTimeStamp);
                objInstance.put(mapObjMapping.get('Source Type').API_Name__c, lw.logSourceType);
                objInstance.put(mapObjMapping.get('Message').API_Name__c, LogHelper.setLogMessage(lw.logMessage));
                objInstance.put(mapObjMapping.get('Source Object').API_Name__c, LogHelper.setLogMessage(lw.sourceObject));
                objInstance.put(mapObjMapping.get('CallOut Type').API_Name__c, LogHelper.setLogMessage(lw.calloutType));
                objInstance.put(mapObjMapping.get('Request Response').API_Name__c, LogHelper.setLogMessage(lw.requestResponse));
            }
        }
        
        return objInstance;
    }

    public static List<SObject> getObjectInstances(List<LogWrapper> listLW)
    {
        SObject returnedInstance;
        List<SObject> listSobjectLogs = new List<SObject>();

        if(!listLW.isEmpty())
        {
            for(LogWrapper wrapObj : listLW)
            {
                returnedInstance = LogHelper.getObjectInstance(wrapObj);

                if(returnedInstance != null)
                {
                    listSobjectLogs.add(returnedInstance);
                }
            }
        }
        
        return listSobjectLogs;
    }

    public static String setLogSeverity(String logSeverity, String logType)
    {
        String logSeverityLocal;

        if(String.isBlank(logSeverity))
        {
            if(logType == 'Error')
            {
                logSeverityLocal = 'Error';
            }
            else if(logType == 'Transaction')
            {
                logSeverityLocal = 'Alert';
            }
            else if(logType == 'Integration')
            {
                logSeverityLocal = 'Warning';
            }
            else
            {
                logSeverityLocal = 'INFO';
            }
        }
        else
        {
            if((logSeverity!='INFO')&&(logSeverity!='Warning')&&(logSeverity!='Alert')&&(logSeverity!='Debug')&&(logSeverity!='Error'))
            {
                logSeverityLocal = 'INFO';
            }
            else
            {
                logSeverityLocal = logSeverity;
            }
        }

        return logSeverityLocal;
    }

    public static String setLogDetails(String logDetails)
    {
        String logDetailsLocal;
        if(logDetails != null && logDetails != '')
        {
            if(String.isNotBlank(logDetails) && logDetails.length() < 100)
            {
                logDetailsLocal = logDetails;
            }
            else
            {
                logDetailsLocal = logDetails.substring(0,100);
            }
        }

        return logDetailsLocal;
    }

    public static String setLogMessage(String logMessage)
    {
        String logMessageLocal;
        system.debug('##### DEBUG :' + logMessage);
        if(logMessage != null && logMessage != '')
        {
            if(String.isNotBlank(logMessage) && logMessage.length() < 1000)
            {
                logMessageLocal = logMessage;
            }
            else
            {
                system.debug('##### DEBUG1 :' + logMessage);
                logMessageLocal = logMessage.substring(0,1000);
            }
        }
        return logMessageLocal;
    }

    public static String validateId(String idParam)
    {
        String id = String.escapeSingleQuotes(idParam);

        if((id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id)) 
        {
            return id;
        }
        return null;
    }

    public static void createAttachmentFromPayload(SObject objL, LogWrapper objW)
    {
        String tempString = LogHelper.validateId((String) objL.get('Id'));

        if(tempString!=null)
        {
            if(objW.logType == 'Integration' && String.isNotBlank(objW.logPayloadFile))
            {
                Attachment attFile = new Attachment();
                attFile.ParentId = (Id) objL.get('Id');
                attFile.Body = Blob.valueOf(objW.logPayloadFile);
                attFile.Description = 'Attachment created for '+ objL.get('Source__c') + ' during execution of '+ objW.logSourceType + '.';
                attFile.Name = objL.get('Source__c') + ' - integration request details.txt';
                attFile.ContentType = 'application/octet-stream';

                try
                {
                    INSERT attFile;
                }
                catch(Exception e)
                {
                    
                }
            }
        }
    }

    public static Attachment returnAttachmentFromPayload(SObject objL, LogWrapper objW)
    {
        String tempString = LogHelper.validateId((String) objL.get('Id'));
        Attachment attFile;

        if(tempString!=null)
        {
            if(objW.logType == 'Integration' && String.isNotBlank(objW.logPayloadFile))
            {
                attFile = new Attachment();
                attFile.ParentId = (Id) objL.get('Id');
                attFile.Body = Blob.valueOf(objW.logPayloadFile);
                attFile.Description = 'Attachment created for '+ objL.get('Source__c') + ' during execution of '+ objW.logSourceType + '.';
                attFile.Name = objL.get('Source__c') + ' - integration request details.txt';
                attFile.ContentType = 'application/octet-stream';
            }
        }
        return attFile;
    }

    public static void createAttachmentFromMessage(SObject objL, String logMessage)
    {
        String tempString = LogHelper.validateId((String) objL.get('Id'));

        if(tempString!=null)
        {
            if(String.isNotBlank(logMessage))
            {
                Attachment attFile = new Attachment();
                attFile.ParentId =  (Id) objL.get('Id');
                attFile.Body = Blob.valueOf(logMessage);
                attFile.Description = 'Attachment created for '+ objL.get('Source__c') + ' with detailed log message.';
                attFile.Name = objL.get('Source__c') + ' - detailed log message.txt';
                attFile.ContentType = 'application/octet-stream';

                try
                {
                    INSERT attFile;
                }
                catch(Exception e)
                {
                    
                }
            }
        }
    }

    public static Attachment returnAttachmentFromMessage(SObject objL, String logMessage)
    {
        String tempString = LogHelper.validateId((String) objL.get('Id'));
        Attachment attFile;

        if(tempString!=null)
        {
            if(String.isNotBlank(logMessage))
            {
                attFile = new Attachment();
                attFile.ParentId =  (Id) objL.get('Id');
                attFile.Body = Blob.valueOf(logMessage);
                attFile.Description = 'Attachment created for '+ objL.get('Source__c') + ' with detailed log message.';
                attFile.Name = objL.get('Source__c') + ' - detailed log message.txt';
                attFile.ContentType = 'application/octet-stream';

                try
                {
                    INSERT attFile;
                }
                catch(Exception e)
                {
                    
                }
            }
        }
        return attFile;
    }

    public static void commitLogsNow()
    {
        List<SObject> listSobjectLogs = new List<SObject>();

        if(!lstLogWrapper.isEmpty())
        {
            LogUtility.commitLogs(lstLogWrapper);

            lstLogWrapper.clear();
        }
    }

    @future
    public static void commitLogsInFuture(String lstLogWrapperJSON)
    {
        List<SObject> listSobjectLogs = new List<SObject>();
        List<LogWrapper> logWrapperList = LogWrapper.decodeJSON(lstLogWrapperJSON);

        if(!logWrapperList.isEmpty())
        {
            LogUtility.commitLogs(logWrapperList);
        }
    }
}