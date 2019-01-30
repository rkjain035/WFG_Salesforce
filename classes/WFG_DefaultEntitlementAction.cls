/**
 *
 Property of Transamerica and Aegon companies. Do not distribute without permission.
 * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
 * @author Deloitte Consulting LLP
 * @date 05/26/2016
 * @description US-2300, US-2301: This class is written for assigning the apropriate entitlement to the case 
 Modification Log:
 -------------------------------------------------------------------------------------------------------
 Developer          ModNumber           Date                    Description
 -------------------------------------------------------------------------------------------------------
 Suhan Jain          M-001              05/26/2016              initial virsion
 *
 **/

public with sharing class WFG_DefaultEntitlementAction {
    @InvocableMethod(label='Update Default Entitlements' description='Determines the default Entitlement for the Case and returns the updated Cases.')
    
    /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Method to update the default Entitlement for a Case based on the WFG_RelatedEntitlement__c formula field
    * @author Deloitte Consulting LLP
    * @date 05/26/2016
    * @param Case list from Process Builder
    * @return No Return
    * @description US-2300, US-2301: entitlement assignment on case creation.
    */
    public static void updateDefaultEntitlements(List<Case> lstCasesToUpdate) {
        List<Case> lstCases = [ 
            SELECT WFG_RelatedEntitlement__c, EntitlementId 
            FROM Case 
            WHERE Id = : new Map<Id, Case>(lstCasesToUpdate).keySet() 
        ];
        
        if(lstCases.size() > 0) {    
            for (Case c : lstCases){
                if (c.EntitlementId == null) {
                    List <Entitlement> lstEntitlements = [
                        SELECT Id
                        FROM Entitlement
                        WHERE Name = : c.WFG_RelatedEntitlement__c AND Status = 'Active'
                    ];
                    
                    if(lstEntitlements.size() > 0) {
                        for (Entitlement entitlement : lstEntitlements) {
                            try {
                                c.EntitlementId = entitlement.ID;
                            } catch (DmlException e) {
                                e.getmessage();
                            }
                        }
                    }
                }
            }
        	update lstCases;
        }
    }
}