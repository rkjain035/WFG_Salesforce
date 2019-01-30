/*
Property of Transamerica and Aegoncompanies.Do not distribute without permission.
* Copyright (c) [2018] Transamerica Corporation, its affiliates and their licensors.
* @author Karthik Raj  
* @date 10-24-2018
* @description  Batch class to create Contact Hierarchy in FSC by a Manual Sharing when User record made Active.
Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Karthik Raj            M-001             10-24-2018               Batch class to create Contact Hierarchy in FSC by a Manual Sharing 
                                                                  when the User record to becomes Active.
*/
global class WFG_CH_UserActiveBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    private DateTime startDate;
    private Set<Id> setUserId = new Set<Id>();
    private Set<Id> contactIdParam = new Set<Id>();
    private Map<String,Id> mapAgentCodeUserId = new Map<String,Id>();
    
    public WFG_CH_UserActiveBatch(Map<String,Id> mapAgentCodeUserIdParam) {
        
        mapAgentCodeUserId.putAll(mapAgentCodeUserIdParam);
        setUserId.addAll(mapAgentCodeUserId.values());
        //Gives the contact's of all the user's who were de-activated.
        Map<Id,Contact> mapContact = new Map<Id,Contact>([select  id 
                                                          from Contact 
                                                          where WFG_AgentCode__c in :mapAgentCodeUserId.keyset()]);
        contactIdParam = mapContact.keySet();
        system.debug('Contact Id in Constructor for User Active Batch -----' + contactIdParam);
        startDate = system.now();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query = 'select Id,WFG_AgentCode__c,WFG_Contact__c,WFG_Contact__r.WFG_Status__c,WFG_PrimaryCode__c,'+
            +'WFG_Contact__r.Reportsto.WFG_AgentCode__c,WFG_Contact__r.Reportsto.WFG_Status__c '+ 
            +'from WFG_AgentCode__c '+
            +'where WFG_Contact__r.ReportsToId in : contactIdParam';
        return Database.getQueryLocator(query); // returns all the contact's who report to the user's that were passed from constructor.
       
    }
    global void execute(Database.BatchableContext bc, List<WFG_AgentCode__c> scope)
    { 
        try
		{
            List<ContactShare> contactShareList = new List<ContactShare>();
            
            for(WFG_AgentCode__c objAgentCode : scope){
                
                ContactShare objContactShare = new ContactShare();
                objContactShare.ContactId = objAgentCode.WFG_Contact__c;
                objContactShare.ContactAccessLevel = 'Read';
                objContactShare.RowCause = 'Manual';
                objContactShare.UserOrGroupId = mapAgentCodeUserId.get(objAgentCode.WFG_Contact__r.Reportsto.WFG_AgentCode__c);
                contactShareList.add(objContactShare);
                
            }
            upsert contactShareList;
            
            system.debug('List of Contact Share ----' + contactShareList);
            system.debug('Query Limit....' + Limits.getQueries());
            system.debug('DML Limit....' + Limits.getDMLStatements());
            System.debug('Heap limit....'+limits.getHeapSize());
        }
        catch(Exception e){
            system.debug('Exception in User Active Batch--' + e);
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_CH_UserActiveBatch', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }
    }
    global void finish(Database.BatchableContext bc)
    {
        DateTime endDate = system.now();
        system.debug('User Id in Finish for User Active Batch -----' + setUserId);
        Database.executeBatch(new WFG_CH_UserActiveChildBatch(setUserId,startDate,endDate));
        
    }
}