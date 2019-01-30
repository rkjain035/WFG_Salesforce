trigger WFG_TRG_SetPartner on Account (after insert, before update) {

    if (trigger.isAfter){
        List<Account> newAccount = [SELECT Id FROM Account WHERE Id IN :trigger.newMap.keySet()];
        for(Account a :newAccount) { 
            a.IsPartner  = true; 
        }  
        update newAccount;
    }
    else {
        for(Account a : Trigger.New) { 
            a.IsPartner  = true; 
        }  
    }
}