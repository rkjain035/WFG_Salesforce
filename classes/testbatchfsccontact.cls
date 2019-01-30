global class testbatchfsccontact implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query = 'Select id,Name from WFG_AgentCode__c where WFG_PrimaryCode__c = true';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<WFG_AgentCode__c> lstAgentcode)
    {
        system.debug('---Main Method----' + lstAgentcode.size());
        for(WFG_AgentCode__c agentCode : lstAgentcode){
            
            fetchParentRecord(agentCode.Id);
            
        }
        /*set<Id> setAccountIds = new set<Id>();
        for(Account acct : scope){
            setAccountIds.add(acct.Id);
        }
        
        list<AccountShare> lstAcctShare = [select id from accountShare where accountId IN: setAccountIds AND userOrGroup.ProfileId != NULL];
        
        database.delete(lstAcctShare, false);*/
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    
    }
    
    public id accId{get;set;}
 
    public void fetchParentRecord(Id agentId)
	{
        List<WFG_AgentCode__c> lstAgentcode = [SELECT id,Name,	WFG_UplineCode__c 
                                               from WFG_AgentCode__c
                                               where WFG_UplineCode__c = : agentId ];
        system.debug('---inside method----' + lstAgentcode.size());
        if(!lstAgentcode.isEmpty()){
            for(WFG_AgentCode__c agentCode : lstAgentcode){
                
                fetchParentRecord(agentCode.id);
                
            }
        }
       //ist<Account> lstAccount = [SELECT ParentId, parent.name, Id 
        //                            FROM Account WHERE Id =: accId];
        //(!lstAccount.isEmpty())
       //
           //dList.add(lstAccount[0].parent.name);
            //stem.debug('######'+idList);
           // fetchParentRecord(lstAccount[0].parentId);
        //}
	}
}