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
Bharat Madaan          M-001             12-08-2016              US-185: List of available FA for referral  
Ninad Patil            M-002             31-JAN-2017             US-480: INtegration Mock related details
Ninad Patil            M-003             09-FEB-2017            US-661: Addition of check for active referral
Nitesh Kumar           M-004             23-FEB-2017            Added a method to get the contact id of current customer
Ninad Patil            M-005             20-June-2017            Added a method Notify Admin when no User is found.
*/
public without sharing class  WFG_ReferralSelection_Controller 
{
     /**
     * This method will remove FA's who have already rejected a referral for the CP
     * @return - WFG_CustomerProfile_Wrapper
     * @see    - N/A
     * @param  - string strCustProfileId
     * @throws - N/A
     */
     @TestVisible private static WFG_ReferralResponseWrapper RemoveAgentsWhomHaveRejectedCPRef(string strCustProfileId,
        WFG_ReferralResponseWrapper objListBeforeFiltered)
     {
        /*
            Select WFG_Referred_To_Agent_Code__c
                from WFG_Referral__c 
                where WFG_Status__c = 'Accepted' 
                and WFG_Customer_Profile__c = 'a360v0000004IJzAAM'
        */

        system.debug('#### RemoveAgentsWhomHaveRejectedCPRef CUST ID ::'+ strCustProfileId);
        
        // use a map, indexed by the FA Agent code , containing all the FA objects 
        map<string, WFG_AD03_AgentsResponseWrapper> mapOPWrapp = new map<string, WFG_AD03_AgentsResponseWrapper>();
        if(strCustProfileId != null && objListBeforeFiltered != null)  // don't do extra work if we dont have too
        {     
            // in APEX Sets prevent dups and allow the contains method vs Lists
             Set<String> setRejectedAgentToCodes = new Set<String>();
          
             for(WFG_Referral__c objRef : [Select WFG_Referred_To_Agent_Code__c FROM WFG_Referral__c 
                  where WFG_Status__c =: System.Label.WFG_ReferralStatus_Rejected
                  and WFG_Customer_Profile__c = :strCustProfileId ])
                {
                   setRejectedAgentToCodes.add(objRef.WFG_Referred_To_Agent_Code__c);
                }
             system.debug('#### IN Rejected Agent List : ' + strCustProfileId + ':' + setRejectedAgentToCodes);
         
              if(setRejectedAgentToCodes != null && !setRejectedAgentToCodes.isEmpty())
             {
                
                system.debug('#### get rid of dups with sets');
                    
                  /* Getting all the Agent Codes in the map as received from integration
                  And putting them as Agent code vs Complete AD03 JSON wrapper*/
                  for(WFG_AD03_AgentsResponseWrapper objAD03Wrapp : objListBeforeFiltered.objRefSelectfWrap.lstResWrapp)
                  {
                        mapOPWrapp.put(objAD03Wrapp.FA_AgentCode.trim(), objAD03Wrapp);
                  }
                  
                    if(objListBeforeFiltered.objRefSelectfWrap != null && objListBeforeFiltered.objRefSelectfWrap.lstResWrapp != null
                              && objListBeforeFiltered.objRefSelectfWrap.lstResWrapp.size()>0)
                        {
                            system.debug('lstResWrapp: ' + objListBeforeFiltered.objRefSelectfWrap.lstResWrapp);
                              for(string strRejectedAgentCode : setRejectedAgentToCodes)
                              {
                                    if(mapOPWrapp != null && !mapOPWrapp.keyset().isEmpty()
                                          && mapOPWrapp.containskey(strRejectedAgentCode.trim()))
                                    {
                                         system.debug('found and removed Agent who rejected: ' + strRejectedAgentCode); 
                                          mapOPWrapp.remove(strRejectedAgentCode);
                                    }
                              }
                        }
                    objListBeforeFiltered.objRefSelectfWrap.lstResWrapp = mapOPWrapp.values();
                
             }

        }                   
        return  objListBeforeFiltered;
     }
     
     /**
     * This method will create and return an instance of WFG_CustomerProfile_Wrapper
     * @return - WFG_CustomerProfile_Wrapper
     * @see    - N/A
     * @param  - N/A
     * @throws - N/A
     */
    @AuraEnabled
    public static WFG_ReferralResponseWrapper getReferralSelectionWrap(string strCustProfileId)
    {
            system.debug('testting');
            WFG_ReferralResponseWrapper objRESToComp = new WFG_ReferralResponseWrapper();
            system.debug('restcomp-->'+objRESToComp);
            objRESToComp = WFG_ReferralUtility.checkCustomerProfiles(strCustProfileId);
            system.debug('restcomp-->'+objRESToComp);
            if(objRESToComp.objGenericRes.boolIsError == false)
            {
                if(WFG_IntegrationStubSwitch__c.getAll().get('AD03').WFG_Stub_ON__c == true)
                {
                    objRESToComp.objRefSelectfWrap = new WFG_ReferralSelection_Wrapper();
                    objRESToComp.objRefSelectfWrap.boolIsStubOn = true;
                }
                else
                {
                    objRESToComp.objRefSelectfWrap = new WFG_ReferralSelection_Wrapper();
                    objRESToComp.objRefSelectfWrap.boolIsStubOn = false;
                    //As STub is off call actual integration
                    
                    WFG_AD03_AgentRequestWrapper objReq = new WFG_AD03_AgentRequestWrapper();
                    //Querying contacts mailing country
                     List<WFg_Customer_Profile__C> lstProfile = [Select id, name, WFG_Contact__c,
                        WFG_Contact__r.Name,WFG_Contact__r.WFG_AgentPayType__c,
                            WFG_Contact__r.mailingCountry,WFG_Contact__r.MailingState
                           FROM WFg_Customer_Profile__C WHERE ID = :strCustProfileId ];
                    system.debug('#### IN Contact Query : ' +strCustProfileId + ':' + lstProfile);
                    if(lstProfile != null && !lstProfile .isEmpty())
                    {
                        system.debug('#### IN Contact Query');
                        objReq.state = lstProfile[0].WFG_Contact__r.mailingState;
                    }
                           
                    //Create request Wrapper
                    List<User> lstUseAgents = [Select id, name, WFG_Agent_Code__c
                        FROM User Where ID =: UserInfo.getUserId()];
                    if(lstUseAgents != null && !lstUseAgents.isEmpty())
                    {
                        string strAgentId = lstUseAgents[0].WFG_Agent_Code__c;
                        List<Contact> lstAgentCons = [Select id, Name, 
                            WFG_AgentCode__c,WFG_AgentID__c,WFG_AgentPayType__c,
                            mailingCountry
                            from Contact WHERE WFG_AgentCode__c = :strAgentId];
                        if(lstAgentCons != null && !lstAgentCons.isEMpty())
                        {
                            objReq.agentType = lstAgentCons[0].WFG_AgentPayType__c;
                            objReq.agentCodeNumber = lstAgentCons[0].WFG_AgentCode__c;                        
                        }
                        objReq.agentCodeNumber = strAgentId;
                    }
                    objRESToComp = WFG_AD03_IntegrationHelper.invokeCallout(objReq);
                }
               if(WFG_IntegrationStubSwitch__c.getAll().get('AD03').WFG_Stub_ON__c == false)
               {
                    system.debug('#### stub is OFF, normal callout to Compass web service; proceed to remove agents who rejected');
                    objRESToComp = RemoveAgentsWhomHaveRejectedCPRef(strCustProfileId, objRESToComp);
                    //objRESToComp = RemoveAgentsWhomHaveRejectedCPRef_Nin(strCustProfileId, objRESToComp);
               }
            }
            return objRESToComp;
     }
     
    
        
    /**
    @author Ninad Patil
    @date 22-Dec-2016
    @description Executed on Trigger Context - After Insert. 
    @return - WFG_ReferralResponseWrapper
    @param  - strCustProfile :customer profile Id
    @param  - boolFaPresent : to indicate whether profile needs to be created or not
    @param  - strReferredTo : referral TO ID
    @throws - N/A
    @author Ninad
    */
    @AUraEnabled
    public static WFG_ReferralResponseWrapper checkQualifiedMoney(string strCustProfile)
    {
     
            WFG_ReferralResponseWrapper objWrapp = new WFG_ReferralResponseWrapper(); 
            if(strCustProfile != null){
                List<WFG_Customer_Profile__c> lstCustProfile = [SELECT Id, name, WFG_OwnQualifiedAssets__c
                                                                FROM WFG_Customer_Profile__c WHERE Id=: strCustProfile];
            }
            return objWrapp;
     }
    /**
    @author Ninad Patil
    @date 22-Dec-2016
    @description Executed on Trigger Context - After Insert. 
    @return - WFG_ReferralResponseWrapper
    @param  - strCustProfile :customer profile Id
    @param  - boolFaPresent : to indicate whether profile needs to be created or not
    @param  - strReferredTo : referral TO ID
    @throws - N/A
    @author Ninad
    */
    @AUraEnabled
    public static WFG_ReferralResponseWrapper createReferral(string strCustProfile, Boolean boolFaPresent, string strReferredTo){
            system.debug('####  CUST ID ::'+ strCustProfile);
            system.debug('####  REferal ID ::'+ strReferredTo);
            WFG_ReferralResponseWrapper objRes = WFG_ReferralUtility.initiateReferral(strCustProfile, boolFaPresent, strReferredTo);
            system.debug('## NINAD ::: '+objRes);
            return objRes;
   }
    /**
    @author Ninad Patil
    @date 22-Dec-2016
    @description Executed on Trigger Context - After Insert. 
    @return - WFG_ReferralResponseWrapper
    @param  - strReferralRecordId : referral ID
    @param  - actionName : Action performed on Referral record
    @throws - N/A
    @author Ninad
    */
    @AUraEnabled
    public static WFG_ReferralResponseWrapper actionReferral(string strReferralRecordId, String actionName){
   
            WFG_ReferralResponseWrapper objRes = WFG_ReferralUtility.updateReferral(strReferralRecordId, actionName);
            return objRes;
    }  
    /**
    @author Ninad Patil
    @date 22-Dec-2016
    @description Executed on Trigger Context - After Insert. 
    @return - WFG_ReferralSelection_Wrapper
    @param  - strReferralId : referral ID
    @throws - N/A
    @author Ninad
    */    
    @AUraEnabled
    public static WFG_ReferralResponseWrapper getPossibleActions(string strReferralId){
            WFG_ReferralResponseWrapper objResWrap = new WFG_ReferralResponseWrapper();
            if(strReferralId != NULL && strReferralId != '')
            {
                List<WFG_Referral__c> lstRef = [SELECT Id, Name, WFG_Referred_To__c, 
                     WFG_Referred_By__c, WFG_Status__c,WFG_Customer_Profile__c
                     FROM WFG_Referral__c WHERE Id=: strReferralId LIMIT 1];
                if(lstRef != null && !lstRef.isEmpty())
                {
                    if(lstRef[0].WFG_Status__c == system.Label.WFG_ReferralStatus_Referred)
                    {
                        if(lstRef[0].WFG_Referred_To__c != NULL && lstRef[0].WFG_Referred_To__c == UserInfo.getUserId())
                        {
                            objResWrap.boolShowAcceptReject = TRUE;
                        }
                        if(lstRef[0].WFG_Referred_By__c != NULL && lstRef[0].WFG_Referred_By__c == UserInfo.getUserId())
                        {
                            objResWrap.boolShowCancel = TRUE;
                        }
                    }
                    if(lstRef[0].WFG_Status__c == System.Label.WFG_ReferralStatus_Accepted)
                    {
                        if(lstRef[0].WFG_Referred_To__c != NULL && lstRef[0].WFG_Referred_To__c == UserInfo.getUserId())
                        {
                            objResWrap.boolShowComplete = TRUE;
                        }
                        if(lstRef[0].WFG_Referred_By__c != NULL && lstRef[0].WFG_Referred_By__c == UserInfo.getUserId())
                        {
                            objResWrap.objGenericRes.boolIsError = TRUE;
                            objResWrap.objGenericRes.strErrorMessage = System.Label.WFG_ReadOnly_Referral;
                        }
                    }
                    if(lstRef[0].WFG_Status__c == System.Label.WFG_ReferralStatus_Cancelled 
                        || lstRef[0].WFG_Status__c == System.Label.WFG_ReferralStatus_Rejected
                        || lstRef[0].WFG_Status__c == System.Label.WFG_ReferralStatus_CompleteSold
                        || lstRef[0].WFG_Status__c == System.Label.WFG_ReferralStatus_CompleteNotSold
                        || lstRef[0].WFG_Status__c == System.Label.WFG_ReferralStatus_AdviceCenter)
                    {
                        if((lstRef[0].WFG_Referred_By__c != NULL 
                            && lstRef[0].WFG_Referred_By__c == UserInfo.getUserId())
                            || (lstRef[0].WFG_Referred_To__c != NULL 
                                && lstRef[0].WFG_Referred_To__c == UserInfo.getUserId())
                        )
                        {
                             objResWrap.objGenericRes.boolIsError = TRUE;
                             objResWrap.objGenericRes.strErrorMessage = System.Label.WFG_ReadOnly_Referral;
                        }
                    }
                    objResWrap.objRefferal = lstRef[0];
                }
            }
            return objResWrap;
    }
    /**
    @author Ninad Patil
    @date 22-Dec-2016
    @description Fetch User from Agent Code
    @return - WFG_ReferralResponseWrapper
    @param  - strAgentCode - Agent Code
    @throws - N/A
    @author Ninad
    */    
    @AuraEnabled
    public static WFG_ReferralResponseWrapper getFiduciaryUser(string strAgentCode, string strCustomerProfileId)
    {
        try
        {
            strAgentCode = strAgentCode.trim();
            WFG_ReferralResponseWrapper objResWrap = new WFG_ReferralResponseWrapper();
            if(strAgentCode != NULL && strAgentCode != '')
            {
                List<String> lstAgentCode = new List<String>();
                lstAgentCode.add(strAgentCode);
                map<string, User> mapFAUser = WFG_SystemModeHelper.getUserRecords(lstAgentCode);
                system.debug('BEFORE CALL : ' + strCustomerProfileId);
                if(mapFAUser.containskey(strAgentCode) 
                    && mapFAUser.get(strAgentCode) != null)
                {
                    objResWrap.objUser = mapFAUser.get(strAgentCode); 
                }
                else
                {
                    objResWrap.objGenericRes.boolIsError = true;
                    objResWrap.objGenericRes.strErrorMessage = Label.WFG_No_User_found_in_the_salesforce_system;
                    //Notify User about compass and SF user Discrepancy.
                    notifySupportForUserDiscrepancy(strAgentCode,strCustomerProfileId);                 
                }
            }
            return objResWrap;
        }
        catch(Exception e)
        {
            WFG_ReferralResponseWrapper objResWrap = new WFG_ReferralResponseWrapper();
            objResWrap.objGenericRes.boolIsError = true;
            objResWrap.objGenericRes.strErrorMessage = e.getMessage();
            return objResWrap;
        }
    }
    /**
    @author Ninad Patil
    @date 19-JUNE-2017  
    @description NotifyUser
    @return - String
    @param  - NA
    @throws - N/A
    */ 
    @AuraEnabled
    public static void notifySupportForUserDiscrepancy(String strAgentCode, string strCustomerProfileId)
    {
        strAgentCode = strAgentCode.trim();
        map<id, User> mapUserIds = new map<id, User>();
        map<string, User> mapUserVsAgentCode = new map<string, User>();
        map<String, Contact> mapContactVSAgentCode = new map<string, Contact>();
        //Query User's Context
        mapUserVsAgentCode.put(strAgentCode, null);
        List<User> lstLogegdInUser = [Select id, name, WFG_Agent_code__c,isActive
            FROM User WHERE ID = :UserInfo.getUserId() OR WFG_Agent_Code__C = :strAgentCode];
        for(User objUser: lstLogegdInUser)
        {
            mapUserIds.put(objUser.id, objUser);
            mapUserVsAgentCode.put(objUser.WFG_Agent_Code__C, objUser);
        }
        
        List<WFG_customer_Profile__C> lstCustProf = [Select id, name from WFG_Customer_Profile__C
            WHERE Id = :strCustomerProfileId];
            
        for(Contact objCon: [Select id, name,WFG_AgentCode__c, WFG_AgentPayType__c,WFG_Fiduciary_Advisor__c from Contact
            Where WFG_AgentCode__c = :mapUserVsAgentCode.keyset()]) 
        {
            mapContactVSAgentCode.put(objCon.WFG_AgentCode__c, objCon);
        }
        system.debug('## MAP FOr Cnotact' +mapContactVSAgentCode);
        List<Messaging.SingleEmailMessage> lstmail = new List<Messaging.SingleEmailMessage>();
        
        Integer used = Limits.getEmailInvocations();
        Integer emailLimit = Limits.getLimitEmailInvocations();
        if(!(used >= emailLimit))
        {
             Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage(); 
             String subject ='Fudiciary is not set up properly @ : ' + system.now() ;

             objEmail.setSubject(subject);
             objEmail.setTargetObjectId(system.Label.WFG_SupportEmailAddress);
             
             objEmail.setSaveAsActivity(false);
             String strBody= '<br/><br/> <B>Please see below details for Missing FA : </B><br/><br/>'; 
             strBody += 'Missing Fiduciary Advisor Agent Code :  ' + strAgentCode + '<br/>';
             if(mapContactVSAgentCode != null && !mapContactVSAgentCode.keyset().isEmpty() && mapContactVSAgentCode.containskey(strAgentCode))
             {
                strBody += 'Missing Fiduciary Advisor Agent Type :  ' + mapContactVSAgentCode.get(strAgentCode).WFG_AgentPayType__c + '<br/>';
                strBody += 'Missing Fiduciary Advisor FA flag: ' + mapContactVSAgentCode.get(strAgentCode).WFG_Fiduciary_Advisor__c + '<br/>';
                if(mapUserVsAgentCode != null && !mapUserVsAgentCode.keyset().isEmpty() && mapUserVsAgentCode.containskey(strAgentCode)
                    && mapUserVsAgentCode.get(strAgentCode) != null)
                {
                    strBody += 'Missing Fiduciary Advisor is Active :  ' + mapUserVsAgentCode.get(strAgentCode).isActive + '<br/>';
                }
                else
                {
                    strBody += 'Missing Fiduciary Advisor is Active: User Does not exist </br>';
                }
             }
             else
             {
                strBody += 'Missing Fiduciary Advisor is Active: User Does not exist <br/>';
             }
             
             strBody += 'Agent Code of Logged In User :   ' + mapUserIds.get(UserInfo.getUserId()).WFG_Agent_code__c + '<br/>';
             strBody += 'Contact Link of Logged In User : ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + mapContactVSAgentCode.get(mapUserIds.get(UserInfo.getUserId()).WFG_Agent_code__c).id + '<br/>';
             strBody += 'User Link of Logged in User :  ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' +UserInfo.getUserId() +'<br/>';
             strBody += 'Customer Profile Link : ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' +lstCustProf[0].id + '<br/>';
                                       
             objEmail.setHtmlBody(strBody); 
             objEmail.setPlainTextBody('');
             lstmail.add(objEmail);
        }
        if(lstmail != null && !lstmail.isEmpty()) Messaging.SendEmailResult [] lstEMailRes = Messaging.sendEmail(lstmail);
    }
    
    /**
    @author Nitesh Kumar
    @date 25-Feb-2017
    @description Fetch contactId
    @return - String
    @param  - customerProfileId
    @throws - N/A
    */    
    @AuraEnabled
    public static String getContactId(string customerProfileId){
        return [select WFG_Contact__c from WFG_Customer_Profile__c where Id = :customerProfileId].WFG_Contact__c;
    }
    
    /**
     * Method will check wheter the current user's profile is FA or not
     * @return - String
     * @see    - N/A
     * @param  - N/A
     * @throws - N/A
    */
    @AuraEnabled
    public static Boolean isFAUser(){
        
        Boolean isFAUser = false;
        String strProfileName = [SELECT Id, Name FROM Profile WHERE Id =: userInfo.getProfileId()].Name;

        if(WFG_FAProfileNames__c.getAll().keyset().contains(strProfileName)){
            isFAUser = true; 
        }
        
        return isFAUser;        
    }
    
     /**
     * Method will get CustomerProfile name
     * @return - String
     * @see    - N/A
     * @param  - N/A
     * @throws - N/A
    */
    @AuraEnabled
    public static String getCustomerProfileName(String id){
        return [SELECT Name FROM WFG_Customer_Profile__c where Id = :id].Name;        
    }
    
}