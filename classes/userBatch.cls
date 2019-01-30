global class userBatch implements Database.Batchable<sObject>{
    
   
   global Database.QueryLocator start(Database.BatchableContext BC){
       string strQuery = 'Select id, WFG_Agent_Code__c from user where lastmodifieddate = today and isActive = true';
      return Database.getQueryLocator(strQuery);
   }

   global void execute(Database.BatchableContext BC, List<User> scope){
     
     list<Account> lstAccounttoInsert = new list<Account>();
     list<Account> lstAccounttoUpdate = new list<Account>();
     for(User objUser : scope){
        Account objAcc = new Account();
        objAcc.Name = 'Test';
        lstAccounttoInsert.add(objAcc);
     }
     list<Account> lstA = [select id, ownerId from Account limit 1];
     
     for(User objUser : scope){
         
         lstA[0].OwnerId = objUser.Id;
         lstAccounttoUpdate.add(lstA[0]);
         break;
     }
     insert lstAccounttoInsert;
     update lstAccounttoUpdate;
    }

   global void finish(Database.BatchableContext BC){
   }
}