/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Ninad
* @date 12-22-2016
* @description  without SHaring class for avoiding User mode data accessibility restrictions.

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Ninad Patil          M-001             12-22-2016              trigger handler
Ninad Patil          M-002             01-19-2017              Modified to include changes for W-000402/W-000403
Ninad Patil          M-003             04-07-2017              Modified to include changes for W-002049
Saravanan            M-004             02-02-2018              Updated ShareCaseRecords methods to add caseTeamMember 
Saravanan            M-005             04-18-2018              Logic to update contact last activitydate. 
*/
public without sharing class WFG_SystemModeHelper 
{
    /**
    @author Ninad Patil
    @date 04-07-2017
    @description : This method is used to create referral record in without sharing mode.
    @return - void
    @param  - List<WFG_Referral__c> list of referral records being updates
    @throws - AddError of trigger exception
    @author Ninad
    */
    public static boolean executedFromCase = false;
    public static List<WFG_Referral__c> createReferralRecord(List<WFG_Referral__c> lstReferral)
    { 
        List<Id> lstRefIds = new List<Id>();   
        insert lstReferral;
        for(WFG_Referral__c objRef : lstReferral)
        {
            lstRefIds.add(objRef.id);
        }
        lstReferral = [Select id, name from WFG_Referral__c WHere Id IN :lstRefIds];
        return lstReferral;
    }
    /**
    @author Ninad Patil
    @date 04-MAR-2017
    @description : This method create map data structure for all users for Agent Code provided.
    @return - void
    @param  - List<WFG_Referral__c> list of referral records being updates
    @throws - AddError of trigger exception
    @author Ninad
    */
    public static map<string,User> getUserRecords(List<string> lstAgentCodes)
    { 
        List<string> lstAgentCodesTrimmed = new List<string>();
        if(lstAgentCodes != null && !lstAgentCodes.isEmpty())
        {
            for(String strAgentCode : lstAgentCodes)
            {
                strAgentCode = strAgentCode.trim();
                lstAgentCodesTrimmed.add(strAgentCode);
            }
        }
        map <string, User> mapAgentCodeUser = new map<string, User>();
        if(lstAgentCodesTrimmed != null && !lstAgentCodesTrimmed.isEmpty())
        {
            for (User objUser: [Select id, name,
                    WFG_Agent_Code__c 
                    from USER 
                    WHERE WFG_Agent_Code__c IN :lstAgentCodesTrimmed
                    AND isActive = true
                    AND profile.Name IN : WFG_FAProfileNames__c.getAll().keyset()])
            {
                mapAgentCodeUser.put(objUser.WFG_Agent_Code__c, objUser);   
            }   
        }
        system.debug('OP : ' + mapAgentCodeUser);
        return mapAgentCodeUser;
    }
    /**
    @author Ninad Patil
    @date 04-MAR-2017
    @description : This mehod being called from before trigger event while referral creation.
    @return - void
    @param  - List<WFG_Referral__c> list of referral records being updates
              Map<Id, WFG_Referral__c>mapNewReferral :New map of referral records,
              Map<Id, WFG_Referral__c>mapOldReferral :Old map of referral records.
    @throws - AddError of trigger exception
    @author Ninad
    */
    public static void populateReferralCountFields(List<WFG_Referral__c> lstReferral)
    {
        map<string, Contact> mapAgentCodeContact = new map<string, Contact>();
        
        for(WFG_Referral__c objRef : lstReferral)
        {
            if(objRef.WFG_Referred_From_Agent_Code__c != null) mapAgentCodeContact.put(objRef.WFG_Referred_From_Agent_Code__c, null);
            if(objRef.WFG_Referred_To_Agent_Code__c != null) mapAgentCodeContact.put(objRef.WFG_Referred_To_Agent_Code__c, null);
        }
        if(mapAgentCodeContact != null && !mapAgentCodeContact.keyset().isEmpty())
        {
            for(Contact objCon : [Select id, name, WFG_AgentCode__c,WFG_AgentPayType__c
                            from Contact Where WFG_Status__c = :system.Label.WFG_ContactStatus AND WFG_AgentCode__c IN :mapAgentCodeContact.keyset() ])
            {
                mapAgentCodeContact.put(objCon.WFG_AgentCode__c, objCon);
            }
            for(WFG_Referral__c objRef : lstReferral)
            {
                objRef.WFG_Referral_Count__c = Integer.valueOf(system.Label.WFG_ReferralCount);
                if(mapAgentCodeContact.containsKey(objRef.WFG_Referred_From_Agent_Code__c)
                    && mapAgentCodeContact.get(objRef.WFG_Referred_From_Agent_Code__c) != null)
                {
                    objRef.WFG_Referred_From_Agent_PayType__c =  mapAgentCodeContact.get(objRef.WFG_Referred_From_Agent_Code__c).WFG_AgentPayType__c;
                }
                if(objRef.WFG_Status__c == system.Label.WFG_ReferralStatus_AdviceCenter)
                {
                    objRef.WFG_Referred_to_Agent_PayType__c =  system.Label.WFG_ReferralStatus_AdviceCenter;
                }
                else if(mapAgentCodeContact.containsKey(objRef.WFG_Referred_to_Agent_Code__c)
                    && mapAgentCodeContact.get(objRef.WFG_Referred_to_Agent_Code__c) != null)
                {
                    objRef.WFG_Referred_to_Agent_PayType__c =  mapAgentCodeContact.get(objRef.WFG_Referred_to_Agent_Code__c).WFG_AgentPayType__c;
                }
            }
        }
    }
    
    /**
    @author Ninad Patil
    @date 04-07-2017
    @description : This method is used to create referral record in without sharing mode.
    @return - void
    @param  - List<WFG_Referral__c> list of referral records being updates
    @throws - AddError of trigger exception
    @author Ninad
    */
    public static void upsertCase(List<Caseshare> lstCase)
    { 
        List<Database.saveResult> lstSaveRes = Database.insert(lstCase, false);
        // Iterate through each returned result
        boolean isError = false;
        for (Database.SaveResult objSvRES : lstSaveRes) 
        {
            if (!objSvRES.isSuccess()) 
            {
                isError = true;
                // Operation failed, so get all errors                
                for(Database.Error err : objSvRES.getErrors()) 
                {                   
                    System.debug(err.getMessage());
                    String strErr = err.getStatusCode() + ': ' + err.getMessage();
                    LogUtility.createLogs('DML', 'ERROR', 'WFG_SystemModeHelper', 'DML', 'APEX',strErr, strErr, null, null, null, false);                                  
                }
            }
        }
    }
    
    /**
    *
    *@author Evry India Pvt Ltd
    *Date - 4/19/2017 
    *Description - W-003018: Fix: Share Cases to the users who created it, so that even if the cases are routed to Queues they are accessible.
    */
    public static void ShareCaseRecords(Case[] lstCase, map<id, case>mapNewCase, map<id, Case> mapOldCase )
    {
        /*
        List<CaseShare> csShareRecords = new List<CaseShare>();
        Map<String,User> userAgentCodeMap = new Map<String, User>();
        Map<Id,Contact> contactAgentCodeMap = new Map<Id,Contact>();
        Set<Id> userIds = new Set<Id>();
        Set<Id>ContactIds = new Set<Id>();
        Map<Id,String> userType = new Map<Id,String>();
        Set<String> agentCodes = new Set<String>();
        for(Case c : lstCase)
        {
            system.debug('***--' + c.ContactId + '--' + c.WFG_InteractingAbout__c);
            userIds.add(c.CreatedById);
            ContactIds.add(c.ContactId);
            if(c.ContactId <> c.WFG_InteractingAbout__c)
            ContactIds.add(c.WFG_InteractingAbout__c);           
            
        } 
        List<Contact> caseContacts = [select id, WFG_AgentCode__c,AccountId from contact where Id IN: ContactIds];
        
        if(caseContacts.size() > 0)
        {
            
            for(Contact cont : caseContacts)
            {
                agentCodes.add(cont.WFG_AgentCode__c);
                contactAgentCodeMap.put(cont.id,cont);
            }
        }
        system.debug('Agent codes--' + agentCodes + '--' + userIds);
        List<User> usrList = [select id, usertype,WFG_Agent_Code__c from user where (WFG_Agent_Code__c IN: agentCodes OR Id IN: userIds) AND isActive = true];
         system.debug('userList---' + usrList );
        if(usrList.size() > 0)
        {
            for(User u : usrList)
            {
               
                system.debug('userAgentCode--' + u.WFG_Agent_Code__c + '--userId--' + u.id);
                if(!userAgentCodeMap.containskey(u.WFG_Agent_Code__c))                             
                userAgentCodeMap.put(u.WFG_Agent_Code__c,u);
                if(!userType.containskey(u.id))
                userType.put(u.id,u.WFG_Agent_Code__c);                
                
                
            }
            
        }
        List<CaseShare> csList = [select caseId,UserOrGroupId from CaseShare where caseId IN: mapNewCase.keyset()];
        Map<Id,List<Id>> csMap = new Map<Id,List<Id>>();
        for(CaseShare csShare : csList) 
        {
            if(csMap.containsKey(csShare.caseId)) {
                List<Id> csIds = csMap.get(csShare.caseId);
                csIds.add(csShare.UserOrGroupId);
                csMap.put(csShare.caseId, csIds);
            } else {
                csMap.put(csShare.caseId, new List<Id> { csShare.UserOrGroupId});
            }
        }
        
        for(Case cs : lstCase)
        {  
            try{
                
                if(mapNewCase.get(cs.id).ownerId <> mapOldCase.get(cs.id).ownerId || mapNewCase.get(cs.id).ContactId <> mapOldCase.get(cs.id).ContactId || mapNewCase.get(cs.id).WFG_InteractingAbout__c <> mapOldCase.get(cs.id).WFG_InteractingAbout__c )
                {
                    Set<Id> UserOrGroupIds = new Set<Id>();
                       
                    UserOrGroupIds.add(cs.CreatedById);                        
                    
                    if(userAgentCodeMap != null && userAgentCodeMap.get(contactAgentCodeMap.get(cs.ContactId).WFG_AgentCode__c) != null && userAgentCodeMap.get(contactAgentCodeMap.get(cs.ContactId).WFG_AgentCode__c).userType == 'Standard')                    
                    {
                    UserOrGroupIds.add(userAgentCodeMap.get(contactAgentCodeMap.get(cs.ContactId).WFG_AgentCode__c).Id);
                    }    
                    if(cs.WFG_InteractingAbout__c != null && (cs.ContactId <> cs.WFG_InteractingAbout__c) )
                    {
                        
                        if(userAgentCodeMap != null && (userAgentCodeMap.get(contactAgentCodeMap.get(cs.WFG_InteractingAbout__c).WFG_AgentCode__c).userType == 'Standard' || contactAgentCodeMap.get(cs.ContactId).AccountId == contactAgentCodeMap.get(cs.WFG_InteractingAbout__c).AccountId ))
                        {
                        UserOrGroupIds.add(userAgentCodeMap.get(contactAgentCodeMap.get(cs.WFG_InteractingAbout__c).WFG_AgentCode__c).Id);
                        }
                    }
                    if(UserOrGroupIds.size() > 0)
                    {
                    for(Id UGId : UserOrGroupIds)
                    {
                        CaseShare shareRec = new CaseShare();
                        shareRec.CaseId = cs.Id;                        
                        shareRec.CaseAccessLevel = 'Edit';
                        shareRec.RowCause = 'Manual';
                        shareRec.UserOrGroupId = UGID;
                        csShareRecords.add(shareRec); 
                    }
                    }
               
            }    
        } 
             catch(Exception dex){
             system.debug('Exception----' + dex);
             //LogUtility.createLog('DML','Standard Contact Sharing','WFG_CaseHandler', 'Error', dex.getDmlMessage(0), 'Error');
            //return;
             }
            } 
        
        /* if(csShareRecords.size() > 0){
            system.debug('ShareRecords');
            for(Integer i = csShareRecords.size() - 1; i >= 0; i--)
            {
            
                for(Id mapShare : csMap.get(csShareRecords[i].caseId))
                {
                    
                    if(mapShare == csShareRecords[i].UserOrGroupId)
                    {
                        csShareRecords.remove(i);
                    }
                }
            } 
            if(csShareRecords.size() > 0)
            {
                system.debug('final list--' + csShareRecords);
                upsertCase(csShareRecords);
            }
        }*//*
          
        List<CaseShare> lstCaseShareFinal = new List<caseShare>();
        For(CaseSHare objCaseSHare : csShareRecords)
        {
            If(csMap.containsKey(objCaseShare.caseId) && csMap.get(objCaseShare.caseId) != null)
            {
                Boolean isAlreadySHared = false;
                For(Id idShareId : csMap.get(objCaseShare.caseId)  )
                {
                    If(objCaseSHare.UserOrGroupId == idShareId)
                    {
                          isAlreadyShared = true;
                          break;
                    }
                }
                if(isAlreadySHared == false) lstCaseShareFinal.add(objCaseSHare);
            }
        }
        If(lstCaseShareFinal != null && ! lstCaseShareFinal.isEMpty()) 
        upsertCase(lstCaseShareFinal);
        
        */
        set<Id> setContactIds = new set<Id>();
        for(case newCase : lstCase){
            Case oldCase;
            if(trigger.isInsert){
                setContactIds.add(newCase.ContactId);
                setContactIds.add(newCase.WFG_InteractingAbout__c);
            } 
            else if(trigger.isUpdate) {
                oldCase = mapOldCase.get(newCase.Id);
                if(oldCase.OwnerId != newCase.OwnerId || oldCase.WFG_InteractingAbout__c != newCase.WFG_InteractingAbout__c || oldCase.WFG_InteractingAbout__c != newCase.ContactId){
                    setContactIds.add(newCase.ContactId);
                    setContactIds.add(newCase.WFG_InteractingAbout__c);
                    setContactIds.add(oldCase.ContactId);
                    setContactIds.add(oldCase.WFG_InteractingAbout__c);
                }
            }
        }

        map<string, contact> mapAgentContact = new map<string, contact>();
        if(setContactIds.size() > 0){
            for(Contact con : [select id, WFG_AgentCode__c,AccountId from contact where Id IN: setContactIds])
                mapAgentContact.put(con.WFG_AgentCode__c, con);
        }
        system.debug('===mapAgentContact===' + mapAgentContact);
        Map<Id, Id> mapUserIdContactId = new Map<Id, Id>();
        if(mapAgentContact.size () > 0){
            for(user usr : [select id, WFG_Agent_Code__c from User where WFG_Agent_Code__c IN: mapAgentContact.keyset() AND isActive = true]){
                mapUserIdContactId.put(mapAgentContact.get(usr.WFG_Agent_Code__c).Id, usr.Id);
            }
        }
        system.debug('==mapUserIdContactId=== ' + mapUserIdContactId);
        set<String> setCaseIdUserId = new set<String>();
        Map<string, set<String>> mapCaseIdUserId = new Map<String , set<String>>();
        set<id> setAccountId = new set<id>();
        for(Case newCase : lstCase){
            Case oldCase;
            if(trigger.isInsert){
                mapCaseIdUserId.put(newCase.Id, new set<string>());
                mapCaseIdUserId.get(newCase.Id).add(mapUserIdContactId.get(newCase.ContactId));
                mapCaseIdUserId.get(newCase.Id).add(mapUserIdContactId.get(newCase.WFG_InteractingAbout__c));
                setAccountId.add(newCase.AccountId);
            } else if(trigger.isUpdate) {
                oldCase = mapOldCase.get(newCase.Id);
                
                if(newCase.ownerId != oldCase.ownerId || oldCase.ContactId != newCase.ContactId || oldCase.WFG_InteractingAbout__c != newCase.WFG_InteractingAbout__c){
                    mapCaseIdUserId.put(newCase.Id, new set<string>());
                    mapCaseIdUserId.get(newCase.Id).add(mapUserIdContactId.get(newCase.ContactId));
                    mapCaseIdUserId.get(newCase.Id).add(mapUserIdContactId.get(newCase.WFG_InteractingAbout__c));
                    setAccountId.add(newCase.AccountId);
                    if(oldCase.ContactId != newCase.ContactId && oldcase.ContactId != newCase.WFG_InteractingAbout__c){
                        setCaseIdUserId.add(newCase.Id+';'+mapUserIdContactId.get(oldCase.ContactId));
                    }
                    
                    if(oldCase.WFG_InteractingAbout__c != newCase.WFG_InteractingAbout__c && oldcase.WFG_InteractingAbout__c != newCase.ContactId){
                        setCaseIdUserId.add(newCase.Id+';'+mapUserIdContactId.get(oldCase.WFG_InteractingAbout__c));
                    }
                }
            }
        }
        system.debug('++++++ MapcaseIdUserId ++ ' + mapCaseIdUserId);
        system.debug('++++++ setCaseIdUserId ++ ' + setCaseIdUserId);

        if(mapCaseIdUserId.size() > 0){
          // uncommented to verify test class - sankarshana  
            executedFromCase = true; 
            list<CaseTeamMember> lstCaseTeamMember = createCaseTeamMembers(mapCaseIdUserId, setCaseIdUserId);
           if(lstCaseTeamMember.size() > 0){
                database.insert(lstCaseTeamMember, false);
            }
        }
        
        if(setAccountId.size() > 0){
           // WFG_SystemModeHelper.deleteAccountSharing(setAccountId, mapUserIdContactId.values());
        }
    }
    
    /**
    *
    *@author Evry India Pvt Ltd
    *Date - 4/18/2018 
    *Description - W-026278: Update the Last Activity Date in the contact record when the related case's Last Activty Date is updated.
    */
    public static void updateContactLastActivityDate(Case[] lstCase, map<id, Case> mapOldCase)
    {
        list<Contact> lstContact = new list<Contact>();
        for(Case newCase : lstCase){
            case oldCase = mapOldCase.get(newCase.Id);
            
            if(newCase.WFG_LastActivityDate__c != oldCase.WFG_LastActivityDate__c){
                Contact con = new Contact();
                con.Id = newCase.ContactId;
                con.WFG_LastContactedDate__c = newCase.WFG_LastActivityDate__c;
                lstContact.add(con);
            }
        }
        
        if(lstContact.size() > 0){
            try{
                update lstContact;
            }  catch(Exception e) {
                system.debug('+++ Execption ++' + e);
                LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_SystemModeHelper', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
            }
        }
    }
    
    @future
    public static void deleteAccountSharing(set<Id> setAccountId, list<Id> lstUserId){
        list<AccountShare> lstAccountShare = new list<AccountShare>();
        if(setAccountId.size() > 0)
            lstAccountShare = [select id from AccountShare where AccountId IN: setAccountId AND UserOrGroupId IN: lstUserId];
        else
            lstAccountShare = [select id from AccountShare where UserOrGroupId IN: lstUserId];
        
        Database.delete(lstAccountShare,false);
    }
    
    /**
    @author : Saravanan
    @date : 7-Mar-2018
    @description : This method is used in caseTriggerHelper, OwnershipUpdateBatch and JIT helper.
    @Return List<caseTeamMember> - List of caseTeamMembers to be inserted.
    */
    public static list<caseTeamMember> createCaseTeamMembers(map<string, set<string>> mapCaseIdUserId, set<String> setCaseIdUserId){
        
        list<caseTeamMember> lstCaseTeamMember = new list<caseTeamMember>();
        list<caseTeamMember> lstDeleteCaseTeamMember = new list<caseTeamMember>();
        set<String> setExistingTeamMember = new set<String>();
        
        list<CaseTeamMember> lstExistingCaseTeamMember = [select id, parentId, memberId from caseTeamMember Where parentId IN: mapCaseIdUserId.keyset()];
        system.debug('-++ executedFromCase' + executedFromCase);
        if(executedFromCase){
            for(caseTeamMember ctm : lstExistingCaseTeamMember){
                string iKey = string.valueOf(ctm.ParentId) +';'+string.valueOf(ctm.memberId);
                setExistingTeamMember.add(iKey);
                if(setCaseIdUserId.contains(iKey))
                    lstDeleteCaseTeamMember.add(ctm);
            }
        } else {
            system.debug('--++ In delete ++' + lstExistingCaseTeamMember.size());
            delete lstExistingCaseTeamMember;
        }

        system.debug('===lstDeleteCaseTeamMember==='+lstDeleteCaseTeamMember);
        CaseTeamRole ctr = [select id from CaseTeamRole where Name =: SYSTEM.LABEL.WFG_CaseTeamRoleName];
        
        for(string caseId : mapCaseIdUserId.keyset()){
            for(string userId : mapCaseIdUserId.get(caseId)){
                if(!setExistingTeamMember.contains(caseId+';'+userId)){
                    caseTeamMember ctm = new caseTeamMember();
                    ctm.memberId = UserId;
                    ctm.parentId = CaseId;
                    ctm.TeamRoleId = ctr.Id;
                    lstCaseTeamMember.add(ctm);
                }
            }
        }
        
        try{
            delete lstDeleteCaseTeamMember;
        } catch(exception e) {
            LogUtility.createLog('EXCEPTION','WFG_SystemModeHelper.DeleteCaseTeam',e.getMessage(), 'Error', e.getStackTraceString(), 'Error');               
        }
        system.debug('===lstCaseTeamMember==='+lstCaseTeamMember);
        return lstCaseTeamMember;
    }
}