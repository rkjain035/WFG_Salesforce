/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author bmadaan
* @date 
* @description Controller for Agent Customer Profile

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Bharat Madaan			M-001									Controller for Agent Customer Profile
JR Mayhew				M-002									Get brand from current user
*/
public class WFG_AgentCustomerProfileController {
	
	/**
     * Method to fetch all customer profile records
     * @return - List of Customer Profile
     * @see    - N/A
     * @param  - contId
     * @throws - N/A
    */
    @AuraEnabled
    public static List<WFG_Customer_Profile__c> getCustomerProfiles(String contId){
        
        return [SELECT Id, Name, WFG_Status__c, CreatedDate FROM WFG_Customer_Profile__c WHERE WFG_Contact__c =: contId ORDER BY CreatedDate DESC LIMIT 5];
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
        
        Boolean isUSUser = false;
        String strProfileName = [SELECT Id, Name FROM Profile WHERE Id =: userInfo.getProfileId()].Name;
        List<WFG_ProfilesCountry__mdt> lstProfileCountry = [SELECT Country__c FROM WFG_ProfilesCountry__mdt WHERE MasterLabel =: strProfileName LIMIT 1];
        
        if(!lstProfileCountry.isEmpty() && lstProfileCountry[0].Country__c == 'United States'){
           isUSUser = true; 
        }
        
        return isUSUser;
    }
    
     /** Added by JR Mayhew 3/12
     * Method to get User branding
     * @return - String
     * @see    - N/A
     * @param  - N/A
     * @throws - N/A
    */
    @AuraEnabled
    public static User getBrandUser() {
      User user = [SELECT Id, FirstName, LastName, WFG_Branding__c, ProfileId FROM User WHERE Id =: userInfo.getUserId() LIMIT 1];
      return user;
  }
    
}