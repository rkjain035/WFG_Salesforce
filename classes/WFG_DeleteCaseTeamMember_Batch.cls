/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Saravanan
* @date 28-MAR-2018
* @description - Deletes all the existing caseTeammember

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------

*/

global class WFG_DeleteCaseTeamMember_Batch implements Database.Batchable<Sobject>{
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query = 'Select Id from caseTeamMember';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Case> scope)
    {  
        delete scope;
    }
    global void finish(Database.BatchableContext bc)
    {
        
    }
}