/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Saurabh Sharma
* @date 1-16-2017
* @description  Test Class for WFG_AgentNewIndividualController

Modification Log:
-------------------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
-------------------------------------------------------------------------------------------------------------------
Mruga Shastri        M-001             27-Feb-2017     Test class for unit testing WFG_AgentEditCustomerDetailController  
*/
@isTest
(seeAllData=False)
private class WFG_AgentEditCustDetailController_Test{


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

 //insert spouse relation
          insert WFG_Test_Data_Utility.createContactReciprocalRoleRecord('Spouse', 'Spouse');
      }

      System.runAs(testLLUser){
          
            Contact testIndividualContact = WFG_Test_Data_Utility.createIndividualRecord('Milly', 'Morris', '(999) 999-9999', 'Single');
            insert testIndividualContact; 
            
        }     

  }

    private static  testMethod void testGetAllIndividual(){
      Profile LLprofile = [Select Id, Name from Profile where Name='LL US' limit 1]; 
      User LLUser = [Select ID, Name from User where ProfileId =: LLprofile.Id and FirstName = 'Test LL' and LastName = 'User' LImit 1];
      System.runAs(LLUser){
        System.Test.StartTest();
          List<contact> contactlst = new list<contact>(); 
          contactlst = WFG_AgentEditCustomerDetailController.getAllIndividuals(); 
          if(contactlst!= null){
              WFG_AgentEditCustomerDetailController.getContactDetails(contactlst[0].Id); 

          }
          
          WFG_AgentEditCustomerDetailController.getCoutryStateDependency();
          WFG_AgentEditCustomerDetailController.getMaritalStatus();
          WFG_AgentEditCustomerDetailController.getGender();
          WFG_AgentEditCustomerDetailController.getConIndicator();
          WFG_AgentEditCustomerDetailController.getCASLConsentValues();
      System.Test.StopTest();
      }
    }
    
    /*
    Test Method to test individual and existing spouse record creation
    */
    static testMethod void testIndividualAndExistingSpouseCreation(){
      Profile LLprofile = [Select Id, Name from Profile where Name='LL US' limit 1]; 
      User LLUser = [Select ID, Name from User where ProfileId =: LLprofile.Id and FirstName = 'Test LL' and LastName = 'User' LImit 1];
      System.runAs(LLUser){
        System.Test.StartTest();
         
          Contact cont = WFG_Test_Data_Utility.createIndividualRecord('Matthew', 'Morris', '(999) 999-9999', 'Married');
           Contact spousecont = WFG_Test_Data_Utility.createIndividualRecord('Amanda', 'Morris', '(999) 999-9999', 'Married');
           insert spousecont;
          //Contact spouseCont = [SELECT Id FROM Contact WHERE FinServ__MaritalStatus__c = 'Single' LIMIT 1];
          WFG_CreateIndividualResponseWrapper responseWrapper = WFG_AgentEditCustomerDetailController.updateContact(cont, NULL, null);
           responseWrapper = WFG_AgentEditCustomerDetailController.updateContact(cont, NULL, spouseCont.id);
          WFG_AgentEditCustomerDetailController.getSpouseDetails(spousecont.Id);
          WFG_AgentEditCustomerDetailController.getSpouseName(spousecont.Id);
          WFG_AgentEditCustomerDetailController.archiveContact(spousecont.Id);
        System.Test.StopTest(); 
      } 
    }
    
    /*
    Test Method to test individual and new spouse record creation
  */
    static testMethod void testIndividualAndNewSpouseCreation(){
      Profile LLprofile = [Select Id, Name from Profile where Name='LL US' limit 1]; 
      User LLUser = [Select ID, Name from User where ProfileId =: LLprofile.Id and FirstName = 'Test LL' and LastName = 'User' LImit 1];
      System.runAs(LLUser){
        System.Test.StartTest();
          Contact cont = WFG_Test_Data_Utility.createIndividualRecord('Matthew', 'Morris', '(999) 999-9999', 'Married');
          Contact spousecont = WFG_Test_Data_Utility.createIndividualRecord('Amanda', 'Morris', '(999) 999-9999', 'Married');
          WFG_CreateIndividualResponseWrapper responseWrapper = WFG_AgentEditCustomerDetailController.updateContact(cont, spouseCont, NULL);
          System.assertEquals('Contact Successfully Created', responseWrapper.objGenericRes.strSuccessMessage, 'Contact creation error - '+responseWrapper.objGenericRes.strErrorMessage);
         
        System.Test.StopTest();  
      }
      
    }


   /*
    Test Method to test negative scenarios
  */
    static testMethod void testNegativeScenarios(){
      WFG_AgentEditCustomerDetailController.getAllIndividuals(); 
      
      Profile LLprofile = [Select Id, Name from Profile where Name='LL US' limit 1]; 
      User LLUser = [Select ID, Name from User where ProfileId =: LLprofile.Id and FirstName = 'Test LL' and LastName = 'User' LImit 1];
      System.runAs(LLUser){
        System.Test.StartTest();
            Contact junkContact = WFG_AgentEditCustomerDetailController.getContactDetails('a1g8A0000008ZfF');
            WFG_AgentEditCustomerDetailController.archiveContact('a1g8A0000008ZfF');
         
        System.Test.StopTest();  
      }
      
    } 

//Insert Reverse Individual & Existing spouse while creating contact-contact relationship 
    static testMethod void testExistingRelationship(){
       List<Contact> allIndividualsLst = new List<Contact>(); 
        
        Profile LLprofile = [Select Id, Name from Profile where Name='LL US' limit 1]; 
        
        User LLUser = [Select ID, Name from User where ProfileId =: LLprofile.Id and FirstName = 'Test LL' and LastName = 'User' LImit 1];
        
        System.runAs(LLUser){
            Test.StartTest(); 
                Contact testIndividualContact = WFG_Test_Data_Utility.createIndividualRecord('Matthew', 'Morris', '1231321234', 'Married');
                Contact testIndividualSpouse =  WFG_Test_Data_Utility.createIndividualRecord('Milli', 'Morris', '1231321234', 'Married');
                Contact testIndividualoldSpouse =  WFG_Test_Data_Utility.createIndividualRecord('Amanda', 'Morris', '1231321234', 'Married');
                WFG_CreateIndividualResponseWrapper responseWrapper = WFG_AgentNewIndividualController.createIndividual(testIndividualContact, testIndividualoldSpouse, NULL);
                
                System.assertEquals('Contact Successfully Created', responseWrapper.objGenericRes.strSuccessMessage, 'Contact creation error - '+responseWrapper.objGenericRes.strErrorMessage);
                WFG_CreateIndividualResponseWrapper response = WFG_AgentEditCustomerDetailController.updateContact(responseWrapper.objContact, null, null);
                response = WFG_AgentEditCustomerDetailController.updateContact(responseWrapper.objContact, testIndividualSpouse, null);
                    
            System.Test.StopTest();
            }

        
    }      
}