/**
@author Mruga Shastri
@date 7-Dec-2016
@description Trigger on Contact Object. Runs on before Insert & Before Update.  
*/
trigger WFG_Contact on Contact (before insert, before update, after update, after insert){

    if(WFG_TriggerActivation__c.getInstance('WFG_Contact') != null && 
       WFG_TriggerActivation__c.getInstance('WFG_Contact').WFG_isActive__c != null && 
       WFG_TriggerActivation__c.getInstance('WFG_Contact').WFG_isActive__c == true){
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                System.debug('Rahul checking length in before insert....'+Trigger.New.size());
                WFG_Contact_Handler.beforeInsert();
            }
            
            if(Trigger.isUpdate){
                System.debug('Rahul checking length in before update....'+Trigger.New.size());
                WFG_Contact_Handler.beforeUpdate();
            }
            
          /*  if(Trigger.isDelete){
            
            } */       
        }
        if(Trigger.isAfter)
        {
          if(Trigger.isInsert)
          {
              System.debug('Rahul checking length in after insert....'+Trigger.New.size());
            system.debug('## AFTER INSERT ::');
            WFG_Contact_Handler.afterInsert(Trigger.new, Trigger.newMap, Trigger.oldMap);
          }
          if(Trigger.isUpdate)
          {
            //WFG_Contact_Handler.afterupdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
           	System.debug('Rahul checking length in after update....'+Trigger.New.size());
            WFG_Contact_Handler.afterupdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
            
          }
        }
        /*
        if(Trigger.isAfter){
            
            if(Trigger.isInsert){
            
            }
            
            if(Trigger.isUpdate){
            }
            
            if(Trigger.isDelete){
            
            }
        } */
    }

}