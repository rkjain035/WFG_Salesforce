/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Mruga Shastri
* @date 13-Feb-2017
* @description  Test Class for WFG_ImportantDatesCOntroller

Modification Log:
-------------------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
-------------------------------------------------------------------------------------------------------------------
Mruga Shastri       M-001           13-Feb-2017     Test class for unit testing WFG_ImportantDatesCOntroller  
*/

@isTest(seeAllData = false)
public class WFG_ImportantDatesController_Test {
        
    @testSetup static void createTestData(){
 
        Contact partnerContact; 
        User currentUser, testLLUser; 
//Activate triggers
        WFG_Test_Data_Utility.createTriggerActivationRecords();
        
        currentUser = [Select Id, Name,UserRoleId from User where Id=: UserInfo.GetUserId()];
//Create LL user & contact.         
        System.runAs(currentUser){
            Account objAcc = WFG_Test_Data_Utility.createBranchOfficeTestRecord('AccountName', '1234', 'USD');
            objAcc.WFG_BranchCode__c = '1234_test';
            insert objAcc;
    
            Contact objCon = WFG_Test_Data_Utility.createContactTestRecord('ConF', 'ConL', objAcc.id, '00HA', 1);
            objCon.WFG_AgentPayType__c = 'WFG';
            objCon.WFG_Fiduciary_Advisor__c = false;
            objCon.WFG_CycleType__c = 'US';
            objCon.WFG_Type__c = 'Agent'; 
            objCon.WFG_AgentId__c = '12345';
            insert objCon;
            
            testLLUser = WFG_Test_Data_Utility.createTestUser('LL US');
            testLLUser.FirstName = 'Test LL';
            testLLUser.LastName = 'User';
            //testLLUser.ContactId = objCon.Id;  
            //testLLUser.UserType = 'PowerPartner';
            //testLLUser.UserRoleId = '00E0S000000QUYC';
            insert testLLUser; 
        }
        
        System.runAs(testLLUser){
            Contact testIndividualContact = WFG_Test_Data_Utility.createIndividualRecord('Matthew', 'Morris', '1231321234', 'Single');
            insert testIndividualContact;

            System.debug('Mathews contact in Data Set up : ' + testIndividualContact); 
            System.debug('Mathews Account in Data set up : ' + testIndividualContact.AccountId); 
            Event testEvent = WFG_Test_Data_Utility.createEvent(testIndividualContact.AccountId);
            testEvent.RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Important Date').getRecordTypeId();
            insert testEvent;           
        
        }
        
    
    }
//Test Method for getting the list of all Events related to a given Contact and Deleting given Event.      
    static testMethod void testGetEvents(){

        
        Profile LLprofile = [Select Id, Name from Profile where Name='LL US' limit 1]; 
        
        User LLUser = [Select ID, Name from User where ProfileId =: LLprofile.Id and FirstName = 'Test LL' and LastName = 'User' LImit 1];
        
        System.runAs(LLUser){

            test.startTest();   
                List<Event> eventLst = new List<Event>(); 
                Contact testIndividualContact = [Select ID, Name, AccountId From Contact where firstName = 'Matthew' AND lastName = 'Morris' Limit 1];
                System.debug('Mathews contact in testMEthod : ' + testIndividualContact); 
                System.debug('Mathews contact in testMEthod : ' + testIndividualContact.AccountId); 
                    if(testIndividualContact != null){
                        eventLst = WFG_ImportantDatesController.getCustomerEvents(testIndividualContact.Id); 
                        System.debug('eventLst -> ' + eventLst);
                        if(!eventlst.isEmpty() && eventLst!= null && eventLst[0] != null){
                            WFG_ImportantDatesController.deleteCustomerEvent(eventLst[0].Id);
                        }
                    }
            test.StopTest();
            }
        
    }   

//Test Method for creating new Event related to a given Contact.      
    static testMethod void testCreateEvents(){ 
        Profile LLprofile = [Select Id, Name from Profile where Name='LL US' limit 1]; 
        
        User LLUser = [Select ID, Name from User where ProfileId =: LLprofile.Id and FirstName = 'Test LL' and LastName = 'User' LImit 1];
        
        System.runAs(LLUser){
            Contact testIndividualContact = [Select ID, Name From Contact where firstName = 'Matthew' AND lastName = 'Morris' Limit 1];
                 
            if(testIndividualContact != null){
                test.startTest();   
                    WFG_ImportantDatesController.createCustomerEvent(testIndividualContact.Id, 'A month from Now!', System.today() + 30); 
                test.StopTest();
            }
         }
    }
    
   //Test Method for deleting the Event. 
    static testMethod void testDeleteEvents(){
        Profile LLprofile = [Select Id, Name from Profile where Name='LL US' limit 1]; 
        User LLUser = [Select ID, Name from User where ProfileId =: LLprofile.Id and FirstName = 'Test LL' and LastName = 'User' LImit 1];
        
        System.runAs(LLUser){
             test.startTest();
             Contact testIndividualContact = WFG_Test_Data_Utility.createIndividualRecord('Morris', 'Mathew', '1231321234', 'Single');
            insert testIndividualContact;
            
             Event testEvent = WFG_Test_Data_Utility.createEvent(testIndividualContact.AccountId);
            testEvent.RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Important Date').getRecordTypeId();
            insert testEvent; 
                    WFG_ImportantDatesController.deleteCustomerEvent(testEvent.Id); 
                test.StopTest();
        }
    }
}