/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Rashmi
* @date 9/19/2018
* @description - This batch class contains logic to update agent one related fields for all the active non canadian Agents and also to assign required permission set

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Rashmi               Mod-01             9/19/2018                UserStoryNo - W-027773
*/
public class WFG_BatchUpdateUsers implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query;
        string strCAN= '%CAN';
        string strRRAgents= 'Registered Reps';
        string strLLAgents= 'Life License Agents';
        string strHomeOffice = 'Home Office';
        if(!test.isRunningtest())
            query = 'Select Id, FederationIdentifier, Initial_DisconnectedPassword__c , isActive,AgentOne__SubCompany_Identifier__c , Initial_DisconnectedUserID__c ,profile.name,AgentOne__IsAgentOne__c, AgentOne__Agent_Number__c, AgentOne__Agency_Number__c , AgentOne__iPipeline_User_Id__c,IPL_PS_AGENT_Last_SSN__c  from User where (UserRole.Name = \''+ strRRAgents +'\'  OR UserRole.Name = \''+ strLLAgents +'\' OR Profile.name like \''+strHomeOffice+'\') AND (NOT Profile.name like \''+ strCAN +'\' ) AND isActive = true';
        else
            query = 'Select Id, FederationIdentifier, Initial_DisconnectedPassword__c , isActive,AgentOne__SubCompany_Identifier__c , Initial_DisconnectedUserID__c ,profile.name,AgentOne__IsAgentOne__c, AgentOne__Agent_Number__c, AgentOne__Agency_Number__c , AgentOne__iPipeline_User_Id__c,IPL_PS_AGENT_Last_SSN__c from User where FederationIdentifier = \'ARC1233\' OR FederationIdentifier  = \'ARC1223\'';
        return Database.getQueryLocator(query);
        
    }
    public void execute(Database.BatchableContext bc, List<User> listAgentUsers){
        
        system.debug('===listAgentUsers=='+listAgentUsers);
        set<Id> setUserId = new set<id>();
        map<string, user> mapFedIdtoUser = new map<string, user>();
        map<string, Contact> mapFedIdtoContact = new map<string, Contact>();
        list<user> lstUsertoUdpate = new list<User>();
        
        for(User objUser : listAgentUsers){
            system.debug('===objUser.FederationIdentifier==='+objUser.FederationIdentifier);
            mapFedIdtoUser.put(objUser.FederationIdentifier,objUser);
            setUserId.add(objUser.Id);
        }

        for(Contact objCon : [Select id, Name,WFG_Status__c, Account.WFG_BranchCode__c,WFG_SSNSIN__c,WFG_FederationId__c,
                            WFG_AgentCode__c from Contact Where WFG_FederationId__c IN: mapFedIdtoUser.keyset()]){
            mapFedIdtoContact.put(objCon.WFG_FederationId__c, objCon);
        }

        
        for(User objUser : listAgentUsers){
            
            system.debug('===objUser===='+objUser);
            system.debug('===mapFedIdtoContact.get(objUser.FederationIdentifier)===='+mapFedIdtoContact.get(objUser.FederationIdentifier));
            if(mapFedIdtoContact.get(objUser.FederationIdentifier) != null){
                objUser.AgentOne__IsAgentOne__c = TRUE;
                objUser.AgentOne__Agent_Number__c  = mapFedIdtoContact.get(objUser.FederationIdentifier).WFG_AgentCode__c;
                objUser.AgentOne__iPipeline_User_Id__c   = mapFedIdtoContact.get(objUser.FederationIdentifier).WFG_AgentCode__c;
                ObjUser.IPL_PS_AGENT_Last_SSN__c = mapFedIdtoContact.get(objUser.FederationIdentifier).WFG_SSNSIN__c;
                
                if(objUser.profile.name.contains('TAN')){
                    
                    ObjUser.AgentOne__Agency_Number__c = mapFedIdtoContact.get(objUser.FederationIdentifier).Account.WFG_BranchCode__c;
                    ObjUser.AgentOne__SubCompany_Identifier__c = '5507';
                    ObjUser.Initial_DisconnectedUserID__c = mapFedIdtoContact.get(objUser.FederationIdentifier).WFG_AgentCode__c + 'MON5507';
                    ObjUser.Initial_DisconnectedPassword__c = mapFedIdtoContact.get(objUser.FederationIdentifier).WFG_AgentCode__c + 'MON5507';
                }
                else{
                    
                    ObjUser.AgentOne__Agency_Number__c = '5725';  
                    ObjUser.AgentOne__SubCompany_Identifier__c = '';
                    ObjUser.Initial_DisconnectedUserID__c = '';
                    ObjUser.Initial_DisconnectedPassword__c = '';
                }
                lstUsertoUdpate.add(ObjUser);
            }
        }

        if(!lstUsertoUdpate.isEmpty())
            update lstUsertoUdpate;
        
    }    
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}