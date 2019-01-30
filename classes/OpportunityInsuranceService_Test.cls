@isTest
private class OpportunityInsuranceService_Test {
	@isTest
    private static void setupInsuranceOpportunity_Test() {
        WFG_TriggerActivation__c wfgTrig = new WFG_TriggerActivation__c();
        wfgTrig.Name = 'WFG_Account';
        insert wfgTrig;
        
        Contact contact1 = new Contact();
        contact1.FirstName = 'Joseph';
        contact1.LastName = 'Parker';
        contact1.Phone = '6104895555';
        contact1.RecordTypeId = [SELECT Id, SobjectType, Name, DeveloperName, IsActive
                 				FROM RecordType
                				WHERE SobjectType='Contact'
                      			AND DeveloperName='IndustriesIndividual'
                				LIMIT 1].Id;       
        contact1.Email = 'joeParker@mail.com';
        contact1.RecordTypeId = '012440000002PZ9AAM';
        contact1.MailingCountry = 'US';
        contact1.MailingCountryCode = 'US';
        insert contact1;
        
        Date d = Date.today();
                
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Joseph_Parker_Opp';
        opp1.StageName = 'Application';
        opp1.WFG_Contact__c = [SELECT Id FROM Contact WHERE FirstName='Joseph' AND LastName='Parker'].Id;
        opp1.CloseDate = d.addDays(5); 
        insert opp1;
        
        Contact contact2;
        contact2 = [SELECT Id, AccountId FROM Contact WHERE FirstName='Joseph' AND LastName='Parker'];
        
        Opportunity opp2;
        opp2 = [SELECT Id, Name FROM Opportunity WHERE Name='Joseph_Parker_Opp'];
        
        System.assertEquals(contact2.Id, OpportunityInsuranceService.setupInsuranceOpportunity(opp2.Id, contact2.AccountId, opp2.Name, 'Term Life').AgentOne__Contact__c);
        System.assertEquals('igo.eapp', OpportunityInsuranceService.setupInsuranceOpportunity(opp2.Id, contact2.AccountId, opp2.Name, 'Term Life').AgentOne__Application_Tool__c);
        System.assertEquals(opp2.Name, OpportunityInsuranceService.setupInsuranceOpportunity(opp2.Id, contact2.AccountId, opp2.Name, 'Term Life').Name);
        //System.assertEquals(opp2.WFG_Product_Type__c, OpportunityInsuranceService.setupInsuranceOpportunity(opp2.AccountId, contact2.Id, opp2.Name, 'Term Life').AgentOne__Product_Type_Name__c);
    	System.assertEquals(opp2.Id, OpportunityInsuranceService.setupInsuranceOpportunity(opp2.Id, contact2.AccountId, opp2.Name, 'Term Life').Opportunity__c);
    }
}