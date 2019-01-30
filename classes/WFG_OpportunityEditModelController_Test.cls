/**
* Property of Transamerica and Aegon companies. Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Nitesh Kumar
* @date   03-Mar-2017 
* @description Test class for WFG_OpportunityEditModelController 
Modification Log:
------------------------------------------------------------------------------------
Developer       Mod Number      Date               Description
------------------------------------------------------------------------------------
Nitesh Kumar     M-001          03-Mar-2017     Test Class for WFG_OpportunityEditModelController; 

*/
@isTest
(seeAllData = false)
public with sharing class WFG_OpportunityEditModelController_Test {

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
            WFG_Customer_Profile__c custProfile = WFG_Test_Data_Utility.createCustomerProfile(testIndividualContact.Id);
            
            Opportunity objOpp = WFG_Test_Data_Utility.createOppty(custProfile);
            insert objOpp;
            
            WFG_CreateCPResponseWrapper responseWrapper = WFG_AgentNewCustomerProfileController.createNewCustomerProfile(JSON.serialize(custProfile), testIndividualContact.Id, objOpp.Id);
            

            Opportunity testOppty = WFG_Test_Data_Utility.createOppty(responseWrapper.objCustProfile);
            insert testOppty;
        }     
    }

private static  testMethod  void  testEditOppty(){
    Opportunity testOpty = new Opportunity();
    Profile LLprofile = [Select Id, Name from Profile where Name='LL US' limit 1]; 
    User LLUser = [Select ID, Name from User where ProfileId =: LLprofile.Id and FirstName = 'Test LL' and LastName = 'User' LImit 1];
    System.runAs(LLUser){
        System.Test.StartTest();
        Id opptyId = [Select ID, Name from Opportunity Limit 1].Id; 
            if(opptyId!= null){
                testOpty =  WFG_OpportunityEditModelController.getOpportunity(opptyId);
                List<WFG_Customer_Profile__c> CPLst = WFG_OpportunityEditModelController.getAllCustomerProfiles(opptyId);
                String CPStatus = WFG_OpportunityEditModelController.getCustomerStatus(testOpty.WFG_CustomerProfile__c);
                testOpty.Name = 'oppty new name'; 
                WFG_OpportunityResponseWrapper  opptyWrapper =  WFG_OpportunityEditModelController.updateOpportunity(testOpty, testOpty.WFG_CustomerProfile__c);
        }
			WFG_OpportunityEditModelController.getIsLicensedPicklistValues();
        System.Test.StopTest();
    }
}

private static  testMethod  void  testEditOpptyDMLs(){
    Opportunity testgetOpty = new Opportunity();

    Profile LLprofile = [Select Id, Name from Profile where Name='LL US' limit 1]; 
    User LLUser = [Select ID, Name from User where ProfileId =: LLprofile.Id and FirstName = 'Test LL' and LastName = 'User' LImit 1];
    System.runAs(LLUser){
    
        System.Test.StartTest();
        Opportunity testOppty = new Opportunity();
        Id opptyId = [Select ID, Name from Opportunity Limit 1].Id; 
            if(opptyId!= null){
                testgetOpty =   WFG_OpportunityEditModelController.getOpportunity(opptyId);
            
                List<WFG_Customer_Profile__c> CPLst = WFG_OpportunityEditModelController.getAllCustomerProfiles('0068A000001eFO4');
                String CPStatus = WFG_OpportunityEditModelController.getCustomerStatus('a1g8A0000008ZfF');
                testgetOpty.Name = 'oppty new name'; 
                WFG_OpportunityResponseWrapper  opptyWrapper =  WFG_OpportunityEditModelController.updateOpportunity(testgetOpty, 'a1g8A0000008ZfF');
                  
                
        }

        System.Test.StopTest();
    }
}

private static  testMethod  void  testEditOpptyOtherExceptions(){
 Opportunity testgetOpty = new Opportunity();

    Profile LLprofile = [Select Id, Name from Profile where Name='LL US' limit 1]; 
    User LLUser = [Select ID, Name from User where ProfileId =: LLprofile.Id and FirstName = 'Test LL' and LastName = 'User' LImit 1];
    System.runAs(LLUser){
    
        System.Test.StartTest();
        Opportunity testOppty = new Opportunity();
                WFG_OpportunityResponseWrapper  opptyWrapper =  WFG_OpportunityEditModelController.updateOpportunity(testOppty, '');

        System.Test.StopTest();
} 


}

}