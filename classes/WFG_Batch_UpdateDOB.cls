global class WFG_Batch_UpdateDOB implements Database.Batchable<sObject> {
   
   global String Query = '';
   
   global WFG_Batch_UpdateDOB(String q)
   {
       Query = q;
   }
   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(Query);
   }
   
   global void execute(
                Database.BatchableContext BC, 
                List<Contact> scope){

        for(Contact c : scope)
        {
			 c.BirthDate = c.BirthDate.addYears(4);
        }
         update scope;
   }

   global void finish(Database.BatchableContext BC){
       AsyncApexJob a = 
           [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob WHERE Id =
            :BC.getJobId()];
                          
       // Send an email to the Apex job's submitter 
       //   notifying of job completion. 
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {a.CreatedBy.Email};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Update DOB Batch Status: ' + a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   }
}