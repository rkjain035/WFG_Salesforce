/*
Property of Transamerica and Aegoncompanies.Do not distribute without permission.
* Copyright (c) [2018] Transamerica Corporation, its affiliates and their licensors.
* @author Karthik Raj
* @date 10-24-2018
* @description  Batch class to create Contact Hierarchy in FSC by a Manual Sharing the when the  contact record becomes Active.
Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Karthik Raj           M-001             10-24-2018              Batch class to create Contact Hierarchy in FSC by a Manual Sharing 
when the contact record becomes Active.
*/

global class WFG_CH_ContactActivebatch implements Database.Batchable<sObject>,Database.Stateful {
    
    private Set<Id> setContactIdsParam = new Set<Id>();
    private map<Id,List<Id>> parentToChildMap = new Map<Id,LIST<Id>>();
    private map<Id,Id> parentToUserMap = new Map<Id,Id>();
    private LIST<Id> parentConId = new LIST<Id>();
    private Map<String,Id> parentContactToAgentCodeMap = new Map<String,Id>();
    private Map<Id,id> parentContactToUserMap = new Map<Id,id>();
    
    public WFG_CH_ContactActivebatch(Set<Id> conIdParam) 
    {
        setContactIdsParam.addAll(conIdParam); // consists of contact whose are newly created
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        for(Contact c : [select id, reportsToId,reportsTo.WFG_AgentCode__c from Contact 
                         where id in :setContactIdsParam and reportsToId != null])
        {
            
            parentContactToAgentCodeMap.put(c.reportsTo.WFG_AgentCode__c,c.reportsToId);
            parentConId.add(c.reportsToId);
            LIST<Id> dummyId = new LIST<Id>();
            if(parentToChildMap.containsKey(c.reportsToId))
            {
                dummyId = parentToChildMap.get(c.reportsToId);
                dummyId.add(c.Id);
                parentToChildMap.put(c.reportsToId,dummyId);
            }
            else{
                dummyId.add(c.Id);
                parentToChildMap.put(c.reportsToId,dummyId);
            }
        }
        System.debug('parentToChildMap....'+parentToChildMap);
        
        if(parentContactToAgentCodeMap.size() > 0)
        {
            for(User u : [Select Id,WFG_Agent_Code__c from User
                          where isActive = true and WFG_Agent_Code__c in : parentContactToAgentCodeMap.keySet()])
            {
                parentContactToUserMap.put(parentContactToAgentCodeMap.get(u.WFG_Agent_Code__c),u.Id);
            }
        }
        
        Set<Id> inputSet = new Set<Id>();
        inputSet = parentToChildMap.KeySet();
        
        String query = 'select userOrGroupId, ContactId from ContactShare where ContactId in : inputSet and rowCause = \'Manual\' ';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<ContactShare> scope)
    { 
        try{
            System.debug('how many user records excluding parent....'+scope.size());
            LIST<ContactShare> conShareList = new LIST<ContactShare>();
            
            for(ContactShare cs : scope) // each parent
            {
                for(Id conId : parentToChildMap.get(cs.ContactId)) // each child
                {
                    ContactShare conShare = new ContactShare();
                    conShare.ContactId = conId;
                    conShare.UserOrGroupId = cs.UserOrGroupId;
                    conShare.RowCause = 'Manual';
                    conShare.ContactAccessLevel = 'Read';
                    conShareList.add(conShare);
                    
                    try{
                        if(parentContactToUserMap.get(cs.ContactId) != null)
                        {
                            conShare = new ContactShare();
                            conShare.ContactId = conId;
                            conShare.UserOrGroupId = parentContactToUserMap.get(cs.ContactId);
                            conShare.RowCause = 'Manual';
                            conShare.ContactAccessLevel = 'Read';
                            conShareList.add(conShare);
                        }
                    }catch(Exception e)
                    {
                        system.debug('Exception in Contact Active  Batch in for Loop --' + e);
           				LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_CH_ContactActivebatch', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
       			
                    }
                    
                    
                }
                
            }
            
            insert conShareList;
            
        }catch(Exception e)
        {
            system.debug('Exception in Contact Active  Batch--' + e);
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_CH_ContactActivebatch', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }
    }
    global void finish(Database.BatchableContext bc)
    {
        makeIsStatusChanged(setContactIdsParam);
    }
    
    public static void makeIsStatusChanged(Set<Id> conId)
    {
        try{
            
            List<Contact> lstContactChange = new List<Contact>();
            system.debug('List of Contact Status Changes ---' + conId);
            
            for(Contact objContact : [Select Id ,WFG_IsNewlyCreatedContact__c from Contact
                                      where Id in : conId])
            {
                Contact con = new Contact(Id=objContact.Id);
                con.WFG_IsNewlyCreatedContact__c = false;
                lstContactChange.add(con);
            }
            
            update lstContactChange;
            
        }catch(Exception e)
        {
            system.debug('Exception in Contact Active  Batch,makeIsStatusChanged Method--' + e);
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_CH_ContactActivebatch - makeIsStatusChanged method', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }
    }
    
    
}