@isTest
Private with sharing class WFG_RemoveAccountShare_Batch_Test 
{
    @testSetup static void setup() {
        WFG_Test_Data_Utility.createTriggerActivationRecords();
        
        User usr = WFG_Test_Data_Utility.createTestUser('RR US');
        usr.WFG_Agent_Code__c =  'Te4t1';
        insert usr;
        
        Account testAccount = WFG_Test_Data_Utility.createBranchOfficeTestRecord('Test Account', 'bC0de', 'USD');
        insert testAccount;
        
        Contact con = WFG_Test_Data_Utility.createContactTestRecord('Test 1', 'Contact 1', testAccount.Id, 'Te4t1', 2);
        insert con;
    }
    
    static testMethod void scenario1()
    {
        Account acct = [select id from account limit 1];
        User usr = [select id from user where WFG_Agent_Code__c = 'Te4t1' limit 1];
        list<AccountShare> acctShareList = [select id from accountShare where accountId =: acct.Id AND UserOrGroupId =: usr.Id];
        System.assertEquals(0, acctShareList.size());
        
        AccountShare acctShare = new AccountShare();
        acctShare.AccountId = acct.Id;
        acctShare.UserOrGroupId = usr.Id;
        acctShare.AccountAccessLevel = 'Read';
        acctShare.OpportunityAccessLevel = 'none';
        insert acctShare;
        
        list<AccountShare> acctShareList_1 = [select id from accountShare where accountId =: acct.Id AND UserOrGroupId =: usr.Id];
        System.assertEquals(1, acctShareList_1.size());
        
        test.starttest();
            Database.executeBatch(new WFG_RemoveAccountShare_Batch(), 100);
        test.stoptest();
        
        list<AccountShare> acctShareList_2 = [select id from accountShare where accountId =: acct.Id AND UserOrGroupId =: usr.Id];
        System.assertEquals(0, acctShareList_2.size());
    }
    
    static testMethod void scenario2()
    {
        Account acct = [select id from account limit 1];
        User usr = [select id from user where WFG_Agent_Code__c = 'Te4t1' limit 1];
        list<AccountShare> acctShareList = [select id from accountShare where accountId =: acct.Id AND UserOrGroupId =: usr.Id];
        System.assertEquals(0, acctShareList.size());
        
        AccountShare acctShare = new AccountShare();
        acctShare.AccountId = acct.Id;
        acctShare.UserOrGroupId = usr.Id;
        acctShare.AccountAccessLevel = 'Read';
        acctShare.OpportunityAccessLevel = 'none';
        insert acctShare;
        
        list<AccountShare> acctShareList_1 = [select id from accountShare where accountId =: acct.Id AND UserOrGroupId =: usr.Id];
        System.assertEquals(1, acctShareList_1.size());
        
        test.starttest();
            Database.executeBatch(new WFG_RemoveAccountShare_Batch(), 10);
        test.stoptest();
        
        list<AccountShare> acctShareList_2 = [select id from accountShare where accountId =: acct.Id AND UserOrGroupId =: usr.Id];
        System.assertEquals(0, acctShareList_2.size());
    }
}