/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Saurabh Sharma
* @date 1-12-2017
* @description  Controller class for Lightning component to create a new Customer Profile record

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Saurabh Sharma        M-001             1-12-2017         US-320 | US-297: Create individual and spouse  
*/
public with sharing class WFG_AgentNewIndividualController {
	
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
    public static List<String> getMaritalStatus(){
        	return WFG_PicklistFieldDescribeUtility.getPicklistValues('Contact', 'FinServ__MaritalStatus__c');
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
     * Method to fetch country state dependency
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
     * Method to create an individual record
     * @return - WFG_CreateIndividualResponseWrapper
     * @see    - N/A
     * @param  - Contact, Contact, Id
     * @throws - N/A
    */ 
    @AuraEnabled
    public static WFG_CreateIndividualResponseWrapper createIndividual(Contact objContact, Contact objSpouseContact, id idSpouseContact){
        try{
        	objContact.recordtypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
            
            //get country and state value
            Map<String, String> mapStateLabelValues = new Map<String, String>(WFG_PicklistFieldDescribeUtility.getPicklistLabelValues('Contact','MailingStateCode'));
            Map<String, String> mapCountryLabelValues = new Map<String, String>(WFG_PicklistFieldDescribeUtility.getPicklistLabelValues('Contact','MailingCountryCode'));
            System.debug('--mapStateLabelValues--:'+mapStateLabelValues);
            System.debug('--mapCountryLabelValues--:'+mapCountryLabelValues);
            if(objContact.MailingCountry != null && objContact.MailingCountry != ''){
                if(mapCountryLabelValues.containsKey(objContact.MailingCountry)){
                    objContact.MailingCountry = mapCountryLabelValues.get(objContact.MailingCountry);
                }
            }
            
            if(objContact.MailingState != null && objContact.MailingState != ''){
                
                if(objContact.MailingCountry.equalsIgnoreCase('PR')){
                    objContact.MailingState = 'PRC';
                }else if(mapStateLabelValues.containsKey(objContact.MailingState)){
                    objContact.MailingState = mapStateLabelValues.get(objContact.MailingState);
                }
            }
            
            if(objSpouseContact != NULL){
                if(objSpouseContact.MailingCountry != null && objSpouseContact.MailingCountry != ''){
                    if(mapCountryLabelValues.containsKey(objSpouseContact.MailingCountry)){
                        objSpouseContact.MailingCountry = mapCountryLabelValues.get(objSpouseContact.MailingCountry);
                    }
                }
                
                if(objSpouseContact.MailingState != null && objSpouseContact.MailingState != ''){
                    if(objSpouseContact.MailingCountry.equalsIgnoreCase('PR')){
                        objSpouseContact.MailingState = 'PRC';
                    }else if(mapStateLabelValues.containsKey(objSpouseContact.MailingState)){
                        objSpouseContact.MailingState = mapStateLabelValues.get(objSpouseContact.MailingState);
                    }
                }
            }

            //check for spouse
            if(idSpouseContact != NULL && objContact != NULL){                
                insert objContact;
                createSpouseRelationship(objContact.id, idSpouseContact);                
                
            }else if(objSpouseContact != NULL && objSpouseContact.LastName != NULL && objSpouseContact.LastName != ''){
                objSpouseContact.recordtypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
                List<Contact> lstContact = new List<Contact>{objContact, objSpouseContact};                
                    
                if(!lstContact.isEmpty()){
                	insert lstContact;
                    createSpouseRelationship(objContact.id, objSpouseContact.id);  
                }
                
            
            }else if(objContact != NULL && objContact.LastName != NULL && objContact.LastName != ''){
                insert objContact;
            }
            
            WFG_CreateIndividualResponseWrapper objRes = new WFG_CreateIndividualResponseWrapper();
            objRes.objGenericRes.strSuccessMessage = 'Contact Successfully Created';
            objRes.objContact = objContact;
            return objRes;
        }
        catch(Exception e){
            WFG_CreateIndividualResponseWrapper objRes = new WFG_CreateIndividualResponseWrapper();
            objRes.objGenericRes.strErrorMessage = e.getTypeName() == 'System.DmlException' ? e.getDmlMessage(0) : e.getMessage();
            objRes.objGenericRes.boolIsError = true;
            LogUtility.createLog('EXCEPTION','Contact','WFG_AgentNewIndividual', 'Error', e.getMessage(), 'Error');
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
	        //get spouse reciprocal role
	        List<FinServ__ReciprocalRole__c> lstReciprocalRole = [SELECT Id FROM FinServ__ReciprocalRole__c WHERE Name = 'Spouse' LIMIT 1];
	        
	        if(!lstReciprocalRole.isEmpty()){
	            //create relationship
	            FinServ__ContactContactRelation__c ccRelation = new FinServ__ContactContactRelation__c();
	            ccRelation.FinServ__Contact__c = idContact;
	            ccRelation.FinServ__RelatedContact__c = idRelatedContact;
	            ccRelation.FinServ__Role__c = lstReciprocalRole[0].Id;
	            
	            if(ccRelation != NULL){
	                insert ccRelation;
	            }            
	        }
         }
         catch(Exception ex){
        	LogUtility.createLog('EXCEPTION','Contact','WFG_AgentNewIndividual', 'Error', ex.getMessage(), 'Error');
        }
        
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
     * Method to fetch Contact details
     * @return - Contact
     * @see    - N/A
     * @param  - N/A
     * @throws - N/A
    */ 
    @AuraEnabled
    public static Contact getContactDetails(Id idContact){
        try{
        	return [SELECT Id, FirstName, LastName, Phone, WFG_Contact_Indicator__c, Email, MailingCountry, MailingStreet, MailingCity,
               MailingState, MailingPostalCode, Birthdate, FinServ__Gender__c, FinServ__MaritalStatus__c FROM Contact WHERE Id =: idContact];
         }
         catch(Exception ex){
        	LogUtility.createLog('EXCEPTION','Contact','WFG_AgentNewIndividual', 'Error', ex.getMessage(), 'Error'); return null;
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
        
        Map<Id, String> mapSpouseIdAndName = new Map<Id, String>();
        List<FinServ__ContactContactRelation__c> lstSpouse = [SELECT FinServ__Contact__r.Name, FinServ__Contact__c, FinServ__RelatedContact__r.Name, FinServ__RelatedContact__c 
                                                              FROM FinServ__ContactContactRelation__c WHERE FinServ__Contact__c =: idContact OR FinServ__RelatedContact__c =: idContact LIMIT 1];
        
        if(!lstSpouse.isEmpty() && lstSpouse != NULL){
            
            if(lstSpouse[0].FinServ__Contact__c == idContact){
                mapSpouseIdAndName.put(lstSpouse[0].FinServ__RelatedContact__c, lstSpouse[0].FinServ__RelatedContact__r.Name);
            }else{
                mapSpouseIdAndName.put(lstSpouse[0].FinServ__Contact__c, lstSpouse[0].FinServ__Contact__r.Name);
            }
        }
        
        return mapSpouseIdAndName;
        
    }
}