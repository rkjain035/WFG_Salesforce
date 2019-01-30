/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author bmadaan
* @date 12-08-2016
* @description  Wrapper class for Referral Selection screen

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Travis Lowe          M-001             04/19-2016              US-185: List of available Customer Profiles for Opportunity  
*/
public without sharing class WFG_CustomerProfileSelection_Wrapper 
{    
    
    @AuraEnabled
    public List<WFG_NestedCustomerProfileSel_Wrapper> lstIndiFA = new List<WFG_NestedCustomerProfileSel_Wrapper>();
    
    /**
     * This constructor will add values to the list - lstIndiFA
     * @return - N/A
     * @see    - N/A
     * @param  - N/A
     * @throws - N/A
     */
    public WFG_CustomerProfileSelection_Wrapper(string contactId)
    {
        if(contactId != null){
            for(WFG_Customer_Profile__c objCP : [Select Id, Name, CreatedDate 
                        FROM WFG_Customer_Profile__c                         
                        WHERE WFG_Status__c = 'Complete'
                          AND WFG_Contact__r.Id = :contactId
                        ORDER BY CreatedDate DESC
                        ])
            {
                lstIndiFA.add(new WFG_NestedCustomerProfileSel_Wrapper (objCP));
            }
        }
    }
}