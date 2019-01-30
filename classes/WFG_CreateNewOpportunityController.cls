public with sharing class WFG_CreateNewOpportunityController {

    private ApexPages.StandardController ctrl; 

    public WFG_CreateNewOpportunityController(ApexPages.StandardController ctrlParam){
      ctrl = ctrlParam; 
    }

    @AuraEnabled
    public static List<String> getProductType() {

        List<String> ptList = new List<String>{'Annuity', 'Disability Insurance', 'Life Insurance', 'Long Term Care', 'Referral Product', 'Other'};
        
        return ptList;
        
    }
    
    @AuraEnabled
    public static List<String> getIsLicensedPicklistValues() {
        return WFG_PicklistFieldDescribeUtility.getPicklistValues('Opportunity', 'Is_the_person_licensed__c');
    }
    
    @AuraEnabled
    public static String getRecordTypeName(String recordTypeId) {
        return [SELECT DeveloperName,Id,Name,SobjectType FROM RecordType where Id=:recordTypeId].Name;
    }
    

    @AuraEnabled
    public static List<WFG_Customer_Profile__c> getCustomerProfiles(String idContact) {
        try {

            return [Select Id, Name, WFG_Status__c From WFG_Customer_Profile__c Where WFG_Contact__c =: idContact];
        } catch(Exception e){
            return null;
        }

    }

    @AuraEnabled
    public static String getContactName(String idContact) {
        try {

            return [Select Id, Name From Contact Where Id =: idContact].Name;
        } catch(Exception e){
            return null;
        }

    }

    @AuraEnabled
    public static String createOpportunity(Opportunity oppt, String customerProfileId, String contactId, String recordTypeId){

        Opportunity newOpp = new Opportunity();
        
        try{
            
            system.debug('@@@ inside if recordTypeId'+recordTypeId); 
            system.debug('@@@ inside system.Label.WFG_POP_OpportunityRecruitment'+system.Label.WFG_POP_OpportunityRecruitment);
            if(recordTypeId == system.Label.WFG_POP_OpportunityRecruitment || recordTypeId == system.Label.WFG_POP_OpportunityRecruitment_CAN){
                system.debug('@@@ inside if'+recordTypeId); 
                WFG_Recruitment_Utility.WFG_OpportunityWrapp obWrapper = new WFG_Recruitment_Utility.WFG_OpportunityWrapp();
                obWrapper  = WFG_Recruitment_Utility.getRecruitmentOpportunity(oppt,contactId);
                String strSuccessMessage;
                system.debug('########' + obWrapper);
                if(obWrapper.boolIsError != true){
                    return strSuccessMessage = obWrapper.objOpp.Id;
                 }
                 else{
                 	strSuccessMessage = obWrapper.strError;
                 	return strSuccessMessage; 
                 }              
            }else{
                newOpp.Name = oppt.Name;
                newOpp.CloseDate = oppt.CloseDate;
                newOpp.Probability = oppt.Probability;
                newOpp.Amount = oppt.Amount;
                newOpp.Description = oppt.Description;
                newOpp.WFG_Product_Type__c = oppt.WFG_Product_Type__c;
                
                newOpp.Stagename = 'Needs Assessment';
                //if(recordTypeId != null && recordTypeId != ''){
                    //newOpp.RecordTypeId = recordTypeId;
                //}
               // else{
                    newOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Insurance').getRecordTypeId();
                //}
                
                if (customerProfileId != null && customerProfileId != '') {
                    
                    try {
    
                        WFG_Customer_Profile__c cp = [Select Id, WFG_Contact__c From WFG_Customer_Profile__c Where Id =: customerProfileId];
                        newOpp.WFG_CustomerProfile__c = customerProfileId;
    
                        if (cp.WFG_Contact__c != null) {
                            newOpp.WFG_Contact__c = cp.WFG_Contact__c;
                        }
    
                    }catch(Exception e) {
                        oppt.WFG_CustomerProfile__c = null;
                    }
                }
    
                if (contactId != null && contactId != '') {
                    
                    newOpp.WFG_Contact__c = contactId;
                    
                }
    
                try {
                    WFG_Customer_Profile__c cp = [Select Id, WFG_Contact__c From WFG_Customer_Profile__c Where Id =: oppt.WFG_CustomerProfile__c];
    
                    if (cp.WFG_Contact__c != null) {
                        newOpp.WFG_Contact__c = cp.WFG_Contact__c;
                    }
                    newOpp.WFG_CustomerProfile__c = cp.Id;
                    //oppt.WFG_CustomerProfile__r = null;
                } catch(Exception e) {
                    oppt.WFG_CustomerProfile__c = null;
                }
    
                insert newOpp;
    			system.debug('################');
                String strSuccessMessage = newOpp.Id;
                return strSuccessMessage;
            }
          }
        catch(Exception e){
        	system.debug('################' + e);
            return 'Error: ' + e.getMessage();
        }
    
    }
    
    @AuraEnabled
    public static Boolean isTANUser(){
        
        Boolean isTANUser = false;
        String strProfileName = [SELECT Id, Name FROM Profile WHERE Id =: userInfo.getProfileId()].Name;

        if(WFG_DenyRecruitProfiles__c.getAll().keyset().contains(strProfileName)){
            isTANUser = true; 
        }
        
        return isTANUser;        
    }
    
    @AuraEnabled
    public static contact getContactDetails(string strIdContact)
    {
    	if(strIdContact != null)
    	{
    		List<Contact> lstCon = [Select id, firstName, lastName from Contact Where Id = :strIdContact];
    		if(lstCon != null && !lstCon.isEmpty())
    		{ 
    			return lstCon[0];
    		}
    		return lstCon[0];
    	}
    	return null;
    }
    
    
     @AuraEnabled
    public Static boolean checkOpportunityDuplication(string strIdContact)
    {
        ID idRecruitmentUSA = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_POP_OpportunityRecruitment).getRecordTypeId();
        Id idRecruitmentCAN = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_POP_OpportunityRecruitment_CAN).getRecordTypeId();
        
        List<Contact> conList = [SELECT Id, AccountId, (Select id, name from WFG_Opportunities__r 
                	where recordtypeID IN (:idRecruitmentUSA,:idRecruitmentCAN) 
                	AND stageName != :system.Label.WFG_OpportunityStage_Opportunity_Lost) from Contact where id= :strIdContact];
        if(conList.size() > 0 && conList[0].WFG_Opportunities__r.size() > 0 ){
            return true;
        } 
       else{
         return false;  
     	}                                                
    }


}