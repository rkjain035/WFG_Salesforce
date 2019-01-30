public with sharing class LogConstructorExtension
{
    public Boolean myFlag {get; set;}
    public Account acc {get; set;}

    public LogConstructorExtension()
    {
        LogConstructorExceptionUtility.logConstructorException('logType', 'logSeverity', 'logSourceType', 'logSource', 'logDetails', 'logMessage');
    }

    public void init()
    {
        if (!myFlag)
        {
            acc=new Account();
            acc.Name='Mindfire Account';
            insert acc;
            myFlag=true;
        }
    }
}