/**
* Property of Transamerica and Aegon companies. Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Nitesh Kumar
* @date   1st Mar 2017
* @description This class is created to serve the purpose of edit opportunity functionality.
Modification Log:
------------------------------------------------------------------------------------
Developer		Mod Number		Date		       Description
------------------------------------------------------------------------------------
Nitesh Kumar     M-001			1st Mar 2017 	 Created the Class and added methods.

*/

public with sharing class WFG_OpportunityEditModelController {
   
     /**
     * Method to fetch the opportunity
     * @return - Opportunity
     * @see    - N/A
     * @param  - oppId
     * @throws - N/A
    */ 
    
    @AuraEnabled
    public static List<String> getIsLicensedPicklistValues() {
        return WFG_PicklistFieldDescribeUtility.getPicklistValues('Opportunity', 'Is_the_person_licensed__c');
    }
    
    @AuraEnabled
    public static Opportunity getOpportunity(String oppId){
        return [	SELECT Id, Name, WFG_Contact__c,Amount,WFG_Lost_Reason__c,Probability,CreatedDate, StageName,WFG_CustomerProfile__r.WFG_Status__c,WFG_CustomerProfile__r.Name, CloseDate,WFG_CustomerProfile__c,AccountId,RecordType.Name, OpportunityReTypeDisplay__c,  WFG_Product_Type__c, Description, Is_the_person_licensed__c
        			FROM Opportunity WHERE Id = :oppId];
    }
    
    
     /**
     * Method to fetch the customer related to the contact of the opportunity
     * @return - List of WFG_Customer_Profile__c
     * @see    - N/A
     * @param  - oppId
     * @throws - N/A
    */ 
    @AuraEnabled
    public static List<WFG_Customer_Profile__c> getAllCustomerProfiles(String oppId){
    	
    	try{
	        Opportunity objOpp = getOpportunity(oppId);
	        return [SELECT Id, Name, WFG_Status__c FROM WFG_Customer_Profile__c WHERE WFG_Contact__c = :objOpp.WFG_Contact__c AND WFG_Status__c='Complete'];
    	}
    	catch(Exception ex){
        	LogUtility.createLog('EXCEPTION','Opportunity','WFG_EditOpportunity', 'Error', ex.getMessage(), 'Error');
        	return null;
        }
    }

    
    /**
     * Method to fetch select customer status
     * @return - List of String
     * @see    - N/A
     * @param  - N/A
     * @throws - N/A
    */ 
    @AuraEnabled
    public static String getCustomerStatus(String customerId){   
    	try{
	        return [SELECT Id, Name, WFG_Status__c FROM WFG_Customer_Profile__c WHERE Id = :customerId].WFG_Status__c;
	    }
	    catch(Exception ex){
	        	LogUtility.createLog('EXCEPTION','Opportunity','WFG_EditOpportunity', 'Error', ex.getMessage(), 'Error');
	        	return null;
	        }
    }
    
    
    /**
     * Method to Update Opportunity
     * @return - List of String
     * @see    - N/A
     * @param  - customerId
     * @throws - N/A
    */ 
    @AuraEnabled
    public static WFG_OpportunityResponseWrapper updateOpportunity(Opportunity opportunityData, String customerProfileId){  
    	
    	try{
    		system.debug('customerProfileId -> ' + customerProfileId);
    		    
    		WFG_OpportunityResponseWrapper objRes = new WFG_OpportunityResponseWrapper();
    		if(customerProfileId != null){
				opportunityData.WFG_CustomerProfile__c = customerProfileId;
    		}
    		else{
    			opportunityData.WFG_CustomerProfile__c = null;
    		}
	        update opportunityData;
	        objRes.objGenericRes.strSuccessMessage = 'Customer Profile Successfully Updated';
            objRes.objOpportunity = opportunityData;                
            return objRes;
    	}
    	catch(DMLException dex){
            WFG_OpportunityResponseWrapper objRes = new WFG_OpportunityResponseWrapper();
            objRes.objGenericRes.strErrorMessage = dex.getDmlMessage(0);
            objRes.objGenericRes.boolIsError = true;
            LogUtility.createLog('DML','Opportunity','WFG_EditOpportunity', 'Error', dex.getDmlMessage(0), 'Error');
            return objRes;
        }        
        catch(Exception ex){
            WFG_OpportunityResponseWrapper objRes = new WFG_OpportunityResponseWrapper();
            objRes.objGenericRes.strErrorMessage = ex.getMessage();
            objRes.objGenericRes.boolIsError = true;
            LogUtility.createLog('EXCEPTION','Opportunity','WFG_EditOpportunity', 'Error', ex.getMessage(), 'Error');
            return objRes;
        }
    }
}