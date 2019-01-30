/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Manish K
* @date 1-27-2017
* @description  Controller class for Lightning component to create a new Individual record

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Manish K             M-001              1-27-2017         US-508: CM - Customer Profile UI
*/
public with sharing class WFG_AgentCustomerProfileDetailController {

    
    /**
     * Method will check wheter the current user's profile is FA or not
     * @return - String
     * @see    - N/A
     * @param  - N/A
     * @throws - N/A
    */
    @AuraEnabled
    public static Boolean isFAUser(){
        
        Boolean isFAUser = false;
        String strProfileName = [SELECT Id, Name FROM Profile WHERE Id =: userInfo.getProfileId()].Name;

        if(WFG_FAProfileNames__c.getAll().keyset().contains(strProfileName)){
            isFAUser = true; 
        }
        
        return isFAUser;        
    }
    
    /**
     * Method will check whether the component is being run in a Community or not
     * @return - String
     * @see    - N/A
     * @param  - N/A
     * @throws - N/A
    */
    @AuraEnabled
    public static boolean isCommunity(){
        try{
            Id siteId = Site.getSiteId(); // only communities have a siteId
            if (siteId != null) {
                return true;
            }
        }        
        catch(Exception ex){
            LogUtility.createLog('EXCEPTION','Customer Profile','WFG_AgentCustomerProfileDetail', 'Error', ex.getMessage(), 'Error');
        }
        return false;
    }
    
    /**
     * Method will check wheter the current user's profile is LL or not
     * @return - String
     * @see    - N/A
     * @param  - N/A
     * @throws - N/A
    */
    @AuraEnabled
    public static Boolean isLLUser(){
        
        Boolean isLLUser = false;
        try{
        	String strProfileName = [SELECT Id, Name FROM Profile WHERE Id =: userInfo.getProfileId()].Name;
            if(WFG_LLProfileNames__c.getAll().keyset().contains(strProfileName)){
                isLLUser = true; 
            }
        }
        catch(Exception ex){
            LogUtility.createLog('EXCEPTION','Customer Profile','WFG_AgentCustomerProfileDetail', 'Error', ex.getMessage(), 'Error');
        	
            isLLUser = false;
        }
        
        return isLLUser;        
    }
    
    /**
     * Method to get User Country
     * @return - String
     * @see    - N/A
     * @param  - N/A
     * @throws - N/A
    */ 
    @AuraEnabled
    public static Boolean isUSUser(){
        
        try{
	        Boolean isUSUser = false;
	        String strProfileName = [SELECT Id, Name FROM Profile WHERE Id =: userInfo.getProfileId()].Name;
	        List<WFG_ProfilesCountry__mdt> lstProfileCountry = [SELECT Country__c FROM WFG_ProfilesCountry__mdt WHERE MasterLabel =: strProfileName];
	        
	        if(!lstProfileCountry.isEmpty() && lstProfileCountry[0].Country__c == 'United States'){
	           isUSUser = true; 
	        }
	        
	        return isUSUser;
        }
    	catch(Exception ex){
        	LogUtility.createLog('EXCEPTION','Customer Profile','WFG_AgentCustomerProfileDetail', 'Error', ex.getMessage(), 'Error');
        	return null;
        }
        
    }
    
	/**
     * Method to check Referral access 
     * @return - Boolean
     * @see    - N/A
     * @param  - N/A
     * @throws - N/A
    */ 
    @AuraEnabled
    public static Boolean checkReferralAccess(){
        
        try{
	        Boolean canRefer = false;
	        String strProfileName = [SELECT Id, Name FROM Profile WHERE Id =: userInfo.getProfileId()].Name;
            
	        List<WFG_ProfilesCountry__mdt> lstProfileCountry = [SELECT Can_Refer__c FROM WFG_ProfilesCountry__mdt WHERE MasterLabel =: strProfileName];
	        
	        if(!lstProfileCountry.isEmpty() && lstProfileCountry[0].Can_Refer__c){
	           canRefer = true; 
	        }
	        
	        return canRefer;
        }
        catch(Exception ex){
        	LogUtility.createLog('EXCEPTION','Customer Profile','WFG_AgentNewCustomerProfile', 'Error', ex.getMessage(), 'Error');
        	return null;
        }
    }
    
    @auraEnabled
    public static WFG_Customer_Profile__c getCustProfile(String idCustProfile)
    {
    	try{
       	 	return [SELECT Id,Name,WFG_advisors_to_contact_you__c,WFG_AnnualGrossIncome__c,WFG_Consent_for_FA_Contact__c,WFG_Consent_to_pass_contact_information__c,WFG_EmploymentStatus__c,WFG_GLI_Coverage_Amount__c,WFG_GroupOrPersonal__c,WFG_HomeOwnership__c,WFG_Interested_in_discussing_options__c,WFG_ListAccountTypes__c,WFG_NumberOfDependents__c,WFG_OwnDI__c,WFG_OwnLifeInsurance__c,WFG_OwnLTC__c,WFG_OwnQualifiedAssets__c,WFG_PLI_Coverage_Amount__c,WFG_Status__c FROM WFG_Customer_Profile__c WHERE Id=: idCustProfile];      
    	}
    	catch(Exception ex){
        	LogUtility.createLog('EXCEPTION','Customer Profile','WFG_AgentCustomerProfileDetail', 'Error', ex.getMessage(), 'Error');
        	return null;
        }
    }
    
    
    /**
     * Method to fetch Asset picklist value
     * @return - List of String
     * @see    - N/A
     * @param  - N/A
     * @throws - N/A
    */ 
    @AuraEnabled
    public static List<String> getAssetList(){
        	return WFG_PicklistFieldDescribeUtility.getPicklistValues('WFG_Customer_Profile__c', 'WFG_ListAccountTypes__c');
    }
}