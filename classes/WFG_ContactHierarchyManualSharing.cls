/*
Property of Transamerica and Aegoncompanies.Do not distribute without permission.
* Copyright (c) [2018] Transamerica Corporation, its affiliates and their licensors.
* @author Karthik Raj  
* @date 17-09-2018
* @description  Batch class to create Contact Hierarchy in FSC by a Manual Sharing the contact record to the Upline contact.
Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
 Karthik Raj           M-001             17-09-2018               Batch class to create Contact Hierarchy in FSC by a Manual Sharing 
															      the User record to contact.
*/

global class WFG_ContactHierarchyManualSharing implements Database.Batchable<sObject> {
    
    global static Map<String,Set<String>> mapContactUpline;
    global static Map<String,String> mapNextContactUpline;
    global static Map<String,String> mapAgentCodes = new map<String,String>();
    global static Set<Id> setNextContactId;
    global static Set<String> setAgentCodes;
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
       String query = 'select WFG_Contact__c,WFG_Contact__r.ReportsToId,WFG_UplineCode__r.WFG_Contact__c '+ 
           +'from WFG_AgentCode__c'+
           +' where'+
           +' WFG_PrimaryCode__c = true and WFG_Contact__r.ReportsToId != null';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<WFG_AgentCode__c> scope)
    {
        try{
            
            Set<Id> setContactId = new Set<Id>();
            List<ContactShare> contactShareList = new List<ContactShare>();
            Map<String, WFG_AgentCode__c> mapCodetoAgentCode = new Map<String, WFG_AgentCode__c>();  
            Map<String,Set<String>> lstUplineContact = new Map<String,Set<String>>();
            
            setAgentCodes = new Set<String>();
               
             for(WFG_AgentCode__c con : scope){
                 setContactId.add(con.WFG_Contact__c);
             }
            
             system.debug('Set of Contact Ids -- ' + setContactId);
            
             contactFetch(setContactId);        
             
            //To get the User inforamtion of Upline Contact fetched from contactFetch Method.
            for(User objUser : [Select Id,WFG_Agent_Code__c 
                                from User 
                                where isActive = true and WFG_Agent_Code__c in : setAgentCodes]){
                mapAgentCodes.put(objUser.WFG_Agent_Code__c,objUser.id);
            }
            
            system.debug('Map of Agent Code User Id  -- ' + mapAgentCodes);
            //To get the AgentCode inforamtion of Upline Contact fetched from contactFetch Method.
            for(WFG_AgentCode__c objAgentCode : [Select id,WFG_Status__c,WFG_AgentCode__c,WFG_PrimaryCode__c,WFG_Contact__c, WFG_Contact__r.WFG_Status__c 
                                                 from WFG_AgentCode__c 
                                                 where WFG_AgentCode__c In : setAgentCodes]){
                
                mapCodetoAgentCode.put(objAgentCode.WFG_AgentCode__c,objAgentCode);
            }
           
             for(String strContact : mapContactUpline.keySet()){
                 
                 Set<String> setContactAgentCode = mapContactUpline.get(strContact);
                 
                 for(String strAgentCode : setContactAgentCode){
                    WFG_AgentCode__c objAgentCode = mapCodetoAgentCode.get(strAgentCode);
                     String strUserId = mapAgentCodes.get(objAgentCode.WFG_AgentCode__c);
                     if(strUserId != null && objAgentCode.WFG_PrimaryCode__c == true){
                        ContactShare objContactShare = new ContactShare();
                        objContactShare.ContactId = strContact;
                        objContactShare.ContactAccessLevel = 'Read';
                        objContactShare.RowCause = 'Manual';
                        objContactShare.UserOrGroupId = strUserId;
                        contactShareList.add(objContactShare);
                    }
               }
           }
           upsert contactShareList;
           system.debug('ContactShare List Ontime CH Manual Sharing Batch ---' + contactShareList);
           system.debug('Query Limit....' + Limits.getQueries());
           system.debug('DML Limit....' + Limits.getDMLStatements());
           system.debug('Heap limit in execute of batch .....'+limits.getHeapSize());
            
        }catch(Exception e)
		{
                system.debug('Exception in Contact Hierarchy one time Batch--' + e);
                LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_ContactHierarchyManualSharing', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }
        
    }
    global void finish(Database.BatchableContext bc)
    {
        
        
    }
    public static void contactFetch(Set<Id> setContactIds)
    {
        try{
        
            setNextContactId = new Set<Id>();
            //Gives the 5-Level of agentcode of the contact record with reports to id.
            List<Contact> lstUplineContacts = [Select id,WFG_AgentCode__c,ReportsTo.WFG_AgentCode__c,ReportsToId,
                                         ReportsTo.ReportsTo.WFG_AgentCode__c,ReportsTo.ReportsToId,
                                         ReportsTo.ReportsTo.ReportsTo.WFG_AgentCode__c,ReportsTo.ReportsTo.ReportsToId,
                                         ReportsTo.ReportsTo.ReportsTo.ReportsTo.WFG_AgentCode__c,ReportsTo.ReportsTo.ReportsTo.ReportsToId,
                                         ReportsTo.ReportsTo.ReportsTo.ReportsTo.ReportsTo.WFG_AgentCode__c,ReportsTo.ReportsTo.ReportsTo.ReportsTo.ReportsToId,
                                         ReportsTo.ReportsTo.ReportsTo.ReportsTo.ReportsTo.ReportsToId
                                         from Contact 
                                         where id in :setContactIds];
            
                
            if(mapContactUpline == Null)
                             mapContactUpline = new Map<String,Set<String>>();
            if(mapNextContactUpline == Null)
                             mapNextContactUpline = new Map<String,String>();
         
             for(Contact objCon :lstUplineContacts){
                 
                 Id contactId = objCon.Id;
                 
                 if(mapNextContactUpline.containsKey(contactId))
                       contactId = mapNextContactUpline.get(contactId);
                 
                 if(!mapContactUpline.containsKey(contactId))
                       mapContactUpline.put(contactId,new set<String>{});
                 
                 if(objCon.ReportsTo.ReportsTo.ReportsTo.ReportsTo.ReportsToId != null)
                 {
                       mapContactUpline.get(contactId).add(objCon.ReportsTo.WFG_AgentCode__c);
                       mapContactUpline.get(contactId).add(objCon.ReportsTo.ReportsTo.WFG_AgentCode__c);
                       mapContactUpline.get(contactId).add(objCon.ReportsTo.ReportsTo.ReportsTo.WFG_AgentCode__c);
                       mapContactUpline.get(contactId).add(objCon.ReportsTo.ReportsTo.ReportsTo.ReportsTo.WFG_AgentCode__c);
                       mapContactUpline.get(contactId).add(objCon.ReportsTo.ReportsTo.ReportsTo.ReportsTo.ReportsTo.WFG_AgentCode__c);
                       Id nextContactId = objCon.ReportsTo.ReportsTo.ReportsTo.ReportsTo.ReportsToId;
                       setNextContactId.add(nextContactId);//Used to store next set of uplinecontact to be fetched.
                       mapNextContactUpline.put(nextContactId, contactId);
                  }
                 else if(objCon.ReportsTo.ReportsTo.ReportsTo.ReportsToId != null)
                 {
                       mapContactUpline.get(contactId).add(objCon.ReportsTo.WFG_AgentCode__c);
                       mapContactUpline.get(contactId).add(objCon.ReportsTo.ReportsTo.WFG_AgentCode__c);
                       mapContactUpline.get(contactId).add(objCon.ReportsTo.ReportsTo.ReportsTo.WFG_AgentCode__c);
                       mapContactUpline.get(contactId).add(objCon.ReportsTo.ReportsTo.ReportsTo.ReportsTo.WFG_AgentCode__c);
                  }else if(objCon.ReportsTo.ReportsTo.ReportsToId != null){
                       mapContactUpline.get(contactId).add(objCon.ReportsTo.WFG_AgentCode__c);
                       mapContactUpline.get(contactId).add(objCon.ReportsTo.ReportsTo.WFG_AgentCode__c);
                       mapContactUpline.get(contactId).add(objCon.ReportsTo.ReportsTo.ReportsTo.WFG_AgentCode__c);
                  }else if(objCon.ReportsTo.ReportsToId != null){
                       mapContactUpline.get(contactId).add(objCon.ReportsTo.WFG_AgentCode__c);
                       mapContactUpline.get(contactId).add(objCon.ReportsTo.ReportsTo.WFG_AgentCode__c);
                  }else if(objCon.ReportsToId != null){
                       mapContactUpline.get(contactId).add(objCon.ReportsTo.WFG_AgentCode__c);
                  }
                 setAgentCodes.addAll(mapContactUpline.get(contactId));
                 
             }
            system.debug('Set of next contactid to  Contact fetch method ---' + setNextContactId);
            //Checks for next set of uplinecontact to be fetched.
            if(setNextContactId.Size() > 0){
                 contactFetch(setNextContactId);
            }
            
           system.debug('Query Limit....' + Limits.getQueries());
           system.debug('DML Limit....' + Limits.getDMLStatements());
           system.debug('Heap limit in execute of batch .....'+limits.getHeapSize());
      }catch(Exception e)
		{
                system.debug('Exception in Contact Hierarchy one time Batch, Contact fetch method --' + e);
                LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_CH_UserActiveChildBatch-contactFetch method', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }      
    }
}