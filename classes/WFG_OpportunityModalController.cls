public with sharing class WFG_OpportunityModalController {

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
            
            WFG_CreateCPResponseWrapper objRes = new WFG_CreateCPResponseWrapper();
            
            if(idContact != NULL){                              
                
                System.debug('show 12321 #Customer Profile '+objCustomerProfile);
                insert objCustomerProfile;

                Opportunity oppt = [Select Id, WFG_CustomerProfile__c From Opportunity Where Id =: idOpportunity];
                oppt.WFG_CustomerProfile__c = objCustomerProfile.Id;
                update oppt;
                objRes.objGenericRes.strSuccessMessage = 'Customer Profile Successfully Created';
                objRes.objCustProfile = objCustomerProfile;                
            }
            
            return objRes;
            
        }catch(DMLException dex){
            WFG_CreateCPResponseWrapper objRes = new WFG_CreateCPResponseWrapper();
            objRes.objGenericRes.strErrorMessage = dex.getDmlMessage(0);
            objRes.objGenericRes.boolIsError = true;
            return objRes;
        }        
        catch(Exception ex){
            WFG_CreateCPResponseWrapper objRes = new WFG_CreateCPResponseWrapper();
            objRes.objGenericRes.strErrorMessage = ex.getMessage();
            objRes.objGenericRes.boolIsError = true;
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
        return [SELECT Id,Name,WFG_advisors_to_contact_you__c,WFG_AnnualGrossIncome__c,WFG_Consent_for_FA_Contact__c,WFG_Consent_to_pass_contact_information__c,WFG_EmploymentStatus__c,
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
            
            WFG_CreateCPResponseWrapper objRes = new WFG_CreateCPResponseWrapper();
            
            upsert objCustomerProfile;
            objRes.objGenericRes.strSuccessMessage = 'Customer Profile Successfully Updated';
            objRes.objCustProfile = objCustomerProfile;                
            
            return objRes;
            
        }catch(DMLException dex){
            WFG_CreateCPResponseWrapper objRes = new WFG_CreateCPResponseWrapper();
            objRes.objGenericRes.strErrorMessage = dex.getDmlMessage(0);
            objRes.objGenericRes.boolIsError = true;
            return objRes;
        }        
        catch(Exception ex){
            WFG_CreateCPResponseWrapper objRes = new WFG_CreateCPResponseWrapper();
            objRes.objGenericRes.strErrorMessage = ex.getMessage();
            objRes.objGenericRes.boolIsError = true;
            return objRes;
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

    @AuraEnabled
    public static List<WFG_Customer_Profile__c> getCustomerProfiles(String idOpportunity) {
        try {
            Opportunity oppt = [Select Id, WFG_Contact__c From Opportunity Where Id =: idOpportunity];
                

            system.debug('show 12321 ' + oppt);

            return [Select Id, Name, WFG_Status__c From WFG_Customer_Profile__c Where WFG_Contact__c =: oppt.WFG_Contact__c AND WFG_Status__c = 'Complete'];
        } catch(Exception e){
            return null;
        }

    }

     @AuraEnabled
    public static String saveButtonAction(String idOpportunity, String idCP, String stgName) {
        String messageItem;
        
        try{
            
            if(idCP != NULL){                              
                

                Opportunity oppt = [Select Id, WFG_CustomerProfile__c, WFG_ModalName__c, StageName From Opportunity Where Id =: idOpportunity];
                oppt.WFG_CustomerProfile__c = idCP;
                oppt.WFG_ModalName__c = null;
                if(stgName != null) oppt.StageName = stgName;

                System.debug('show 12321 #Opportunity '+oppt);
                update oppt;
                messageItem = 'Customer Profile Successfully related to this Opportunity'; 
            }
            
            return messageItem;
            
        }        
        catch(Exception ex){

            messageItem = 'Error' + ex.getMessage();
            return messageItem;
        }
    }
}