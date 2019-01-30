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
Bharat Madaan          M-001             12-08-2016              US-185: List of available FA for referral  
*/
public without sharing class WFG_ReferralSelection_Wrapper 
{    
    
    @AuraEnabled
    public List<WFG_NestedReferralSel_Wrapper> lstIndiFA = new List<WFG_NestedReferralSel_Wrapper>();
    
    
    
    @auraEnabled
    public Boolean boolIsStubOn = FALSE;
    @AuraEnabled
    public WFG_AD03_AgentRequestWrapper objReqWrapp = new WFG_AD03_AgentRequestWrapper();
    @AuraEnabled
    public List<WFG_AD03_AgentsResponseWrapper> lstResWrapp = new List<WFG_AD03_AgentsResponseWrapper>();
    
    /**
     * This constructor will add values to the list - lstIndiFA
     * @return - N/A
     * @see    - N/A
     * @param  - N/A
     * @throws - N/A
     */
   public WFG_ReferralSelection_Wrapper()
    {
        for(user objUser : [Select Id, firstname,lastname, Phone, Email, Street, City, State, Country, PostalCode
                    from USER 
                    WHERE isActive = true
                    AND profile.Name IN : WFG_FAProfileNames__c.getAll().keyset()])
        {
            lstIndiFA.add(new WFG_NestedReferralSel_Wrapper (objUser, 'xxxxxx'));
        }
    } 
}