global class WFG_DeleteExistingAgentCodes implements Database.Batchable<SObject> {
	global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query = 'select id from WFG_AgentCode__c';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, list<WFG_AgentCode__c> scope)
    {
        delete scope;      
    }
    global void finish(Database.BatchableContext bc)
    {
        
    }
}