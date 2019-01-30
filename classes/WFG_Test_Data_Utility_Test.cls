@isTest
public class WFG_Test_Data_Utility_Test {
    static testMethod void test(){
        WFG_Test_Data_Utility.createTriggerActivationRecords();
        WFG_Test_Data_Utility.createTriggerActivation();
        list<Account> actlist = new list<Account>();
        system.debug('Accounts = '+WFG_Test_Data_Utility.createBranchOfficeTestData(10));
        actlist.addAll(WFG_Test_Data_Utility.createBranchOfficeTestData(10));
        insert actlist;
        user u = WFG_Test_Data_Utility.createTestUser('Standard User');
        account a = WFG_Test_Data_Utility.createBranchOfficeTestRecord('Test','121','USD');
        insert a;
        contact c = WFG_Test_Data_Utility.createContactTestRecord('Fname','Lname',a.Id,'123',12);
        WFG_AgentCode__c agc = WFG_Test_Data_Utility.CreateAgentCode('KK1232',c.Id,system.today(),true);
        list<Contact> conlist = new list<Contact>();
        conlist.add(c);
        contact con = new contact();
        WFG_Test_Data_Utility.updateContactTestRecord(con,'WFG');
        profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        user u2 = WFG_Test_Data_Utility.createUserRecord('p@transamerica.com',true,'12', conlist[0].Id, profileId.Id);
        account a3 = WFG_Test_Data_Utility.createIndividualRecord('Test');
        contact con2 = WFG_Test_Data_Utility.createIndividualRecord('FName','Lname','1231231231','Single');
        contact con3 = WFG_Test_Data_Utility.createPhoneIndividualRecord('FName','Lname','1231231231','Single');
        account a4 = WFG_Test_Data_Utility.createBusinessAccountRecord('Test','123','Business');
        contact con4 = WFG_Test_Data_Utility.createBusinessContactRecord('Fname','Lname',a.ID,'p@transamerica.com');
        FinServ__ReciprocalRole__c fsr = WFG_Test_Data_Utility.createAccountReciprocalRoleRecord('Account Role','Test');
        FinServ__ReciprocalRole__c fsr2 = WFG_Test_Data_Utility.createContactReciprocalRoleRecord('Account Role','Test');
        FinServ__AccountAccountRelation__c fsAAR = WFG_Test_Data_Utility.createAccountAccountRelationshipRecord(a.Id,a3.Id,fsr.Id);
        FinServ__ContactContactRelation__c fsCCR = WFG_Test_Data_Utility.createContactContactRelationshipRecord(con2.Id,con3.Id,fsr.Id);
        AccountContactRelation ACR = WFG_Test_Data_Utility.createAccountContactRelationshipRecord(con2.Id,a.Id);
        FinServ__FinancialAccount__c FFA = WFG_Test_Data_Utility.createIndividualInvestmentAccountRecord(a4.Id);
        FinServ__FinancialAccount__c FFA2 = WFG_Test_Data_Utility.createIndividualCurrentProductRecord(a4.Id);
        WFG_Customer_Profile__c CP = WFG_Test_Data_Utility.createCustomerProfile(con4.Id);
        WFG_Referral__c REF = WFG_Test_Data_Utility.createReferral(CP,u.Id);
        WFG_Customer_Profile__c CP2 = WFG_Test_Data_Utility.createCustomerProfile(con);
        Opportunity opp = WFG_Test_Data_Utility.createOppty(a.Id);
        Opportunity opp2 = WFG_Test_Data_Utility.createOppty(CP);
        Event ev = WFG_Test_Data_Utility.createEvent(a.Id);
        Lead l = WFG_Test_Data_Utility.createLead();
        account a5 = WFG_Test_Data_Utility.createHouseholdRecord('Test');
        WFG_Launch_Training__kav objArticle = WFG_Test_Data_Utility.createKnowledgeArticle('TestUrl','Launch Blue US', 'US');
    }
}