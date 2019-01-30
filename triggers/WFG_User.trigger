/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Samit Bhoumick
* @description  Trigger for user Object.
*/
trigger WFG_User on User(before insert, before update, after insert, after update) {
     
    if(WFG_TriggerActivation__c.getAll().containskey('WFG_User') 
        && !WFG_TriggerActivation__c.getAll().get('WFG_User').WFG_isActive__c)
    {
        return;
    }
        
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            WFG_userTriggerHandler.beforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
       
            WFG_userTriggerHandler.beforeUpdate(Trigger.new, trigger.newMap, trigger.oldMap);
            
        }
        
    }
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            WFG_userTriggerHandler.afterInsert(trigger.new,trigger.newMap);
        }
        if(Trigger.isUpdate){
            WFG_userTriggerHandler.afterUpdate(trigger.new, trigger.newmap, trigger.oldmap, true);
            // Logic to delete caseTeam Member for inactive user.
            set<Id> userIdSet = new set<Id>();
            for(User usr : trigger.new){
                if(!usr.isActive && trigger.oldMap.get(usr.Id).isActive)
                    userIdSet.add(usr.Id);
            }
         //   WFG_OwnershipUpdate.deleteCaseTeamMember(userIdSet);
        }     
    }
}