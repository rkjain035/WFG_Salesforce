/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Deepthi
* @date 16-03-2018
* @description - Test class for WFG_UserCreateUpdate_Batch.

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Deepthi               Mod-01             16-03-2018              UserStoryNo - W025898,W025899
*/

@isTest
private class WFG_UserCreateUpdate_Batch_Test {
    @testSetup 
    static void setup() {         
        
        WFG_Test_Data_Utility.createTriggerActivationRecords();  
        
        List<user> lstUser = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'LL Us'];        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testbatch06', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',
        UserName='testuser06batch@test.com',FederationIdentifier='A1031w_comm',isActive=true);
        lstUser.add(u);
        
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testbatch07', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',
        UserName='testuser07batch@test.com',FederationIdentifier='A1033w',isActive=true);
        lstUser.add(u1);
        insert lstUser;
        
        Profile FSCPrf = [SELECT Id,userlicenseId FROM Profile WHERE Name = 'LL US']; 
        
        User FSCUser = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testbatch08', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = FSCPrf.Id,TimeZoneSidKey='America/Los_Angeles',
        UserName='testuser08batch@test.com',FederationIdentifier='A1032w',isActive=true);
        
       
        insert FSCUser;
        
        
         /* user userList = new User();
          userList = WFG_Test_Data_Utility.createTestUser('LL US');          
          userList.WFG_Agent_Code__c =  'Te4t2';
          insert userList;    */    
        
        List<Account> accList = WFG_Test_Data_Utility.createBranchOfficeTestData(2);
        insert accList;
        
        list<Contact> contactList = new list<Contact>();
        contactList.add(WFG_Test_Data_Utility.createContactTestRecord('Test 1', 'Contact1', accList[0].Id, 'Te4t1', 2));
        contactList.add(WFG_Test_Data_Utility.createContactTestRecord('Test 2', 'Contact2', accList[0].Id, 'Te4t2', 2)); 
        contactList[0].WFG_Email_Verification__c = true;
        contactList[0].WFG_AlternateEmail__c = 'test1@test.com';
        contactList[0].WFG_CycleType__c = 'US';
        contactList[1].WFG_Email_Verification__c = true;
        contactList[1].WFG_AlternateEmail__c = 'test2@test.com';
        contactList[1].WFG_CycleType__c = 'US';
        insert contactList;       
        
        
    }
    
    static testMethod void updateUserMethod() 
    {   
        Map<string, string> mapProfileVsContactID = new Map<string, string>();
        List<contact> conList = [Select Id,Name,LastName,WFG_Type__c,WFG_AgentPayType__c,WFG_CycleType__c,WFG_Fiduciary_Advisor__c,WFG_Email_Verification__c from contact where lastname = 'Contact1'];
        system.assert(conlist.size() > 0);
        user lstUser = [Select id, name, LocaleSidKey,profileId, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey,WFG_Agent_Code__c,ContactId 
            FROM User WHERE UserName = 'testuser06batch@test.com'];
        system.assert(lstUser != null);                                                       
        lstUser.IsActive = False; 
        system.debug('Conlist:'+conlist);
        mapProfileVsContactID.put(conlist[0].Id,lstUser.profileId);
        system.debug('map:'+mapProfileVsContactID);
        //update lstUser;   
        Test.startTest();
                    
            DataBase.executeBatch(new WFG_UserCreateUpdate_Batch(),10);             
        Test.stopTest();               
    }        
}