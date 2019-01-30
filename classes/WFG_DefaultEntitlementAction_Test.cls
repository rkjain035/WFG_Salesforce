@isTest
public class WFG_DefaultEntitlementAction_Test {

    public static testMethod void testingMethod(){
        List<WFG_TriggerActivation__c > lstTriggerActivation = new List<WFG_TriggerActivation__c>();
        WFG_TriggerActivation__c AccountTriggerActivation = new WFG_TriggerActivation__c(); 
        AccountTriggerActivation.Name = 'WFG_Account'; 
        AccountTriggerActivation.WFG_isActive__c = true; 
        lstTriggerActivation.add(AccountTriggerActivation );
        insert lstTriggerActivation;
        list<Account> lstAccount = WFG_TestDataFactory.createAccounts(1);  
        insert lstAccount;
        list<Contact> lstContact = WFG_TestDataFactory.createContacts(1,lstAccount);
        lstContact[0].WFG_AgentLevel__c = 71;
        insert lstContact;
        Entitlement et = WFG_TestDataFactory.Entitlement(lstAccount[0].Id);
        insert et;
        list<Case> lstCase = WFG_TestDataFactory.createCases(1, lstContact);
        lstCase[0].EntitlementId = et.Id;
        insert lstCase;
        WFG_DefaultEntitlementAction.updateDefaultEntitlements(lstCase);
    }
}