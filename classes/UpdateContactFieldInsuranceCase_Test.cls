@isTest
private class UpdateContactFieldInsuranceCase_Test {
	@isTest
    private static void updateContactField_Test () {     
        WFG_TriggerActivation__c wfgTrig = new WFG_TriggerActivation__c();
        wfgTrig.Name = 'WFG_Account';
        insert wfgTrig;
        
        Contact contact1 = new Contact(FirstName='Pete', LastName='Granderson', Phone='1112223333', Email='pete@mail.com', RecordTypeId='012440000002PZ9AAM', MailingCountry = 'US', MailingCountryCode = 'US');
        insert contact1;
        
        Contact contact2 = new Contact(FirstName='Brian', LastName='Barnes', Phone='9998887777', Email='brian@mail.com', RecordTypeId='012440000002PZ9AAM', MailingCountry = 'US', MailingCountryCode = 'US');
        insert contact2;
        
        Date d = Date.today();
        
        Opportunity opp1 = new Opportunity(Name='PeterGranderson_Opp');
        opp1.StageName = 'Application';
        opp1.WFG_Contact__c = [SELECT Id From Contact WHERE FirstName='Brian' AND LastName='Barnes'].Id;
        opp1.CloseDate = d.addDays(5); 
        insert opp1;
        
        AgentOne__InsuranceCase__c insCase1 = new AgentOne__InsuranceCase__c(Name='PeterGranderson_InsCase');
        insCase1.AgentOne__Contact__c = [SELECT Id From Contact WHERE FirstName='Pete' AND LastName='Granderson'].Id;
        insCase1.Opportunity__c	= [SELECT Id FROM Opportunity WHERE Name='PeterGranderson_Opp'].Id;
        insert insCase1;
        
        Set<Id> orphanedInsCaseIds = new Set<Id>(); 
        orphanedInsCaseIds.add([SELECT Id From AgentOne__InsuranceCase__c WHERE Name='PeterGranderson_InsCase'].Id);

        Set<Id> opporunityIds = new Set<Id>();
        opporunityIds.add([SELECT Id FROM Opportunity WHERE Name='PeterGranderson_Opp'].Id);
        
        Test.startTest();
        UpdateContactFieldInsuranceCase.updateContactField(orphanedInsCaseIds, opporunityIds);
        Test.stopTest();
        
        AgentOne__InsuranceCase__c insCase2 = [SELECT Id, AgentOne__Contact__c FROM AgentOne__InsuranceCase__c WHERE Name='PeterGranderson_InsCase'];
        Opportunity opp2 = [SELECT Id, WFG_Contact__c FROM Opportunity WHERE Name='PeterGranderson_Opp'];
        System.assertEquals(insCase2.AgentOne__Contact__c, opp2.WFG_Contact__c);
    }
}