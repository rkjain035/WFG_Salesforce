public class OpportunityInsuranceService {

    @AuraEnabled
    public static AgentOne__InsuranceCase__c setupInsuranceOpportunity(String recordId, String accountId, String oppName, String productType) {           
        String toolName = 'igo.eapp';

        Contact c = [SELECT id, name FROM contact WHERE accountId = :accountId LIMIT 1]; 
        //Contact c = [SELECT Id, Name FROM Contact WHERE AccountId = :accountId LIMIT 1];
        
        AgentOne__InsuranceCase__c ic = new AgentOne__InsuranceCase__c();
        ic.AgentOne__Contact__c = c.id;
        ic.AgentOne__Application_Tool__c = toolname;
        ic.name = oppName;
        ic.AgentOne__Product_Type_Name__c = productType;
        ic.Opportunity__c = recordId;
        insert ic;
        
            
        // need to update the Opportunity with the insurance case
        Opportunity o = new Opportunity();
        o.Id = recordId;
        o.Insurance_Case__c = ic.Id;        
        update o;
                
        return ic;
    }
}