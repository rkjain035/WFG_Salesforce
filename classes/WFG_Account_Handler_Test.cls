@isTest
private class WFG_Account_Handler_Test{
    Private static Account testAcc1;
    Private static Account testAcc2;
    Private static Account testAcc3; 
    Private Static String BranchCodeUniqueError = System.Label.Unique_Constraint_On_Branch_Code;

    private static void createTestData(){
    WFG_Test_Data_Utility.createTriggerActivationRecords(); // Added during Service Center changes before FSC Installation
        //WFG_Test_Data_Utility.createWFGUtilityCustomSettingRecords(); // Nik - Fix for the null pointer exceptions due to WFG Utility references
    Datetime d = System.now();
    Time t = d.time();
    String str = '2507' + String.valueOf(t);
     testAcc1 = WFG_Test_Data_Utility.createBranchOfficeTestRecord('WFG11',str,'USD');
     testAcc2 = WFG_Test_Data_Utility.createBranchOfficeTestRecord('WFG11',str,'USD');
     testAcc3 = WFG_Test_Data_Utility.createBranchOfficeTestRecord('','','');
  
     WFG_TriggerActivation__c triggerActivation = new WFG_TriggerActivation__c(); 
      triggerActivation.Name = 'WFG_TRG_SetPartner'; 
      triggerActivation.WFG_isActive__c = true; 
      insert triggerActivation;
 }
         
    static testmethod void testCreateAccount(){ 
    createTestData();
            try 
            {
            Test.startTest();
            insert testAcc1;
            Test.stopTest();
            }
            catch(Exception e) 
            {
             System.Assert(e.getMessage().contains(BranchCodeUniqueError));
            }
    }
    static testmethod void testDuplicteAccount(){ 
    createTestData();
               try 
            {
            Test.startTest();
            insert testAcc1;
            insert testAcc2;
            Test.stopTest();
            }
            catch(Exception e) 
            {
             System.Assert(e.getMessage().contains(BranchCodeUniqueError));
            }
    }
 }