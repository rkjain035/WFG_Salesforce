/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Saravanan Haldurai
* @date 03-JAN-2019
* @description - Creates new Contact to contact relation, Financial Account and task from redtail record.

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
Saravanan Haldurai    W-028484           03-JAN-2019             Creates new Contact, Financial Account and spouse contact from the duplicate redtail record.
--------------------------------------------------------------------------------------------------------
*/
global class Redtail_InsertRelatedData_Batch implements Database.Batchable<sobject> {

    global Database.Querylocator start (Database.BatchableContext BC) {
        string query = 'select id, Redtail_Batch_Processed__c, Redtail_Created_SpouseConId__c, Redtail_ID__c, Redtail_Created_ContactId__c, Redtail_Next_Activity_Subject__c, Redtail_Next_Activity_Start_Date__c, Redtail_Last_Activity_Subject__c, Redtail_Unique_ID__c,  Redtail_Last_Activity_Start_Date__c,Redtail_Is_duplicate__c, ';
    set<string> dupCheck = new set<String>();
    
    for(Redtail_Object_Mappings__c mapp : [select Redtail_Field_Name__c from Redtail_Object_Mappings__c where Redtail_Object_Name__c = 'Financial Account'])
    {
      if(!dupCheck.contains(mapp.Redtail_Field_Name__c))
        query = query + mapp.Redtail_Field_Name__c +', ';
      
      dupCheck.add(mapp.Redtail_Field_Name__c);
    }
    
    query = query + 'Redtail_Is_duplicate_FA__c  from Redtail__c where Redtail_Batch_Processed__c = FALSE';
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext BC, List<Redtail__c> scope) {
        Map<Id, Redtail__C> mapUpdateRedtail = new map<Id, Redtail__c>();
        FinServ__ReciprocalRole__c reciprocalRole = [select id from FinServ__ReciprocalRole__c where name = 'Spouse' and Recordtype.Name = 'Contact Role' limit 1];
        list<FinServ__ContactContactRelation__c> lstContactRelation = new list<FinServ__ContactContactRelation__c>();
        list<Task> lstTaskInsert = new list<Task>();
        map<String, Redtail__c> mapRedtail = new map<String, Redtail__c>();
        map<string, String> mapAcctcontact = new map<String, string>();
        Map<Id, Redtail__c> mapRedtailUpdate = new Map<Id, Redtail__c>();
        
        set<string> setRedtailId = new set<string>();
        for(Redtail__c redtail : scope){
            setRedtailId.add(redtail.Redtail_Unique_ID__c);
        }
        
        for(Redtail__c redtail : [select id, Redtail_Unique_ID__c, Redtail_Created_ContactId__c from Redtail__c where Redtail_Unique_ID__c IN: setRedtailId and Redtail_Created_ContactId__c != NULL]){
            mapRedtail.put(redtail.Redtail_Unique_ID__c , redtail);
        }
        
        
        for(Redtail__c redtail : scope){
            
            if(mapRedtail.containsKey(redtail.Redtail_Unique_ID__c)){
                redtail.Redtail_Created_ContactId__c = mapRedtail.get(redtail.Redtail_Unique_ID__c).Redtail_Created_ContactId__c;
            }
            
            if(!redtail.Redtail_Is_duplicate__c){
                if(redtail.Redtail_Created_SpouseConId__c != NULL && redtail.Redtail_Created_ContactId__c != NULL){
                    FinServ__ContactContactRelation__c con2con = new FinServ__ContactContactRelation__c();
                    con2con.FinServ__Contact__c = redtail.Redtail_Created_ContactId__c;
                    con2con.FinServ__RelatedContact__c = redtail.Redtail_Created_SpouseConId__c;
                    con2con.FinServ__Role__c = reciprocalRole.Id;
                    con2con.FinServ__Active__c = true; 
                    con2con.OwnerId = redtail.Redtail_OwnerId__c;
                    lstContactRelation.add(con2con);
                }
            
                if(Redtail.Redtail_Last_Activity_Subject__c != NULL && Redtail.Redtail_Last_Activity_Start_Date__c != NULL) {
                    Task newTaskClosed = new Task();
                    newTaskClosed.WhoId = Redtail.Redtail_Created_ContactId__c;
                    newTaskClosed.OwnerId = Redtail.Redtail_OwnerId__c;
                    newTaskClosed.Subject = Redtail.Redtail_Last_Activity_Subject__c;
                    newTaskClosed.ActivityDate = Date.valueOf(Redtail.Redtail_Last_Activity_Start_Date__c);
                    newTaskClosed.Status = 'Completed';
                    lstTaskInsert.add(newTaskClosed);
                }
                if(Redtail.Redtail_Next_Activity_Subject__c != NULL && Redtail.Redtail_Next_Activity_Start_Date__c != NULL){
                    Task newTaskOpen = new Task();
                    newTaskOpen.WhoId = Redtail.Redtail_Created_ContactId__c;
                    newTaskOpen.OwnerId = Redtail.Redtail_OwnerId__c;
                    newTaskOpen.Subject = Redtail.Redtail_Next_Activity_Subject__c;
                    newTaskOpen.ActivityDate = Date.valueOf(Redtail.Redtail_Next_Activity_Start_Date__c);
                    lstTaskInsert.add(newTaskOpen);
                }
            }
            
            system.debug('--Redtail_Created_ContactId__c--' + redTail.Redtail_Created_ContactId__c);
            redTail.Redtail_Batch_Processed__c = true;
            mapRedtailUpdate.put(redTail.id, redTail);
        }
        
        try {

            insert lstContactRelation;
            insert lstTaskInsert;
            update mapRedtailUpdate.values();
        } catch(Exception e) {
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'Redtail_InsertRelatedData_Batch', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}