@isTest
private class InsuranceCaseToOpportunityTrigger_Test {
    private static boolean linkToOpp;
    
    static void init(){
    	WFG_TriggerActivation__c wfgTrig = new WFG_TriggerActivation__c();
        wfgTrig.Name = 'WFG_Account';
        insert wfgTrig;
        
        Contact c = new Contact(FirstName='Ben', LastName='Garrison', Phone='0001113333', Email='benGarrison@mail.com', RecordTypeId='012440000002PZ9AAM', MailingCountry = 'US', MailingCountryCode = 'US');
        insert c;
        
        Date d = Date.today();
        
        Opportunity o = new Opportunity(Name='Opp_BenGarrison');
        o.WFG_Contact__c = [SELECT Id FROM Contact WHERE FirstName='Ben' AND LastName='Garrison'].Id;
        o.StageName = 'Application';
        o.CloseDate = d.addDays(5);
        insert o;
        
        AgentOne__InsuranceCase__c i = new AgentOne__InsuranceCase__c(Name='InsCase_BenGarrison');
        //i.AgentOne__Is_e_App_Archived__c = false;
        i.AgentOne__Contact__c = [SELECT Id FROM Contact WHERE FirstName='Ben' AND LastName='Garrison'].Id;
        if(linkToOpp) { i.Opportunity__c = [SELECT Id FROM Opportunity WHERE Name='Opp_BenGarrison'].Id; }
        insert i;
        

    }
    
    /*WFGAGTONE-116 : Orphaned Case*/
	@isTest
    private static void orphanedCase_Test () {
        linkToOpp = false;
        init();
        
        AgentOne__InsuranceCase__c insCase = [SELECT Id, Opportunity__c FROM AgentOne__InsuranceCase__c WHERE Name='InsCase_BenGarrison'];
        insCase.Opportunity__c = [SELECT Id FROM Opportunity WHERE Name='Opp_BenGarrison'].Id;
        update insCase;
        
        AgentOne__InsuranceCase__c ins = [SELECT Id, AgentOne__Product_Type_Name__c FROM AgentOne__InsuranceCase__c WHERE Name='InsCase_BenGarrison'];
        Opportunity opp = [SELECT Id, WFG_Product_Type__c, Insurance_Case__c FROM Opportunity WHERE Name='Opp_BenGarrison'];
        System.assertEquals(opp.WFG_Product_Type__c, ins.AgentOne__Product_Type_Name__c);
        System.assertEquals(opp.Insurance_Case__c, ins.Id);
    }
    
    /*WFGAGTONE-106 : Update Opportunity Record*/
    @isTest
    private static void updateOpportunity_Test () {
        linkToOpp = true;
        init();
        
        AgentOne__InsuranceCase__c ins = [SELECT Id, AgentOne__Product_Type_Name__c FROM AgentOne__InsuranceCase__c WHERE Name='InsCase_BenGarrison'];
        Opportunity opp = [SELECT Id, WFG_Product_Type__c, Insurance_Case__c FROM Opportunity WHERE Name='Opp_BenGarrison'];
        System.assertEquals(opp.WFG_Product_Type__c, ins.AgentOne__Product_Type_Name__c);
    }
}