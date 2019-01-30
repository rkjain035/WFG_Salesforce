@isTest
private class WFG_launch_Checklist_Controller_Test {
    static testMethod void WFGOnboardingChecklistTest () {  
        
        WFG_TriggerActivation__c objTriggerActivation = new WFG_TriggerActivation__c(Object_Name__c = 'Account', Name ='WFG_Account', WFG_isActive__c = true);
        insert objTriggerActivation;  
        
        Account objAcc = WFG_Test_Data_Utility.createBranchOfficeTestRecord('AccountName', '1234', 'USD');
        //objAcc.IsPartner = true;
        insert objAcc;
        
        Contact testContact1 = WFG_Test_Data_Utility.createContactTestRecord('ConF', 'ConL', objAcc.id, '121211w', 1);
        testContact1.WFG_AgentPayType__c = 'WFG';
        testContact1.WFG_Fiduciary_Advisor__c = false;
        testContact1.WFG_CycleType__c = 'US';
        testContact1.WFG_Type__c = 'Launch'; 
        testContact1.WFG_AgentId__c = '121211w';
        testContact1.WFG_Status__c = 'Active';
        testContact1.MailingCountry = 'US';
        testContact1.MailingState = 'AL';
        
        Contact testContact2 = WFG_Test_Data_Utility.createContactTestRecord('ConF', 'ConL', objAcc.id, '12134211w', 1);
        testContact2.WFG_AgentPayType__c = 'WFG';
        testContact2.WFG_Fiduciary_Advisor__c = false;
        testContact2.WFG_CycleType__c = 'US';
        testContact2.WFG_Type__c = 'Launch'; 
        testContact2.WFG_AgentId__c = '12134211w';
        testContact2.WFG_Status__c = 'Active';
        testContact2.MailingCountry = 'US';
        testContact2.MailingState = 'AL';
        
        Test.startTest();
        if(testContact1 != null){
        insert testContact1;
        }
        if(testContact2 != null){
        insert testContact2;}
        Test.stopTest();
    
        user objLaunchUser = WFG_Test_Data_Utility.createTestUser('Launch Blue US');
        objLaunchUser.contactId = testContact1.Id;
        if(objLaunchUser != NULL)
            INSERT objLaunchUser;
            
        user objLaunchUser1 = WFG_Test_Data_Utility.createTestUser('Launch Blue CAN');
        objLaunchUser1.contactId = testContact2.Id;
        if(objLaunchUser1 != NULL)
            INSERT objLaunchUser1;  
            
        User objSAUser = WFG_Test_Data_Utility.createTestUser('System Administrator');
        
    //    system.RunAs(objSAUser){ 
        insert new WFG_OnboardingOpptyRecordTypeID__c(
                Record_Type_ID__c = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Onboarding').getRecordTypeId(),
                Canada_Record_Type_Id__c = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Onboarding CANADA').getRecordTypeId()
            ); 
            WFG_Onboarding_Checklist__c objOnboardingChecklist = new WFG_Onboarding_Checklist__c(Contact__c = testContact2.Id, Recruiting_Contact__c = testContact1.Id, WFG_Agent_Code__c = '12134211w', WFG_Recruiting_Agent_Code__c = '121211w'); 
            insert objOnboardingChecklist;
  //      }
        
        system.runAS(objLaunchUser1){
            WFG_launch_Checklist_Controller objChecklistCOnt = new WFG_launch_Checklist_Controller();
            WFG_launch_Checklist_Controller.getCheckList(null);
           // WFG_launch_Checklist_Controller.getlicenseStepsCompleted();
        }

        system.runAS(objLaunchUser){
            WFG_launch_Checklist_Controller objChecklistCOnt = new WFG_launch_Checklist_Controller();
            WFG_launch_Checklist_Controller.getCheckList(null);
           // WFG_launch_Checklist_Controller.getlicenseStepsCompleted();
        }       
    }
}