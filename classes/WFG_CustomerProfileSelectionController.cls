public class WFG_CustomerProfileSelectionController {

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
travis Lowe         M-001             4-19-2016              US-185: List of available CustomerProfile for Opportunity  
*/

    /**
    @author Ninad Patil
    @date 22-Dec-2016
    @description Executed on Trigger Context - After Insert. 
    @return - WFG_ReferralResponseWrapper
    @param  - strCustomerProfileRecordId : customer profiel ID
    @param  - actionName : Action performed on Customer Profile record
    @throws - N/A
    @author Ninad
    */
    @AUraEnabled
    public static WFG_CustomerProfileResponseWrapper getCustomerProfiles(string opptyId){
        WFG_CustomerProfileResponseWrapper objRes = null;
        //check if oppty is in an associable state
        if(isOpptyAssociable(opptyId))
        {
            //continue
            string contactId = getContactIdForOpportunity(opptyId);
            objRes = new WFG_CustomerProfileResponseWrapper(contactId);
            objRes.contactId = contactId;   
        }
        else
        {
           //set an error
           objRes = new WFG_CustomerProfileResponseWrapper(null);
           objRes.objGenericRes.boolIsError = true; 
           objRes.objGenericRes.strErrorMessage = 'Customer Profile cannot be associated with this Opportunity.'; 
            
        }
        return objRes;
    }
    
    
    /**
     * Method to see if Opportunity is in a proper state to have a CP associated
     * @return - boolean
     * @see    - N/A
     * @param  - String idOpportunity
     * @throws - N/A
    */ 
    @auraEnabled
    public static Boolean isOpptyAssociable(String idOpportunity){
        
        Opportunity rslt = [SELECT Id, Name, IsClosed
                FROM Opportunity WHERE Id=: idOpportunity LIMIT 1]; 
        if(rslt.IsClosed){
            return false;
        }
        else
        {
            return true;
        }
    }
    
    @AUraEnabled
    public static WFG_CustomerProfileResponseWrapper updateOpptyWithCP(string opptyId, string cpId){
   
        string contactId = getContactIdForOpportunity(opptyId);
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
     * Method to get Contact for Opportunity
     * @return - id string
     * @see    - N/A
     * @param  - String idOpportunity
     * @throws - N/A
    */ 
    @auraEnabled
    public static String getContactIdForOpportunity(String idOpportunity){
        
        Opportunity rslt = [SELECT Id, Name, WFG_Contact__c
                FROM Opportunity WHERE Id=: idOpportunity LIMIT 1];  
        return rslt.WFG_Contact__c;
    }
    
}