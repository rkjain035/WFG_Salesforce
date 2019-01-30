/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Saravanan Haldurai
* @date 03-JAN-2019
* @description - Creates Financial Account from redtail record.

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
Saravanan Haldurai    W-028484           03-JAN-2019             Creates financial account for the redtail record.
--------------------------------------------------------------------------------------------------------
*/
public class Redtail_createFinancialAccount
{
    public static void Redtail_createFinancialAccount(integer count){
        string query = 'select id, Redtail_Batch_Processed__c, Redtail_Created_SpouseConId__c, Redtail_ID__c, Redtail_Created_ContactId__c, Redtail_Next_Activity_Subject__c, Redtail_Next_Activity_Start_Date__c, Redtail_Last_Activity_Subject__c, Redtail_Unique_ID__c,  Redtail_Last_Activity_Start_Date__c,Redtail_Is_duplicate__c, ';
        set<string> dupCheck = new set<String>();

        for(Redtail_Object_Mappings__c mapp : [select Redtail_Field_Name__c from Redtail_Object_Mappings__c where Redtail_Object_Name__c = 'Financial Account'])
        {
            if(!dupCheck.contains(mapp.Redtail_Field_Name__c))
                query = query + mapp.Redtail_Field_Name__c +', ';
          
            dupCheck.add(mapp.Redtail_Field_Name__c);
        }
        
        query = query + 'Redtail_Is_duplicate_FA__c  from Redtail__c where Redtail_Is_duplicate_FA__c = false and Redtail_Created_FA_Id__c = NULL limit ' + count;
        
        list<Redtail__c> lstRedtail = database.query(query);
        
        list<Redtail_Object_Mappings__c> lstMapping = 
            [select Redtail_Default_Value__c, Redtail_Is_Required__c, Redtail_Is_Spouse__c, Redtail_Object_Name__c, Redtail_Related_Field_Name__c, Redtail_Field_Name__c 
            from Redtail_Object_Mappings__c 
            where Redtail_Object_Name__c = 'Financial Account'];
        
        set<string> setConId = new set<String>();
        for(Redtail__c redtail : lstRedtail){
            setConId.add(redtail.Redtail_Created_ContactId__c);
        }
        Map<string, Redtail__c> mapRedtail = new map<string, Redtail__c>();
        
        map<String, string> acctMap = new map<String, String>();
        for(Contact con : [select id, Accountid, Redtail_Id__c from contact where Id in: setConId])
            acctMap.put(con.Redtail_Id__c, con.AccountId);
            
        for(Redtail__c redTail : lstRedtail){
            mapRedtail.put(redTail.Redtail_Account_Number__c, redTail);
        }
        
        list<FinServ__FinancialAccount__c> lstFinancialAccount = new list<FinServ__FinancialAccount__c>();
        Map<Id, Redtail__c> mapRedtailUpdate = new Map<Id, Redtail__c>();
        
        Id recTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Current Products').getRecordTypeId();
        for(Redtail__c redTail : lstRedtail){
            mapRedtail.put(redTail.Redtail_Account_Number__c, redTail);
            FinServ__FinancialAccount__c financialAccount = new FinServ__FinancialAccount__c();
            financialAccount.recordtypeId = recTypeId;
            financialAccount.FinServ__PrimaryOwner__c = acctMap.get(redtail.Redtail_Id__c);
            for(Redtail_Object_Mappings__c mapping : lstMapping)
            {
                if(redTail.get(mapping.Redtail_Field_Name__c) == NULL && mapping.Redtail_Is_Required__c){
                    financialAccount = NULL;
                } 
                if(financialAccount != NULL) {
                    financialAccount.put(mapping.Redtail_Related_Field_Name__c , redTail.get(mapping.Redtail_Field_Name__c));
                }
            }
            
            if(financialAccount != NULL)
                lstFinancialAccount.add(financialAccount);
        }
        
        list<Database.SaveResult> lstResultFa = Database.insert(lstFinancialAccount, false);
        
        try {
            Integer countVal = 0;
            for(Database.SaveResult result : lstResultFa){
                FinServ__FinancialAccount__c financialAccount = lstFinancialAccount[countVal];
                Redtail__c redtail = mapRedtail.get(financialAccount.Name);
                
                Redtail__c newRedtail;
                if(mapRedtailUpdate.containsKey(redTail.Id))
                    newRedtail = mapRedtailUpdate.get(redTail.Id);
                else {
                    newRedtail= new RedTail__c();
                    newRedtail.Id = redTail.id;
                }
                
                if(!result.isSuccess()){
                    newRedtail.Redtail_Error_Message__c  = 'Financial Account - ' + result.getErrors()[0].getMessage();
                    system.debug('___fa_____d' + result.getErrors()[0].getMessage());
                } else {
                    newRedtail.Redtail_FinancialAccountCreated__c = true;
                    newRedtail.Redtail_Created_FA_Id__c = result.getId();
                    system.debug('___fa____'+result.getId());
                }
                countVal += 1;
                mapRedtailUpdate.put(newRedtail.id, newRedtail);
            }
            update mapRedtailUpdate.values();
        } catch(Exception e) {
            system.debug('Exception in Redtail Update--' + e);
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'Redtail_createFinancialAccount', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }
    }
}