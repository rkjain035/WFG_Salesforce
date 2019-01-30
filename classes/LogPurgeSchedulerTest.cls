@isTest
public class LogPurgeSchedulerTest {
	public static testmethod void LogPurgeSchedulerTestMethod()
    {
        Archival_Settings__c objArc = new Archival_Settings__c();
        objArc.Name = 'Default';
        objArc.ALERT__c = TRUE;
        objArc.DEBUG__c = TRUE;
        objArc.ERROR__c = TRUE;
        objArc.INFO__c = TRUE;
        objArc.INTERVAL__c = 0;
        objArc.WARNING__c = TRUE;
        INSERT objArc;
        DLOG_Object__c objDOL = new DLOG_Object__c();
        objDOL.Severity__c = 'INFO';
        INSERT objDOL;
        Test.startTest();
        	LogPurgeScheduler objSch = new LogPurgeScheduler();
        	String CRON_EXP = '0 0 0 3 9 ? 2022';
        	String jobId = System.schedule('Test LogPurgeScheduler', CRON_EXP, objSch);
        	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        	System.assertEquals(0, ct.TimesTriggered);
        TEst.stopTest();
    }
}