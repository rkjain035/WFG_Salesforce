@isTest
private with sharing class WFG_CaseTeamMemberDeleteAllTest {
	
     @testSetup static void setup()
        {
            WFG_Test_Data_Utility.createTriggerActivationRecords();
            list<user> userList = new list<User>();
             userList.add(WFG_Test_Data_Utility.createTestUser('RR US'));
        userList.add(WFG_Test_Data_Utility.createTestUser('FA US'));
        
        userList[0].WFG_Agent_Code__c =  'Te4t1';
        userList[1].WFG_Agent_Code__c =  'Te4t2';
        
        insert userList;
             Account testAccount = WFG_Test_Data_Utility.createBranchOfficeTestRecord('Test Account123', 'bC0de', 'USD');
        	insert testAccount;
            
             list<Contact> contactList = new list<Contact>();
        	contactList.add(WFG_Test_Data_Utility.createContactTestRecord('Test 1', 'Contact 1', testAccount.Id, 'Te4t1', 2));
        	contactList.add(WFG_Test_Data_Utility.createContactTestRecord('Test 2', 'Contact 2', testAccount.Id, 'Te4t2', 2));
        
        	insert contactList;
            
        }
    
    static testMethod void testMethod1()
    {
       	list<Contact> contactList = [select id, WFG_AgentCode__c from Contact];
        list<Case> caseInsertList = new list<Case>();
        caseInsertList.add(insertCase(contactList[0],contactList[1]));
        caseInsertList.add(insertCase(contactList[1],contactList[1]));
        insert caseInsertList;
        
        list<CaseTeamMember> caseTeamList = [select id from caseTeamMember Where ParentId IN: caseInsertList];
        System.debug('size...'+caseTeamList.size());
        System.assertEquals(3, caseTeamList.size());
        
         test.starttest();
            Database.executeBatch(new WFG_CaseTeamMemberDeleteAll(),100);
        test.stoptest();
        
        list<CaseTeamMember> caseTeamList2 = [select id from caseTeamMember Where ParentId IN: caseInsertList];
        System.assertEquals(0, caseTeamList2.size());
        
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