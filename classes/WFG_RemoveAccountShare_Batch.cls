/*
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Saravanan Haldurai
* @date 07-Jan-2018
* @description - Batch class that fetch the account Share to User and remove the share.

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Saravanan             MOD 1             11/15/2018               Update the start query with the Account share instead of fetching Acount.
*/
global class WFG_RemoveAccountShare_Batch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        string query = 'select id from accountShare where userOrGroup.ProfileId != NULL AND account.RecordType.Name = \'Branch Office\'';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<accountShare> scope)
    {
        database.delete(scope, false);
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
    
}