public with sharing class WFG_POPCreateLeadController {

    @AuraEnabled
    public static Map<String,List<String>> getCoutryStateDependency(){
        return WFG_PicklistFieldDescribeUtility.getDependentOptions('Lead','CountryCode','StateCode');
    }
    
    @AuraEnabled
    public static List<String> getSalutation(){
        return WFG_PicklistFieldDescribeUtility.getPicklistValues('Lead','Salutation');
    }
    
    @AuraEnabled
    public static List<String> getLeadTypes(){
        return WFG_PicklistFieldDescribeUtility.getPicklistValues('Lead','WFG_Lead_Type__c');
    }
    
    @AuraEnabled
    public static List<String> getLeadStatusValues(){
        return WFG_PicklistFieldDescribeUtility.getPicklistValues('Lead','Status');
    }
    
    @AuraEnabled
    public static WFG_POPWrapper convertLead(String leadId){
            
      return WFG_LeadConversion_Utility.convertLead(leadId);  
    }
    
    @AuraEnabled
    public static List<String> getCASLConsentValues(){
            return WFG_PicklistFieldDescribeUtility.getPicklistValues('Contact', 'WFG_CASL_Consent__c');
    }
    
    @AuraEnabled
    public static Lead getLeadRecord(String leadId, String source){
        Lead objLead = [ SELECT Id, Salutation, Email, FirstName, LastName,isConverted,WFG_CASL_Consent__c,ConvertedContactId, Status, Phone, Street, City, State, Country, CountryCode, StateCode, PostalCode, WFG_Lead_Type__c,CreatedDate
                FROM Lead 
                WHERE Id = :leadId AND OwnerId =: userInfo.getUserId()];
        System.debug('Lead Record : ' + objLead);       
            //get country and state value
            Map<String, String> mapStateLabelValues = new Map<String, String>(WFG_PicklistFieldDescribeUtility.getPicklistLabelValues('Lead','StateCode'));
            Map<String, String> mapCountryLabelValues = new Map<String, String>(WFG_PicklistFieldDescribeUtility.getPicklistLabelValues('Lead','CountryCode'));
            
            if(!mapStateLabelValues.isEmpty()){
                for(String key : mapStateLabelValues.keySet()){
                    if(mapStateLabelValues.get(key) == objLead.StateCode){
                        objLead.State = key;
                    }
                    else if(objLead.State == 'PRC'){
                            objLead.State = 'Puerto Rico';
                    }
                }
            }
            
            if(!mapCountryLabelValues.isEmpty()){
                for(String key : mapCountryLabelValues.keySet()){
                    if(mapCountryLabelValues.get(key) == objLead.Country){
                        objLead.Country = key;
                    }
                }
            }

        system.debug('State -> ' + objLead.State + '   ' + objLead.Country);

        return objLead;
    }    
    
    @AuraEnabled
    public static WFG_POPLeadResponseWrapper saveUpdateLead(Lead objLead){
        
        String LeadId;
        if(objLead.Id != null){
            LeadId = objLead.Id;
        }
        
        try{
            Map<String, String> mapStateLabelValues = new Map<String, String>(WFG_PicklistFieldDescribeUtility.getPicklistLabelValues('Lead','StateCode'));
            Map<String, String> mapCountryLabelValues = new Map<String, String>(WFG_PicklistFieldDescribeUtility.getPicklistLabelValues('Lead','CountryCode'));
            
            if(objLead.Country != null && objLead.Country != ''){
                if(mapCountryLabelValues.containsKey(objLead.Country)){
                    objLead.Country = mapCountryLabelValues.get(objLead.Country);
                }
            }
            
            if(objLead.State != null && objLead.State != ''){
                
                if(objLead.Country.equalsIgnoreCase('PR')){
                    objLead.State = 'PRC';  
                }else if(mapStateLabelValues.containsKey(objLead.State)){
                    objLead.State = mapStateLabelValues.get(objLead.State);
                }
            }
            //upsert objLead;

            
            List<Lead> lst = new List<Lead>();
            lst.add(objLead);

            Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(lst);
            WFG_POPLeadResponseWrapper objRes;
            
            if (results.size() != 0) {
                List<Lead> duplicate_leads = new List<Lead>();
                for (Datacloud.FindDuplicatesResult findDupeResult : results) {
                    for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                        for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                            for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                                Lead tempLead = new Lead();
                                tempLead = (Lead)matchRecord.getRecord();
                                if(LeadId != tempLead.Id){
                                    duplicate_leads.add((Lead)matchRecord.getRecord());
                                }
                            }
                        }
                    }
                }
                
                if(duplicate_leads.size() > 0){
                    objRes = new WFG_POPLeadResponseWrapper();
                    objRes.objGenericRes.strErrorMessage = 'Duplicate Error';
                    objRes.objGenericRes.boolIsError = true;                
                    return objRes;
                }
                else{
                    upsert objLead;
                    objRes = new WFG_POPLeadResponseWrapper();
                    objRes.objGenericRes.strSuccessMessage = 'Lead has been create/updated';
                    objRes.objLead = objLead;                
                    
                }
            }  
            
           return objRes; 
        }
        catch(DMLException dex){
            WFG_POPLeadResponseWrapper objRes = new WFG_POPLeadResponseWrapper();
            objRes.objGenericRes.strErrorMessage = dex.getDmlMessage(0);
            objRes.objGenericRes.boolIsError = true;
            LogUtility.createLog('EXCEPTION','Lead','WFG_POPEditLead', 'Error', dex.getDmlMessage(0), 'Error');
            return objRes;
        }
    }
   
    
    @AuraEnabled 
    public static string deleteLeadRecord(String leadId){
        List<Lead> lstLead = new List<Lead>();
        String strLeadName; 
       if(leadId != null){
             lstLead = [SELECT Id, FirstName, LastName FROM Lead WHERE  Id =: LeadId];
             System.debug('lstLead to Delete' + lstLead);
        }
        if(!lstLead.isEmpty() && lstLead != null){
            strLeadName = lstLead[0].FirstName + ' ' + lstLead[0].LastName;
            try{
                delete lstLead;
                return strLeadName;
                 
            }catch(Exception ex){
                System.Debug('Exception while deleting Lead : ' + ex);
                LogUtility.createLog('EXCEPTION','Lead','WFG_POPEditLead', 'Error', ex.getMessage(), 'Error');
                return null;
            }
        } 
        
        return null;
    }

    @AuraEnabled 
    public static Boolean validateForConversion(String leadId){
        
        List<Lead> lstLead = new List<Lead>();
        Boolean isValid = false; 
       if(leadId != null){
             lstLead = [SELECT Id, FirstName, LastName, Email, Phone, State, Country FROM Lead WHERE  Id =: LeadId];
             
        }
        System.debug('@@@ lstLead to validate' + lstLead);
        if(!lstLead.isEmpty() && lstLead != null){
            if(lstLead[0].FirstName!= null && lstLead[0].FirstName != '' && lstLead[0].LastName != null && lstLead[0].LastName != '' && lstLead[0].Phone != null && lstLead[0].Phone != '' && lstLead[0].Email != null && lstLead[0].Email != '' && lstLead[0].State != null && lstLead[0].State != '' && lstLead[0].Country != null && lstLead[0].Country != ''){
                isValid = true;
                
            }
        } 
        
        return isValid;
    }
}