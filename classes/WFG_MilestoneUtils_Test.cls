@isTest
public class WFG_MilestoneUtils_Test {
    static testMethod void test(){
        WFG_TestDataFactory.createTriggerActivationRecords();
        list<Account> actlist = WFG_TestDataFactory.createAccounts(1);
        insert actlist;
        list<Contact> conlist = WFG_TestDataFactory.createContacts(1, actlist);
        insert conlist;
        Entitlement et = new Entitlement();
        et.AccountId = actlist[0].Id;
        et.Name = 'Enter';
        insert et;
        list<case> caselist = WFG_TestDataFactory.createCases(1, conlist);
        caselist[0].EntitlementId = et.Id;
        insert caselist;
        list<Id> caseIds = new list<Id>();
        caseIds.add(caselist[0].Id);
        WFG_MilestoneUtils.completeMilestone(caseIds,'Mile', system.now()+10);
        
    }
}