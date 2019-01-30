/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Karthik Raj
* @date 10-17-2018 
* @description - Test class for WFG_ContactHierarchyManualSharing,WFG_Rollback_ManualSharing.

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Rahul K Jain            Mod-01          10-25-2018            Rollback all the manual share on Agent Contacts
*/

global class WFG_Rollback_ManualSharing  implements Database.Batchable<SObject>{
	
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query = 'select id from ContactShare where rowCause = \'Manual\' ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, list<ContactShare> scope)
    {
        
        try { 
            Delete scope;
        }catch(Exception e){system.debug('Exception in Roll Back Contact Share Batch--' + e);LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_Rollback_ManualSharing', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);}
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
    
}