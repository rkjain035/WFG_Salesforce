/**
@author Mruga Shastri
@date 7-Dec-2016
@description Trigger Handler for the Trigger WFG_Account.
*/
public with sharing class WFG_Account_Handler{
/**
@author Mruga Shastri
@date 7-Dec-2016
@description Executed on Trigger Context - Before Insert. Collects the list of Service center Account being Inserted & checks for Duplicate Branch Code. 
*/    
    public static void beforeInsert(){
        List<Account> lstAccounts = new List<Account>(); 
        List<Account> lstUniqueBranchCodeAccount = new List<Account>(); 
        lstAccounts = getBranchOfficeAccount(Trigger.New); 
        if(!lstAccounts.isEmpty())
        {
            lstUniqueBranchCodeAccount = checkWhileUpload(trigger.isInsert, trigger.isUpdate, lstAccounts, (Map<Id, Account>)trigger.newMap,(Map<Id, Account>)trigger.oldMap);
        }
        if(!lstUniqueBranchCodeAccount.isEmpty() && lstUniqueBranchCodeAccount != null)
        {
            checkInDB(trigger.isInsert, trigger.isUpdate, lstUniqueBranchCodeAccount , (Map<Id, Account>)trigger.newMap,(Map<Id, Account>)trigger.oldMap);
        }
    }
    
    /*public static void afterInsert(){
    
    }*/
/**
@author Mruga Shastri
@date 7-Dec-2016
@description Executed on Trigger Context - Before Update. Collects the list of Service center Account being Inserted & checks for Duplicate Branch Code. 
*/
    public static void beforeUpdate(){
        List<Account> lstAccounts = new List<Account>(); 
        List<Account> lstUniqueBranchCodeAccount = new List<Account>(); 
        lstAccounts = getBranchOfficeAccount(Trigger.New); 
        if(!lstAccounts.isEmpty())
        {
            lstUniqueBranchCodeAccount = checkWhileUpload(trigger.isInsert, trigger.isUpdate, lstAccounts, (Map<Id, Account>)trigger.newMap,(Map<Id, Account>)trigger.oldMap);
        }
        if(!lstUniqueBranchCodeAccount.isEmpty() && lstUniqueBranchCodeAccount != null)
        {
            checkInDB(trigger.isInsert, trigger.isUpdate, lstUniqueBranchCodeAccount , (Map<Id, Account>)trigger.newMap,(Map<Id, Account>)trigger.oldMap);
        }
    }
    
    /*public static void afterAfterUpdate(){
    
    }*/  

/**
@author Mruga Shastri
@date 7-Dec-2016
@description Collects the list of Service center Account. (Contacts with RecordType - Branch Office)
@Return List<Contact> - List of Accounts with with RecordType - Branch Office
*/
    Private Static List<Account> getBranchOfficeAccount(List<Account> lstNewAccounts){

        ID recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.WFG_Account_BranchOffice).getRecordTypeId(); 
        List<Account> lstAccounts = new List<Account>(); 

        for(Account Acc : lstNewAccounts){
            
            if(Acc.RecordTypeId == recordTypeId){
                lstAccounts.add(Acc);
            }
        }
        return lstAccounts; 
    }


    Private Static String BranchCodeUniqueError = System.Label.Unique_Constraint_On_Branch_Code;
/**
@author Mruga Shastri
@date 7-Dec-2016
@description Makes a map of Contacts with a Unique Branch code out of the list of Branch Office Accounts.
@Return List<Contact> - List of Accounts with with RecordType - Branch Office & Branch Code Unique. 
*/
    Private Static List<Account> checkWhileUpload(Boolean isInsert, boolean isUpdate, List<Account> lstAcc, Map<Id, Account> mapNew, map<Id, Account> mapOLd){
        List<Account> lstAccountValid = new List<Account>();
        Map<string, Integer> mapUniuqKey = new Map<string , Integer>();
        for(Account oAcc : lstAcc){
            if(!mapUniuqKey.containsKey(oAcc.WFG_BranchCode__c)){
                mapUniuqKey.put(oAcc.WFG_BranchCode__c, 0);               
                lstAccountValid.add(oAcc);
            }
            else{
                oAcc.WFG_BranchCode__c.addError(BranchCodeUniqueError);
            }                                                        
        }
        return lstAccountValid;
    }
 
/**
@author Mruga Shastri
@date 7-Dec-2016
@description Makes a map of Contacts with a Unique Branch code out of the list of Branch Office Accounts.
@Return List<Contact> - List of Accounts with with RecordType - Branch Office & Branch Code Unique. 
*/   
    public static void checkInDB(Boolean isInsert, boolean isUpdate,List<Account> lstAcc, Map<Id, Account> mapNew, map<Id, Account> mapOLd){
        List<Account> lstACcountForNext = new List<Account>();
        List<Account> lstEligible = new List<Account>();
        Map<String, Integer> mapBranchCode= new map<String, Integer>();
        Account newAccount = new Account();
        Account oldAccount = new Account(); 

        for(Account oAcc: lstAcc){
            if(isUpdate){
                if(!mapNew.isEmpty() && mapNew != null && mapNew.containsKey(oAcc.id)){
                    newAccount = mapNew.get(oAcc.Id); 
                }
                if(!mapOLd.isEmpty() && mapOLd != null && mapOld.containsKey(oAcc.id)){
                    oldAccount = mapOld.get(oAcc.Id); 
                }
                if(newAccount.WFG_BranchCode__c <> oldAccount.WFG_BranchCode__c){
                lstEligible.add(oAcc);
                mapBranchCode.put(oAcc.WFG_BranchCode__c , 0);
                }
            }

            if(isInsert){
                lstEligible.add(oAcc);
                mapBranchCode.put(oAcc.WFG_BranchCode__c , 0);
            }
            
        }
        if(lstEligible != null && !lstEligible.isEmpty()){
        
            for(Account oAcc: [Select id, Name, WFG_BranchCode__c from Account WHere WFG_BranchCode__c IN : mapBranchCode.keyset()]){
                if(mapBranchCode.containsKey(oAcc.WFG_BranchCode__c )){
                    Integer iCount = mapBranchCode.get(oAcc.WFG_BranchCode__c);
                     mapBranchCode.put(oAcc.WFG_BranchCode__c , ++iCount);
                }
            }
            if(mapBranchCode != null && !mapBranchCode.isEMPty())
            {
                for(Account oAcc: lstEligible){
                     if(mapBranchCode.containsKey(oAcc.WFG_BranchCode__c ) && mapBranchCode.get(oAcc.WFG_BranchCode__c ) > 0){
                         oAcc.WFG_BranchCode__c.addError(BranchCodeUniqueError);
                    }
                }
            }
                   
        }
                                               
    }
}