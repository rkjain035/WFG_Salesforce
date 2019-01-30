global class WFG_CaseTeamMemberUpdate  implements Database.Batchable<SObject>{
	
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        string query = 'select id, WFG_InteractingAbout__r.WFG_AgentCode__c, Contact.WFG_AgentCode__c from case limit 10';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Case> scope)
    {
        Set<Id> caseIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Set<String> caseIdExistingMemberId = new Set<String>();
        Set<String> caseIdUserId = new Set<String>();
        for(Case c : scope)
        {
            caseIds.add(c.Id);
            contactIds.add(c.WFG_InteractingAbout__c);
            contactIds.add(c.ContactId);
        }
        
        //System.debug('case id...'+caseIds);
        LIST<CaseTeamMember> ctm = [select id, memberId , parentId from CaseTeamMember where parentId =: caseIds];
        for(CaseTeamMember caseTeam : ctm)
        {
            String caseIdExistingMemberIdString = caseTeam.parentId+';'+caseTeam.memberId;
            caseIdExistingMemberId.add(caseIdExistingMemberIdString);
        }
        System.debug('caseIdExistingMemberId...'+caseIdExistingMemberId);
        
        
        
        
        map<string, contact> mapAgentContact = new map<string, contact>();
        
        if(contactIds.size() > 0)
        {
            for(Contact con : [select id, WFG_AgentCode__c from contact where Id IN: contactIds])
                mapAgentContact.put(con.WFG_AgentCode__c, con);
        }
        //System.debug('mapAgentContact....'+mapAgentContact);
        Map<Id, Id> mapContactIdUserId = new Map<Id, Id>();
        if(mapAgentContact.size () > 0){
            for(user usr : [select id, WFG_Agent_Code__c from User where WFG_Agent_Code__c IN: mapAgentContact.keyset()]){
                mapContactIdUserId.put(mapAgentContact.get(usr.WFG_Agent_Code__c).Id, usr.Id);
            }
        }
        //System.debug('mapContactIdUserId...'+mapContactIdUserId);
        for(case c: scope)
        {
            caseIdUserId.add(c.Id+';'+mapContactIdUserId.get(c.ContactId));
            caseIdUserId.add(c.Id+';'+mapContactIdUserId.get(c.WFG_InteractingAbout__c));
        }
        System.debug('caseIdUserId...'+caseIdUserId);
    }
    global void finish(Database.BatchableContext bc)
    {
        
    }
}