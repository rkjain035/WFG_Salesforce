@isTest
Private with sharing class WFG_AddCaseTeamMember_Batch_Test 
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
        system.debug('**contactlist**'+contactList);
        system.debug('**Caselist**'+testCase);
        list<CaseTeamMember> caseTeamList = [select id from caseTeamMember Where ParentId =: testCase.Id];
        system.debug('**caseTeamList**'+caseTeamList);
        System.assertEquals(2, caseTeamList.size());
        
        
        delete [select id from caseTeamMember where ParentId =: testCase.Id];
        
        list<CaseTeamMember> caseTeamList_1 = [select id from caseTeamMember Where ParentId =: testCase.Id];
        System.assertEquals(0, caseTeamList_1.size());
        
        test.starttest();
            Database.executeBatch(new WFG_AddCaseTeamMember_Batch(2), 100);
        test.stoptest();
        
        list<CaseTeamMember> caseTeamList_2 = [select id from caseTeamMember Where ParentId =: testCase.Id];
        System.assertEquals(2, caseTeamList_2.size());
    }
    
    static testMethod void scenario2()
    {
        list<Contact> contactList = [select id, WFG_AgentCode__c from Contact];
        list<Case> caseInsertList = new list<Case>();
        caseInsertList.add(insertCase(contactList[0],contactList[1]));
        caseInsertList.add(insertCase(contactList[0],contactList[1]));
        insert caseInsertList;
        
        list<CaseTeamMember> caseTeamList = [select id from caseTeamMember Where ParentId IN: caseInsertList];
        System.assertEquals(4, caseTeamList.size());
        
        
        delete [select id from caseTeamMember where ParentId IN: caseInsertList];
        
        list<CaseTeamMember> caseTeamList_1 = [select id from caseTeamMember Where ParentId IN: caseInsertList];
        System.assertEquals(0, caseTeamList_1.size());
        
        test.starttest();
            Database.executeBatch(new WFG_AddCaseTeamMember_Batch(0), 100);
        test.stoptest();
        
        list<CaseTeamMember> caseTeamList_2 = [select id from caseTeamMember Where ParentId IN: caseInsertList];
        System.assertEquals(4, caseTeamList_2.size());
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