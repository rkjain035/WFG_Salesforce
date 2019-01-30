public class testdummyapexfsccontact {
    
   public static integer size=0;

    public static void matchCode(){
       // Integer size = 0;
        string agentId = 'a0w2F000000GIM2';
        List<WFG_AgentCode__c> lstAgentcode = [SELECT id,Name,	WFG_UplineCode__c 
                                               from WFG_AgentCode__c
                                               where id = : agentId ];
            system.debug('---Main Method----' + lstAgentcode.size());
            if(!lstAgentcode.isEmpty()){
                for(WFG_AgentCode__c agentCode : lstAgentcode){
                   size = size + 1;  
                	system.debug('---Main Method Name----' + agentCode.Name);
                    if(agentCode.Id != null){
                        fetchParentRecord(agentCode.Id);
                	}
        		}
         	}
         system.debug('---Size ----' + size);
	}	
     public static void fetchParentRecord(Id agentId)
	{
            for(WFG_AgentCode__c agentCode : [SELECT id,Name,	WFG_UplineCode__c 
                                               from WFG_AgentCode__c
                                               where WFG_UplineCode__c = : agentId] ){
               size = size + 1;                      
                if(agentCode.Id != null){
                     system.debug('---Inside Method Name ----' + agentCode.Name);
                        fetchParentRecord(agentCode.Id);
                }    
            }
	}

}