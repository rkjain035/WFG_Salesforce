/*
Property of Transamerica and Aegoncompanies.Do not distribute without permission.
* Copyright (c) [2018] Transamerica Corporation, its affiliates and their licensors.
* @author Rahul K Jain
* @date 17-09-2018
* @description  Batch class to update "ReportsTo" on Agent Contacts based on the upline code in their respective AgentCode 
	record
Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Rahul K Jain           M-001             17-09-2018              Batch class to update "ReportsTo" on Agent Contacts 
																 based on the upline code in their respective AgentCode record.
*/
global class WFG_AssignReportsToForAgents implements Database.Batchable<sObject> {
	
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
         String query = 'select WFG_Contact__c,WFG_UplineCode__r.WFG_Contact__c from WFG_AgentCode__c'+
            +' where WFG_PrimaryCode__c = true and WFG_UplineCode__r.WFG_PrimaryCode__c = true'+
            +' and WFG_Contact__r.recordType.Name = \'Agent\' and WFG_UplineCode__r.WFG_Contact__r.recordType.Name = \'Agent\' and WFG_Contact__r.ReportsToId = Null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<WFG_AgentCode__c> scope)
    {
        try
		{
            LIST<Contact> listAgentContacts = new LIST<Contact>();
        
            for(WFG_AgentCode__c agc : scope)
            {
               Contact c = new Contact(id = agc.WFG_Contact__c);
                
                     c.ReportsToId = agc.WFG_UplineCode__r.WFG_Contact__c;
               
               listAgentContacts.add(c);
            }
            update listAgentContacts;
        }catch(Exception e){system.debug('Exception in WFG_AssignReportsToForAgents Batch--' + e);LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_AssignReportsToForAgents', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);}
        
    }
    global void finish(Database.BatchableContext bc)
    {
        
    } 
}