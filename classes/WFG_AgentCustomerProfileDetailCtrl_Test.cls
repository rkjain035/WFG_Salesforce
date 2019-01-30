/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Nitesh Kumar
* @date 28-Feb-2017
* @description  Test Class for WFG_AgentCustomerProfileDetailController

Modification Log:
-------------------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
-------------------------------------------------------------------------------------------------------------------
Nitesh                  M-001          28-Feb-2017      Test class for unit testing WFG_AgentCustomerProfileDetailController  
*/
@isTest(seeAllData = false)
public with sharing class WFG_AgentCustomerProfileDetailCtrl_Test {
    /*
    Method to create test setup data
    */
    @testSetup 
    static void createSetupData() {
        
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
          
          User exceptionUser = WFG_Test_Data_Utility.createTestUser('API Only');
          insert exceptionUser;
      }

      System.runAs(testLLUser){
          
            Contact testIndividualContact = WFG_Test_Data_Utility.createIndividualRecord('Matthew', 'Morris', '(999) 999-9999', 'Single');
            insert testIndividualContact; 
            
        }     
    }
    
 /*
    Test Method to test referral access
  */
    static testMethod void testReferralAccess(){
        
      Profile LLprofile = [Select Id, Name from Profile where Name='LL US' limit 1]; 
      User LLUser = [Select ID, Name from User where ProfileId =: LLprofile.Id and FirstName = 'Test LL' and LastName = 'User' LImit 1];
      System.runAs(LLUser){
        System.Test.StartTest();
          WFG_AgentCustomerProfileDetailController.checkReferralAccess();
        System.Test.StopTest();
        }
    }
 /*
    Test Method to test customer profile positive scenarios
  */
    static testMethod void testCPCases(){
      Profile LLprofile = [Select Id, Name from Profile where Name='LL US' limit 1]; 
      User LLUser = [Select ID, Name from User where ProfileId =: LLprofile.Id and FirstName = 'Test LL' and LastName = 'User' LImit 1];
      System.runAs(LLUser){
        System.Test.StartTest();
//Cover Schema methods - 
          Contact testIndividualContact = [Select ID, Name, AccountId From Contact where firstName = 'Matthew' AND lastName = 'Morris' Limit 1];
          WFG_Customer_Profile__c custProfile = WFG_Test_Data_Utility.createCustomerProfile(testIndividualContact.Id);
          Opportunity opportunity = WFG_Test_Data_Utility.createOppty(custProfile);
          WFG_CreateCPResponseWrapper responseWrapper = WFG_AgentNewCustomerProfileController.createNewCustomerProfile(JSON.serialize(custProfile), testIndividualContact.Id, opportunity.Id);

          WFG_AgentCustomerProfileDetailController.getCustProfile(responseWrapper.objCustProfile.id);
          WFG_AgentCustomerProfileDetailController.getCustProfile('a1g8A0000008XN8');
          WFG_AgentCustomerProfileDetailController.isUSUser();
          WFG_AgentCustomerProfileDetailController.isFAUser();
          WFG_AgentCustomerProfileDetailController.getAssetList();
          WFG_AgentCustomerProfileDetailController.isCommunity();
        System.Test.StopTest();
      } 
    } 
    
 /*
    Test Method to test exception scenarios
  */
    static testMethod void testErrors(){
      Profile ExceptionProfile = [Select Id, Name from Profile where Name='API Only' limit 1]; 
      User ExceptionUser = [Select ID, Name from User where ProfileId =: ExceptionProfile.Id LImit 1];
       
        System.runAs(ExceptionUser){
        System.Test.StartTest();
          WFG_AgentCustomerProfileDetailController.isUSUser();
          WFG_AgentCustomerProfileDetailController.isFAUser();
          WFG_AgentCustomerProfileDetailController.getAssetList();
          WFG_AgentCustomerProfileDetailController.checkReferralAccess();
       System.Test.StopTest();
     }
    }

}