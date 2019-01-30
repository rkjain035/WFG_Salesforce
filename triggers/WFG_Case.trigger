/**
 *
 Property of Transamerica and Aegon companies. Do not distribute without permission.
 * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
 * @author Deloitte Consulting LLP
 * @date 05/26/2016
 * @description US-2300, US-2301: this Trigger is for assigning the entitlement to case. 
 * 
  Modification Log:
 -------------------------------------------------------------------------------------------------------
 Developer          ModNumber           Date                    Description
 -------------------------------------------------------------------------------------------------------
 Suhan Jain          M-001              05/26/2016              Initial version
 Manuel              M-002              07/19/2016              Updated to trigger CompleteMilestone
 Rabee               W-027352           08/01/2018              Created before update event for Case research statsus


**/

trigger WFG_Case on Case (before insert, after insert, before update, after update) {
    
    if(Trigger.isBefore){
        //check if valid contact was supplied and look it up if not
        //List <Case> oNewCases = new List<Case>();
        //Case oTest = new Case();
        //oTest.WFG_InteractingAboutCode__c
        
        for(Case oCase : Trigger.new)
        {
            
            if (oCase.WFG_InteractingAbout__c == null)
            {
                Id idContact = [Select Id from Contact WHERE WFG_AgentCode__c = : oCase.WFG_InteractingAboutCode__c][0].Id;
                //System.debug(idContact);
                oCase.WFG_InteractingAbout__c = idContact;
            }
            
              if (oCase.ContactId == null )
            //if(oCase.On_Behalf_Of__c == NULL)
            {
                Contact thisContact = [Select Id from Contact WHERE WFG_AgentCode__c = : oCase.WFG_AgentCode__c][0];
                //System.debug(idContact);
                if (thisContact != null)
                {
                   oCase.ContactId = thisContact.Id;
                   //oCase.On_Behalf_Of__c = thisContact.Id;
                }
            }
        }
        //calling handler class
        WFG_CaseHandler.AssignCaseEntitlement(Trigger.new);   
        
    }
    
    if(Trigger.isafter){
        WFG_CaseHandler.CompleteMilestone(Trigger.new);
        if(trigger.isUpdate || trigger.isInsert){
            WFG_systemModeHelper.ShareCaseRecords(Trigger.new, trigger.newMap, trigger.oldMap);
        }
        //WFG_CaseShareHandler.ShareCaseRecords(Trigger.new);
        if(trigger.isUpdate)
            //WFG_CaseHandler.updateContactLastActivityDate(Trigger.new, trigger.oldMap);
            WFG_systemModeHelper.updateContactLastActivityDate(Trigger.new, trigger.oldMap);
    }
}