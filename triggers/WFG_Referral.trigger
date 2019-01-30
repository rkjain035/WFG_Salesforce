/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Ninad Patil
* @description  Trigger for Referral Object.

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Ninad Patil          M-001             23-12-2016              Respomse wrapper from Apex to lightning component  
*/
trigger WFG_Referral on WFG_Referral__c (before insert, before update, after insert, after update) {
    
   // if(WFG_TriggerActivation__c.getInstance('WFG_Referral').WFG_isActive__c){
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                WFG_Referral_Handler.beforeInsert(Trigger.new);
            }
            if(Trigger.isUpdate){
                WFG_Referral_Handler.beforeUpdate(trigger.new, trigger.newmap, trigger.oldmap);
            }
            
        }
        
        if(Trigger.isAfter){
            if(Trigger.isInsert){
                WFG_Referral_Handler.afterInsert(trigger.new);
                WFG_Referral_Handler.populateActiveREferral(trigger.newmap, trigger.oldmap, false);
            }
            if(Trigger.isUpdate){
                WFG_Referral_Handler.afterUpdate(trigger.new, trigger.newmap, trigger.oldmap, true);
                WFG_Referral_Handler.populateActiveREferral(trigger.newmap, trigger.oldmap, true);
            }     
        }
   // }    

}