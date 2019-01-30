/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Deepthi
* @date 13-03-2018
* @description - This batch class contains logic to deactivate existing LL/MF users in the application and 
                 create new user records with profiles(FSC).

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Deepthi               Mod-01             27-03-2018              UserStoryNo - W025901
*/
global class WFG_CaseTeamMemberDeleteAll implements Database.Batchable<SObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query = 'select id from CaseTeamMember';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope)
    {    
        Database.delete(scope, false);
    }
    global void finish(Database.BatchableContext bc)
    {
        
    }
    
}