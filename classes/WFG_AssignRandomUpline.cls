global class WFG_AssignRandomUpline implements Database.Batchable<sObject>, Database.Stateful {
    
    integer count = 10;
    integer level = 0;
    public String operation = null;
    
    public WFG_AssignRandomUpline(String operation, integer level)
    {
        this.operation = operation;
        this.level = level;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        string query = null;
        
        if(operation.equalsIgnoreCase('Assign'))
        {
            query = 'select id, Random_Number__c, WFG_UplineCode__c from WFG_AgentCode__c where WFG_UplineCode__c = null'+ 
                +' order by Random_Number__c asc';
        }
        else if(operation.equalsIgnoreCase('Remove'))
        {
            query = 'select id, WFG_UplineCode__c from WFG_AgentCode__c';
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<WFG_AgentCode__c> scope)
    {
        list<WFG_AgentCode__c> agentList = new list<WFG_AgentCode__c>();
        if(operation.equalsIgnoreCase('Remove'))
        {
            for(WFG_AgentCode__c con : scope)
            {
                con.WFG_UplineCode__c = null;
                agentList.add(con);
            }
            update agentList;
        }
        else if(operation.equalsIgnoreCase('Assign'))
        {
            list<WFG_AgentCode__c> agentRecords = [select id, Random_Number__c, WFG_UplineCode__c 
                                                   from WFG_AgentCode__c 
                                                   where WFG_UplineCode__c = null and Random_Number__c > 10
                                                   order by Random_Number__c asc limit 200];
            
            for(WFG_AgentCode__c con : agentRecords)
            {
                Integer rand = Math.round(Math.random()*count);
                rand = 10 + rand;
                //if(rand == 0)
                	//rand = 1 + rand;
                
                if(rand == con.Random_Number__c)
                {
                    
                    rand = Math.round(Math.random()*count);
                    rand = 10 + rand;
                    //if(rand == 0)
                    	//rand = 1 + rand;
                    
                    while(rand == con.Random_Number__c) 
                    {
                        rand = Math.round(Math.random()*count);
                        rand = 10 + rand;
                        //if(rand == 0)
                        	//rand = 1 + rand;
                    }
                    WFG_AgentCode__c agentCode = new WFG_AgentCode__c();
                    agentCode.Id = con.Id;
                    agentCode.WFG_UplineCode__r = new WFG_AgentCode__c(Random_Number__c = rand);
                    agentList.add(agentCode);
                    
                }
                else{
                    WFG_AgentCode__c agentCode = new WFG_AgentCode__c();
                    agentCode.Id = con.Id;
                    agentCode.WFG_UplineCode__r = new WFG_AgentCode__c(Random_Number__c = rand);
                    agentList.add(agentCode);
                }
                System.debug('rand....'+rand);
            }
            update agentList;
            count = count + level;
        }
    }
    global void finish(Database.BatchableContext BC)
    {
    }
}