public class UpdateContactFieldInsuranceCase {
	@future
    public static void updateContactField(Set<Id> orphanedInsCaseIds, Set<Id> opporunityIds) {
        System.debug('*****BEGIN UpdateContactFieldInsuranceCase*****');
        List<AgentOne__InsuranceCase__c> insCases = [SELECT Id, Opportunity__c, AgentOne__Contact__c, AgentOne__PrimaryInsured_Name__c FROM AgentOne__InsuranceCase__c WHERE Id in :orphanedInsCaseIds];
        List<Opportunity> opps = [SELECT Id, WFG_Contact__c FROM Opportunity WHERE Id in :opporunityIds];
        
        Set<Id> contactIds = new Set<Id>();
        for(Opportunity opp1 : opps) {
        	contactIds.add(opp1.WFG_Contact__c);    
        }
        List<Contact> contacts = [SELECT Id, Name, OwnerId FROM Contact WHERE Id in :contactIds];
        
        for(AgentOne__InsuranceCase__c insCase : insCases) {
            for(Opportunity opp2 : opps) {
                if(insCase.Opportunity__c == opp2.Id) {
                 	insCase.AgentOne__Contact__c = opp2.WFG_Contact__c;
                    for(Contact contact : contacts){
                        if (opp2.WFG_Contact__c == contact.Id){
                         	insCase.AgentOne__PrimaryInsured_Name__c = contact.Name;
                        }
                    }
                    break;
                }
            }
        }
        update insCases; 
    }
}