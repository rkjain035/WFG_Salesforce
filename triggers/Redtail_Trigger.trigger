/**
@author Saravanan haldurai
@date 14-Dec-2018
@description Trigger on redtail Object. Runs on After Insert & After Update. 
Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
Saravanan Haldurai    W-028484           14-Dec-2018             Trigger on redtail Object. Runs on After Insert & After Update.
*/
trigger Redtail_Trigger on Redtail__c (after insert){ //, after update) {
    
    if(trigger.isInsert)
        Redtail_Trigger_Handler.onAfterInsert(trigger.new);
   /* else {
        if(trigger.isUpdate && !Redtail_Trigger_Handler.skipSpouseContact)
            Redtail_Trigger_Handler.onAfterUpdate(trigger.new);
            
        if(trigger.isUpdate && !Redtail_Trigger_Handler.skipContact2Contact)
            Redtail_Trigger_Handler.insertContact2Contact(trigger.new);
    } */
}