global class WFG_AssignRandomNumbers implements Database.Batchable<SObject>, Database.stateful {
	
    public Integer count = 1;
    
	global Database.QueryLocator start(Database.BatchableContext BC)
    {
		string query = 'select id,Random_Number__c from WFG_AgentCode__c where Random_Number__c != null ';
            
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<WFG_AgentCode__c> scope)
    {
        list<WFG_AgentCode__c> agentList = new list<WFG_AgentCode__c>();
		for(WFG_AgentCode__c agentCode : scope)
		{
            agentCode.Random_Number__c = count++;
			agentList.add(agentCode);
		}
		upsert agentList; 
	}
	
	global void finish(Database.BatchableContext BC){
	}
}