/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Saravanan Haldurai
* @date 14-DEC-2018
* @description - Creates new Contact, Financial Account and spouse contact from the realted redtail record.

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
Saravanan Haldurai    W-028484           14-DEC-2018             Creates new Contact, Financial Account and spouse contact from the realted redtail record.
--------------------------------------------------------------------------------------------------------
*/ 
public class Redtail_Trigger_Handler
{
    public static void onAfterInsert(list<Redtail__c> lstNew)
    {
        set<string> setExternalIds = new set<String>();
        Map<Id, Redtail__c> mapRedtailUpdate = new Map<Id, Redtail__c>();
        Map<string, Redtail__c> mapRedtail = new map<string, Redtail__c>();
        Map<string, string> mapRedtailContactID = new map<String, string>();
        list<Contact> lstNewContacts = new list<Contact>();
        set<string> setFADuplicate = new set<String>();
        
        Contact agentContact = [select id, mailingState from Contact where WFG_AgentCode__c =: lstNew[0].Redtail_Agent_Id__c limit 1];
        list<Redtail_Object_Mappings__c> lstMapping = 
            [select Redtail_Default_Value__c, Redtail_Is_Spouse__c, Redtail_Is_Required__c, Redtail_Related_Field_Name__c, Redtail_Field_Name__c 
             from Redtail_Object_Mappings__c 
             where Redtail_Object_Name__c = 'Contact'];
        
        for(Redtail__c redTail : lstNew){
            setExternalIds.add(redTail.Redtail_Unique_ID__c);
            setFADuplicate.add(redTail.Redtail_FinancialAccountIkey__c);
        }
        system.debug('====setFADuplicat===' + setFADuplicate);
        list<Redtail__c> lstRedtailDB = [select id, Redtail_Id__c, Redtail_FinancialAccountIkey__c, Redtail_Unique_ID__c, Redtail_Created_ContactId__c 
                                         from Redtail__c 
                                         where (Redtail_Unique_ID__c IN: setExternalIds OR Redtail_FinancialAccountIkey__c in: setFADuplicate) AND ID NOT IN: lstNew];
        setExternalIds = new set<String>();
        setFADuplicate = new set<String>();
        
        for(Redtail__c redTail : lstRedtailDB){
            setExternalIds.add(redTail.Redtail_Unique_ID__c);
            setFADuplicate.add(redTail.Redtail_FinancialAccountIkey__c);
            mapRedtailContactID.put(redTail.Redtail_ID__c, redTail.Redtail_Created_ContactId__c);
        }
       
        system.debug('++++++' + setExternalIds);
        Id recTypeId = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        for(Redtail__c redTail : lstNew)
        {
            if(setExternalIds.contains(redTail.Redtail_Unique_ID__c)) 
            {
                Redtail__c newRedtail = new Redtail__c();
                newRedtail.Id = redTail.Id;
                if(setExternalIds.contains(redTail.Redtail_Unique_ID__c))
                    newRedtail.Redtail_Is_duplicate__c = true;
                if(setFADuplicate.contains(redTail.Redtail_FinancialAccountIkey__c))
                    newRedtail.Redtail_Is_duplicate_FA__c = true;
                else
                    setFADuplicate.add(redTail.Redtail_FinancialAccountIkey__c);
                mapRedtailUpdate.put(redTail.id, newRedtail);
                system.debug('=== Has dup for ===' + redTail.Redtail_ID__c);
            } 
            else 
            {
                setFADuplicate.add(redTail.Redtail_FinancialAccountIkey__c);
                system.debug('===in here ');
                Contact con = new Contact();
                con.recordtypeId = recTypeId;
                con.FinServ__PrimaryAddressIsMailing__c = true;
                
                Contact spouseCon = new Contact();
                spouseCon.recordtypeId = recTypeId;
                spouseCon.FinServ__PrimaryAddressIsMailing__c = true;
                
                for(Redtail_Object_Mappings__c mapping : lstMapping)
                {
                    if(mapping.Redtail_Is_Spouse__c){
                        if(redTail.get(mapping.Redtail_Field_Name__c) == NULL && mapping.Redtail_Is_Required__c){
                            spouseCon = NULL;
                        }
                        if(spouseCon != NULL) {
                            spouseCon.put(mapping.Redtail_Related_Field_Name__c , redTail.get(mapping.Redtail_Field_Name__c));
                        }
                    } else {
                        con.put(mapping.Redtail_Related_Field_Name__c , redTail.get(mapping.Redtail_Field_Name__c) != NULL ? 
                            redTail.get(mapping.Redtail_Field_Name__c) : mapping.get('Redtail_Default_Value__c'));
                    }
                }
                
                if(con.MailingState == NULL){
                    con.mailingState = agentContact.mailingState;
                }
                if(spouseCon != NULL){
                    spouseCon.Redtail_ID__c = spouseCon.Redtail_ID__c+'_S';
                    if(spouseCon.MailingState == NULL)
                        spouseCon.mailingState = agentContact.mailingState;
                    
                    lstNewContacts.add(spouseCon);
                }
                system.debug('======= Con ' + con);
                mapRedtail.put(redTail.Redtail_ID__c, redTail);
                setExternalIds.add(redTail.Redtail_Unique_ID__c);
                lstNewContacts.add(con);
            }
        }
        
        system.debug('---' +lstNewContacts.size());
        
        list<Database.SaveResult> lstResult = Database.insert(lstNewContacts, false);
        try{
            Integer count = 0;
            for(Database.SaveResult result : lstResult){
                boolean isSpouse = false;
                Contact con = lstNewContacts[count];
                Redtail__c redtail = mapRedtail.get(con.Redtail_Id__c);
                system.debug('***Redtail**'+ redtail);
                system.debug('***contact**' + con);
                
                if(redtail == NULL){
                    isSpouse = true;
                    redtail = mapRedtail.get(con.Redtail_Id__c.removeEnd('_S'));
                }
                
                Redtail__c newRedtail;
                if(mapRedtailUpdate.containsKey(redtail.id))
                    newRedtail = mapRedtailUpdate.get(redtail.id);
                else {
                    newRedtail = new Redtail__c();
                    newRedtail.Id = redTail.Id;
                    newRedtail.Redtail_ID__c = redTail.Redtail_ID__c;
                } 
                
                if(!result.isSuccess()){
                   newRedtail.Redtail_Error_Message__c  = 'Parent Contact - ' + result.getErrors()[0].getMessage();
                   system.debug('________d' + result.getErrors()[0].getMessage());
                } else {
                    if(isSpouse)
                        newRedtail.Redtail_Created_SpouseConId__c = result.getId();
                    else{
                        newRedtail.Redtail_Created_ContactId__c = result.getId();
                        mapRedtailContactID.put(redTail.Redtail_ID__c, newRedtail.Redtail_Created_ContactId__c);
                    }
                    system.debug('_______'+result.getId() + '---' + newRedtail);
                }
                mapRedtailUpdate.put(redTail.ID, newRedtail);
                system.debug('--------------' + newRedtail);
                count +=1;
            }
            
            
            for(Redtail__c redTail : mapRedtailUpdate.values()){
                if(redTail.Redtail_Created_ContactId__c == NULL)
                    redTail.Redtail_Created_ContactId__c = mapRedtailContactID.get(redTail.Redtail_ID__c);
            }

            update mapRedtailUpdate.values();
        } catch(Exception e) {
            system.debug('Exception in Redtail Update--' + e);
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'Redtail_Trigger_Handler AI-'+lstNew.size(), 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }
    }
}