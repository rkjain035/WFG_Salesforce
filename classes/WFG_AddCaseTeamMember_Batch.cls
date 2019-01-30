global class WFG_AddCaseTeamMember_Batch implements Database.Batchable<Sobject>{
    
    private Integer limitQuery;
    public WFG_AddCaseTeamMember_Batch(Integer limitQuery)
    {
        this.limitQuery = limitQuery;
    }
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        
        
     
        
        String query;
        if(limitQuery > 0){
            query = 'Select Id, WFG_InteractingAbout__r.WFG_AgentCode__c, Contact.WFG_AgentCode__c from Case '+ 
            'where WFG_InteractingAbout__r.WFG_AgentCode__c != null or Contact.WFG_AgentCode__c != null order by createdDate desc limit '+limitQuery;
            
        }else{
            query = 'Select Id, WFG_InteractingAbout__r.WFG_AgentCode__c, Contact.WFG_AgentCode__c from Case '+ 
            'where WFG_InteractingAbout__r.WFG_AgentCode__c != null or Contact.WFG_AgentCode__c != null order by createdDate desc';
        }
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Case> scope)
    {  
        Map<String, List<Id>> dummyMap = new Map<String, List<Id>>();
        Set<String> AgentCodes = new Set<String>();
        for(Case c : scope)
        {
            if(c.WFG_InteractingAbout__r.WFG_AgentCode__c != null)
            {
                LIST<Id> caseIds = new LIST<Id>();
                if(!AgentCodes.contains(c.WFG_InteractingAbout__r.WFG_AgentCode__c))
                { 
                    caseIds.add(c.Id);
                    AgentCodes.add(c.WFG_InteractingAbout__r.WFG_AgentCode__c);
                    dummyMap.put(c.WFG_InteractingAbout__r.WFG_AgentCode__c, caseIds);
                }
                else{
                    caseIds = dummyMap.get(c.WFG_InteractingAbout__r.WFG_AgentCode__c);
                    caseIds.add(c.Id);
                    dummyMap.put(c.WFG_InteractingAbout__r.WFG_AgentCode__c, caseIds);
                }
            }
            if( c.Contact.WFG_AgentCode__c != null && (c.Contact.WFG_AgentCode__c != c.WFG_InteractingAbout__r.WFG_AgentCode__c) )
            {
                LIST<Id> caseIds = new LIST<Id>();
                if(!AgentCodes.contains(c.Contact.WFG_AgentCode__c))
                {   
                    caseIds.add(c.Id);
                    AgentCodes.add(c.Contact.WFG_AgentCode__c);
                    dummyMap.put(c.Contact.WFG_AgentCode__c, caseIds);
                }
                else{ 
                    caseIds = dummyMap.get(c.Contact.WFG_AgentCode__c);
                    caseIds.add(c.Id);
                    dummyMap.put(c.Contact.WFG_AgentCode__c, caseIds);
                }
            }
        }
        
        LIST<User> userList = [select id, WFG_Agent_Code__c 
                               from 
                               User 
                               where WFG_Agent_Code__c =: dummyMap.keySet() and isActive = true];
        
        Id teamRoleId = [select id from CaseTeamRole where Name =: SYSTEM.LABEL.WFG_CaseTeamRoleName].Id;
        LIST<CaseTeamMember> caseTeam = new LIST<CaseTeamMember>();
        for(User u : userList)
        {
            LIST<Id> parentIds = new LIST<Id>();
            parentIds = dummyMap.get(u.WFG_Agent_Code__c);
            for(Id parentId : parentIds)
            {
                CaseTeamMember ctm = new CaseTeamMember();
                ctm.ParentId = parentId;
                ctm.MemberId = u.Id;
                ctm.TeamRoleId = teamRoleId;
                caseTeam.add(ctm);
            }
            
        }
       Database.insert(caseTeam,false);
    }
    global void finish(Database.BatchableContext bc)
    {
        
    }
    
}