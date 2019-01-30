/**
    *
    Property of Transamerica andAegoncompanies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * @author Samit
    * @date 03-30-2017
    * @description  Restrict User from editing their records
    Modification Log:
    --------------------------------------------------------------------------------------------------------
    Developer             Mod Number         Date                    Description
    --------------------------------------------------------------------------------------------------------
    Samit Bhoumick          M-001             03-30-2017             User Trigger  
    Praveen Lakkundi        M-002             03-15-2018             This method accepts Inactive UserIds from process builder and deletes the associated knowledge permission sets from it
    Praveen Lakkundi        M-003             03-16-2018             This method accepts users id and service center group Id to return Group Member instance.
    Praveen Lakkundi        M-004             03-16-2018             This method accepts set of user ids and add or remove users from Home office public group.
    saravanan Haldurai      M-005             03-28-2018             Added the logic to update WFG_Inactivated_Date. Also added 
                                                                     the logic to transfer the case team member when the UT happens.
    Rashmi Shet             M-006             05-10-2018             Added logic to remove FSC standard permission set and FSC standard
                                                                     license when user becomes inactive.
    Rashmi Shet             M-007             27-7-2018              Added logic to add AgentOne Permission set for the FSC users . 
    Rashmi Shet             M-008             9-8-2018               Called a mehod to update the ownership of individual contact and account and onboarding opportunity when they 
                                                                     become active and if they are associated with onboarding checklist.                                                                  
    */
    public class WFG_userTriggerHandler
    {
        public static boolean createCaseTeamMember = false;
        public static void beforeInsert(List<User> lstUser)
        {
            
        }
        
        public static void beforeUpdate(List<User> lstUser, Map<Id, User> mapNewUser, Map<Id, User> mapOldUser){   
            system.debug('======in before update===');
            validateUser(lstUser, mapNewUser, mapOldUser);
            /* Removing the logic since we are not populating inactivated Date.
            for(user usr : lstUser){
                if(mapOldUser.get(usr.Id).isActive && !usr.isActive)
                    usr.WFG_Inactivated_Date__c = system.today();
            } */
        }
        
        
        public static void afterUpdate(List<User> lstUser, Map<Id, User> mapNewUser, Map<Id, User> mapOldUser, boolean boolIsUpdate){
            /*Map<Id, User> mapUsers = new Map<Id, User>([SELECT Id, Profile.Name FROM User where profile.name like 'Launch%' and isActive = true]);
            
            set<Id> setOfActivatedUserIds = new set<Id>();
            for(User objUser : lstUser){
                user LaunchUser = mapUsers.get(objUser.Id);
                if(objUser.isActive != mapOldUser.get(objUser.Id).isActive && LaunchUser != null)
                    setOfActivatedUserIds.add(objUser.Id);
            }
           // if(!setOfActivatedUserIds.isEmpty())
                //System.enqueueJob(new WFG_Launch_UpdateRecordsOwnership(lstActivatedUsers));
            //    WFG_Launch_UpdateRecordsOwnership.updateLaunchRelatedRecords(setOfActivatedUserIds);*/

            addOrRemoveUsersToHomeOfficePublicGroup(mapNewUser.keyset());
            
            /*Remove the logic to add Case team member when user is active.
            set<Id> setUserIds = new set<Id>();
            
            for(user usr : lstUser){
                if(!mapOldUser.get(usr.Id).isActive && usr.isActive)
                    setUserIds.add(usr.Id); 
            }
            
            system.debug('+++setUserIds++++ ' + setUserIds);
            system.debug('+++createCaseTeamMember++++ ' + createCaseTeamMember);
            
            if(setUserIds.size() > 0 && createCaseTeamMember){
                updateCaseTeamMember(setUserIds);
            }
            */
        }
        
        public static void afterInsert(List<User> lstTriggerNew,Map<Id, User> mapNewUser){
            /*Map<Id, User> mapUsers = new Map<Id, User>([SELECT Id, Profile.Name FROM User where profile.name like 'Launch%' and isActive = true]);
            set<Id> setOfNewUserIds = new set<Id>();
            for(User objUser : lstTriggerNew){
                user LaunchUser = mapUsers.get(objUser.Id);
                if(LaunchUser != null)
                    setOfNewUserIds.add(objUser.Id);
            }
           // if(!setOfNewUserIds.isEmpty())
                //System.enqueueJob(new WFG_Launch_UpdateRecordsOwnership(lstNewUsers));
            //    WFG_Launch_UpdateRecordsOwnership.updateLaunchRelatedRecords(setOfNewUserIds);*/
            
            addOrRemoveUsersToHomeOfficePublicGroup(mapNewUser.keyset());
            /*Remove the logic to add Case team member when user is active.
            set<Id> setUserIds = new set<Id>();
            
            for(user usr : lstTriggerNew){
                if(usr.isActive)
                    setUserIds.add(usr.Id);
            }
            
            system.debug('+++setUserIds++++ ' + setUserIds);
            system.debug('+++createCaseTeamMember++++ ' + createCaseTeamMember);
            
            if(setUserIds.size() > 0 && createCaseTeamMember){
                updateCaseTeamMember(setUserIds);
            }
            */
        } 
        
        private static void validateUser(List<User> lstUser, Map<Id, User> mapNewUser, Map<Id, User> mapOldUser)
        {
            Id idCurrentUserId = UserInfo.getUserId();
            Set<String> setFields = Schema.SObjectType.User.fields.getMap().keySet();
            for(String row: setFields)
            {
                if(!Schema.SObjectType.User.fields.getMap().get(row).getDescribe().isUpdateable())
                {
                    setFields.remove(row);
                }
            }  
            setFields.remove('timezonesidkey');
            setFields.remove('localesidkey'); 
            for(User objUser: lstUser)
            {
                if(WFG_DisableUserEdit__c.getInstance(idCurrentUserId) != NULL && WFG_DisableUserEdit__c.getInstance(idCurrentUserId).WFG_Disable_Edit__c)
                {
                    Boolean boolChanged = FALSE;
                    for(String strFieldName: setFields)
                    {
                        if(objUser.get(strFieldName) != mapOldUser.get(objUser.Id).get(strFieldName))
                        {
                            boolChanged = TRUE;
                        }
                    }
                    if(boolChanged)
                    {
                        objUser.addError(Label.WFG_UserRestrictEditValidationMessage);
                    }
                }
            }
        }   
        
        /**
         * This method accepts users id and service center group Id to return Group Member instance.
         * @author - Praveen L
         * @return - N/A
         * @see    - N/A
         * @param  - List of User Ids
         * @throws - N/A
         */
        public static List<GroupMember> createGMInstanceForHomeOfficePublicGroup(ID idUser,Id idServiceCenter){
            List<GroupMember> lstGroupMembers = new List<GroupMember>();
            GroupMember objGM = new GroupMember();
            objGM.groupId = idServiceCenter;
            objGM.UserOrGroupId = idUser;
            lstGroupMembers.add(objGM) ;
            return lstGroupMembers;
        }
        
        /**
         * This method accepts set of user ids and add or remove users from Home office public group.
         * @author - Praveen L
         * @return - N/A
         * @see    - N/A
         * @param  - List of User Ids
         * @throws - N/A
         */
        public static void addOrRemoveUsersToHomeOfficePublicGroup(set<Id> setUserIds){
            List<GroupMember> lstAddGroupMember = new List<GroupMember>();
            Set<id> setRemoveGroupIds = new set<id>();
            Map<string,string> mapProfileIdToName = new Map<string,string>();
            Id idServiceCenter;
            List<Group> lstServiceCenterGroup = [select id from group where developername =: system.label.Service_Center_Home_Office];
            if(!lstServiceCenterGroup.isEmpty() && lstServiceCenterGroup != null){
                idServiceCenter = lstServiceCenterGroup[0].Id;
            }
            for(profile pf :[select name,id from profile where name like '%Home Office']){
                    mapProfileIdToName.put(pf.id,pf.Name);
            }
            List<User> lstUsers=[Select Id, Name, User.Profile.Name, User.IsActive from user Where Id IN :setUserIds];
            for(User u : lstUsers){
                if(mapProfileIdToName.get(u.profileId) == u.Profile.Name && u.isActive == true){
                    lstAddGroupMember = createGMInstanceForHomeOfficePublicGroup(u.Id,idServiceCenter);
                }
                else
                {
                   setRemoveGroupIds.add(u.id);
                }  
            }
            if(!lstAddGroupMember.isEmpty() && lstAddGroupMember != null)
            insert lstAddGroupMember;
            if(!setRemoveGroupIds.isEmpty() && setRemoveGroupIds != null){
                List<GroupMember> lstGroupMemberDelete = [ Select Id from GroupMember where UserOrGroupID in :setRemoveGroupIds and GroupId =: idServiceCenter];
                if(!lstGroupMemberDelete.isEmpty() && lstGroupMemberDelete!= null)
                    delete lstGroupMemberDelete;
            }
        }
        
        /**
         * This wrapper class contains variables for removePermissionSet method
         * @author - Praveen L
         * @return - N/A
         * @see    - N/A
         * @param  - N/A
         * @throws - N/A
         */
        public class RequestForVariables {
            @InvocableVariable(label='User Id' required=true)
            public String strUserId;
            @InvocableVariable(label='InsertorDelete' required=true)
            public String strInsertorDelete;
        }
        
        
        /**
         * This method accepts list of Wrapper Class variables and add or remove permission sets accordingly.
         * @author - Praveen L
         * @return - N/A
         * @see    - N/A
         * @param  - List of Wrapper Class variables
         * @throws - N/A
         */
        @InvocableMethod(

        label='User Ids and records to be inserted or deleted'
        description='Add UserIds and know whether these records have to be inserted or deleted')
        public static void AddorRemovePermissionSetandLicense(List<RequestForVariables> lstRequestForVariables){


            try{
            
                map<string,string> mapUserIdoType = new map<string, string>();
                string strInsorDel = '';
                strInsorDel = lstRequestForVariables[0].strInsertorDelete;
                
                //To retrieve the parameters passed from process builder
                for(RequestForVariables rfv:lstRequestForVariables){
                    mapUserIdoType.put(rfv.strUserId,rfv.strInsertorDelete);
                }
                //List to store Canada Users
                List<User> lstCanadaUsers = new List<User>();
                //List to store US Users
                List<User> lstUSUsers = new List<User>();

                Map<String, Object> mapUSUsers = new Map<String, Object>();
                Map<String, Object> mapCanadaUsers = new Map<String, Object>();
                
                map<string, string> mapPermissionSettoId = new map<string, string>();
                map<string, list<PermissionSetAssignment>> mapAssigneIdtoPermissionSet = new map<string, list<PermissionSetAssignment>>();
                
                List<PermissionSetLicenseAssign> lstPermissionsetLicenseAssignment = new List<PermissionSetLicenseAssign>();
                List<PermissionSetAssignment> lstPermissionsetAssignmentInsert = new List<PermissionSetAssignment>();
                List<UserPackageLicense> lstNewUserPackageLicense = new List<UserPackageLicense>();
                List<PermissionSetAssignment> lstPermissionsetAssignmentToDelete = new List<PermissionSetAssignment>();
                list<PackageLicense> lstAgentOnePackageLicense = new list<PackageLicense>();
                List<UserPackageLicense> lstUserPackageLicensetoDelete = new List<UserPackageLicense>();
               

                map<Id, User> mapidtoUser = new map<id, User>();
                map<string, UserPackageLicense> mapUsertoUserPackageLicense = new map<string, UserPackageLicense>();
                
                lstAgentOnePackageLicense = [SELECT Id, NamespacePrefix, AllowedLicenses, UsedLicenses, ExpirationDate,Status FROM PackageLicense WHERE NamespacePrefix = : 'AgentOne' LIMIT 1];
                
                string strUSknowledgeArticle = Label.WFG_US_Knowlegde_Articles;
                string strCANknowledgeArticle = Label.WFG_Canada_Knowlegde_Articles;
                string strFSCPermissionSet = Label.WFG_FSC_Permission_Set;
                string strAgentOnePermissionSet = Label.WFG_AgentOnePermissionSet;
                if(strInsorDel == 'Insert'){
                    
                    for(User objUser : [Select id,contactId,Profile.Name,CountryCode from User where Id In: mapUserIdoType.keyset()]){
                        mapidtoUser.put(objUser.Id, objUser);
                    }
                    
                    /*for(PermissionSet objPermissionSet : [select id, name from PermissionSet where name like '%Knowledge_Articles' OR  name like 'FinancialServicesCloudStandard' OR name like 'AgentOne_Agent']){
                        
                        mapPermissionSettoId.put(objPermissionSet.name,objPermissionSet.Id);
                    }*/
                    
                    for(PermissionSet objPermissionSet : [select id, name from PermissionSet where name =: strUSknowledgeArticle OR  name =: strCANknowledgeArticle OR name =: strFSCPermissionSet OR name =: strAgentOnePermissionSet]){
                        
                        mapPermissionSettoId.put(objPermissionSet.name,objPermissionSet.Id);
                    }
                    
                    for(PermissionSetAssignment objPerSetAssign : [Select id,AssigneeId,PermissionSet.Name from PermissionSetAssignment where AssigneeId IN: mapUserIdoType.keyset() AND PermissionSetId IN: mapPermissionSettoId.values()]){
                        
                        if(mapAssigneIdtoPermissionSet.containsKey(objPerSetAssign.AssigneeId)) {
                            List<PermissionSetAssignment> lstPermSetAssignment = mapAssigneIdtoPermissionSet.get(objPerSetAssign.AssigneeId);
                            lstPermSetAssignment.add(objPerSetAssign);
                            mapAssigneIdtoPermissionSet.put(objPerSetAssign.AssigneeId, lstPermSetAssignment);
                        } else {
                            mapAssigneIdtoPermissionSet.put(objPerSetAssign.AssigneeId, new List<PermissionSetAssignment> { objPerSetAssign });
                        }
                    
                    }
                    
                    
                    for(UserPackageLicense objUserPL : [SELECT Id, PackageLicenseId, UserId from UserPackageLicense where UserId IN: mapUserIdoType.keyset() AND PackageLicenseId =: lstAgentOnePackageLicense[0].id]){
                    
                        mapUsertoUserPackageLicense.put(objUserPL.UserId, objUserPL);
                    }
                
                    for(string strUserId : mapUserIdoType.keyset()){
                        User objU = mapidtoUser.get(strUserId);
                        system.debug('===objU.Profile.Name==='+objU.Profile.Name);
                        if(objU.contactId == NULL){

                            if(objU.Profile.Name.startsWith('LL') || objU.Profile.Name.startsWith('FA') || objU.Profile.Name.startsWith('IAR') || objU.Profile.Name.startsWith('MF') ||objU.Profile.Name.startsWith('RR')){
                                
                                UserPackageLicense objUserPackageLicense = new UserPackageLicense();
                                PermissionSetAssignment objPermFSC;
                                PermissionSetAssignment objPermAgentOne;
                                PermissionSetAssignment objKnowledge;
                                
                                if(mapUsertoUserPackageLicense.containsKey(strUserId))
                                    objUserPackageLicense = mapUsertoUserPackageLicense.get(strUserId);
                                if(mapAssigneIdtoPermissionSet.containsKey(strUserId)){
                                
                                    List<PermissionSetAssignment> lstPermSetAssignment = mapAssigneIdtoPermissionSet.get(strUserId);
                                    for(PermissionSetAssignment obj: lstPermSetAssignment){
                                    
                                        if(obj.PermissionSet.Name == strFSCPermissionSet)
                                            objPermFSC = obj;
                                        else if(obj.PermissionSet.Name == strAgentOnePermissionSet)  
                                            objPermAgentOne = obj;
                                        else if(obj.PermissionSet.Name == strUSknowledgeArticle || obj.PermissionSet.Name == strCANknowledgeArticle)   
                                            objKnowledge = obj;
                                            
                                    }
                                }
                                
                                if(!objU.Profile.Name.contains('CAN') && !objU.Profile.Name.contains('TAN')){
                                    
                                    if(objPermAgentOne == NULL){
                                        PermissionSetAssignment objPermissionSet= new PermissionSetAssignment();
                                        objPermissionSet.AssigneeId = strUserId;
                                        objPermissionSet.PermissionSetId= mapPermissionSettoId.get('AgentOne_Agent');
                                        lstPermissionsetAssignmentInsert.add(objPermissionSet);
                                        UserPackageLicense objUserPL = new UserPackageLicense();   
                                        objUserPL.PackageLicenseId = lstAgentOnePackageLicense[0].Id;
                                        objUserPL.UserId = strUserId;
                                        lstNewUserPackageLicense.add(objUserPL);
                                    }
                                }

                                else{
                                    
                                    if(objUserPackageLicense != null)
                                        lstUserPackageLicensetoDelete.add(objUserPackageLicense);
                                    if(objPermAgentOne != null)
                                        lstPermissionsetAssignmentToDelete.add(objPermAgentOne);
                                    
                                }
                                
                                if(objU.Profile.Name.contains('TAN')){
                                
                                    if(objKnowledge != null)
                                        lstPermissionsetAssignmentToDelete.add(objKnowledge);
                                }
                                if(objPermFSC == NULL){
                                    PermissionSetAssignment objPermissionSet= new PermissionSetAssignment();
                                    objPermissionSet.AssigneeId = strUserId;
                                    objPermissionSet.PermissionSetId= mapPermissionSettoId.get(strFSCPermissionSet);
                                    lstPermissionsetAssignmentInsert.add(objPermissionSet);
                                }
                            }   
                        }
                        if(!objU.Profile.Name.contains('TAN')){
                            if(objU.countrycode == 'US' || objU.countrycode == 'PR' || objU.countrycode == 'United States' || objU.countrycode == 'Puerto Rico'){
                                lstUSUsers.add(objU);
                                
                            }
                            if(objU.countrycode == 'CA' || objU.countrycode == 'Canada' ){
                                lstCanadaUsers.add(objU);
                            }
                        }
                        
                    }
                }
                
                system.debug('====lstNewUserPackageLicense===='+lstNewUserPackageLicense);
                system.debug('====lstPermissionsetAssignmentInsert===='+lstPermissionsetAssignmentInsert);
                //Get the Canada users and run a flow to insert Canada permission set
                if(!lstCanadaUsers.isEmpty()){

                    for(user u:lstCanadaUsers){

                        mapCanadaUsers.put('UserID',u.Id);
                        system.debug('Canada Users = '+mapCanadaUsers.values());
                    }
                    Flow.Interview.Canada_Knowledge_Permission_Set recordCanadaUpdaterFlow = new Flow.Interview.Canada_Knowledge_Permission_Set(mapCanadaUsers);
                    recordCanadaUpdaterFlow.start();
                    object psa = recordCanadaUpdaterFlow.getVariableValue('UserID');
                    System.debug('Flow returned ' + psa);
                }

                //Get the US users and run a flow to insert Canada permission set
                if(!lstUSUsers.isEmpty()){
                    for(user u:lstUSUsers){

                        mapUSUsers.put('UserID',u.ID);
                        system.debug('US Users = '+mapUSUsers.values());

                    }
                    Flow.Interview.US_Knowledge_Permission_Set recordUSUpdaterFlow = new Flow.Interview.US_Knowledge_Permission_Set(mapUSUsers);
                    recordUSUpdaterFlow.start();
                    object psa = recordUSUpdaterFlow.getVariableValue('UserID');
                    System.debug('Flow returned ' + psa);
                }
                system.debug('===strInsorDel==='+strInsorDel);
                //Fetch the required knowledge and FSC permission sets which needs to be deleted
                if(strInsorDel == 'Delete'){

                   /* lstPermissionsetAssignmentToDelete = [SELECT Id FROM PermissionSetAssignment WHERE (PermissionSet.Name like '%Knowledge_Articles' OR PermissionSet.Name like 'FinancialServicesCloudStandard' OR PermissionSet.Name like 'AgentOne_Agent') AND Assignee.id =: mapUserIdoType.keyset()];*/
                   
                    lstPermissionsetAssignmentToDelete = [select id from PermissionSetAssignment where (PermissionSet.name =: strUSknowledgeArticle OR  PermissionSet.name =: strCANknowledgeArticle OR PermissionSet.name =: strFSCPermissionSet OR PermissionSet.name =: strAgentOnePermissionSet) AND Assignee.id IN: mapUserIdoType.keyset()];
                    
                    system.debug('====lstPermissionsetAssignmentToDelete==='+lstPermissionsetAssignmentToDelete);

                    lstPermissionsetLicenseAssignment = [select id from PermissionSetLicenseAssign where PermissionSetLicenseId IN (select id from PermissionSetLicense where MasterLabel = 'Financial Services Cloud Standard' and status = 'active') and AssigneeId IN: mapUserIdoType.keyset()];
                    
                    lstUserPackageLicensetoDelete = [Select id, PackageLicenseId, UserId from UserPackageLicense where PackageLicenseId =: lstAgentOnePackageLicense[0].Id AND UserId =: mapUserIdoType.keyset()];
                

                }
                
                system.debug('===strInsorDel===='+strInsorDel);
                list<sobject> lstRecordstoDelete = new list<sobject>();
                if(!lstPermissionsetAssignmentToDelete.isEmpty() && lstPermissionsetAssignmentToDelete != null){
                    lstRecordstoDelete.addAll(lstPermissionsetAssignmentToDelete);
                }

                if(!lstPermissionsetLicenseAssignment.isEmpty() && lstPermissionsetLicenseAssignment != null){
                    lstRecordstoDelete.addAll(lstPermissionsetLicenseAssignment);
                }

                if(!lstUserPackageLicensetoDelete.isEmpty() && lstUserPackageLicensetoDelete != null){
                    lstRecordstoDelete.addAll(lstUserPackageLicensetoDelete);
                }
                system.debug('===lstRecordstoDelete===='+lstRecordstoDelete);
                //Insert/Delete the list of permission sets
                if(!test.isRunningTest()){

                    if(!lstNewUserPackageLicense.isEmpty())
                        insert lstNewUserPackageLicense;

                    if(!lstPermissionsetAssignmentInsert.isEmpty())
                        insert lstPermissionsetAssignmentInsert;
                        
                    if(!lstRecordstoDelete.isEmpty() && lstRecordstoDelete != null){
                        delete lstRecordstoDelete;
                    }  
                }
             
            }catch(Exception e)
            {
            
                LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_userTriggerHandler', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
            }
        }
        
        /*Remove the logic to add Case team member when user is active.
        @future
        public static void updateCaseTeamMember(set<Id> setUserIds){
            Date minDateRange = NULL;
            set<string> setExistingActiveAgentCodes = new set<String>();
            set<string> setNewActiveAgentCodes = new set<String>();
            map<string, Id> mapAgentCodeUser = new map<string, Id>();
            
            for(User currUser : [select id, WFG_Inactivated_Date__c, WFG_Agent_Code__c from user where Id IN: setUserIds])
            {
                mapAgentCodeUser.put(currUser.WFG_Agent_Code__c, currUser.Id);
                if(currUser.WFG_Inactivated_Date__c != NULL){
                    setExistingActiveAgentCodes.add(currUser.WFG_Agent_Code__c);
                    if(minDateRange == NULL || currUser.WFG_Inactivated_Date__c < minDateRange)
                        minDateRange = currUser.WFG_Inactivated_Date__c;
                } else {
                    setNewActiveAgentCodes.add(currUser.WFG_Agent_Code__c);
                }
            }
            
            map<string, set<string>> mapCaseIdUserId = new map<string, set<string>>();
            set<Id> setAccountIds = new set<Id>();
            
            if(setExistingActiveAgentCodes.size() > 0){
                for(case newCase : [select id, AccountId, WFG_InteractingAbout__r.WFG_AgentCode__c, Contact.WFG_AgentCode__c from case where (WFG_InteractingAbout__r.WFG_AgentCode__c IN: setExistingActiveAgentCodes OR Contact.WFG_AgentCode__c IN: setExistingActiveAgentCodes) AND LastModifiedDate >=: minDateRange]){
                    mapCaseIdUserId.put(newCase.Id, new set<string>());
                    mapCaseIdUserId.get(newCase.Id).add(mapAgentCodeUser.get(newCase.WFG_InteractingAbout__r.WFG_AgentCode__c));
                    mapCaseIdUserId.get(newCase.Id).add(mapAgentCodeUser.get(newCase.Contact.WFG_AgentCode__c));
                    setAccountIds.add(newCase.AccountId);
                }
            }
            
            if(setNewActiveAgentCodes.size() > 0){
                for(case newCase : [select id, AccountId, WFG_InteractingAbout__r.WFG_AgentCode__c, Contact.WFG_AgentCode__c from case where WFG_InteractingAbout__r.WFG_AgentCode__c IN: setNewActiveAgentCodes OR Contact.WFG_AgentCode__c IN: setNewActiveAgentCodes]){
                    mapCaseIdUserId.put(newCase.Id, new set<string>());
                    mapCaseIdUserId.get(newCase.Id).add(mapAgentCodeUser.get(newCase.WFG_InteractingAbout__r.WFG_AgentCode__c));
                    mapCaseIdUserId.get(newCase.Id).add(mapAgentCodeUser.get(newCase.Contact.WFG_AgentCode__c));
                    setAccountIds.add(newCase.AccountId);
                }
            }
            
            if(mapCaseIdUserId.size() > 0){
                list<CaseTeamMember> lstCaseTeamMember = WFG_SystemModeHelper.createCaseTeamMembers(mapCaseIdUserId, new set<String>());
                
                if(lstCaseTeamMember.size() > 0){
                    database.insert(lstCaseTeamMember, false);
                }
            }
        }
        */
    }