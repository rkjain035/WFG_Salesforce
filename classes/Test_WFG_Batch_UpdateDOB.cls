@isTest
public class Test_WFG_Batch_UpdateDOB {
	 static testmethod void test()  {
        Test.startTest();
        // march 16, 2017
        String conStr  = '0 0 1 1/1 * ? *'; // 1am daily http://www.cronmaker.com
        String TestJobName = 'TEST Batch DOB';
		String jobId = System.schedule('TEST Batch DOB' , conStr,new WFG_Schedule_Batch_DOB());
        
      // Get the information from the CronTrigger API object
      	CronTrigger ct = [SELECT CronJobDetail.Name     	
         	FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(ct.CronJobDetail.Name, TestJobName);


        
        Test.stopTest();

    }
}