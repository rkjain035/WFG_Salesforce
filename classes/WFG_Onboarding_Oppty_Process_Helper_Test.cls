/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Praveen Lakkundi
* @date 24-08-2018
* @description  Controller class for Lightning component in the training Screen of WFG Launch

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Praveen                Mod-01          24/08/2018              W-027435 - Test class for WFG_Onboarding_Oppty_Process_Helper apex class
*/
@isTest
public class WFG_Onboarding_Oppty_Process_Helper_Test{
    private static Account testAcc;
    
    @testSetup static void createTestData(){
        WFG_Test_Data_Utility.createTriggerActivationRecords(); // Added during Service Center changes before FSC Installation
        Time t = System.now().time();
        String str = String.valueOf(t); 
        testAcc = WFG_Test_Data_Utility.createBranchOfficeTestRecord('WFG11',str,'USD'); 
        if(testAcc !=null){
            insert testAcc;
        }
        
     }
     
     static testMethod void testContact1Creation() {   
        user u = [select id from user where id=:userinfo.getUserId()];
        
        //get profile
        Profile p = [select name, id from profile where name= 'RR US']; 
        system.assert(p.id != null);
        
        //get Role
        userRole ur = [select name from userrole where name = 'Registered Reps'];
        system.assert(ur.id != null);
        
        //get Onboarding Recordtype
        recordtype rec = [select id from recordtype where name ='Onboarding'];
        system.assert(rec.id != null);
        WFG_OnboardingOpptyRecordTypeID__c onboardingRecInstance = new WFG_OnboardingOpptyRecordTypeID__c();
        onboardingRecInstance.name = 'TFN';
        onboardingRecInstance.Record_Type_ID__c = rec.Id;
        insert onboardingRecInstance;
        
        Id accountId = [select id from account where name ='WFG11'].Id;
        
        //create recruiting contact
        Contact objCon1 = WFG_Test_Data_Utility.createContactTestRecord('TestFLF', 'TestLLF', accountId, 'KA251', 1);
        objCon1.WFG_AgentPayType__c = 'WFG';
        objCon1.WFG_Fiduciary_Advisor__c = false;
        objCon1.WFG_CycleType__c = 'US';
        objCon1.WFG_Type__c = 'Agent'; 
        objCon1.WFG_Status__c = 'ACTIVE';
        objCon1.WFG_AgentId__c = 'KA251';
        ObjCon1.email = 'KingKong1@email.com';
        ObjCon1.homephone = '1231231231';
        ObjCon1.mailingCountry = 'US';
        ObjCon1.mailingState = 'NY';
        insert objCon1;
        
        //Create prospect contact
        Contact objCon = WFG_Test_Data_Utility.createContactTestRecord('TestFF', 'TestLF', accountId, 'KA261', 1);
        objCon.WFG_AgentPayType__c = 'WFG';
        objCon.WFG_Fiduciary_Advisor__c = false;
        objCon.WFG_CycleType__c = 'US';
        objCon.WFG_Type__c = 'Launch'; 
        objCon.WFG_Channel__c = 'Green';
        objCon.WFG_Status__c = 'ACTIVE';
        objCon.WFG_AgentId__c = 'KA261';
        ObjCon.email = 'test1@gmail.com';
        ObjCon.homephone = '1231231231';
        ObjCon.mailingCountry = 'US';
        ObjCon.mailingState = 'NY';
        insert objCon;
        
        //create associated user            
        User objUsr = WFG_Test_Data_Utility.createUserRecord('KingKong1@email.com', true, 'AKA251',null, p.id);
        objUsr.UserRoleId = ur.Id;
        Test.startTest();
        system.runAs(u){
            insert objUsr;
        }
        Test.stopTest();
        
        //Create lead by making associated user as Owner
        lead l = new lead();
        l.firstname = 'TestFF';
        l.lastname = 'TestLF';
        l.email = 'test1@gmail.com';
        l.ownerId = objUsr.Id;
        l.Company = 'Test';
        insert l;
        
        //Create Onboaring Checklist
        WFG_Onboarding_Checklist__c oc = WFG_Test_Data_Utility.createOnboardingChecklistRecord(objCon.Id,objCon1.Id,null,null);
        insert oc;
    }
}