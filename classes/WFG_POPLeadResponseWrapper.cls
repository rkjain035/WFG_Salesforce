public with sharing class WFG_POPLeadResponseWrapper {
	
	@AuraEnabled
	public WFG_ComponentResponseWrapper objGenericRes = new WFG_ComponentResponseWrapper();
	
    @AuraEnabled
    public Lead objLead;
    
}