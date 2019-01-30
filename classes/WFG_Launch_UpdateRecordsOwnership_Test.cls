/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author : Rashmi Shet
* @date 08/10/2018
* @description  Profile Identification utility

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Rashmi Shet           M-001             08/10/2018               W-027426 - Test class for the class 'WFG_Launch_UpdateRecordsOwnership'
*/

@isTest
private class WFG_Launch_UpdateRecordsOwnership_Test {

    @testSetup static void createTestData(){
        
        Profile profLLUS = [select name, id from profile where name= 'LL US'];
        Profile profLaunchBlueUS = [select name, id from profile where name= 'LL US'];  
        
        WFG_TriggerActivation__c objTriggerActivation = new WFG_TriggerActivation__c(Object_Name__c = 'Account', Name ='WFG_Account', WFG_isActive__c = true);
        insert objTriggerActivation;  
        
        Account objAccBranchOffice = WFG_Test_Data_Utility.createBranchOfficeTestRecord('AccountName', 'ACC12', 'USD');
        insert objAccBranchOffice;
        
        Contact objFSCCon = WFG_Test_Data_Utility.createContactTestRecord('ConFirstname', 'ConLastName', objAccBranchOffice.id, '0123615w', 17);
        objFSCCon.WFG_AgentPayType__c = 'WFG';
        objFSCCon.WFG_CycleType__c = 'US';
        objFSCCon.WFG_Type__c = 'Agent'; 
        objFSCCon.MailingCountry = 'US';
        objFSCCon.mailingState = 'AL';
       // objFSCCon.WFG_Status__c = 'ACTIVE';      
        objFSCCon.email = 'test@updateRecords.com';
        insert objFSCCon;
        
        User objUsr = WFG_Test_Data_Utility.createUserRecord('test@updateRecords.com', false, 'A0123615w', null, profLLUS.id);
        objUsr.isActive = false;
        insert objUsr;
        
        
        Contact objLaunchCon = WFG_Test_Data_Utility.createContactTestRecord('ConFirstname', 'ConlaunchLastName', objAccBranchOffice.id, '012365w', 17);
        objLaunchCon.WFG_AgentPayType__c = 'WFG';
        objLaunchCon.WFG_CycleType__c = 'US';
        objLaunchCon.WFG_Type__c = 'Launch'; 
        objLaunchCon.WFG_Status__c = 'ACTIVE';
        objLaunchCon.WFG_Channel__c = 'BLUE';           
        objLaunchCon.email = 'testUser1@transamerica.com';
        objLaunchCon.MailingCountry = 'US';
        objLaunchCon.mailingState = 'AL';
        insert objLaunchCon;
        
        user objLaunchUser = WFG_Test_Data_Utility.createTestUser('Launch Blue US');
        objLaunchUser.contactId = objLaunchCon.Id;
        objLaunchUser.isactive = false;
        if(objLaunchUser != NULL)
            INSERT objLaunchUser;
        
    }
    
    static testmethod void testUpdateRecordOwnership(){
        
        contact objLaunchCon = [select id, WFG_AgentCode__c  from contact where lastname =: 'ConlaunchLastName' limit 1];
        contact objRecruitingCon = [select id, WFG_AgentCode__c  from contact where lastname =: 'ConLastName' limit 1];

        insert new WFG_OnboardingOpptyRecordTypeID__c(
            Record_Type_ID__c = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Onboarding').getRecordTypeId(),
            Canada_Record_Type_Id__c = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Onboarding CANADA').getRecordTypeId()
        );
            
        WFG_Onboarding_Checklist__c objOnboardingChecklist = new WFG_Onboarding_Checklist__c(Contact__c = objLaunchCon.Id, Recruiting_Contact__c = objRecruitingCon.Id, WFG_Agent_Code__c = '012365w', WFG_Recruiting_Agent_Code__c = '0123615w'); 
        insert objOnboardingChecklist;
        
        user objUsr1 = [select id, WFG_Agent_Code__c,isActive  from User where Username = 'test@updateRecords.com' limit 1];
        objUsr1.isActive = true;
        set<Id> lstUsersUpdated = new set<Id>();
        lstUsersUpdated.add(objUsr1.Id);
        Test.startTest();       
        //WFG_Launch_UpdateRecordsOwnership obj = new WFG_Launch_UpdateRecordsOwnership();
        WFG_Launch_UpdateRecordsOwnership.updateLaunchRelatedRecords(lstUsersUpdated);
       // System.enqueueJob(new WFG_Launch_UpdateRecordsOwnership(lstUsersUpdated));
        Test.stopTest();
        
    }
}