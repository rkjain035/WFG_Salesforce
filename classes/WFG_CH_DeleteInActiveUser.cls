/*
Property of Transamerica and Aegoncompanies.Do not distribute without permission.
* Copyright (c) [2018] Transamerica Corporation, its affiliates and their licensors.
* @author 
* @date 10-24-2018
* @description  Batch class to Delete Contact Hierarchy in FSC  when User record made InActive.
Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Karthik Raj            M-001             10-24-2018               Batch class to create Contact Hierarchy in FSC
                                                                  when the User record to becomes InActive.
*/
global class WFG_CH_DeleteInActiveUser implements Database.Batchable<sObject>,Database.Stateful{
    
    private Set<Id> setUserIdParam = new Set<Id>();
    private Boolean isCheckFromBatch;
    
    public WFG_CH_DeleteInActiveUser(Set<Id> setUsrIds) {
        
        setUserIdParam = setUsrIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query = 'select Id from ContactShare where UserOrGroupId in : setUserIdParam and rowcause = \'Manual\' and ' +
             +'(Contact.WFG_Status__c = \'TERMINATED\' or  Contact.WFG_Status__c = \'VESTED\' or Contact.WFG_Status__c = \'REJECTED\' or Contact.WFG_Status__c = \'TERM FOR CAUSE\')';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<ContactShare> scope)
    { 
        	try{system.debug('ContactShare Deleted ---' + scope);Delete scope;
            }catch(Exception e){system.debug('Exception in Delete Inactive User Batch--' + e);LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_CH_DeleteInActiveUser', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);}
    }
    global void finish(Database.BatchableContext bc)
    {

    }
}