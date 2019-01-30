/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Samit
* @date 02-09-2017
* @description  Wrapper Class for Opportunity Sales Tool Component
Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Samit Bhoumick          M-001             02-02-2017             Opportunity Trigger
Ninad Patil             M-002           27-APR-2017             Modified Opportunity Trigger handler for
                                                                Sale Won = Sale Accepted
                                                                Sale Lost = Sale Not Accepted  
*/

public class WFG_Opportunity_Handler
{
    public static void beforeInsert(List<Opportunity> lstOpty){
        restrictNumberOfActiveOpportunities(lstOpty, null , null, false);
        populateOptyFieldsInsert(lstOpty);
    }
    
    public static void beforeUpdate(List<Opportunity> lstOpty,
                                    Map<Id, Opportunity> mapNewOpty, Map<Id, Opportunity> mapOldOpty)
    {
        restrictNumberOfActiveOpportunities(lstOpty, mapNewOpty , mapOldOpty, true);
        populateOptyFieldsUpdate(lstOpty, mapOldOpty);
        Id idQualifiedRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_OpportunityQualifiedRetirement).getRecordTypeId();
        Id idinsuranceTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_OppRecType_Insurance).getRecordTypeId();
        
        Id idQualifiedRTIdReadOnly = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_Opportunity_RecordType_QualifiedRetirementReadOnly).getRecordTypeId();
        Id idInsuranceRTIdReadOnly = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_Opportunity_RecordType_InsuranceReadOnly).getRecordTypeId();
        
        //Deepthi_EVRY : Code added in order to merge two triggers on Opportunity.
        Profile prof = [Select Id, Name From Profile Where Id =: userinfo.getProfileId()];
        Set<String> profileNameSet = WFG_Community_Partner_Group__c.getAll().keyset();

        if (prof != null && profileNameSet.contains(prof.Name)) {
            setupOpptModal(lstOpty, mapOldOpty);
            }
        
        for(Opportunity opt : lstOpty)
        {  
            //Start POC Code for notification bell - Travis Lowe
            if(mapNewOpty.get(opt.ID).StageName <> mapOldOpty.get(opt.ID).StageName)
            {
                try{
                    Opportunity opty = mapNewOpty.get(opt.ID);
                    Id userId = opty.CreatedBy.ID;
                    String msg = 'Opportunity ' + opty.Description + ' changed to ' + opty.StageName;
                    //ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), 'me', ConnectApi.FeedElementType.FeedItem, msg);
                }
                catch (Exception ex){
                    
                        system.debug(ex.getMessage());
                        opt.addError(ex.getMessage());
                }

            }
            //End POC code for notification bell - Travis Lowe
            if(opt.StageName == system.Label.WFG_OpportunityStage_CloseWon &&
                mapNewOpty.get(opt.ID).StageName <> mapOldOpty.get(opt.ID).StageName &&
                    (opt.WFG_Lost_Reason__c <> '' || opt.WFG_Lost_Reason__c <> null) )
            {
                opt.WFG_Lost_Reason__c = '';
            }
            if((mapOldOpty.get(opt.ID).StageName == system.Label.WFG_OpportunityStage_CloseWon 
                || mapOldOpty.get(opt.ID).StageName == system.Label.WFG_OpportunityStage_CloseLost)
                &&
                mapNewOpty.get(opt.ID).StageName <> mapOldOpty.get(opt.ID).StageName
                && (opt.recordtypeId == idQualifiedRTId
                    || opt.recordtypeId == idinsuranceTId 
                    || opt.recordtypeId == idQualifiedRTIdReadOnly
                    || opt.recordtypeId == idInsuranceRTIdReadOnly))
            {
                WFG_Opportunity_validations__c objCustSet = WFG_Opportunity_validations__c.getInstance();
                if(objCustSet.WFG_Validate__c == true)
                {
                    opt.addError(system.Label.WFG_OppFinalStageError);
                }
            }
        }
        changeRecordType(lstOpty,mapOldOpty);      
    }
    
    public static void afterUpdate(List<Opportunity> lstOpty,
                                   Map<Id, Opportunity> mapNewOpty, Map<Id, Opportunity> mapOldOpty, boolean boolIsUpdate){                                 
    }
    
    public static void afterInsert(List<Opportunity> lstTriggerNew){
    
        
    }
    
    /**
    * This method Populates Customer Profile & Referral in Opportunity during Update.
    * @param  - N/A
    * @throws - N/A
    * @author Samit
    * @date 02-09-2017
    */    
    private static void changeRecordType(List<Opportunity> lstOpty, Map<Id, Opportunity> mapOldOpty)
    {
        Id idQualifiedRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_OpportunityQualifiedRetirement).getRecordTypeId();
        Id idInsuranceRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_OppRecType_Insurance).getRecordTypeId();
        
        Id idQualifiedRTIdReadOnly = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_Opportunity_RecordType_QualifiedRetirementReadOnly).getRecordTypeId();
        Id idInsuranceRTIdReadOnly = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_Opportunity_RecordType_InsuranceReadOnly).getRecordTypeId();
        
        for(Opportunity objOpty: lstOpty)
        {
            if(objOpty.recordtypeId == idQualifiedRTId
                || objOpty.recordtypeId == idInsuranceRTId)
            {
                if(objOpty.stageName <> mapOldOpty.get(objOpty.id).stageName 
                    && (objOpty.stageName == system.Label.WFG_OpportunityStage_CloseWon 
                        || objOpty.stageName == system.Label.WFG_OpportunityStage_CloseLost))
                {
                    if(objOpty.recordTypeId == idQualifiedRTId) objOpty.recordTypeId = idQualifiedRTIdReadOnly;
                    if(objOpty.recordTypeId == idInsuranceRTId) objOpty.recordTypeId = idInsuranceRTIdReadOnly;                                 
                }
            }
        }
    }
    
    /**
    * This method Populates Customer Profile & Referral in Opportunity during Update.
    * @param  - N/A
    * @throws - N/A
    * @author Samit
    * @date 02-09-2017
    */    
    private static void populateOptyFieldsUpdate(List<Opportunity> lstOpty, Map<Id, Opportunity> mapOldOpty)
    {
        List<Opportunity> lstApplicableOptyRef =  new List<Opportunity>();
        List<Opportunity> lstApplicableOptyAcc =  new List<Opportunity>();
        Id idQualifiedRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_OpportunityQualifiedRetirement).getRecordTypeId();
        Id idInsuranceRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_OppRecType_Insurance).getRecordTypeId();
        for(Opportunity objOpty: lstOpty)
        {
            if(objOpty.WFG_CustomerProfile__c != mapOldOpty.get(objOpty.Id).WFG_CustomerProfile__c 
                || objOpty.WFG_Source__c != mapOldOpty.get(objOpty.Id).WFG_Source__c)
            {
                if(objOpty.RecordTypeId == idQualifiedRTId && (objOpty.WFG_CustomerProfile__c == NULL 
                    || objOpty.WFG_Source__c != System.Label.WFG_OpportunitySourceReferral))
                {
                    objOpty.WFG_Referral__c = NULL;
                }
                if(objOpty.WFG_Source__c == System.Label.WFG_OpportunitySourceReferral 
                   && objOpty.RecordTypeId == idQualifiedRTId 
                   && objOpty.WFG_CustomerProfile__c != NULL 
                   && objOpty.WFG_Referral__c == NULL)
                {
                    lstApplicableOptyRef.add(objOpty); 
                }
            }
            if(objOpty.WFG_Contact__c != mapOldOpty.get(objOpty.Id).WFG_Contact__c)
            {
                lstApplicableOptyAcc.add(objOpty); 
            }
            //Checking for Opportunity being moved to Final Stage.
            if(objOpty.stageName <> mapOldOpty.get(objOpty.Id).stageName 
               && objOpty.stageName == System.Label.WFG_OpportunityStage_CloseWon
               && objOpty.WFG_Lost_Reason__c != null)
            {
                objOpty.WFG_Lost_Reason__c = null;
            }
        }
        if(lstApplicableOptyRef != null && !lstApplicableOptyRef.isEmpty())populateOptyReferral(lstApplicableOptyRef);
        if(lstApplicableOptyAcc != null && !lstApplicableOptyAcc.isEmpty()) populateOptyAccount(lstApplicableOptyAcc);
    }
    
    public static void setupOpptModal(List<Opportunity> lstOpty, Map<Id, Opportunity> mapOldOpty)
    {
        for (Opportunity opp: lstOpty) 
        {
            system.debug('opp.StageName### ' + opp.StageName);
            if (opp.StageName == system.Label.WFG_OpportunityStage_Recommendation || 
                opp.StageName == system.Label.WFG_OpportunityStage_Application || 
                opp.StageName == system.label.WFG_OpportunityStage_PendingSale || 
                opp.StageName == system.Label.WFG_OpportunityStage_CloseWon) 
            {                
                if (opp.WFG_CustomerProfile__c != null 
                    && opp.WFG_Customer_Profile_Status__c == system.Label.WFG_CustomerProfileIncomplete) 
                {  
                    opp.WFG_ModalName__c = 'showEditModal:' + opp.Stagename;                
                    //opp.StageName = mapOldOpty.get(opp.Id).StageName;
                }
                
                if (opp.WFG_CustomerProfile__c == null) 
                { 
                    opp.WFG_ModalName__c = 'showModal:' + opp.Stagename; 
                    //opp.StageName = mapOldOpty.get(opp.Id).StageName;                    
                }                
            }
            
        }
    }
    
    /**
* This method Populates Customer Profile & Referral in Opportunity during Insertion
* @param  - N/A
* @throws - N/A
* @author Samit
* @date 02-09-2017
*/    
    private static void populateOptyFieldsInsert(List<Opportunity> lstOpty)
    {
        List<Opportunity> lstApplicableOpty = new List<Opportunity>();
        List<Opportunity> lstApplicableOptyRef =  new List<Opportunity>();
        List<Opportunity> lstApplicableOptyAcc = new List<Opportunity>();
        List<Id> lstReferralId = new List<Id>();
        Id idQualifiedRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_OpportunityQualifiedRetirement).getRecordTypeId();
        for(Opportunity objOpty: lstOpty)
        {
            if(objOpty.WFG_CustomerProfile__c == NULL && objOpty.WFG_Referral__c != NULL)
            {
                lstApplicableOpty.add(objOpty);
                lstReferralId.add(objOpty.WFG_Referral__c);
            }
            if(objOpty.WFG_Source__c == System.Label.WFG_OpportunitySourceReferral && objOpty.RecordTypeId == idQualifiedRTId && objOpty.WFG_CustomerProfile__c != NULL && objOpty.WFG_Referral__c == NULL)
            {
                lstApplicableOptyRef.add(objOpty);              
            }
            if(objOpty.WFG_Contact__c != NULL && objOpty.AccountId == NULL)
            {
                lstApplicableOptyAcc.add(objOpty);
            }
        }
        
        if(!lstApplicableOpty.isEmpty())
        {
            Map<Id, WFG_Referral__c> mapReferral = new Map<Id, WFG_Referral__c>(
                [SELECT Id, (SELECT Id FROM Customer_Profiles__r) FROM WFG_Referral__c WHERE Id IN: lstReferralId]);
            for(Opportunity objOpty: lstApplicableOpty)
            {
                if(objOpty.WFG_Referral__c != NULL && mapReferral.get(objOpty.WFG_Referral__c) != NULL
                   && (!mapReferral.get(objOpty.WFG_Referral__c).Customer_Profiles__r.isEmpty()))
                {
                    ObjOpty.WFG_CustomerProfile__c = mapReferral.get(objOpty.WFG_Referral__c).Customer_Profiles__r[0].Id;
                }
            }
        }
        populateOptyReferral(lstApplicableOptyRef);
        populateOptyAccount(lstApplicableOptyAcc);
    }
    
    /**
* This method Populates Referral in Opportunity.
* @param  - lstApplicableOptyRef: List of Applicable Opportunity that needs to be updated
* @throws - N/A
* @author Samit
* @date 02-09-2017
*/   
    private static void populateOptyReferral(List<Opportunity> lstApplicableOptyRef)
    {
        if(!lstApplicableOptyRef.isEmpty())
        {
            List<Id> lstCPId = new List<Id>();
            for(Opportunity objOpty: lstApplicableOptyRef)
            {
                lstCPId.add(objOpty.WFG_CustomerProfile__c);
            }
            Map<Id, WFG_Customer_Profile__c> mapCp = new Map<Id, WFG_Customer_Profile__c>(
                [SELECT WFG_Referral__c FROM WFG_Customer_Profile__c WHERE Id IN: lstCPId]);
            for(Opportunity objOpty: lstApplicableOptyRef)
            {
                if(objOpty.WFG_CustomerProfile__c != NULL && mapCp.get(objOpty.WFG_CustomerProfile__c) != NULL)
                {
                    objOpty.WFG_Referral__c = mapCp.get(objOpty.WFG_CustomerProfile__c).WFG_Referral__c;
                }
            }
        }
    }
    
    /**
* This method Populates Account in Opportunity.
* @param  - lstApplicableOptyRef: List of Applicable Opportunity that needs to be updated
* @throws - N/A
* @author Samit
* @date 02-09-2017
*/  
    private static void populateOptyAccount(List<Opportunity> lstApplicableOptyAcc)
    {
        if(!lstApplicableOptyAcc.isEmpty())
        {
            List<Id> lstConId = new List<Id>();
            for(Opportunity objOpty: lstApplicableOptyAcc)
            {
                lstConId.add(objOpty.WFG_Contact__c);
            }
            Map<Id, Contact> mapCon = new Map<Id, Contact>(
                [SELECT Id, AccountId FROM Contact WHERE Id IN: lstConId]);
            for(Opportunity objOpty: lstApplicableOptyAcc)
            {
                if(objOpty.WFG_Contact__c != NULL && mapCon.get(objOpty.WFG_Contact__c) != NULL)
                {
                    objOpty.AccountId = mapCon.get(objOpty.WFG_Contact__c).AccountId;
                }
            }
        }        
    }   
    
     /**
    * This method restricts only one opportunity for the Recruiting type of opportunities.
    * @param  - lstApplicableOptyRef: List of Applicable Opportunity that needs to be updated
    * @throws - N/A
    * @author Ninad
    * @date 02-09-2017
    */  
    private static void restrictNumberOfActiveOpportunities(List<Opportunity> lstOpportunity, map<Id, opportunity> mapNewOpportunity,
        map<id, opportunity> mapOldOpportunity, boolean isUpate)
    {
        ID idRecruitmentUSA = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_POP_OpportunityRecruitment).getRecordTypeId();
        Id idRecruitmentCAN = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_POP_OpportunityRecruitment_CAN).getRecordTypeId();
        
        List<Opportunity> lstOPP = new List<Opportunity>();
        List<Id> lstOppId = new List<Id>();
        for(Opportunity objOpp : lstOpportunity)
        {
            if(
                (objOpp.RecordTypeId == idRecruitmentUSA || objOpp.RecordTypeId == idRecruitmentCAN) 
                && 
                (!isUpate || 
                    (isUpate && (mapNewOpportunity.get(objOpp.Id).WFG_Contact__C <> mapOldOpportunity.get(objOpp.Id).WFG_Contact__C) 
                    || (mapNewOpportunity.get(objOpp.Id).recordtypeId <> mapOldOpportunity.get(objOpp.Id).recordtypeId))))
            {
                lstOPP.add(objOpp);
                if(isUpate) lstOppId.add(objOpp.Id);
            }
        }
        
        if(!lstOPP.isEmpty())
        {
            
            List<Id> lstConId = new List<Id>();
            for(Opportunity objOpty: lstOPP)
            {
                lstConId.add(objOpty.WFG_Contact__c);
            }
            Map<Id, Contact> mapCon = new Map<Id, Contact>(
                [SELECT Id, AccountId, (Select id, name from WFG_Opportunities__r 
                    where recordtypeID IN (:idRecruitmentUSA,:idRecruitmentCAN) 
                    AND stageName != :system.Label.WFG_OpportunityStage_Opportunity_Lost
                    AND ID NOT IN :lstOppId) 
                FROM Contact WHERE Id IN: lstConId]);
            system.debug('######## MAP ::' + mapCon);
            for(Opportunity objOpty: lstOPP)
            {
                if(mapCon.containsKey(objOpty.WFG_Contact__c) && mapCon.get(objOpty.WFG_Contact__c) != null)
                {
                    if(mapCon.get(objOpty.WFG_Contact__c).WFG_Opportunities__r != null && !mapCon.get(objOpty.WFG_Contact__c).WFG_Opportunities__r.isEmpty())
                    {
                        system.debug('######## MAP :: ERROR THROWN');
                        objOpty.addError(system.Label.WFG_RecruitmentOppNUnmber_Restriction);
                    }
                }
            }
        }        
    } 
    
}