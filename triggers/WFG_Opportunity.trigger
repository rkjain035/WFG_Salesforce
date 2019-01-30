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
Samit Bhoumick          M-001             02-02-2017             Opportunity Trigger  
*/
trigger WFG_Opportunity on Opportunity (before insert, before update, after insert, after update) {
     
	if(WFG_TriggerActivation__c.getAll().containskey('WFG_Opportunity') 
		&& !WFG_TriggerActivation__c.getAll().get('WFG_Opportunity').WFG_isActive__c)
	{
		return;
	}
		
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            WFG_Opportunity_Handler.beforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            WFG_Opportunity_Handler.beforeUpdate(Trigger.new, trigger.newMap, trigger.oldMap);
        }
        
    }
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            WFG_Opportunity_Handler.afterInsert(trigger.new);
        }
        if(Trigger.isUpdate){
            WFG_Opportunity_Handler.afterUpdate(trigger.new, trigger.newmap, trigger.oldmap, true);
        }     
    }
}