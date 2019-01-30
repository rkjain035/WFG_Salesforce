/**
@author Ninad Patil
@date 29-Dec-2016
@description Controller for lightning page Referral home page 

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Karthik Raj           Mod-01            06-JUL-2018               (W-26577) Sorting with CreatedDate to Display Referrals on HomePage instead of LastmodifiedDate
                                                                  and added getReferralListViewID to fetch the referral All list view.

*/
public with sharing class WFG_ReferralHomePage_Controller 
{
    /**
     * This Method will fetch all the referrals for logged in User.
     * @return - List<WFG_Referral>
     * @see    - NA
     * @param  - NA
     * @throws - NA
     */
    @AuraEnabled
    public static List<WFG_Referral__c> getReferrals()
    {
        List<WFG_Referral__c> lstPending = new List<WFG_Referral__c>();
        List<WFG_Referral__c> lstRest = new List<WFG_Referral__c>();
        List<WFG_Referral__c> lstRefferal = [Select Id, Name,
                WFG_Referred_To__c,WFG_Referred_To__r.Name,CreatedDate,
                WFG_Referred_By__r.Name,WFG_Primary_Phone__c,WFG_Email__c,   
                WFG_Contact_First_Name__c,WFG_Contact_Last_Name__c, WFG_Status__c
                FROM WFG_Referral__c 
                WHERE (WFG_Referred_To__c = :UserInfo.getUserId() OR WFG_Referred_By__c =:UserInfo.getUserId()) 
                	AND (WFG_Status__C IN (	:system.Label.WFG_ReferralStatus_Referred,
                							:system.Label.WFG_ReferralStatus_Rejected,
                							:system.label.WFG_ReferralStatus_Accepted))
                Order BY CreatedDate DESC]; // Sorting with CreatedDate to Display Referrals on HomePage
        for(WFG_Referral__c objRef : lstRefferal)
        {
            if(objRef.WFG_Status__C == System.Label.WFG_ReferralStatus_Referred) lstPending.add(objRef);
            else lstRest.add(objRef);
        }
        lstRefferal = new List<WFG_Referral__c>();
        lstRefferal.addAll(lstPending);
        lstRefferal.addAll(lstRest);
        return lstRefferal;
    }
    
    @AuraEnabled
    public static boolean checkNRFProfile()
    {
        Boolean isBoolIsNRF = true;
    	//Boolean isBoolIsNRF =  WFG_AgentCustomerProfileDetailController.checkReferralAccess();
    	String usrProfileName = [select Profile.Name from User u where id = :Userinfo.getUserId()].Profile.Name;
        system.debug('## :' + usrProfileName); 
    	if(usrProfileName.contains('_NRF'))
    	{
            isBoolIsNRF = false;
            system.debug('###### canrefer :: ' + isBoolIsNRF);
    		return isBoolIsNRF;
    	}else if(usrProfileName.contains('CAN'))
    	{
            isBoolIsNRF = false;
            system.debug('###### canrefer :: ' + isBoolIsNRF);
    		return isBoolIsNRF;
    	}
    	return isBoolIsNRF;
    }
    
    /**
     * This method is used to display a list view of all Referral when ViewAll button is clicked from Referral tile HomePage
     * @return - List<WFG_Referral>
     * @see    - NA
     * @param  - NA
     * @throws - NA
     */
    @AuraEnabled
    public static String getReferralListViewID()
    {
        return [select id from ListView where SObjectType = 'WFG_Referral__c' and DeveloperName = 'All'].Id;
    }
}