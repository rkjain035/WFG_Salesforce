global class WFG_KeepUsersWhoHaveActiveContacts implements Database.Batchable<SObject> 
{
	global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query = 'select id, WFG_Agent_Code__c, FederationIdentifier, username, CommunityNickname from User where isActive = true'+
            +' and (Profile.Name like \'RR%\' or Profile.Name like \'LL%\' or Profile.Name like \'FA%\' '+
            +' or Profile.Name like \'IAR%\' or Profile.Name like \'MF%\')';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, list<User> scope)
    {
        Set<String> agentCodes = new Set<String>();
        LIST<Contact> contactsHavingUser = new LIST<Contact>();
        
        for(User u : scope)
        {
            agentCodes.add(u.WFG_Agent_Code__c); 
        }
        contactsHavingUser = [select id, WFG_AgentCode__c from Contact where WFG_AgentCode__c in :agentCodes];
        String description = '';
        for(Contact c : contactsHavingUser)
        {
            agentCodes.remove(c.WFG_AgentCode__c);
        }
        String strAppend = 'FSC';
        LIST<User> usersToUpdate = new LIST<user>();
        for(User u : scope)
        {
            if(agentCodes.contains(u.WFG_Agent_Code__c))
            {
                u.isActive = false;
                u.FederationIdentifier = u.FederationIdentifier + strAppend;
            	u.username = u.username + strAppend ;
            	u.CommunityNickname = u.CommunityNickname + strAppend;
            	u.WFG_Agent_Code__c = u.WFG_Agent_Code__c + strAppend;
                usersToUpdate.add(u);
            }
        }
        update usersToUpdate;
    }
    global void finish(Database.BatchableContext bc)
    {
        
    }
}