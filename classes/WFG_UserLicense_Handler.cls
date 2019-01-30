/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Deepthi N
* @date 24-Feb-2017
* @description - Class to handle licence update

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Saravanan             Mod-01            22-FEB-2018              PC to FSC conversion. Removed the logic used for CC to PC conversion.
                                                                 Update the logic for CC to FSC users. Only FA users will be created as a active Users. All other FSC users will be created as a inactive user. Removed the logic that make isportalUser diabled. Since we are using only one community.
Rashmi                Mod-02            12-June-2018             Handling the transformation from launch to FSC and also from FSC to
                                                                 Launch. Appending '_comm' for launch users when it becomes inactive.                                                                
*/

public without sharing class WFG_UserLicense_Handler{

    @future
    Public static void LicenseUpdate(Set<id> lstcontactIds)
    {
        try
        {
            Map<Id, WFG_JITHelper.JITResponse> mapObjRes = new Map<Id, WFG_JITHelper.JITResponse>();
            Map<Id,Profile> mapProfiles = new Map<id,profile>([SELECT Id,UserLicense.Name FROM Profile]);
            set<string> strFedIdsWithAppend = new set<String>();
            list<User> lstUpdateUser = new list<User>();
            list<User> lstInsertUser = new list<User>();
            list<user> lstUserDeactivate = new list<User>();
            
            boolean boolIsError = false;
            string strErrorMailString = 'Contact Id, Federation Id, User ID, Operation , Error \n';
            
            List<Contact> lstContacts = [select id, firstname, WFG_Status__c, lastname,WFG_FederationId__c,WFG_AgentCode__c,WFG_Channel__c,
                                        mailingcountry, mailingstreet, mailingstate, mailingpostalCode, MailingCity, Fax, email,phone, 
                                        WFG_AgentID__c,WFG_Type__c,WFG_AgentPayType__c,WFG_CycleType__c, WFG_Fiduciary_Advisor__c, WFG_Home_Office_Agent__c, 
                                        WFG_SSNSIN__c, AgentOne__SSN_Tax_ID__c from contact where Id IN: lstcontactIds];
                                       
            for(Contact Con : lstContacts){
                strFedIdsWithAppend.add(con.WFG_FederationId__c+'%');
            }
            
            Map <String, String> mapNewProfiles = WFG_ProfileIdentificationMatrix.getProfileId(lstContacts);
            system.debug('===mapNewProfiles==='+mapNewProfiles);
            Map<String, User> mapUsers = new map<String, User>();
            
            // retrieve all user records with federation Id and federation id with _comm or _FSC
            for(user usr :  [Select id, FederationIdentifier, contactId, ProfileId, isActive, isPortalEnabled, EmailEncodingKey, 
                                   LanguageLocaleKey, TimeZoneSidKey, LocaleSidKey, Username, CommunityNickname, Alias, FirstName, LastName, Email, 
                                   Profile.UserLicense.Name, WFG_Agent_Code__c from user where FederationIdentifier LIKE: strFedIdsWithAppend])
            {
                mapUsers.put(usr.FederationIdentifier, Usr);
            }
            system.debug('===mapUsers====='+mapUsers);
            Map<String, Id> mapRoles = new map<string, Id>();
            for(UserRole roleId : [select Id, name from UserRole WHere name = 'Registered Reps' OR name = 'Life License Agents'] ){
                mapRoles.put(roleId.Name, roleId.id);
            }
            
            list<Contact> lstUsersToBeCreated = new list<COntact>();
            
            for(Contact con : lstContacts){
                system.debug('==con==='+con);
                // The current active user need to be deactivated since the licence will be changed from CC to FSC or FSC to cc
                User userToDeactivate = mapUsers.get(con.WFG_FederationId__c);
                user userToCreate;
                string fedID;
                string inactiveUserFedId;
                // Get values that need to appended to fedration Id to retrieve the inactive user from system
                if((con.WFG_Type__c.containsIgnoreCase(Label.WFG_Associate) || (con.WFG_Type__c.containsIgnoreCase(Label.WFG_Launch))) && !con.WFG_Fiduciary_Advisor__c){
                    fedId = con.WFG_FederationId__c+'_comm';
                    inactiveUserFedId = con.WFG_FederationId__c+'_FSC';
                }
                else{
                    fedId = con.WFG_FederationId__c+'_FSC';
                    inactiveUserFedId = con.WFG_FederationId__c+'_comm';
                }
                // If the user to be deactivated is not null we append _comm or _FSC based on the type and FA flag. Also will enable UTCheck to true
                String strAppend = '';
                if(userToDeactivate != NULL){
                    if(mapProfiles.get(userToDeactivate.ProfileId).UserLicense.Name.contains('Community'))
                        strAppend = '_comm';
                    else
                        strAppend = '_FSC';
                } else {
                    userToDeactivate = mapUsers.get(inactiveUserFedId);   
                }
                
                if(userToDeactivate != NULL){
                    userToDeactivate.WFG_UTCheck__c = true;
                    userToDeactivate = WFG_JITHelper.fetchContactData(userToDeactivate, con, NULL);
                    lstUserDeactivate.add(appendLogic(userToDeactivate, strAppend));
                }
                
                //If existing user found with _comm or _fsc we update the profile Id accordingly, Remove the appended values and Make isActive as true only for FA users.
                if(mapUsers.containsKey(fedId)){
                    User usr = mapUsers.get(fedId);
                    system.debug('===usr.ProfileId==='+usr.ProfileId);
                    system.debug('===mapNewProfiles.get(con.Id)==='+mapNewProfiles.get(con.Id));
                    if(usr.ProfileId != mapNewProfiles.get(con.Id) || con.WFG_Fiduciary_Advisor__c){
                        
                        system.debug('===in if==');
                        usr.ProfileId = mapNewProfiles.get(con.Id);
                        
                        if(con.WFG_Fiduciary_Advisor__c && system.label.WFG_UserCreationContactStatus.containsIgnoreCase(con.WFG_Status__c)){
                            usr.isActive = true;
                            usr = WFG_JITHelper.removeAppendLogic(usr, '_FSC');
                        }
                        if(!con.WFG_Type__c.ContainsIgnoreCase('Associate') && con.WFG_Type__c.ContainsIgnoreCase('Agent') && !con.WFG_Fiduciary_Advisor__c){
                            usr.userRoleId = mapRoles.get('Life License Agents');
                        } else if(!con.WFG_Type__c.ContainsIgnoreCase('Associate')){
                            usr.userRoleId = mapRoles.get('Registered Reps');
                        }
                        lstUpdateUser.add(WFG_JITHelper.fetchContactData(usr, con, NULL));
                    }
                    
                } else if(system.label.WFG_UserCreationContactStatus.containsIgnoreCase(con.WFG_Status__c) && ((!con.WFG_Type__c.containsIgnoreCase(label.WFG_Associate) && !con.WFG_Type__c.containsIgnoreCase(Label.WFG_Launch)) || con.WFG_Fiduciary_Advisor__c)){
                    lstUsersToBeCreated.add(con);
                }
                
                
            }
            
            system.debug('========lstUsersToBeCreated========='+lstUsersToBeCreated);
            // lstUsersToBeCreated - When there is no user present in system that needs to be activated. We will create a new FSC user if the users are not present in the system and activate the user based on the FA flag.
            if(lstUsersToBeCreated.size() > 0){
                mapObjRes = WFG_JITHelper.createUser(lstUsersToBeCreated);
                
                for(Contact con : lstUsersToBeCreated){
                    if(mapObjRes.ContainsKey(con.Id) && mapObjRes.get(con.Id) != NULL){
                        WFG_JITHelper.JITResponse objJITres = mapObjRes.get(con.Id);
                        
                        if(objJITres.boolIsError != NULL && !objJITres.boolIsError && objJITres.objUser != NULL){
                            String append = '';
                            User userToCreate = objJITres.objUser;
                            if(mapProfiles.get(userToCreate.ProfileId).UserLicense.Name.contains('Community'))
                                append = '_comm';
                            else
                                append = '_FSC';
                                
                            if(con.WFG_Fiduciary_Advisor__c){
                                userToCreate.isActive = true;
                            }
                            else {
                                userToCreate = appendLogic(userToCreate, append);
                            }
                            
                           
                            lstInsertUser.add(userToCreate);
                        } else if (objJITres.boolIsError != NULL && objJITres.boolIsError){
                            boolIsError = true;
                            strErrorMailString += con.id + ',' +con.WFG_FederationId__c + ',' + ',Insert,'+ objJITres.strErrMsg + ' \n';
                        } else {
                            boolIsError = true;
                            strErrorMailString += con.id + ',' +con.WFG_FederationId__c + ',' + ',Insert,User instance could not be generated properly \n';
                        }
                    }
                }
            }
            // Update the users to be deactived with _comm or _fsc apended
            if(!lstUserDeactivate.isEmpty()){
                system.debug('++++++++ ' + lstUserDeactivate);
                update lstUserDeactivate;
            }
            
            // Update the users to be activated with _fsc removed.
            if(!lstUpdateUser.isEmpty()){
                system.debug('++++++++ ' + lstUpdateUser);
                update lstUpdateUser;
            }
            
            // Insert the user record if no users present in the system with _fsc or _comm
            if(!lstInsertUser.isEmpty()){
                system.debug('++++++++ ' + lstInsertUser);
                insert lstInsertUser;
            }   
        } catch(Exception e)
        {
            system.debug('Exception in License Handler--' + e);
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_UserLicense_Handler', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }
    }
    
     /**
     * This method accepts user record and the string value to append, returns the instance of user record with the appended values.
     * @return - User
     * @see    - N/A
     * @param  - User record and String
     * @throws - N/A
     */
    public static User appendLogic(User currUser, String strAppend){
        currUser.isActive = false;
        if(!currUser.FederationIdentifier.endsWithIgnoreCase(strAppend) && strAppend != ''){
            currUser.FederationIdentifier = currUser.FederationIdentifier + strAppend;
            currUser.username = currUser.username + strAppend ;
            currUser.CommunityNickname = currUser.CommunityNickname + strAppend;
            currUser.WFG_Agent_Code__c = currUser.WFG_Agent_Code__c + strAppend;
        }
        return currUser;
    }
    
    //This method returns a random hexadigit code. Used by Batch class WFG_UserCreateUpdate_Batch.
    //As part of PC to FSC conversion, above mentioned batch class deactivates all PC users by appending an hexa digit code.
    public static string generateHexaDigitCode()
    {
        String strhashString = '-com' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(strhashString));
        String strhexDigest = EncodingUtil.convertToHex(hash);
        strhexDigest = strhexDigest.substring(0,5);
        system.debug('##########' + strhexDigest );
        return strhexDigest;
     }   
}