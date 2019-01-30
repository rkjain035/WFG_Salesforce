/*
Property of Transamerica and Aegoncompanies.Do not distribute without permission.
* Copyright (c) [2018] Transamerica Corporation, its affiliates and their licensors.
* @author Karthik Raj  
* @date 10-24-2018
* @description  Batch class to create Contact Hierarchy in FSC by a Manual Sharing when User record made Active from WFG_CH_UserActiveBatch.
Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Karthik Raj            M-001             10-24-2018               Batch class to create Contact Hierarchy in FSC by a Manual Sharing 
                                                                  when the User record to becomes Active from WFG_CH_UserActiveBatch.
*/

global class WFG_CH_UserActiveChildBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    private boolean scopeFlag;
    private datetime startDate;
    private datetime endDate;
    private datetime currentStartDate;
    private Set<Id> setUserIds = new Set<Id>();
    private Id ContactId;
    public WFG_CH_UserActiveChildBatch(Set<Id> setUserId,Datetime sdate,Datetime edate) {  
       
        currentStartDate = system.now();//Used as Start Date from Recursive Batch
        startDate = sDate;
        endDate = eDate;
        scopeFlag = true;
        setUserIds.addAll(setUserId);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query = 'Select Id,reportsToId from Contact where reportsToId in '+
            +'(Select ContactId '+ 
            +'from ContactShare '+
            +'where UserOrGroupId in : setUserIds and lastmodifieddate >= : startDate  and lastmodifieddate <= : endDate and rowcause = \'Manual\') ';
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Contact> scope)
    {
        try{
            if(scope.size() > 0)
            {
                List<ContactShare> contactShareList = new List<ContactShare>();
                Map<Id,Id> mapReportsToIdContactId = new Map<Id,Id>();
                Map<Id,Id> mapContactIdUserId = new Map<Id,Id>();
                for(Contact objContact : scope){
                    
                    mapReportsToIdContactId.put(objContact.Id,objContact.ReportsToId);
                }
                system.debug('Contact Id ReportstoId of Upline ContactId of lastmodified date in User Active Child Batch....' + mapReportsToIdContactId);
                for(ContactShare objContactShare : [Select UserOrGroupId,ContactId from ContactShare 
                                                    where UserOrGroupId in : setUserIds and ContactId in : mapReportsToIdContactId.values()]){
                     
                    mapContactIdUserId.put(objContactShare.ContactId,objContactShare.UserOrGroupId);                                    
                                                    
                }
                for(Id objContactShare : mapReportsToIdContactId.keyset()){
                    
                    ContactShare objConShare = new ContactShare();
                    objConShare.ContactId = objContactShare;
                    objConShare.ContactAccessLevel = 'Read';
                    objConShare.RowCause = 'Manual';
                    objConShare.UserOrGroupId = mapContactIdUserId.get(mapReportsToIdContactId.get(objContactShare));
                    contactShareList.add(objConShare);
                    scopeFlag = false;
                    ContactId = objConShare.ContactId;
                }
                
                
                upsert contactShareList;
                
                system.debug('ContactShare List in User Active Child Batch ---' + contactShareList);
                system.debug('Query Limit....' + Limits.getQueries());
                system.debug('DML Limit....' + Limits.getDMLStatements());
                System.debug('Heap limit in execute of batch 2.....'+limits.getHeapSize());
                
            }else{
                scopeFlag = true;
            }
        }catch(Exception e)
		{
                system.debug('Exception in User Active Child Batch--' + e);
                LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_CH_UserActiveChildBatch', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }
    }
    
    global void finish(Database.BatchableContext bc)
    {
        if(!scopeFlag){
            
            endDate = system.now();
            Database.executeBatch(new WFG_CH_UserActiveChildBatch(setUserIds,currentStartDate,endDate));
            
        }
        else{
            system.debug('UserId for InActive Batch in Finish batch of User Active Child Batch - - - ' + setUserIds);
            List<User> lstUser = new List<User>();
            for(User objUser : [Select Id,WFG_LastUpdatedDate__c from User where id in: setUserIds])
            {
                User userInfo = new User(id=objUser.Id);
                userInfo.WFG_LastUpdatedDate__c = NULL;
                lstUser.add(userInfo);
            }
            Update lstUser;
            //Database.executeBatch(new WFG_CH_DeleteInActiveUser(setUserIds)); 
            
        }
        
    }
    
}