global class WFG_CreateAgentCodesForContacts implements Database.Batchable<SObject>, Database.stateful {
	
    public Integer count = 0;
    
	global Database.QueryLocator start(Database.BatchableContext BC)
    {
		string query = 'select id,WFG_AgentCode__c from Contact where recordType.Name = \'Agent\' ';
            //string query = 'select id, WFG_AgentCode__c from';
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<Contact> scope)
    {

        list<WFG_AgentCode__c> agentList = new list<WFG_AgentCode__c>();
		for(Contact con : scope)
		{
			WFG_AgentCode__c agentCode = new WFG_AgentCode__c();
			agentCode.WFG_AgentCode__c = con.WFG_AgentCode__c;
			agentCode.WFG_Contact__c = con.Id;
			agentCode.Name = con.WFG_AgentCode__c;
            agentCode.WFG_PrimaryCode__c = true;
            //agentCode.Random_Number__c = count++;
			agentList.add(agentCode);
		}
		insert agentList; 
	}
	
	global void finish(Database.BatchableContext BC){
	}
}