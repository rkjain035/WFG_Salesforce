/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author bmadaan
* @date 12-08-2016
* @description  Controller class for Referral Selection screen

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Ninad Patil         M-001             12-08-2016              US-185: List of available FA for referral  
*/
public class WFG_NestedReferralSel_Wrapper {

    @AuraEnabled
    public Contact objConReocrd;
    @AuraEnabled
    public User objUserReocrd;
    @AuraEnabled
    public boolean boolIsSelect;
    @AuraEnabled
    public string isRelation;
    /**
     * This methodis parametrized constructor
     * @return - NA
     * @see    - N/A
     * @param  - objuser : User record
     * @param  - strRelation : relation (upline/Downline)
     * @throws - N/A
     */
    public WFG_NestedReferralSel_Wrapper (User objuser, string strRelation)
    {
        objUserReocrd = objuser;
        this.isRelation = strRelation;
        this.boolIsSelect = false;
    }
}