/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Saurabh Sharma
* @date 1-30-2017
* @description  Controller class for Lightning component to create a new Individual record

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Saurabh Sharma        M-001             1-30-2017         US-405: Create new Customer Profile for Customer 
*/
public with sharing class WFG_AgentNewCustomerProfileController {
    
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
        List<WFG_ProfilesCountry__mdt> lstProfileCountry = [SELECT Country__c FROM WFG_ProfilesCountry__mdt WHERE MasterLabel =: strProfileName];
        
        if(!lstProfileCountry.isEmpty() && lstProfileCountry[0].Country__c == 'United States'){
            isUSUser = true; 
        }
        
        return isUSUser;        
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
        Id siteId = Site.getSiteId(); // only communities have a siteId
        if (siteId != null) {
            return true;
        }
        return false;
    }
    
    @AuraEnabled
    public static string ProfileType(){
        
        string strProfile = '';
        try{
            String strProfileName = [SELECT Id, Name FROM Profile WHERE Id =: userInfo.getProfileId()].Name;
            if(WFG_LLProfileNames__c.getAll().keyset().contains(strProfileName)){
                strProfile = 'LL';
            }
            if(WFG_FAProfileNames__c.getAll().keyset().contains(strProfileName)){
                strProfile = 'FA';
            }
        }
        catch(Exception e){
            strProfile = '';
        }
        return strProfile;
    }
    /**
     * Method will check wheter the current user's profile is LL or not
     * @return - String
     * @see    - N/A
     * @param  - N/A
     * @throws - N/A
    */
   /* @AuraEnabled
    public static Boolean isLLUser(){
        
        Boolean isLLUser = false;
        try{
            String strProfileName = [SELECT Id, Name FROM Profile WHERE Id =: userInfo.getProfileId()].Name;
            if(WFG_LLProfileNames__c.getAll().keyset().contains(strProfileName)){
                isLLUser = true; 
            }
        }
        catch(Exception e){
            isLLUser = false;
        }
        
        return isLLUser;        
    }*/
    /**
     * Method will check wheter the current user's profile is FA or not
     * @return - String
     * @see    - N/A
     * @param  - N/A
     * @throws - N/A
    */
    /*@AuraEnabled
    public static Boolean isFAUser(){
        
        Boolean isFAUser = false;
        String strProfileName = [SELECT Id, Name FROM Profile WHERE Id =: userInfo.getProfileId()].Name;

        if(WFG_FAProfileNames__c.getAll().keyset().contains(strProfileName)){
            isFAUser = true; 
        }
        system.debug('===isFAUser ==='+isFAUser );
        return isFAUser;        
    }*/
    /**
     * Method to check Referral access 
     * @return - Boolean
     * @see    - N/A
     * @param  - N/A
     * @throws - N/A
    */ 
    @AuraEnabled
    public static Boolean checkReferralAccess(){
        
        Boolean canRefer = false;
        String strProfileName = [SELECT Id, Name FROM Profile WHERE Id =: userInfo.getProfileId()].Name;
        List<WFG_ProfilesCountry__mdt> lstProfileCountry = [SELECT Can_Refer__c FROM WFG_ProfilesCountry__mdt WHERE MasterLabel =: strProfileName];
        System.debug('#Can Refer '+lstProfileCountry[0].Can_Refer__c + '  Profile '+strProfileName);
        if(!lstProfileCountry.isEmpty() && lstProfileCountry[0].Can_Refer__c){
            canRefer = true; 
        }
        system.debug('===canRefer ==='+canRefer );
        return canRefer;
    }
    
    @AuraEnabled
    public static list<CPPicklistWrapper> getPicklistValue(){
        
        system.debug('=======in====');
        list<CPPicklistWrapper> lstCPPicklistWrapper = new list<CPPicklistWrapper>();
        list<string> lstString = new list<String>{'WFG_EmploymentStatus__c', 'WFG_GroupOrPersonal__c', 'WFG_ListAccountTypes__c'};
        for(string str : lstString){
            list<string> lstPickVals = WFG_PicklistFieldDescribeUtility.getPicklistValues('WFG_Customer_Profile__c', str);
         
            lstCPPicklistWrapper.add(new CPPicklistWrapper(str, lstPickVals));
        }
        return lstCPPicklistWrapper;
        
    }
    /**
     * Method to fetch Employment Status picklist value
     * @return - List of String
     * @see    - N/A
     * @param  - N/A
     * @throws - N/A
    */ 
    @AuraEnabled
    public static List<String> getEmploymentStatus(){
            return WFG_PicklistFieldDescribeUtility.getPicklistValues('WFG_Customer_Profile__c', 'WFG_EmploymentStatus__c');
    }
    
    /**
     * Method to fetch Insurance picklist value
     * @return - List of String
     * @see    - N/A
     * @param  - N/A
     * @throws - N/A
    */ 
    @AuraEnabled
    public static List<String> getInsuranceType(){
            return WFG_PicklistFieldDescribeUtility.getPicklistValues('WFG_Customer_Profile__c', 'WFG_GroupOrPersonal__c');
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
    
    /**
     * Method to create new Customer Profile record
     * @return - Class
     * @see    - N/A
     * @param  - String customerProfile, Id contact
     * @throws - N/A
    */ 
    @AuraEnabled
    public static WFG_CreateCPResponseWrapper createNewCustomerProfile(String strCustomerProfile, Id idContact, Id idOpportunity){
        
        try{            
            WFG_Customer_Profile__c objCustomerProfile = (WFG_Customer_Profile__c)JSON.deserialize(strCustomerProfile, WFG_Customer_Profile__c.class);
            objCustomerProfile.WFG_Contact__c = idContact;
            System.debug('#Customer Profile '+objCustomerProfile+' id'+idContact);
            
            //set GLI and PLI value to blank if coming as 0
            objCustomerProfile.WFG_PLI_Coverage_Amount__c = objCustomerProfile.WFG_PLI_Coverage_Amount__c == 0.0 ? null : objCustomerProfile.WFG_PLI_Coverage_Amount__c;
            objCustomerProfile.WFG_GLI_Coverage_Amount__c = objCustomerProfile.WFG_GLI_Coverage_Amount__c == 0.0 ? null : objCustomerProfile.WFG_GLI_Coverage_Amount__c;
            
            WFG_CreateCPResponseWrapper objRes = new WFG_CreateCPResponseWrapper();
            
            if(idContact != NULL){                              
                
                insert objCustomerProfile;
                objRes.objGenericRes.strSuccessMessage = 'Customer Profile Successfully Created';
                objRes.objCustProfile = objCustomerProfile;                
            }
            
            if(idOpportunity != NULL && objCustomerProfile.Id != NULL){
                Opportunity objOppt = new Opportunity(Id = idOpportunity);
                objOppt.WFG_CustomerProfile__c = objCustomerProfile.Id;
                
                update objOppt;
            }
            
            return objRes;
            
        }catch(DMLException dex){
            WFG_CreateCPResponseWrapper objRes = new WFG_CreateCPResponseWrapper();
            objRes.objGenericRes.strErrorMessage = dex.getDmlMessage(0);
            objRes.objGenericRes.boolIsError = true;
            LogUtility.createLog('DML','Customer Profile','WFG_AgentNewCustomerProfile', 'Error', dex.getDmlMessage(0), 'Error');
            return objRes;
        }        
        catch(Exception ex){
            WFG_CreateCPResponseWrapper objRes = new WFG_CreateCPResponseWrapper();
            objRes.objGenericRes.strErrorMessage = ex.getMessage();
            objRes.objGenericRes.boolIsError = true;
            LogUtility.createLog('EXCEPTION','Customer Profile','WFG_AgentNewCustomerProfile', 'Error', ex.getMessage(), 'Error');
            return objRes;
        }
    }
    
    
    /**
     * Method to get Customer Profile record
     * @return - WFG_Customer_Profile__c
     * @see    - N/A
     * @param  - String idcustomerProfile
     * @throws - N/A
    */ 
    @auraEnabled
    public static WFG_Customer_Profile__c getcustomerProfile(String idcustomerProfile){
        
        return [SELECT Id,Name,WFG_Contact__c,WFG_advisors_to_contact_you__c,WFG_AnnualGrossIncome__c,WFG_Consent_for_FA_Contact__c,WFG_Consent_to_pass_contact_information__c,WFG_EmploymentStatus__c,
                WFG_GLI_Coverage_Amount__c,WFG_GroupOrPersonal__c,WFG_HomeOwnership__c,WFG_Interested_in_discussing_options__c,WFG_ListAccountTypes__c,WFG_NumberOfDependents__c,WFG_OwnDI__c,
                WFG_OwnLifeInsurance__c,WFG_OwnLTC__c,WFG_OwnQualifiedAssets__c,WFG_PLI_Coverage_Amount__c,WFG_Status__c FROM WFG_Customer_Profile__c WHERE Id=: idcustomerProfile];            
    }
    
    
    /**
     * Method to create update Customer Profile record
     * @return - Class
     * @see    - N/A
     * @param  - String customerProfile, Id contact
     * @throws - N/A
    */ 
    @AuraEnabled
    public static WFG_CreateCPResponseWrapper updateNewCustomerProfile(String strCustomerProfile){
        
        try{            
            WFG_Customer_Profile__c objCustomerProfile = (WFG_Customer_Profile__c)JSON.deserialize(strCustomerProfile, WFG_Customer_Profile__c.class);
            
            //set GLI and PLI value to blank if coming as 0
            objCustomerProfile.WFG_PLI_Coverage_Amount__c = objCustomerProfile.WFG_PLI_Coverage_Amount__c == 0.0 ? null : objCustomerProfile.WFG_PLI_Coverage_Amount__c;
            objCustomerProfile.WFG_GLI_Coverage_Amount__c = objCustomerProfile.WFG_GLI_Coverage_Amount__c == 0.0 ? null : objCustomerProfile.WFG_GLI_Coverage_Amount__c;
            
            WFG_CreateCPResponseWrapper objRes = new WFG_CreateCPResponseWrapper();
            
            update objCustomerProfile;
            objRes.objGenericRes.strSuccessMessage = 'Customer Profile Successfully Updated';
            objRes.objCustProfile = objCustomerProfile;                
            
            return objRes;
            
        }catch(DMLException dex){
            WFG_CreateCPResponseWrapper objRes = new WFG_CreateCPResponseWrapper();
            objRes.objGenericRes.strErrorMessage = dex.getDmlMessage(0);
            objRes.objGenericRes.boolIsError = true;
            LogUtility.createLog('EXCEPTION','Customer Profile','WFG_AgentNewCustomerProfile', 'Error', dex.getDmlMessage(0), 'Error');
            return objRes;
        }        
        catch(Exception ex){
            WFG_CreateCPResponseWrapper objRes = new WFG_CreateCPResponseWrapper();
            objRes.objGenericRes.strErrorMessage = ex.getMessage();
            objRes.objGenericRes.boolIsError = true;
            LogUtility.createLog('EXCEPTION','Customer Profile','WFG_AgentNewCustomerProfile', 'Error', ex.getMessage(), 'Error');
            return objRes;
        }
    }

    @AuraEnabled
    public static String updateOpportunity(String idOpportunity, String stageName){

        try {            
            Opportunity oppty = [Select Id, StageName, WFG_ModalName__c From Opportunity Where Id =: idOpportunity];
            oppty.StageName = stageName;
            oppty.WFG_ModalName__c = null;
            update oppty;
            return 'Update Opportunity.';
        } catch(Exception ex){
            return ex.getMessage();
        }
    }

    @AuraEnabled
    public static String changeModalNameBack(String idOpportunity) {
        try {
            Opportunity oppt = [Select Id, WFG_ModalName__c From Opportunity Where Id =: idOpportunity];
            oppt.WFG_ModalName__c = null;
            update oppt;

            return 'The Opportunity Modal Name change back to null';
        } catch(Exception e){
            return 'Error: ' + e.getMessage();
        }

    }
       
    
    
    /**
     * Method to check the eligibility of the customer to refer
     * @return - boolean
     * @see    - N/A
     * @param  - idCustProfile
     * @throws - N/A
    */ 
    @AuraEnabled
    public static boolean isCustomerEligibleForReferral(String idCustProfile){
        
       try{
            Boolean isUSSUer = WFG_AgentCustomerProfileDetailController.isUSUser();
            Set<String> activeReferralsStatus = WFG_Active_Referrals__c.getAll().keyset();
            WFG_Customer_Profile__c objCustomerProfile = [  SELECT WFG_advisors_to_contact_you__c,
                                                                WFG_Status__c,
                                                                WFG_Consent_for_FA_Contact__c,
                                                                WFG_Consent_to_pass_contact_information__c,
                                                                WFG_Interested_in_discussing_options__c,
                                                                WFG_ListAccountTypes__c,
                                                                WFG_OwnQualifiedAssets__c,
                                                                (SELECT Id from Referrals__r WHERE WFG_Status__c IN :activeReferralsStatus) 
                                                            FROM WFG_Customer_Profile__c 
                                                            WHERE Id=: idCustProfile];
            
            if(objCustomerProfile != null 
                && isUSSUer
                    && WFG_AgentCustomerProfileDetailController.checkReferralAccess()
                        && objCustomerProfile.WFG_Status__c == 'Complete'
                            && objCustomerProfile.Referrals__r.size() == 0
                                && objCustomerProfile.WFG_advisors_to_contact_you__c == 'Yes' 
                                    && objCustomerProfile.WFG_Consent_for_FA_Contact__c == 'Yes' 
                                        && objCustomerProfile.WFG_Consent_to_pass_contact_information__c == 'Yes' 
                                            && objCustomerProfile.WFG_Interested_in_discussing_options__c == 'Yes' 
                                                && objCustomerProfile.WFG_OwnQualifiedAssets__c == 'Yes'
                                                    && objCustomerProfile.WFG_ListAccountTypes__c != null){
                return true;
            }
            else{
                return false;
            }
       }
        catch(Exception ex){
            LogUtility.createLog('EXCEPTION','Customer Profile','WFG_AgentNewCustomerProfile', 'Error', ex.getMessage(), 'Error');
            return null;
        }
    }
    
    /**
     * Method to check the the customer profile is editabel or not
     * @return - boolean
     * @see    - N/A
     * @param  - idCustProfile
     * @throws - N/A
    */ 
    @AuraEnabled
    public static boolean isNonEdtable(String idCustProfile){
        WFG_Customer_Profile__c objCustomerProfile = [  SELECT WFG_Status__c FROM WFG_Customer_Profile__c WHERE Id=: idCustProfile];
        if(objCustomerProfile != null && objCustomerProfile.WFG_Status__c == 'Complete'){
            return true;
        }
        else{
            return false;   
        }
    }
    
    /**
     * Method to fetch all individual records
     * @return - List of String
     * @see    - N/A
     * @param  - N/A
     * @throws - N/A
    */    
    @AuraEnabled
    public static List<Contact> getAllIndividuals(){
        
        string strLoggedInUserId = userinfo.getuserid();
        return [SELECT Id, Name FROM Contact WHERE RecordType.Name = 'Individual' AND OwnerId =: strLoggedInUserId];
    }
    
    
    @AUraEnabled
    public static WFG_CustomerProfileResponseWrapper updateOpptyWithCP(string opptyId, string cpId, String contactId){
        
        system.debug('---' + opptyId + '  ---  ' + cpId + ' --- ' + contactId);
        
        WFG_CustomerProfileResponseWrapper objRes = new WFG_CustomerProfileResponseWrapper(contactId);
        objRes.objGenericRes.boolIsError = FALSE;
        objRes.objGenericRes.strErrorMessage = '';
       try
       {
           
               Opportunity objRef =  new Opportunity();
               objRef = [SELECT Id, Name, WFG_Contact__c, WFG_CustomerProfile__c
                 FROM Opportunity WHERE Id = : opptyId];
               objRef.WFG_CustomerProfile__c = cpId;
               UPDATE objRef;
               objRes.objOppty = objRef;
               objRes.objGenericRes.boolIsError = false;
               objRes.objGenericRes.strSuccessMessage = System.Label.WFG_ReferralUpdate_SuccMsg;              
                      
       }
       //Handles the DML Operation
        catch(DMLException de)
        {      
            //For loop to get all the DML error messages and put them in proper format
            for(Integer i=0; i < de.getNumDml(); i++)
            {
                objRes.objGenericRes.strErrorMessage = objRes.objGenericRes.strErrorMessage + de.getDmlMessage(i) + '\n';
            }
            //Populates the Error variables
            objRes.objGenericRes.boolIsError = TRUE;
            objRes.objGenericRes.strErrorMessage = objRes.objGenericRes.strErrorMessage.removeEnd('\n');
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_CustomerProfile__c', 'EXCEPTION', 'APEX',objRes.objGenericRes.strErrorMessage, objRes.objGenericRes.strErrorMessage, null, null, null, true);
        }
        //Handles all other exceptions
        catch(Exception e){
            //Populates the Error variables
            objRes.objGenericRes.boolIsError = TRUE;
            objRes.objGenericRes.strErrorMessage = e.getMessage(); 
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_CustomerProfile__c', 'EXCEPTION', 'APEX',e.getMessage(), e.getMessage(), null, null, null, true);
        } 
       //Returns the updated Wrapper Instance with Error variables and Id variables
        return objRes;
   }
   
   public class CPPicklistWrapper{
       @AuraEnabled
       public string strPicklistName { get; set;}
       @AuraEnabled
       public list<string> lstPicklstVal  { get; set;}
       public CPPicklistWrapper(string strPicklistName, list<string> lstPicklstVal){
           this.strPicklistName = strPicklistName;
           this.lstPicklstVal = lstPicklstVal;
       }
    }
    
}