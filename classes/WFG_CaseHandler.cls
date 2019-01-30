/**
 *
 Property of Transamerica and Aegon companies. Do not distribute without permission.
 * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
 * @author Deloitte Consulting LLP
 * @date 05/26/2016
 * @description US-2300, US-2301: this class is assigncaseentitlement handler class. This class is written for assigning the apropriate entitlement to the case 
 Modification Log:
 -------------------------------------------------------------------------------------------------------
 Developer          ModNumber           Date                    Description
 -------------------------------------------------------------------------------------------------------
 Suhan Jain          M-001              05/26/2016              Initial version

 **/
public with sharing class WFG_CaseHandler {

     /**
     *
     Property of Transamerica and Aegon companies.Do not distribute without permission.
     * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
     * methode which trigger the corresponding handler class before insert
     * @author Deloitte Consulting LLP
     * @date 05/26/2016
     * @param Case object from the trigger
     * @return No Return
     * @description US-2300, US-2301: entitlement assignment on case creation.
     */
    public static void AssignCaseEntitlement(Case[] lstCase) {
        
        //Get All Entitlements with Status Active
        List<Entitlement> lstEntitlement = [select Name,Id from Entitlement where Name IN:WFG_EntitlementName__c.getall().keySet()];
        Map<String,Id> mapEntitlement =  new Map<String,Id>();
        for(Entitlement entitlements: lstEntitlement )
        {
            mapEntitlement.put(entitlements.Name, entitlements.Id);
        } 
        for (Case cases: lstCase) {  
            if(cases.Status != 'Closed') {
                cases.EntitlementId = mapEntitlement.get(cases.WFG_RelatedEntitlement__c);
            }
        }
    }
    
    /**
     *
     Property of Transamerica and Aegon companies.Do not distribute without permission.
     * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
     * methode which trigger the corresponding handler class before insert
     * @author Deloitte Consulting LLP
     * @date 07/19/2016
     * @param Case object from the trigger
     * @return No Return
     * @description US-2365: This updates the Milestones to Completed if the Cases are Closed.
     */
    public static void CompleteMilestone(Case[] lstCase) {
        
        //Update the Milestones to completed when Cases are Closed
        if (UserInfo.getUserType() == 'Standard'){
            DateTime completionDate = System.now(); 
            List<Id> updateCases = new List<Id>();
            for (Case c : lstCase){
                if (((c.isClosed == true)||(c.Status == 'Closed'))&&((c.SlaStartDate <= completionDate)&&(c.SlaExitDate == null)))
                    updateCases.add(c.Id);
            }
            if (updateCases.isEmpty() == false)
                WFG_MilestoneUtils.completeMilestone(updateCases, 'Resolution Time', completionDate);
        }
    } 
    
    public static void updateContactLastActivityDate(Case[] lstCase, map<id, Case> mapOldCase)
    {
        list<Contact> lstContact = new list<Contact>();
        for(Case newCase : lstCase){
            case oldCase = mapOldCase.get(newCase.Id);
            
            if(newCase.WFG_LastActivityDate__c != oldCase.WFG_LastActivityDate__c){
                Contact con = new Contact();
               // con.Id = newCase.ContactId;
                con.Id = newCase.On_Behalf_Of__c;
                con.WFG_LastContactedDate__c = newCase.WFG_LastActivityDate__c;
                lstContact.add(con);
            }
        }
        
        if(lstContact.size() > 0){
            try{
                update lstContact;
            }  catch(Exception e) {
                system.debug('+++ Execption ++' + e);
                LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_SystemModeHelper', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
            }
        }
    }
}