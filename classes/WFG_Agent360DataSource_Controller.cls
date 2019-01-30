/*
Property of Transamerica and Aegon companies. Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Madhurupa Ghose Roy
* @date 05-20-2016
* @description US-2295: This page does below processing
  - View the 360 degree information for an Agent

Modification Log:
__________________________________________________________________________________________________________
Developer          ModNumber           Date                    Description
__________________________________________________________________________________________________________
Madhurupa          M-001               06-15-2016              US-2287: Modified complaints management 
                                                               quick case with additional fields/actions
Ramanarayanan P    M-002               06-15-2016              US-2351: Open the About agent's page and
                                                               case detail page upon creation
Madhurupa          M-003               06-16-2016              US-2345: Added interacting columns on case
                                                               card details on agent 360
Manuel             M-004               06-16-2016              US-2358: Fields for Upline, Spouse, BOM, RBM
                                                               and BOS created in Salesforce to be imported
                                                               from Compass
Ramanarayanan P    M-005               06-22-2016              US-2351: Open the About agent's page and
                                                               case detail page upon creation
Madhurupa          M-006               06-22-2016              US-2287: Modified complaints management 
                                                               quick case with additional fields/actions
Ramanarayanan P    M-007               06-24-2016              US-2351: Open the About agent's page and
                                                               case detail page upon creation
Ramanarayanan P    M-008               06-24-2016              US-2332: Interacting With/About Component
                                                               for case feed layout
Madhurupa          M-009               06-28-2016              US-2287: Modified complaints management 
                                                               quick case with additional fields/actions
Madhurupa          M-0010              06-28-2016              US-2374: Hide statuses that are null

Manuel             M-0011              07-18-2016              TKT-000124: Remove Contact.Phone from intPhoneCount

Deepthi N          M-0012              03-31-2017              W-002940: State PRC to PR text update
*/

public class WFG_Agent360DataSource_Controller {
    
     /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Queries Cases
    * @author Deloitte Consulting LLP
    * @date 05-20-2016
    * @param contactId
    * @return CaseWrapper
    * @description Queries Cases.
    */
    
    @AuraEnabled 
    public static WFG_Agent360_CaseWrapper getCaseResults(String contactId){
        
        WFG_Agent360_CaseWrapper caseWrapper = new WFG_Agent360_CaseWrapper();
        List<String> lstLabel = new List<String>();
        List<Case> lstCases = new List<Case>();
        List<Case> lstDisplayedCases = new List<Case>();
        Integer intCount = 0, intOpenCases = 0, intInProgressCases = 0;
               
        String query = 'SELECT id';
        System.debug('$$$$$$'+query);
        for(Schema.FieldSetMember fields : Schema.SObjectType.Case.FieldSets.WFG_CaseFields.getfields()){
            query += ', ' + fields.getfieldpath();
        }
        lstLabel.add('Age');
        
        query += ', Contact.Name, WFG_InteractingAbout__r.Name';
        query += ' FROM Case WHERE ContactId = :contactId OR WFG_InteractingAbout__c = :contactId ORDER BY CreatedDate desc';
        lstCases = Database.query(query);
        System.debug('lstCases ##'+lstCases);
        if(lstCases.size() > 0) {
        System.debug('lstCases ##'+lstCases);
            for(Case objCase:lstCases){
                if(objCase.Status == WFG_Utility__c.getAll().get('CaseNewStatus').Value__c || objCase.Status == WFG_Utility__c.getAll().get('CaseProgStatus').Value__c || objCase.Status == WFG_Utility__c.getAll().get('CaseRschStatus').Value__c || objCase.Status == WFG_Utility__c.getAll().get('CaseEscStatus').Value__c){
                    intOpenCases++;
                }
                if (objCase.Status == WFG_Utility__c.getAll().get('CaseProgStatus').Value__c){
                    intInProgressCases++;
                }
                if(intCount < 5){
                    lstDisplayedCases.add(objCase);
                }
                intCount++;
            }
        }
        
        caseWrapper.lstCases = lstDisplayedCases;
        caseWrapper.intOpenCasesCount = intOpenCases;
        caseWrapper.intInProgressCasesCount = intInProgressCases;
        caseWrapper.intCount = intCount;
        
        if(lstCases != null && !lstCases.isEmpty()){
            caseWrapper.hasCases = true;
        }
        return caseWrapper;
    }
    
     /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Gets Contact, AgentCode, AgentStatus
    * @author Deloitte Consulting LLP
    * @date 05-20-2016
    * @param ContactId
    * @return Void
    * @description Gets Contact, AgentCode, AgentStatus
    */
    
    @AuraEnabled
    public static WFG_AgentHeaderData getContact(Id contactId) {
        Integer intPhoneCount = 0, intEmailCount = 0, intAgentCodeCount=0;
        List<String> lstPhn = new List<String>();
        List<String> lstEmail = new List<String>();
        WFG_AgentHeaderData data = new WFG_AgentHeaderData();
       
        Contact[] query = [
            SELECT Id, 
            Name,
            WFG_AgentID__c,
            FirstName,
            WFG_AgentCode__c, 
            WFG_AgentLevel__c,
            WFG_Res__c, 
            Birthdate, 
            WFG_SpouseCode__c, 
            WFG_SpouseCode__r.WFG_Contact__r.Id,
            WFG_SpouseCode__r.WFG_Contact__r.Name,
            WFG_SpouseCode__r.Name,
            WFG_SpouseName__c,
            WFG_Spouse__c,
            WFG_SpouseAgent__c,
            WFG_LastContactedDate__c, 
            WFG_Channel__c,
            WFG_Dedicated__c,
            MailingStreet,
            MailingCity,MailingPostalCode,MailingState,MailingCountry,MailingLatitude,MailingLongitude,
            Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingCountry,
            Account.BillingPostalCode,Account.BillingLatitude,Account.BillingLongitude,
            WFG_Status__c,
            WFG_BulletinName__c,
            WFG_SSNSIN__c,
            Account.Phone,
            AssistantPhone,
            HomePhone,
            MobilePhone,
            OtherPhone,
            Phone,
            Email,
            WFG_AlternateEmail__c,
            Owner.Name,
            WFG_BrokerCRDNumber__c,
            WFG_AgentLevelDescription__c
            FROM Contact
            Where Id =:contactId
        ];
        if(!query.isEmpty()) {            
            Map<String, WFG_AgentRelatedCodeWrapper> mapAgentCodes = new Map<String, WFG_AgentRelatedCodeWrapper>();
            List<WFG_AgentRelatedCodeWrapper> lstAcList = new List<WFG_AgentRelatedCodeWrapper>();
            data.agentStatus = false;
            for (WFG_AgentCode__c objAc2 : [SELECT id,
                                         Name,
                                         WFG_PrimaryCode__c,
                                         WFG_USStatus__c,
                                         WFG_USStatusDate__c,
                                         WFG_CAStatus__c,
                                         WFG_CAStatusDate__c,
                                         WFG_PRStatus__c,
                                         WFG_PRStatusDate__c,
                                         WFG_Level__c,
                                         WFG_LevelDescription__c,
                                         WFG_StartDate__c,
                                         WFG_SMDApprovalDate__c,
                                         WFG_LevelStartDate__c,
                                         WFG_RegionalBranchManagerCode__r.WFG_Contact__r.Name,
                                         WFG_BranchOfficeManagerCode__r.WFG_Contact__r.Name,
                                         WFG_BranchOfficeSupervisorCode__r.WFG_Contact__r.Name,
                                         WFG_RegionalBranchManagerCode__r.WFG_Contact__r.Id,
                                         WFG_BranchOfficeManagerCode__r.WFG_Contact__r.Id,
                                         WFG_BranchOfficeSupervisorCode__r.WFG_Contact__r.Id,
                                         WFG_RegionalBranchManagerCode__r.Name,
                                         WFG_BranchOfficeManagerCode__r.Name,
                                         WFG_BranchOfficeSupervisorCode__r.Name,
                                         WFG_UplineCode__r.WFG_Contact__r.Name,
                                         WFG_UplineCode__r.Name,
                                         WFG_UplineCode__r.WFG_Contact__r.Id
                                         FROM WFG_AgentCode__c
                                         WHERE WFG_Contact__c=:query[0].Id] ){
                if(objAc2.Name!= NULL ){
                    WFG_AgentRelatedCodeWrapper wrapper = new WFG_AgentRelatedCodeWrapper();
                    wrapper.agentId = objAc2.id;
                    wrapper.agentName = objAc2.Name;
                    wrapper.USStatus = objAc2.WFG_USStatus__c;
                    wrapper.USStatusDate = getConvertedDate(objAc2.WFG_USStatusDate__c);
                    wrapper.CAStatus = objAc2.WFG_CAStatus__c;
                    wrapper.CAStatusDate = getConvertedDate(objAc2.WFG_CAStatusDate__c);
                    wrapper.PRStatus = objAc2.WFG_PRStatus__c;
                    wrapper.PRStatusDate = getConvertedDate(objAc2.WFG_PRStatusDate__c);
                    wrapper.Level = objAc2.WFG_Level__c;
                    wrapper.LevelDescription = objAc2.WFG_LevelDescription__c;
                    wrapper.StartDate = getConvertedDate(objAc2.WFG_StartDate__c);
                    wrapper.SMDApprovalDate = getConvertedDate(objAc2.WFG_SMDApprovalDate__c);
                    wrapper.LevelStartDate = getConvertedDate(objAc2.WFG_LevelStartDate__c);
                    wrapper.RegionalBranchManagerCodeName = objAc2.WFG_RegionalBranchManagerCode__r.WFG_Contact__r.Name;
                    wrapper.BranchOfficeManagerCodeName = objAc2.WFG_BranchOfficeManagerCode__r.WFG_Contact__r.Name;
                    wrapper.BranchOfficeSupervisorCodeName = objAc2.WFG_BranchOfficeSupervisorCode__r.WFG_Contact__r.Name;
                    wrapper.UplineCodeName = objAc2.WFG_UplineCode__r.WFG_Contact__r.Name;                   
                    wrapper.RegionalBranchManagerCodeId = objAc2.WFG_RegionalBranchManagerCode__r.WFG_Contact__r.Id;
                    wrapper.BranchOfficeManagerCodeId = objAc2.WFG_BranchOfficeManagerCode__r.WFG_Contact__r.Id;
                    wrapper.BranchOfficeSupervisorCodeId = objAc2.WFG_BranchOfficeSupervisorCode__r.WFG_Contact__r.Id;
                    wrapper.UplineCodeId = objAc2.WFG_UplineCode__r.WFG_Contact__r.Id;                   
                    wrapper.RegionalBranchManagerCode = objAc2.WFG_RegionalBranchManagerCode__r.Name;
                    wrapper.BranchOfficeManagerCode= objAc2.WFG_BranchOfficeManagerCode__r.Name;
                    wrapper.BranchOfficeSupervisorCode = objAc2.WFG_BranchOfficeSupervisorCode__r.Name;
                    wrapper.UplineCode = objAc2.WFG_UplineCode__r.Name;
                    wrapper.PrimaryCode = objAc2.WFG_PrimaryCode__c;
                    if((objAc2.WFG_USStatus__c !=null) || (objAc2.WFG_CAStatus__c !=null) || (objAc2.WFG_PRStatus__c !=null) )
                    {
                        data.agentStatus = true;
                    }
                    
                    mapAgentCodes.put(objAc2.Name, wrapper);
                    
                    if(wrapper!=null){
                        lstAcList.add(wrapper);
                        data.lstAgentCodes = lstAcList;
                    }
                    intAgentCodeCount++;
                }
                
            }
            data.mapAgentCodes = mapAgentCodes;
            data.intAgentCodeCount=intAgentCodeCount; 
            
            WFG_AgentStatus__c [] lstAstat = [SELECT id, 
                                              Name,
                                              WFG_Contact__c,
                                              WFG_StartDate__c,
                                              WFG_Status__c
                                              FROM WFG_AgentStatus__c
                                              WHERE WFG_Contact__c=:query[0].Id];
            
            if(!lstAstat.isEmpty()){
                data.agentStatus = true;
            }
            
            if(!lstAstat.isEmpty()){
                for(WFG_AgentStatus__c objStatus:lstAstat) {
                    
                    if(objStatus.Name == WFG_Utility__c.getAll().get('NewCaseAgtWFGIAStatus').Value__c || objStatus.Name == WFG_Utility__c.getAll().get('NewCaseAgtWFG_IAStatus').Value__c) {
                        data.WFGIAStatus = objStatus.WFG_Status__c;
                        if(objStatus.WFG_StartDate__c!=null){
                            data.WFGIAStartDate = getConvertedDate(objStatus.WFG_StartDate__c);
                        }
                    }
                    if(objStatus.Name == WFG_Utility__c.getAll().get('NewCaseAgtTFAStatus').Value__c) {
                        data.TFAStatus = objStatus.WFG_Status__c;
                        if(objStatus.WFG_StartDate__c!=null){
                            data.TFAStartDate = getConvertedDate(objStatus.WFG_StartDate__c);
                        }
                    }
                    if(objStatus.Name == WFG_Utility__c.getAll().get('NewCaseAgtTFAIAStatus').Value__c || objStatus.Name == WFG_Utility__c.getAll().get('NewCaseAgtTFA_IAStatus').Value__c) {
                        data.TFAIAStatus = objStatus.WFG_Status__c;
                        if(objStatus.WFG_StartDate__c!=null){
                            data.TFAIAStartDate = getConvertedDate(objStatus.WFG_StartDate__c);
                        }
                    }
                    if(objStatus.Name == WFG_Utility__c.getAll().get('NewCaseAgtWFGSStatus').Value__c) {
                        data.WFGSStatus = objStatus.WFG_Status__c;
                        if(objStatus.WFG_StartDate__c!=null){
                            data.WFGSStartDate = getConvertedDate(objStatus.WFG_StartDate__c);
                        }
                    }
                    if(objStatus.Name == WFG_Utility__c.getAll().get('NewCaseAgtAMLStatus').Value__c) {
                        data.AMLStatus = objStatus.WFG_Status__c;
                        if(objStatus.WFG_StartDate__c!=null){
                            data.AMLStartDate = getConvertedDate(objStatus.WFG_StartDate__c);
                        }
                    }
                    if(objStatus.Name == WFG_Utility__c.getAll().get('NewCaseAgtE_OStatus').Value__c) {
                        data.EOStatus = objStatus.WFG_Status__c;
                        if(objStatus.WFG_StartDate__c!=null){
                            data.EOStartDate = getConvertedDate(objStatus.WFG_StartDate__c);
                        }
                    }
                }  
            }
            
            
            data.contactId = query[0].Id;
            data.name = query[0].Name;
            data.AgId = query[0].WFG_AgentID__c;
            data.AgentCode = query[0].WFG_AgentCode__c;
            data.AgentLevel = query[0].WFG_AgentLevel__c;
            data.Res = query[0].WFG_Res__c; 
            data.FirstName = query[0].FirstName;
            data.SSNSIN = query[0].WFG_SSNSIN__c;
            if(query[0].Owner.Name!=null || query[0].Owner.Name !='') {
                data.OwnerName = query[0].Owner.Name;
            }
            data.BrokerCRDNumber = query[0].WFG_BrokerCRDNumber__c; 
            data.AgentLevelDescription = query[0].WFG_AgentLevelDescription__c;
            
            if(query[0].Birthdate!=null){
                data.Birthdate = query[0].Birthdate.month()+'/'+query[0].Birthdate.day();
            }
            if((query[0].WFG_SpouseCode__c==null) && (query[0].WFG_Spouse__c !=null || (query[0].WFG_Spouse__c !=''))){
                data.Spouse1= query[0].WFG_Spouse__c;           
            }
            else if(query[0].WFG_SpouseCode__c!=null || query[0].WFG_SpouseCode__c!=''){
                data.Spouse2 = query[0].WFG_SpouseCode__r.WFG_Contact__r.Name+' ('+query[0].WFG_SpouseCode__r.Name+')'; 
                data.Spouse2Id = query[0].WFG_SpouseCode__r.WFG_Contact__r.Id;
            }
            
               
            if(query[0].WFG_LastContactedDate__c!=null){
                data.LastContactDate = query[0].WFG_LastContactedDate__c.month()+'/'+query[0].WFG_LastContactedDate__c.day()+'/'+query[0].WFG_LastContactedDate__c.year();  
            }
            data.Channel = query[0].WFG_Channel__c;                   
            data.Dedicated = query[0].WFG_Dedicated__c;         
            data.MailingStreet = query[0].MailingStreet;   
            //data.MailingState = query[0].MailingState;
            data.MailingState = query[0].WFG_Res__c ;
            data.MailingCity = query[0].MailingCity; 
            data.MailingCountry = query[0].MailingCountry; 
            data.MailingPostalCode = query[0].MailingPostalCode; 
            data.MailingLatitude = query[0].MailingLatitude; 
            data.MailingLongitude = query[0].MailingLongitude; 
            data.BillingStreet = query[0].Account.BillingStreet; 
            data.BillingCity = query[0].Account.BillingCity; 
            if(query[0].Account.BillingState != 'PRC'){
            data.BillingState = query[0].Account.BillingState; 
            }
            else
            {
            data.BillingState = 'PR';
            }
            data.BillingCountry = query[0].Account.BillingCountry; 
            data.BillingPostalCode = query[0].Account.BillingPostalCode; 
            data.BillingLatitude = query[0].Account.BillingLatitude; 
            data.BillingLongitude = query[0].Account.BillingLongitude; 
            data.Status = query[0].WFG_Status__c;  
            if(query[0].Account.Phone!=null){                
                data.BranchPhone = query[0].Account.Phone;
                intPhoneCount++;
            }

            if(query[0].HomePhone!=null){
                data.HomePhone = query[0].HomePhone;
                intPhoneCount++;
            }
            if(query[0].MobilePhone!=null){
                data.MobilePhone = query[0].MobilePhone;    
                intPhoneCount++;
            }
            if(query[0].Email!=null){                
                data.Email = query[0].Email;
                intEmailCount++;
            }
            if(query[0].WFG_AlternateEmail__c!=null){                
                data.AlternateEmail = query[0].WFG_AlternateEmail__c;
                intEmailCount++;
            }
            data.intPhoneCount = intPhoneCount;
            data.intEmailCount = intEmailCount;
            data.BulletinName = query[0].WFG_BulletinName__c; 
            
        }
        
        return data;
        
    }
    
     /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * getCaseStatus
    * @author Deloitte Consulting LLP
    * @date 05-20-2016
    * @param No Parameter
    * @return Void
    * @description getCaseStatus
    */
    
    @AuraEnabled
    public static List<String> getCaseStatus(){
        
        List<String> lstCaseStatus = new List<String>();
        
        for(Schema.PicklistEntry picklist : Case.Status.getDescribe().getPicklistValues()){
            lstCaseStatus.add(picklist.getLabel());
        }

        return lstCaseStatus;
    }
    
     /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * getCaseSource
    * @author Deloitte Consulting LLP
    * @date 05-20-2016
    * @param No Parameter
    * @return Void
    * @description getCaseSource
    */
    
    @AuraEnabled
    public static List<String> getCaseSource(){
        
        List<String> lstCaseSource = new List<String>();
        for(Schema.PicklistEntry picklist : Case.Origin.getDescribe().getPicklistValues()){
            lstCaseSource.add(picklist.getLabel());
        }
        return lstCaseSource;
    }
    
     /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * getCaseType
    * @author Deloitte Consulting LLP
    * @date 05-20-2016
    * @param No Parameter
    * @return Void
    * @description getCaseType
    */
    
    @AuraEnabled
    public static List<String> getCaseType(){
        
        List<String> lstCaseType = new List<String>();
        lstCaseType.add(WFG_Utility__c.getAll().get('NewCaseTypeNone').Value__c);
        if(lstCaseType.size()>0){
            for(Schema.PicklistEntry picklist : Case.Type.getDescribe().getPicklistValues()){
                lstCaseType.add(picklist.getLabel());
            }
        }
        
        return lstCaseType;
    }
    
     /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * getCaseReason
    * @author Deloitte Consulting LLP
    * @date 05-20-2016
    * @param No Parameter
    * @return Void
    * @description getCaseReason
    */
    
    @AuraEnabled
    public static List<String> getCaseReason(){
        
        List<String> lstCaseReason = new List<String>();
        for(Schema.PicklistEntry picklist : Case.WFG_Case_Reason_2__c.getDescribe().getPicklistValues()){
            lstCaseReason.add(picklist.getLabel());
        }
        return lstCaseReason;
    }
    
     @AuraEnabled
    public static Map<String,List<String>> getDependentOptions()
    {
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        Schema.SObjectType pType = objGlobalMap.get(WFG_Utility__c.getAll().get('NewCaseDepOptObj').Value__c);
        Map<String,List<String>> mapreturnVal = WFG_PicklistFieldDescribeUtility.getDependentOptions(WFG_Utility__c.getAll().get('NewCaseDepOptObj').Value__c, 
            WFG_Utility__c.getAll().get('NewCaseDepOptFld1').Value__c, 
            WFG_Utility__c.getAll().get('NewCaseDepOptFld2').Value__c);
        return mapreturnVal;
    }
    
     /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * getDependentOptions
    * @author Deloitte Consulting LLP
    * @date 05-20-2016
    * @param No Parameter
    * @return Void
    * @description getDependentOptions
    */
    
    //Code  Added By Ram - Picklist Dependency
    @AuraEnabled
    public static Map<String,List<String>> getDependentOptions1()
    {
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        Schema.SObjectType pType = objGlobalMap.get(WFG_Utility__c.getAll().get('NewCaseDepOptObj').Value__c);
        Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();   
        List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(WFG_Utility__c.getAll().get('NewCaseDepOptFld1').Value__c).getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> dep_ple = objFieldMap.get(WFG_Utility__c.getAll().get('NewCaseDepOptFld2').Value__c).getDescribe().getPicklistValues();
        List<String> lstLabel = new List<String>();
        List<String> lstValidFor = new List<String>();
        Integer ctrlSize = ctrl_ple.size();
        Integer depSize = dep_ple.size();
        String pEntryStructure = '';
        
        for(Integer pControllingIndex=0; pControllingIndex < ctrlSize; pControllingIndex++)
        {             
            objResults.put(ctrl_ple[pControllingIndex].getLabel(),new List<String>());            
        }
        
        for(Integer pDependentIndex=0; pDependentIndex < depSize; pDependentIndex++){          
            pEntryStructure = JSON.serialize(dep_ple[pDependentIndex]);    
            WFG_PicklistEntry objDepPLE = (WFG_PicklistEntry)JSON.deserialize(pEntryStructure, WFG_PicklistEntry.class);         
            lstLabel.add(objDepPLE.label);
            lstValidFor.add(objDepPLE.validFor);     
        }
       
        return DependentCalculation(lstLabel,lstValidFor,objResults);   
    }
    
     /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * DependentCalculation
    * @author Deloitte Consulting LLP
    * @date 05-20-2016
    * @param No Parameter
    * @return Void
    * @description DependentCalculation
    */
    
    //Added By Ram
    public static  Map<String,List<String>> DependentCalculation(List<String> lstLabel,List<String>lstValidFor,Map<String,List<String>> objResults){
        Map<String, Integer> Base64CharCodes = new Map<String,Integer>{
            'A'=>0,'B'=>1,'C'=>2,'D'=>3,'E'=>4,'F'=>5,'G'=>6,'H'=>7,'I'=>8,'J'=>9,
                'K'=>10,'L'=>11,'M'=>12,'N'=>13,'O'=>14,'P'=>15,'Q'=>16,'R'=>17,'S'=>18,'T'=>19,
                'U'=>20,'V'=> 21,'W'=>22,'X'=>23,'Y'=>24,'Z'=>25,'a'=>26,'b'=>27,'c'=>28,'d'=>29,'e'=>30,'f'=>31,'g'=>32,'h'=>33,'i'=>34,'j'=>35,
                'k'=>36,'l'=>37,'m'=>38,'n'=>39,'0'=>40,'p'=>41,'q'=>42,'r'=>43,'s'=>44,'t'=>45,
                'u'=>46,'v'=> 47,'w'=>48,'x'=>49,'y'=>50,'z'=>51,'1'=>53,'2'=>54,'3'=>55,'4'=>56,'5'=>57,'6'=>58,
                '7'=>59,'8'=> 60,'9'=>61,'/'=>63,'0'=>52 
                };
       
        List<String> ctrlLabel = new List<String>();
        if(!objResults.isEmpty()) {
            for(String ctrl:objResults.keySet())
            {
                ctrlLabel.add(ctrl);
            }
            Integer bytesBeingUsed=0;
            Integer pFullValue = 0;
            Integer bit=0,targetOctet=0,shiftBits=0,pShiftAmount=0,tBitVal = 0;
            Integer i,m,j;
            String valid='';
                
            Map<String,Integer> pBytesMap = new Map<String,Integer>();
            if(lstValidFor.size() > 0) {
            for(String valid2 : lstValidFor)
            {
                for( j=0;j<valid2.length();j++){
                    //get current character value
                    pShiftAmount = (valid2.length()-(j+1))*6;
                    //pBytes.Add((Base64CharCodes.get((valid.Substring(j, j+1)))));
                    pFullValue = pFullValue + (Base64CharCodes.get((valid2.Substring(j, j+1))) << (pShiftAmount)); 
                    //pBytes.Add((Base64CharCodes.get((valid.charAt(j)))));
                 }
               pBytesMap.put(valid2, pFullValue);
                pFullValue = 0;
            }
            for( i=0;i<objResults.keySet().size();i++)
            {
                for( m=0;m<lstValidFor.size();m++ )
                {
                    
                    valid = lstValidFor[m];
                    bytesBeingUsed  = (valid.length() * 6)/8;
                    bit = 7 - (Math.mod(i,8));
                    targetOctet = (bytesBeingUsed - 1) - (i >> bytesBeingUsed);
                    shiftBits = (targetOctet * 8) + bit; 
                    tBitVal = ((Integer)(Math.Pow(2, shiftBits)) & pBytesMap.get(valid)) >> shiftBits;
                    if(tBitVal==1)
                    {
                      objResults.get(ctrlLabel[i]).add(lstLabel[m]);
                    }
                }           
            }
        }
     }
         return objResults;
    }
    
     /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Searches Agent Codes
    * @author Deloitte Consulting LLP
    * @date 05-20-2016
    * @param No Parameter
    * @return Void
    * @description Searches Agent Codes
    */
    
    @AuraEnabled
    public static List<WFG_AgentSearchData> getContacts(String searchText){
        
        List<WFG_AgentSearchData> lstSearchResult = new List<WFG_AgentSearchData>();
       // String strAgentCode = searchText;
        String strAgentCode = searchText.trim();
        String strFirstNameSearch = '%'+strAgentCode;
        String strLastNameSearch = +strAgentCode+'%';
        Set<Id> setContactIds = new Set<Id>();
        
        if(String.isNotBlank(strAgentCode) && strAgentCode != null){              
           
            Set<ID> setIds = new Set<ID>();
            String strLikeQuery = '{'+strAgentCode+'*}';
            
            System.debug('locha saala....'+strLikeQuery);
            //strLikeQuery = strLikeQuery.replaceAll('', '*');
            system.debug('===strLikeQuery ====='+strLikeQuery );
            system.debug('===strAgentCode ====='+strAgentCode);
 
            String strQuery = 'FIND '+strLikeQuery + ' IN ALL FIELDS RETURNING  WFG_AgentCode__c(Id, WFG_Contact__c WHERE (Name = \''+strAgentCode+'\')), Contact(Id,FirstName, LastName, Name WHERE (Name LIKE \''+strAgentCode+'\') or (FirstName = \''+strAgentCode+'\') or (WFG_SSNSIN__c = \''+strAgentCode+'\') or (LastName = \''+strAgentCode+'\')) LIMIT 10';
            system.debug('===strQuery ====='+strQuery );
            List<List<SObject>> lstDynamicSearchList = Search.query(strQuery);
            system.debug('strQuery'+strQuery);
            system.debug('+++query'+lstDynamicSearchList);
            if(lstDynamicSearchList.size() > 0){
            
                for(WFG_AgentCode__c objAgn : (List<WFG_AgentCode__c>) lstDynamicSearchList[0]) {
                    setIds.add(objAgn.WFG_Contact__c);         
                }
                
                for(Contact objContact : (List<Contact>) lstDynamicSearchList[1]) {              
                    setIds.add(objContact.Id);          
                }
                
                if(!setIds.isEmpty()){
                    for(WFG_AgentCode__c agnCode : [Select Id, Name, WFG_Contact__c, WFG_Contact__r.Name, WFG_Contact__r.WFG_SSNSIN__c, WFG_Contact__r.WFG_AgentLevel__c FROM WFG_AgentCode__c Where WFG_Contact__c IN :setIds LIMIT 10]){
                        lstSearchResult.add(new WFG_AgentSearchData(agnCode.WFG_Contact__c, agnCode.WFG_Contact__r.Name, agnCode.Name, agnCode.WFG_Contact__r.WFG_AgentLevel__c, agnCode.WFG_Contact__r.WFG_SSNSIN__c));
                    
                    }
                    
                }   
            }
        } 
        System.debug('Doodh ka doodh aur pani ka pani....'+lstSearchResult);
        return lstSearchResult;
    }

    
     /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Create new case
    * @author Deloitte Consulting LLP
    * @date 05-20-2016
    * @param No Parameter
    * @return Void
    * @description Create new case
    */
    
    //Modified By Ram
    @AuraEnabled
    public static Case createNewCase(Id ContactId,String Subject,String Description,String Type,String Status,String Resolution,String Origin,String intWith,Id IntAbtId,String strAbtCode,String strBhlfCode,String Reason){
        Case newCase = new Case();
        newCase.ContactId = ContactId;
        newCase.Subject = Subject;
        newCase.Description = Description;        
        newCase.Type = Type;
        newCase.Status = Status;
        newCase.WFG_Resolution__c = Resolution;
        newCase.Origin = Origin;
        newCase.WFG_InteractingWith__c = intWith;
        newCase.WFG_InteractingAbout__c = IntAbtId;
        newCase.WFG_InteractingAboutCode__c = strAbtCode;
        newCase.WFG_AgentCode__c = strBhlfCode;
        newCase.WFG_Case_Reason_2__c = Reason;
        System.debug('@@@####newCase'+newCase);
        //Enforce Assignment Rule
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.useDefaultRule = true;
        dmo.EmailHeader.triggerOtherEmail = true;
      //System.debug('###$$$EmailOptions'+dmo.emailHeader.triggerAutoResponseEmail);
        try {
            if(newCase != null) {
                
                Database.SaveResult sr = Database.insert(newCase,dmo);

                // Iterate through each returned result
                //for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                      //Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted case. Case ID: ' + sr.getId());
                      //return 'Successfully inserted case. Case ID: ' + sr.getId();
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                          //return 'The following error has occurred. ' + err.getStatusCode() + ': ' + err.getMessage() + ' Case fields that affected this error: ' + err.getFields();
                        }
                }              
                system.debug('Case to be inserted: '+dmo);
              //database.insert(newCase,dmo); 
            }
        }
        catch (DMLException e){
            ApexPages.addMessages(e);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {System.Label.WFG_SupportEmail};
            mail.setToAddresses(toAddresses);
            mail.setReplyTo(System.Label.WFG_SupportEmail);
            mail.setSenderDisplayName(WFG_Utility__c.getAll().get('NewCaseExcepMsg').Value__c);
            mail.setSubject(WFG_Utility__c.getAll().get('NewCaseExcepErrMsg').Value__c + UserInfo.getOrganizationName());
            mail.setPlainTextBody(e.getMessage());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        }
        
        return newCase;
        
    }
    
     /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Queries Cases
    * @author Deloitte Consulting LLP
    * @date 05-20-2016
    * @param No Parameter
    * @return Void
    * @description Queries Cases.
    */
    
    //Added By Ram
    @AuraEnabled
    public static Case getCaseContact(Id caseId)
    {
        return [select Id,Contact.Name, ContactId, on_behalf_of__c, on_behalf_of__r.Name, WFG_AgentCode__c, WFG_InteractingWith__c, WFG_InteractingAbout__c, WFG_InteractingAbout__r.Name, WFG_InteractingAboutCode__c from Case where Id=:caseId];
    
    }
    
     /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Create Case
    * @author Deloitte Consulting LLP
    * @date 05-20-2016
    * @param No Parameter
    * @return Void
    * @description Create Case
    */
    
    @AuraEnabled
    public static void createNewCaseRecord(Case newCaseRec){
        System.debug('##$'+newCaseRec);
        try {
            if(newCaseRec != null){
                update newCaseRec; 
            }
        }
        catch (DMLException e){
            ApexPages.addMessages(e);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {System.Label.WFG_SupportEmail};
            mail.setToAddresses(toAddresses);
            mail.setReplyTo(System.Label.WFG_SupportEmail);
            mail.setSenderDisplayName(WFG_Utility__c.getAll().get('NewCaseExcepMsg').Value__c);
            mail.setSubject(WFG_Utility__c.getAll().get('NewCaseExcepErrMsg').Value__c + UserInfo.getOrganizationName());
            mail.setPlainTextBody(e.getMessage());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
    }
    
     /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Queries Quick Text
    * @author Deloitte Consulting LLP
    * @date 05-20-2016
    * @param No Parameter
    * @return Void
    * @description Queries Quick Text
    */
    
    //added by suhan for querring the quick text messsages
    @AuraEnabled
    @RemoteAction
    public static List < QuickText > autocompleteComment() {
        List < QuickText > lstQuickText = new List < QuickText > ();
        lstQuickText =[select message from quicktext];
        return lstQuickText;
    }
    
    /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Picklist Entry
    * @author Deloitte Consulting LLP
    * @date 05-20-2016
    * @param No Parameter
    * @return Void
    * @description Picklist Entry
    */
    
    public class WFG_PicklistEntry{
        public string active ;
        public string defaultValue;
        public string label;
        public string value; 
        public string validFor;
        public WFG_PicklistEntry(){
            
        }
    }
    
     /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Queries Liveagent Transcripts.
    * @author Deloitte Consulting LLP
    * @date 05-20-2016
    * @param No Parameter
    * @return Void
    * @description Queries Liveagent Transcripts.
    */
    
    //Added By Ram for Chat Transcript - US 2372
    @AuraEnabled
    public static List<WFG_ChatTranscript> getChatTranscripts(String contactId)
    {
        List<WFG_ChatTranscript> lstTranscript = new List<WFG_ChatTranscript>();
        List<LiveChatTranscript> lstChatTranscript = new List<LiveChatTranscript>();
        //Integer count = 0;
        String query = 'SELECT id';
        for(Schema.FieldSetMember fields : Schema.SObjectType.LiveChatTranscript.FieldSets.WFG_ChatTranscriptFields.getfields()){
            query += ', ' + fields.getfieldpath();
            
        }
        query += ',CreatedBy.Name,Contact.Name FROM LiveChatTranscript WHERE ContactId = :contactId ORDER By CreatedDate DESC ';
        lstChatTranscript = Database.query(query);
        if(lstChatTranscript.size() > 0) {
            for(LiveChatTranscript lt : lstChatTranscript)
            {
               WFG_ChatTranscript obj = new WFG_ChatTranscript(lt);
                lstTranscript.add(obj);
               
            }
        }
        
        return lstTranscript;
    } 
     /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Formats Date to MM/DD/YYY
    * @author Deloitte Consulting LLP
    * @date 05-20-2016
    * @param No Parameter
    * @return Void
    * @description: Formats Date to MM/DD/YYY
    */   
    
    @AuraEnabled 
    public static string getConvertedDate(Date originalDate){ 
        String convertedDate;
        if(originalDate!=null) {
            convertedDate = originalDate.month()+'/'+originalDate.day()+'/'+originalDate.year();
        }
        return convertedDate;
    }
    
        
}