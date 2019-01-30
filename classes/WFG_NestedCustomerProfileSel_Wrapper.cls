/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author bmadaan
* @date 12-08-2016
* @description  Controller class for Customer Profile Selection screen

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Travis Lowe        M-001             4-19-2016              US-185: List of available Customer Profile for Opportunity  
*/
public class WFG_NestedCustomerProfileSel_Wrapper {

    @AuraEnabled
    public Contact objConRecord;
    @AuraEnabled
    public WFG_Customer_Profile__c objCPRecord;
    @AuraEnabled
    public boolean boolIsSelect;
    /**
     * This methodis parametrized constructor
     * @return - NA
     * @see    - N/A
     * @param  - objuser : CustomerProfile record
     * @throws - N/A
     */
    public WFG_NestedCustomerProfileSel_Wrapper (WFG_Customer_Profile__c objCP)
    {
        objCPRecord = objCP;
        this.boolIsSelect = false;
    }
}