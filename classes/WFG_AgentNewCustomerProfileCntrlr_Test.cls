/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Saurabh Sharma
* @date 1-31-2017
* @description  Test Class for WFG_AgentNewCustomerProfileController

Modification Log:
-------------------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
-------------------------------------------------------------------------------------------------------------------
Saurabh Sharma        M-001             1-16-2017     Test class for unit testing WFG_AgentNewCustomerProfileController  
*/
@isTest(seeAllData = false)
public class WFG_AgentNewCustomerProfileCntrlr_Test {
    
    /*
    Method to create test setup data
    */
    @testSetup static void createSetupData() {
        
        Contact partnerContact; 
        User currentUser, testLLUser; 
        //Activate triggers
        WFG_Test_Data_Utility.createTriggerActivationRecords();
        
        currentUser = [Select Id, Name from User where Id=: UserInfo.getUserId()];
        //Create LL user & contact.         
        System.runAs(currentUser){
            
             Account objAcc = WFG_Test_Data_Utility.createBranchOfficeTestRecord('AccountName', '1234', 'USD');
        objAcc.WFG_BranchCode__c = '1234_test';
        insert objAcc;

        Contact objCon1 = WFG_Test_Data_Utility.createContactTestRecord('ConF', 'ConL', objAcc.id, '00HA', 1);
        objCon1.WFG_AgentPayType__c = 'WFG';
        objCon1.WFG_Fiduciary_Advisor__c = false;
        objCon1.WFG_CycleType__c = 'US';
        objCon1.WFG_Type__c = 'Registered_Rep'; 
        objCon1.WFG_AgentId__c = '12345';
        insert objCon1; 
            
            testLLUser = WFG_Test_Data_Utility.createTestUser('LL US');
            testLLUser.FirstName = 'Test LL';
            testLLUser.LastName = 'User';
            //testLLUser.ContactId = objCon1.Id;  
            insert testLLUser; 
        }
        
        System.runAs(testLLUser){
            
            Contact testIndividualContact = WFG_Test_Data_Utility.createIndividualRecord('Matthew', 'Morris', '(999) 999-9999', 'Single');
            insert testIndividualContact;
            
            Id idAccount = [SELECT AccountId FROM Contact WHERE Id =: testIndividualContact.Id].AccountId;
            Opportunity testOpportunity = WFG_Test_Data_Utility.createOppty(idAccount);
            testOpportunity.WFG_Contact__c = testIndividualContact.Id;
            insert testOpportunity;
        }     
        
    }
    
    /*
    Test Method to test customer profile positive scenarios
    */
    static testMethod void testCPPositiveCases(){ 
        Profile LLprofile = [Select Id, Name from Profile where Name='LL US' limit 1]; 
        User LLUser = [Select ID, Name from User where ProfileId =: LLprofile.Id and FirstName = 'Test LL' and LastName = 'User' LImit 1];
        System.runAs(LLUser){
            System.Test.StartTest();
            //Cover Schema methods - 
            WFG_AgentNewCustomerProfileController.getEmploymentStatus();
            WFG_AgentNewCustomerProfileController.getInsuranceType();
            WFG_AgentNewCustomerProfileController.getAssetList();
            WFG_AgentNewCustomerProfileController.isUSUser();
            //WFG_AgentNewCustomerProfileController.isFAUser();
            WFG_AgentNewCustomerProfileController.getAllIndividuals();
            WFG_AgentNewCustomerProfileController.checkReferralAccess();
            //Cover other methods -           
            Contact testIndividualContact = [Select ID, Name, AccountId From Contact where firstName = 'Matthew' AND lastName = 'Morris' Limit 1];
            WFG_Customer_Profile__c custProfile = WFG_Test_Data_Utility.createCustomerProfile(testIndividualContact.Id);
            
            //Id idOpportunity = [SELECT Id FROM Opportunity WHERE AccountId =: testIndividualContact.AccountId LIMIT 1].Id;
            Id idOpportunity = null;
            
            WFG_CreateCPResponseWrapper responseWrapper = WFG_AgentNewCustomerProfileController.createNewCustomerProfile(JSON.serialize(custProfile), testIndividualContact.Id, idOpportunity);
            List<WFG_Customer_Profile__c> lstCP = new List<WFG_Customer_Profile__c>();
            System.assertEquals('Customer Profile Successfully Created', responseWrapper.objGenericRes.strSuccessMessage, 'Customer Profile creation error - '+responseWrapper.objGenericRes.strErrorMessage);
            WFG_AgentNewCustomerProfileController.isNonEdtable(responseWrapper.objCustProfile.Id);
            WFG_AgentNewCustomerProfileController.isCustomerEligibleForReferral(responseWrapper.objCustProfile.Id);
            
            WFG_Customer_Profile__c getCP = new WFG_Customer_Profile__c();
            getCP = WFG_AgentNewCustomerProfileController.getcustomerProfile(responseWrapper.objCustProfile.id);
            WFG_CreateCPResponseWrapper cpWrapper =  WFG_AgentNewCustomerProfileController.updateNewCustomerProfile(JSON.serialize(custProfile));
            boolean eligibleReferral = WFG_AgentNewCustomerProfileController.isCustomerEligibleForReferral(responseWrapper.objCustProfile.id);
            
            
            Opportunity opp = new Opportunity();
            opp = [select id from Opportunity LIMIT 1];
            WFG_AgentNewCustomerProfileController.updateOpptyWithCP(opp.Id, responseWrapper.objCustProfile.id,testIndividualContact.Id);
            WFG_AgentNewCustomerProfileController.updateOpptyWithCP(opp.Id, 'NegativeTest',testIndividualContact.Id);
            
            System.Test.StopTest();
        } 
    }
    
    /*
Test Method to test customer profile negative scenarios
*/
    static testMethod void testCPNegativeCases(){
        Profile LLprofile = [Select Id, Name from Profile where Name='LL US' limit 1]; 
        User LLUser = [Select ID, Name from User where ProfileId =: LLprofile.Id and FirstName = 'Test LL' and LastName = 'User' LImit 1];
        System.runAs(LLUser){
            System.Test.StartTest();
            //Cover other methods -           
            Contact testIndividualContact = [Select ID, Name, AccountId From Contact where firstName = 'Matthew' AND lastName = 'Morris' Limit 1];
            WFG_Customer_Profile__c custProfile = WFG_Test_Data_Utility.createCustomerProfile(testIndividualContact.Id);
            
            WFG_CreateCPResponseWrapper responseWrapper = WFG_AgentNewCustomerProfileController.createNewCustomerProfile(JSON.serialize(custProfile), '0038A003404ioArQAI', null);
            List<WFG_Customer_Profile__c> lstCP = new List<WFG_Customer_Profile__c>();
            System.assertNotEquals('Customer Profile Successfully Created', responseWrapper.objGenericRes.strSuccessMessage, 'Customer Profile creation error - '+responseWrapper.objGenericRes.strErrorMessage);
            
            System.Test.StopTest();
        } 
    }
    
    /*
Test Method to test customer profile all other Exception scenarios
*/
    static testMethod void testCPOtherExceptions(){
        Profile LLprofile = [Select Id, Name from Profile where Name='LL US' limit 1]; 
        User LLUser = [Select ID, Name from User where ProfileId =: LLprofile.Id and FirstName = 'Test LL' and LastName = 'User' LImit 1];
        System.runAs(LLUser){
            System.Test.StartTest();
            
            WFG_Customer_Profile__c custProfile = new WFG_Customer_Profile__c();
            
            
            WFG_CreateCPResponseWrapper createResponseWrapper = WFG_AgentNewCustomerProfileController.createNewCustomerProfile('', '0038A003404ioArQAI', null);
            WFG_CreateCPResponseWrapper updateResponseWrapper = WFG_AgentNewCustomerProfileController.updateNewCustomerProfile('');
            boolean failEligibilityCheck = WFG_AgentNewCustomerProfileController.isCustomerEligibleForReferral('a1g8A0000008ZfF');
            String oppexception = WFG_AgentNewCustomerProfileController.updateOpportunity('00689AV32330000Zad', 'Need Assessment');
            String opptexeption = WFG_AgentNewCustomerProfileController.changeModalNameBack('00689AV32330000Zad');
            System.Test.StopTest();
        } 
    }    
}