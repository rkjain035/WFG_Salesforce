/*
Property of Transamerica and Aegoncompanies.Do not distribute without permission.
* Copyright (c) [2018] Transamerica Corporation, its affiliates and their licensors.
* @author Rahul K Jain
* @date 17-09-2018
* @description   Batch class to rollback "ReportsTo" on Agent Contacts.
	record
Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Rahul K Jain           M-001             17-09-2018              Batch class to rollback "ReportsTo" on Agent Contacts.
*/
global class WFG_Rollback_ReportsToContact implements Database.Batchable<SObject> {
	
    global Database.QueryLocator start(Database.BatchableContext bc)
    { 
        String query = 'select id from Contact where recordType.Name = \'Agent\' and reportsToId != null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> scope)
    {
        try{
            list<Contact> listRollBackContacts = new LIST<Contact>();
            for(Contact c : scope)
            {
                c.ReportsToId = null;
                listRollBackContacts.add(c);
            }
            update listRollBackContacts;
        }catch(Exception e){system.debug('Exception in Roll Back Reports to Batch--' + e);LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_Rollback_ReportsToContact', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);}
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
}