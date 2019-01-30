/*
Property of Transamerica and Aegoncompanies.Do not distribute without permission.
* Copyright (c) [2018] Transamerica Corporation, its affiliates and their licensors.
* @author Karthik Raj
* @date 10-24-2018 
* @description  Batch class to Delete Contact Hierarchy in FSC by a Manual Sharing when the contact record becomes InActive.
Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
 Karthik Raj           M-001             10-24-2018               Batch class to create Contact Hierarchy in FSC by a Manual Sharing 
															      when the contact record becomes InActive.
*/

global class WFG_CH_ContactInActivebatch implements Database.Batchable<sObject> {

    private Set<Id> setContactIdsParam;    

    public WFG_CH_ContactInActivebatch(Set<Id> conIdParam) {
        setContactIdsParam = conIdParam;
    }
   
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
       String query = 'select Id,ContactId,UserOrGroupId from ContactShare where ContactId in : setContactIdsParam and rowcause = \'Manual\'';
       return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<ContactShare> scope)
    { 
        try{
            
            LIST<Contact> listContacts = new LIST<Contact>();
            
            Delete scope;

            for(ContactShare objContactShare : scope)
            {
                Contact objContact = new Contact(Id = objContactShare.ContactId);
                objContact.isStatusChanged__c = false;
                listContacts.add(objContact);
            }
            upsert listContacts;
            
            system.debug('List of Conatct Status Change --' + listContacts);
            
        }catch(Exception e){system.debug('Exception in Contact InActive  Batch--' + e);LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_CH_ContactInActivebatch', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);}
    }
    global void finish(Database.BatchableContext bc)
    {
        
        
    }
    
}