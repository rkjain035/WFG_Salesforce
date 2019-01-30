/**
@author Mruga Shastri
@date 7-Dec-2016
@description Trigger on Account Object. Runs on before& After Insert & Before Update.  
*/
trigger WFG_Account on Account (after insert, before update, before insert) {

    ID rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch Office').getRecordTypeId();

    List<Account> lstAcc= new List<Account>();
    List<Account> listAcc = new List<Account>();
    
    if (trigger.isAfter){
        List<Account> newAccount = [SELECT Id,RecordTypeId FROM Account WHERE Id IN :trigger.newMap.keySet() AND RecordTypeId = :rtId ];
        for(Account a :newAccount) { 
            a.IsPartner  = true; 
        }  
        update newAccount;
    }
    else {
        for(Account a : Trigger.New) {
            if(a.RecordTypeId == rtId){
                //a.IsPartner  = true;
            }
        }  
    }
    if(WFG_TriggerActivation__c.getInstance('WFG_Account').WFG_isActive__c){
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                WFG_Account_Handler.beforeInsert(); 
            }
            if(Trigger.isUpdate){
                 WFG_Account_Handler.beforeUpdate(); 
            }
        }
    }
}