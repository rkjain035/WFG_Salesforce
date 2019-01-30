/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author N/A
* @date N/A
* @description - N/A

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Saravanan             Mod-01             24-OCT-2018             Test Class for WFG_RecreateCaseTeamMemberBatch    
*/
@isTest
Private with sharing class WFG_RecreateCaseTeamMemberBatch_Test 
{
    @testSetup static void setup() {
        list<user> userList = new list<User>();
        WFG_Test_Data_Utility.createTriggerActivationRecords();
        userList.add(WFG_Test_Data_Utility.createTestUser('RR US'));
        userList.add(WFG_Test_Data_Utility.createTestUser('FA US'));
        
        userList[0].WFG_Agent_Code__c =  'Te4t1';
        userList[1].WFG_Agent_Code__c =  'Te4t2';
        
        insert userList;
        
        Account testAccount = WFG_Test_Data_Utility.createBranchOfficeTestRecord('Test Account', 'bC0de', 'USD');
        insert testAccount;
        
        list<Contact> contactList = new list<Contact>();
        contactList.add(WFG_Test_Data_Utility.createContactTestRecord('Test 1', 'Contact 1', testAccount.Id, 'Te4t1', 2));
        contactList.add(WFG_Test_Data_Utility.createContactTestRecord('Test 2', 'Contact 2', testAccount.Id, 'Te4t2', 2));
        
        insert contactList;        
    }
    
    static testMethod void scenario1()
    {
        list<Contact> contactList = [select id, WFG_AgentCode__c from Contact];
        case testCase = insertCase(contactList[0],contactList[1]);        
        insert testCase;
        
        list<CaseTeamMember> caseTeamList = [select id from caseTeamMember Where ParentId =: testCase.Id];
        system.debug('**caseTeamList**'+caseTeamList);
        System.assertEquals(2, caseTeamList.size());
        
        map<Id, User> userMap = new map<Id, User>([select id from user where WFG_Agent_Code__c =  'Te4t1' OR WFG_Agent_Code__c =  'Te4t2']);
        test.starttest();
            Database.executeBatch(new WFG_RecreateCaseTeamMemberBatch(userMap.keyset()), 30);
        test.stoptest();
        
        list<CaseTeamMember> caseTeamList_1 = [select id from caseTeamMember Where ParentId =: testCase.Id];
        system.debug('**caseTeamList_1**'+caseTeamList_1);
        System.assertEquals(2, caseTeamList_1.size());
    }
    
    static Case insertCase(Contact onbehalfOf, Contact aboutTo){
        Case testCase = new case();
        testCase.Origin = 'Phone';
        testCase.Type = 'Commissions';
        testCase.WFG_Case_Reason_2__c = 'Chargebacks';
        testCase.Subject = 'Test Subject';
        testCase.Description = 'Test Description';
        testCase.Status = 'New';
        testCase.ContactId = onbehalfOf.Id;
        testCase.WFG_AgentCode__c = onbehalfOf.WFG_AgentCode__c;
        testCase.WFG_InteractingAbout__c = aboutTo.Id;
        testCase.WFG_InteractingAboutCode__c = aboutTo.WFG_AgentCode__c;
        
        return testCase;
    }
}