/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author N/A
* @date N/A
* @description - N/A

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Saravanan             Mod-01             24-OCT-2018             Delete and recreate caseteammember for users that got activated today                                                      
*/ 
global class WFG_RecreateCaseTeamMemberBatch implements Database.Batchable<Sobject>{
    
    public string query;
    public set<id> setUserIds;
    
    public WFG_RecreateCaseTeamMemberBatch(set<Id> setUserId)
    {
        setUserIds = new set<id>();
        setUserIds = setUserId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        query = 'select id, WFG_Inactivated_Date__c, WFG_Agent_Code__c from user where Id IN: setUserIds';
        if(test.isrunningtest())
            query = query + ' LIMIT 20';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<User> scope)
    {   
        updateCaseTeam(scope);
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
    
    public static void updateCaseTeam(list<user> lstUser)
    {
        map<String, user> mapAgentInfo = new map<String, user>();
        CaseTeamRole ctr = [select id from CaseTeamRole where Name =: SYSTEM.LABEL.WFG_CaseTeamRoleName limit 1];
        List<CaseTeamMember> lstCaseTeamMember = new List<CaseTeamMember>();
        
        delete [select id from caseTeamMember where MemberId IN: lstUser];
        
        for(user usr : lstUser){
            mapAgentInfo.put(usr.WFG_Agent_Code__c, usr);
        }
        
        
        for(case newCase : [select id, WFG_InteractingAbout__r.WFG_AgentCode__c, Contact.WFG_AgentCode__c 
                            from case 
                            where WFG_InteractingAbout__r.WFG_AgentCode__c IN: mapAgentInfo.keyset() 
                            OR Contact.WFG_AgentCode__c IN: mapAgentInfo.keyset()])
        {
            String interactingAbout = newCase.WFG_InteractingAbout__r.WFG_AgentCode__c;
            String onBehalfOf = newCase.Contact.WFG_AgentCode__c;
            
            if(mapAgentInfo.containsKey(interactingAbout))
            {
                CaseTeamMember ctm = createCaseTeam(mapAgentInfo.get(interactingAbout).Id,newCase.Id,ctr.Id);
                lstCaseTeamMember.add(ctm);
            }
            if(mapAgentInfo.containsKey(onBehalfOf) && (interactingAbout != onBehalfOf))
            {
                CaseTeamMember ctm = createCaseTeam(mapAgentInfo.get(onBehalfOf).Id,newCase.Id,ctr.Id);
                lstCaseTeamMember.add(ctm);
            }
        }
        try{
            insert lstCaseTeamMember;
        } catch(Exception e) {
            system.debug('+++ Execption ++' + e);
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_RecreateCaseTeamMemberBatch', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }
    }
    
    public static caseTeamMember createCaseTeam(Id userId, id CaseId, id RoleId)
    {
        caseTeamMember ctm = new caseTeamMember();
        ctm.memberId = UserId;
        ctm.parentId = CaseId;
        ctm.TeamRoleId = RoleId;
        
        return ctm;
    }
    
}