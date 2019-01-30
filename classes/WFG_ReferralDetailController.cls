/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Nitesh Kumar
* @date 02-18-2017
* @description  Controller class for Referral details page.

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Nitesh Kumar           M-001             18-FEB-2017            Added a method to get the contact id of current customer
*/
public with sharing class WFG_ReferralDetailController {
	
    /**
     * This method fetch the referral details
     * @return - WFG_Referral__c
     * @see    - N/A
     * @param  - refId
     * @throws - N/A
     */
    @AuraEnabled
    public static WFG_Referral__c getReferralDetail(String refId){
        WFG_Referral__c referral = [SELECT  Id,Name, WFG_Contact__c, WFG_Contact__r.Name, WFG_Referred_To__r.Name, CreatedDate,
                                    WFG_Contact_First_Name__c,WFG_Contact_Last_Name__c,WFG_Customer_Profile__r.Name,WFG_Email__c,
                                    WFG_Home_Country__c,WFG_Primary_Phone__c,WFG_Referred_By__r.Name,WFG_Referred_From_Agent_Code__c,
                                    WFG_State__c,WFG_Status__c,WFG_Street_Address__c,WFG_Fiduciary_Contact__c,WFG_Zipcode__c,
                                    WFG_City__c,WFG_Sent_To_Compass__c,WFG_Customer_Profile__c
                                    FROM WFG_Referral__c 
                                    WHERE Id =: refId];
        return referral;
    }
    
     /**
     * This method cancel the referral
     * @return - WFG_ComponentResponseWrapper
     * @see    - N/A
     * @param  - refId, action
     * @throws - N/A
     */
    @AuraEnabled
    public static WFG_ComponentResponseWrapper cancelReferralAction(String refId, String action){
    	
	        WFG_ReferralResponseWrapper referralResponse = WFG_ReferralUtility.updateReferral(refId, action);
	        return referralResponse.objGenericRes;
    }
    
}