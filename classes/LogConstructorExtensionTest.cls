@isTest
public class LogConstructorExtensionTest {
    public static testMethod void LogConstructorExtensionTestMethod()
    {
        Test.startTest();
            WFG_Test_Data_Utility.createTriggerActivationRecords();
            LogConstructorExtension objLog= new LogConstructorExtension();
            objLog.myFlag = FALSE;
            objLog.init();
            System.assert(objLog.acc != NULL);
        Test.stopTest();
    }
}