/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Saurabh Sharma
* @date 2/9/2017
* @description  Controller class for Lightning component to create a new Customer Profile record

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Saurabh Sharma        M-001            2/9/2017         US-320 | US-297: Create individual and spouse  
*/
public with sharing class WFG_AgentEditCustomerDetailController {
    
    /**
    * Method to fetch Contact details
    * @return - Contact
    * @see    - N/A
    * @param  - N/A
    * @throws - N/A
    */ 
    @AuraEnabled
    public static Contact getContactDetails(Id idContact){
        
        try{
	        Contact cont = [SELECT Id, FirstName, LastName, WFG_Middle_Name__c, Phone, WFG_Contact_Indicator__c, Email, MailingCountry, MailingStreet, MailingCity,
	                        MailingState, MailingPostalCode, Birthdate, FinServ__Gender__c, FinServ__MaritalStatus__c, WFG_CASL_Consent__c FROM Contact WHERE Id =: idContact];
	        
	        
	        //get country and state value
	        Map<String, String> mapStateLabelValues = new Map<String, String>(WFG_PicklistFieldDescribeUtility.getPicklistLabelValues('Contact','MailingStateCode'));
	        Map<String, String> mapCountryLabelValues = new Map<String, String>(WFG_PicklistFieldDescribeUtility.getPicklistLabelValues('Contact','MailingCountryCode'));
	        
	        if(!mapStateLabelValues.isEmpty()){
	            for(String key : mapStateLabelValues.keySet()){
	                if(mapStateLabelValues.get(key) == cont.MailingState){
	                    cont.MailingState = key;
	                }
	                else if(cont.MailingState == 'PRC'){
				        	cont.MailingState = 'Puerto Rico';
			        }
	            }
	        }
	        
	        if(!mapCountryLabelValues.isEmpty()){
	            for(String key : mapCountryLabelValues.keySet()){
	                if(mapCountryLabelValues.get(key) == cont.MailingCountry){
	                    cont.MailingCountry = key;
	                }
	            }
	        }
	        
	        
	        return cont;       
       	}
         catch(Exception ex){
        	LogUtility.createLog('EXCEPTION','Contact','WFG_AgentEditCustomerDetails', 'Error', ex.getMessage(), 'Error');
        	return null;
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
       
        	return [SELECT Id, Name FROM Contact WHERE RecordType.Name = 'Individual' LIMIT :Limits.getLimitQueryRows()- Limits.getQueryRows()]; 
    }
    
    /**
    * Method to fetch Marital Status picklist value
    * @return - List of String
    * @see    - N/A
    * @param  - N/A
    * @throws - N/A
    */ 
    @AuraEnabled
    public static Map<String,List<String>> getCoutryStateDependency(){

        	return WFG_PicklistFieldDescribeUtility.getDependentOptions('Contact','MailingCountryCode','MailingStateCode');

         
    }
    
    /**
    * Method to fetch Marital Status picklist value
    * @return - List of String
    * @see    - N/A
    * @param  - N/A
    * @throws - N/A
    */ 
    @AuraEnabled
    public static List<String> getMaritalStatus(){

        return WFG_PicklistFieldDescribeUtility.getPicklistValues('Contact', 'FinServ__MaritalStatus__c');

       
    }
    
    /**
    * Method to fetch gender picklist value
    * @return - List of String
    * @see    - N/A
    * @param  - N/A
    * @throws - N/A
    */ 
    @AuraEnabled
    public static List<String> getGender(){

        return WFG_PicklistFieldDescribeUtility.getPicklistValues('Contact', 'FinServ__Gender__c');

         
    }
    
    /**
    * Method to fetch Contact Indicator picklist value
    * @return - List of String
    * @see    - N/A
    * @param  - N/A
    * @throws - N/A
    */ 
    @AuraEnabled
    public static List<String> getConIndicator(){

        return WFG_PicklistFieldDescribeUtility.getPicklistValues('Contact', 'WFG_Contact_Indicator__c');

         
    }
    /**
     * Method to fetch CASL Consent picklist value
     * @return - List of String
     * @see    - N/A
     * @param  - N/A
     * @throws - N/A
    */ 
    @AuraEnabled
    public static List<String> getCASLConsentValues(){
            return WFG_PicklistFieldDescribeUtility.getPicklistValues('Contact', 'WFG_CASL_Consent__c');
    }
    /**
    * Method to update contact
    * @return - Contact
    * @see    - N/A
    * @param  - N/A
    * @throws - N/A
    */
    @AuraEnabled
    public static WFG_CreateIndividualResponseWrapper updateContact(Contact objContact, Contact objSpouseContact, id idSpouseContact){

        //get country and state value
        Map<String, String> mapStateLabelValues = new Map<String, String>(WFG_PicklistFieldDescribeUtility.getPicklistLabelValues('Contact','MailingStateCode'));
        Map<String, String> mapCountryLabelValues = new Map<String, String>(WFG_PicklistFieldDescribeUtility.getPicklistLabelValues('Contact','MailingCountryCode'));
        
        if(objContact != null && objContact.MailingCountry != null && objContact.MailingCountry != ''){
            if(mapCountryLabelValues.containsKey(objContact.MailingCountry)){
                objContact.MailingCountry = mapCountryLabelValues.get(objContact.MailingCountry);
            }
        }
        
        if(objContact != null && objContact.MailingState != null && objContact.MailingState != ''){
            if(objContact.MailingCountry.equalsIgnoreCase('PR')){
                objContact.MailingState = 'PRC';
            }else if(mapStateLabelValues.containsKey(objContact.MailingState)){
                objContact.MailingState = mapStateLabelValues.get(objContact.MailingState);
            }
        }
        
        if(objSpouseContact != NULL && objSpouseContact.MailingCountry != null && objSpouseContact.MailingCountry != ''){
            if(mapCountryLabelValues.containsKey(objSpouseContact.MailingCountry)){
                objSpouseContact.MailingCountry = mapCountryLabelValues.get(objSpouseContact.MailingCountry);
            }
        }
        
        if(objSpouseContact != NULL && objSpouseContact.MailingState != null && objSpouseContact.MailingState != ''){
            if(objSpouseContact.MailingCountry.equalsIgnoreCase('PR')){
                objSpouseContact.MailingState = 'PRC';
            }else if(mapStateLabelValues.containsKey(objSpouseContact.MailingState)){
                objSpouseContact.MailingState = mapStateLabelValues.get(objSpouseContact.MailingState);
            }
        }
        try{
            //check spouse
            if(idSpouseContact != NULL && objContact != NULL){
                update objContact;
                createSpouseRelationship(objContact.id, idSpouseContact);                
                
            }else if(objSpouseContact != NULL && objSpouseContact.LastName != NULL && objSpouseContact.LastName != ''){
                objSpouseContact.recordtypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
                List<Contact> lstContact = new List<Contact>{objContact, objSpouseContact};                
                if(!lstContact.isEmpty()){
                    upsert lstContact;
                }
                createSpouseRelationship(objContact.id, objSpouseContact.id);  
                
            }else if(objContact != NULL && objContact.LastName != NULL && objContact.LastName != ''){
                update objContact;
                if(objSpouseContact.LastName == NULL && idSpouseContact == NULL){
                    createSpouseRelationship(objContact.id, NULL);
                }
            }
            WFG_CreateIndividualResponseWrapper objRes = new WFG_CreateIndividualResponseWrapper();
            objRes.objGenericRes.strSuccessMessage = 'Contact Successfully Created';
            objRes.objContact = objContact;
            return objRes;
        } catch(Exception ex){
            WFG_CreateIndividualResponseWrapper objRes = new WFG_CreateIndividualResponseWrapper();
            objRes.objGenericRes.strErrorMessage = ex.getTypeName() == 'System.DmlException' ? ex.getDmlMessage(0) : ex.getMessage();
            objRes.objGenericRes.boolIsError = true;
            LogUtility.createLog('EXCEPTION','Contact','WFG_AgentEditCustomerDetails', 'Error', ex.getMessage(), 'Error');
            return objRes;
        }
    }
    
    /**
    * Private method to create an spouse relationship record
    * @return - N/A
    * @see    - N/A
    * @param  - Id, Id
    * @throws - N/A
    */ 
    private static void createSpouseRelationship(Id idContact, Id idRelatedContact){
        
        try{
	        if(idContact != NULL && idRelatedContact != NULL){
	            
	            Map<String, Id> mapReciprocalRoleAndId = new Map<String, Id>();
	            
	            //get spouse reciprocal role
	            for(FinServ__ReciprocalRole__c role : [SELECT Id, Name FROM FinServ__ReciprocalRole__c WHERE Name = 'Spouse' LIMIT 1]){
	                
	                if(!mapReciprocalRoleAndId.containsKey(role.Name)){
	                    mapReciprocalRoleAndId.put(role.Name, role.Id);
	                }
	            }
	            
	            if(!mapReciprocalRoleAndId.isEmpty()){
	                
	                //update existing spouse relationship
	                List<FinServ__ContactContactRelation__c> lstSpouseRelationship = [SELECT Id, FinServ__Active__c FROM FinServ__ContactContactRelation__c WHERE ((FinServ__Contact__c !=: idContact AND FinServ__RelatedContact__c !=: idRelatedContact) OR (FinServ__RelatedContact__c !=: idContact AND FinServ__Contact__c !=: idRelatedContact))
	                                                                                  AND (FinServ__Contact__c =: idRelatedContact OR FinServ__RelatedContact__c =: idContact OR FinServ__Contact__c =: idRelatedContact OR FinServ__RelatedContact__c =: idContact) AND FinServ__Role__r.Name = 'Spouse' AND FinServ__Active__c = true];
	                
	                if(!lstSpouseRelationship.isEmpty()){
	                    for(FinServ__ContactContactRelation__c rlstnshp : lstSpouseRelationship){
	                        rlstnshp.FinServ__Active__c = false;
	                    }
	                    
	                    //update existing spouse
	                    update lstSpouseRelationship;                    
	                    
	                }
	                
	                //create relationship
	                FinServ__ContactContactRelation__c ccRelation = new FinServ__ContactContactRelation__c();
	                ccRelation.FinServ__Contact__c = idContact;
	                ccRelation.FinServ__RelatedContact__c = idRelatedContact;
	                ccRelation.FinServ__Role__c = mapReciprocalRoleAndId.get('Spouse');
	                
	                if(ccRelation != NULL){
	                	insert ccRelation;
	                }
	                
	            } 
	        }else if(idContact != NULL && idRelatedContact == NULL){
	            
	            //update existing spouse relationship
	            List<FinServ__ContactContactRelation__c> lstSpouseRelationship = [SELECT Id, FinServ__Role__c FROM FinServ__ContactContactRelation__c WHERE 
	                                                                              (FinServ__Contact__c =: idContact OR FinServ__RelatedContact__c =: idContact) AND FinServ__Role__r.Name = 'Spouse' LIMIT 1];
	            
	            
	            if(!lstSpouseRelationship.isEmpty()){
	                lstSpouseRelationship[0].FinServ__Active__c = false;
	                update lstSpouseRelationship;
	            }
	        }
	      }
         catch(Exception ex){
        	LogUtility.createLog('EXCEPTION','Contact','WFG_AgentEditCustomerDetails', 'Error', ex.getMessage(), 'Error');
        }   
        
    }
    
    /**
    * Method to fetch Spouse details
    * @return - Contact
    * @see    - N/A
    * @param  - N/A
    * @throws - N/A
    */
    @AuraEnabled
    public static Map<Id, String> getSpouseDetails(Id idContact){
        
        try{
        Map<Id, String> mapSpouseIdAndName = new Map<Id, String>();
        List<FinServ__ContactContactRelation__c> lstSpouse = [SELECT FinServ__Contact__r.Name, FinServ__Contact__c, FinServ__RelatedContact__r.Name, FinServ__RelatedContact__c 
                                                              FROM FinServ__ContactContactRelation__c WHERE (FinServ__Contact__c =: idContact OR FinServ__RelatedContact__c =: idContact) AND FinServ__Active__c = true LIMIT 1];
        
        if(!lstSpouse.isEmpty()){
            if(lstSpouse[0].FinServ__Contact__c == idContact){
                mapSpouseIdAndName.put(lstSpouse[0].FinServ__RelatedContact__c, lstSpouse[0].FinServ__RelatedContact__r.Name);
            }else{
                mapSpouseIdAndName.put(lstSpouse[0].FinServ__Contact__c, lstSpouse[0].FinServ__Contact__r.Name);
            }
        }
        
        return mapSpouseIdAndName;
        }
         catch(Exception ex){
        	LogUtility.createLog('EXCEPTION','Contact','WFG_AgentEditCustomerDetails', 'Error', ex.getMessage(), 'Error');
        	return null;
        } 
        
    }

     /**
     * Method to archive a contact
     * @return - VOID
     * @see    - N/A
     * @param  - cont
     * @throws - N/A
    */
    @auraEnabled
    public static void archiveContact(Id contactId){
        List<Contact> currentContact = new List<contact>();
	
        if(contactId!= null){
            currentContact = [Select Id, Name, AccountId, WFG_Contact_Indicator__c from Contact where id=:contactID ];
        }
        if(!currentContact.isEmpty() && currentContact != null){
            currentContact[0].WFG_Contact_Indicator__c = 'Inactive'; 
            try{
                update currentContact;
            }catch(Exception ex){
                System.debug('Exception in archiving contact : ' + ex); 
        		LogUtility.createLog('EXCEPTION','Contact','WFG_AgentEditCustomerDetails', 'Error', ex.getMessage(), 'Error');
            }  
        } 
    }
    
    /**
     * Method to get the spouse name of a contact
     * @return - String
     * @see    - N/A
     * @param  - contactId
     * @throws - N/A
    */
    @auraEnabled
    public static String getSpouseName(Id contactId){
        
        try{
	        List<FinServ__ContactContactRelation__c> lstContRelation = new List<FinServ__ContactContactRelation__c>();
	        
	        if(contactId != null){
	            lstContRelation = [Select FinServ__RelatedContact__r.Name from FinServ__ContactContactRelation__c where FinServ__Contact__c = :contactId AND FinServ__Role__r.Name = 'Spouse' AND FinServ__Active__c = true ORDER BY LastModifiedDate DESC LIMIT 1];
	        }   
	        
	        //system.debug('Size -> ' + lstContRelation.size() + '   ' + lstContRelation[0].FinServ__Role__r.Name);
	            
	        if(lstContRelation.size() > 0){
	       		return lstContRelation[0].FinServ__RelatedContact__r.Name;
	        }
	        else{
	        	return '';
	        }
        }
         catch(Exception ex){
        	LogUtility.createLog('EXCEPTION','Contact','WFG_AgentEditCustomerDetails', 'Error', ex.getMessage(), 'Error');
        	return null;
        
    	}
    }
    
}