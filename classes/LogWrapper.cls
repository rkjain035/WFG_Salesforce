/**
 *    @author        Deloitte Digital
 *    @date          4/11/2016
 *    @description   Wrapper class to store the logs in generic form.
 *
 *    Modification Log:
 *    ------------------------------------------------------------------------------------     
 *    Developer                       Date                Description
 *    ------------------------------------------------------------------------------------        
 *    Nikhil More                   4/11/2016          Original Version
**/
public with sharing class LogWrapper
{
    public String logType {get; set;}
    public String logObject {get; set;}
    public String logSource {get; set;}
    public String logDetails {get; set;}
    public String logMessage {get; set;}
    public String logSeverity {get; set;}
    public String logSourceType {get; set;}
    public String logPayloadFile {get;set;}
    public Datetime logTimeStamp {get; set;}
// Mruga Shastri 30-Nov Added as part of Error Log Enhancements.    
    public String sourceObject {get; set;}
    public String calloutType {get; set;}
    public String requestResponse {get; set;}
    
    public LogWrapper() 
    {
        
    }

    public static String encodeJSON(List<LogWrapper> wrappedLogs)
    {
        String wrappedLogsJSON = '';

        if(!wrappedLogs.isEmpty())
        {
            wrappedLogsJSON = JSON.serialize(wrappedLogs);
        }

        return wrappedLogsJSON;
    }

    public static List<LogWrapper> decodeJSON(String wrappedLogsJSON)
    {
        List<LogWrapper> wrappedLogs = new List<LogWrapper>();

        if(!String.isBlank(wrappedLogsJSON))
        {
            wrappedLogs = (List<LogWrapper>) JSON.deserialize(wrappedLogsJSON, List<LogWrapper>.class);
        }

        return wrappedLogs;
    }
}