/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author bmadaan
* @date 12-08-2016
* @description  JIT Helper class

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Ninad Patil           M-001             01-MAR-2017             US-707/709/710 Utility craete User instance from contact.
Saravanan             M-002             20-FEB-2018             Update the logic to fetch the contact based on federation ID.
                                                                Update the method to fetech the user information from contact.
                                                                Allow user to login only when the contact status is active.
Rashmi                M-003             08-June-2018            Updated the logic to create new Launch users(customer community) when the Launch prospects login via JIT.                                                                      
                                                                                            
Rashmi                M-004             26-July-2018            Added logic to update Agent one fieldsfor the FSC users from the contact
*/
public without sharing class WFG_JITHelper 
{
    /**
     * This is class to wrapp User and subsequet error message.
     * @return - string
     * @see    - N/A
     * @param  - Contact
     * @throws - N/A
     */
    public class JITResponse
    {
        public User objUser;
        public boolean boolIsError = false;
        public string strErrMsg ='';
        public contact objContact;
    }
    /**
     * This method will accept federation Id and returns JIT Response for it.
     * @return - JITResponse
     * @see    - N/A
     * @param  - strFederationId
     * @throws - N/A
     */
    public static JITResponse getUser(string strFederationId)
    {
        WFG_JITHelper.JITResponse objJITres = new WFG_JITHelper.JITResponse();
        
        //Checks whether the contact exists for the federation id passed
        Contact objCon = checkContactExistance(strFederationId);
        
        if(objCon == NULL){
            objJITres.boolIsError = true;
            objJITres.strErrMsg = system.Label.WFG_ContactMustExist;
        } else {
            fetchAndUpdateOnboardingCheckist(objCon.Id);
            string strAppend = '';
            User objUser = fetchUserContext(strFederationId);
            
            system.debug('+++ objCon +++' + objCon);
            //Satisfies if Type is Associate and not fiduciary advisor
            
            if(objUser != NULL){
                system.debug('+++++Existing User+++' + objUser );
            }
            //checks if there is already existing community user which is inactive and returns if it is found
            else if(objCon.WFG_Type__c != NULL && !objCon.WFG_Fiduciary_Advisor__c && (objCon.WFG_Type__c.ContainsIgnoreCase('Associate') || (objCon.WFG_Type__c.ContainsIgnoreCase('Launch')))){
                strAppend = '_comm';
                strFederationId = strFederationId+strAppend;
                objUser = fetchUserContext(strFederationId);
                
                //Satisfies if its fiduciary advisor is true else type will be Agent/IAR/Registered Rep
            } else if(objCon.WFG_Fiduciary_Advisor__c) {
                objUser = fetchUserContext(strFederationId);
            } else {
                strAppend = '_FSC';
                strFederationId = strFederationId+strAppend;
                objUser = fetchUserContext(strFederationId);
            }
            
            system.debug('+++ objUser +++' + objUser);
            //Satisfies if there is no user present and if true then active user is created else user is activated and remove appendlgic is appended
            if(objUser == NULL){
                Map<Id, WFG_JITHelper.JITResponse> mapJITres = createUser(new list<Contact> {objCon});
                objJITres = mapJITres.get(objCon.id);
            } else {
                if(strAppend != '')
                    objUser = removeAppendLogic(objUser, strAppend); 
                    
                objJITres.objUser = WFG_JITHelper.fetchContactData(objUser, objCon, NULL);
            }
        }
        
        
        return objJITres;
    }
     /**
     * This method will accept federation Id and returns Contact associated to this.
     * @return - contact
     * @see    - N/A
     * @param  - strFederationId
     * @throws - N/A
     */
    public static contact checkContactExistance(string strFederationId)
    {
        if(strFederationId != null && strFederationId != '')
        {
            Set<String> setActiveConStatus = new set<String>();
            setActiveConStatus.addAll(system.label.WFG_UserCreationContactStatus.split(';'));
            
            system.debug('#### FED ID : '+strFederationId);
            List<Contact> lstCon = [Select id, Name, WFG_CycleType__c,WFG_Status__c, Account.WFG_BranchCode__c,WFG_Channel__c,
                    WFG_Fiduciary_Advisor__c,WFG_AgentPayType__c,Email, phone,
                    FirstName,LastName,title,mailingstreet,mailingstate,mailingCity,
                    mailingPostalCode,mailingCountry,Fax,WFG_AgentCode__c,
                    WFG_AlternateEmail__c, WFG_FederationId__c,WFG_Type__c,accountId,
                    WFG_Email_Verification__c, WFG_SSNSIN__c, AgentOne__SSN_Tax_ID__c 
                from Contact Where WFG_FederationId__c = :strFederationId AND WFG_Status__c IN: setActiveConStatus];
            system.debug('IN CONTACT ### :: ' + lstCon);
            if(lstCon != null && !lstCon.isEmpty())
            {
                return lstCon[0];
            }
        }
        return null;
    }
    /**
     * This method will accept Contact Id and checks if it is RR/FA or not
     * @return - boolean
     * @see    - N/A
     * @param  - Contact
     * @throws - N/A
     */
    /*private static boolean checkContactisRR(Contact objCon)
    {
        system.debug('##### 1 ::'+objCon);
        if(objCon != null)
        {
            User objUser = WFG_UserCreateUpdateUtility.getUserForJITHandler(objCon);
            if(objUser != null)
            {
                map<string ,WFG_RRProfileNames__c> mapRRprofileNames = WFG_RRProfileNames__c.getAll();
                map<string ,WFG_FAProfileNames__c> mapFAprofileNames = WFG_FAProfileNames__c.getAll();
                set<string> setRRFAProfileName = new set<string>();
                if(mapRRprofileNames != null && !mapRRprofileNames.keyset().isEmpty())
                {
                    for(string strName : mapRRprofileNames.keyset())
                    setRRFAProfileName.add(strName);
                }
                if(mapFAprofileNames != null && !mapFAprofileNames.keyset().isEmpty())
                {
                    for(string strName : mapFAprofileNames.keyset())
                    setRRFAProfileName.add(strName);
                }
                string strProfielName = '';
                if(objUser.profileId != null)
                {
                    strProfielName = [Select id, name from Profile WHERE Id = :objUser.profileId].name;
                }
                if(setRRFAProfileName.contains(strProfielName))
                {
                    system.debug('##### 6 ::'+strProfielName);
                    return true;
                }
            }
        }
        return false;
    }*/
    /**
     * This method will accept list of contacts and returns map of contact Id and JIT responsewrapper.
     * @return - Map<Id, WFG_JITHelper.JITResponse>
     * @see    - N/A
     * @param  - List<Contact>
     * @throws - N/A
     */
    public static Map<Id, WFG_JITHelper.JITResponse> createUser(List<Contact> lstCon)
    {
        system.debug('======in create=======');
        //map contains the profile of community users, i.e., support community
        Map<id, Profile> profileMap = new map<Id, Profile>([Select id, name from profile WHERE name = :system.Label.WFG_Support_Profile OR name LIKE '%Launch%']);
        
        User objCurrentUser = [Select id, name, LocaleSidKey, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey 
            FROM User WHERE Id = :Userinfo.getuserId()];
        
        Map<Id, WFG_JITHelper.JITResponse> mapJITres = new Map<Id, WFG_JITHelper.JITResponse>();
        Map<String, Id> mapRoles = new map<string, Id>();
        for(UserRole roleId : [select Id, name from UserRole WHere name = 'Registered Reps' OR name = 'Life License Agents'] ){
            mapRoles.put(roleId.Name, roleId.id);
        }
        Map<string, User> mapContactVsUsers = WFG_UserCreateUpdateUtility.getUserInstances(lstCon);
        
        for(Contact con : lstCon){
            WFG_JITHelper.JITResponse objJITres = new WFG_JITHelper.JITResponse();
            if(mapContactVsUsers.containsKey(con.id)){
                User userToBeCreated = mapContactVsUsers.get(con.id);
                
                if(profileMap.containsKey(userToBeCreated.ProfileId))
                    userToBeCreated.ContactID = con.Id;
                else{
                    if(con.WFG_Type__c.ContainsIgnoreCase('Agent') && !con.WFG_Fiduciary_Advisor__c)
                        userToBeCreated.userRoleId = mapRoles.get(Label.WFG_LifeLicensedAgents);
                    else
                        userToBeCreated.userRoleId = mapRoles.get(Label.WFG_RegisteredRepsRole);
                        
                    if(con.WFG_Home_Office_Agent__c && con.WFG_AgentPayType__c != 'TAN'){
                        userToBeCreated.UserPermissionsSupportUser = true;
                    } else {
                        userToBeCreated.UserPermissionsSupportUser = false;
                    }
                }
                system.debug('+++ userToBeCreated +++' + userToBeCreated);
                userToBeCreated = fetchContactData(userToBeCreated,con,objCurrentUser);
                objJITres.objUser = userToBeCreated;
                mapJITres.put(Con.Id,objJITres);
            } else {
                objJITres.boolIsError = true;
                objJITres.strErrMsg = system.Label.WFG_NoValidProfileException;
                mapJITres.put(con.id,objJITres);
            }
        }
        
        return mapJITres;
    }
    /**
     * This method will accept user instance and current logged in user instance and COntact instance, sends back User after populating values.
     * @return - User
     * @see    - N/A
     * @param  - objUser/Contact and current user instance
     * @throws - N/A
     */ 
    public static User fetchContactData(User objUser,Contact objCon, User objcurrentUser)
    {   
        try{
            if(objCon != null && objUser != null)
            {
                String append = '';
                if(objUser.userName != NULL){
                    If(objUser.userName.endsWithIgnoreCase('_FSC'))
                        append = '_FSC';
                    else if(objUser.userName.endsWithIgnoreCase('_comm'))
                        append = '_comm';
                }
                
                if(objCon.WFG_Email_Verification__c && objCon.WFG_AlternateEmail__c != NULL){
                    if(system.label.WFG_SandboxType != 'PROD')
                        objUser.userName = objCon.WFG_AlternateEmail__c + '.' + system.label.WFG_SandboxType;
                    else
                        objUser.userName = objCon.WFG_AlternateEmail__c;
                } else {
                    if(system.label.WFG_SandboxType != 'PROD')
                        objUser.userName = objCon.WFG_AgentCode__c + '@' + system.Label.WFG_EMailDomain + '.' + system.label.WFG_SandboxType;
                    else
                        objUser.userName = objCon.WFG_AgentCode__c + '@' + system.Label.WFG_EMailDomain;
                }
                
                if(append != '')
                    objUser.userName = objUser.userName + append;
                
                objUser.Phone = objCon.Phone;
                objUser.FirstName = objCon.firstName;
                objUser.LastName = objCon.LastName;
                objUser.street = objCon.mailingstreet;
                objUser.state= objCon.mailingstate;
                objUser.City= objCon.MailingCity;
                objUser.PostalCode= objCon.mailingpostalCode;
                objUser.Country= objCon.MailingCountry;
                objUser.Fax= objCon.Fax;
                
                if(objcurrentUser != NULL){
                    objUser.LocaleSidKey =  objcurrentUser.LocaleSidKey;
                    objUser.LanguageLocaleKey = objcurrentUser.LanguageLocaleKey; 
                    objUser.TimeZoneSidKey = objcurrentUser.TimeZoneSidKey; 
                    objUser.EmailEncodingKey = objcurrentUser.EmailEncodingKey;
                    objUser.FederationIdentifier = objCon.WFG_FederationId__c;
                    objUser.CommunityNickname =  objCon.Firstname + ' ' + objCon.WFG_AgentCode__c;
                    objUser.title = objCon.title;
                    objUser.WFG_Agent_Code__c = objCon.WFG_AgentCode__c;
                    
                    if(objCon.WFG_CycleType__c != null && objCon.WFG_CycleType__c == System.Label.WFG_CycleType_CA) {
                        objUser.DefaultCurrencyIsoCode = System.Label.WFG_CADCurrency;
                        objUser.LocaleSidKey = system.Label.WFG_CALocalSidKey;
                    }
                    
                    String strAlias = '';
                    if(objUser.FirstName == null){
                        strAlias = objUser.LastName;
                    } else {
                        strAlias = objUser.FirstName.substring(0,1) + objUser.LastName;
                    }
                    
                    if(system.label.WFG_SandboxType != null || system.label.WFG_SandboxType != ''){
                        objUser.Alias = strAlias + system.label.WFG_SandboxType;
                    } else {
                        objUser.Alias = strAlias ;
                    }
                    
                    if(objUser.Alias.length() > 5) {
                        objUser.Alias = objUser.Alias.substring(0, 5);
                    }
                    
                }
                
                if(objCon.Email != null )
                {
                    ObjUser.EMail = objCon.EMail;
                } else {
                    if(system.label.WFG_SandboxType != 'PROD') {
                        objUser.EMail = objCon.WFG_AgentCode__c + '@' + system.Label.WFG_EMailDomain + '.' + system.label.WFG_SandboxType;
                    } else {
                        objUser.EMail = objCon.WFG_AgentCode__c + '@' + system.Label.WFG_EMailDomain;
                    }
                }
                
                //string strProfileLicenseName = [Select id, name,UserLicense.Name from Profile WHERE Id = :objUser.profileId].UserLicense.Name;
                
                 if((objCon.WFG_CycleType__c != 'CA' && objCon.WFG_AgentPayType__c != 'TAN') && (objCon.WFG_Type__c == 'Agent' || objCon.WFG_Type__c == 'REGISTERED_REP' || objCon.WFG_Type__c == 'IAR' || objCon.WFG_Type__c.ContainsIgnoreCase('REGISTERED_REP') || objCon.WFG_Type__c.ContainsIgnoreCase('IAR') || ((objCon.WFG_Type__c == 'ASSOCIATE' || objCon.WFG_Type__c == 'LAUNCH') && objCon.WFG_Fiduciary_Advisor__c == TRUE))){
                        
                    if(objUser.contactId == NULL) { //strProfileLicenseName == 'Salesforce'){
                        
                        ObjUser.AgentOne__IsAgentOne__c = TRUE;
                        if(ObjUser.AgentOne__Agent_Number__c != objCon.WFG_AgentCode__c)
                            ObjUser.AgentOne__Agent_Number__c = objCon.WFG_AgentCode__c;
                        if(ObjUser.AgentOne__iPipeline_User_Id__c != objCon.WFG_AgentCode__c)   
                            ObjUser.AgentOne__iPipeline_User_Id__c = objCon.WFG_AgentCode__c;
                        ObjUser.IPL_PS_AGENT_Last_SSN__c = objCon.WFG_SSNSIN__c;
                        ObjUser.AgentOne__SSN_Tax_ID__c = objCon.AgentOne__SSN_Tax_ID__c;
                        ObjUser.AgentOne__Agency_Number__c = '5725'; 
                        
                    }  
                }
                 else{
                    ObjUser.AgentOne__IsAgentOne__c = false;
                    ObjUser.AgentOne__Agent_Number__c = '';
                    ObjUser.AgentOne__iPipeline_User_Id__c = '';
                    ObjUser.IPL_PS_AGENT_Last_SSN__c = '';
                    ObjUser.AgentOne__Agency_Number__c = '';
                    ObjUser.AgentOne__SubCompany_Identifier__c = '';
                    ObjUser.Initial_DisconnectedUserID__c = '';
                    ObjUser.Initial_DisconnectedPassword__c = '';
                    ObjUser.AgentOne__SSN_Tax_ID__c = '';
                }
                
                system.debug('+++++ User Info +++' + objUser);
            }
            return objUser; 
        }catch(Exception e)
        {
            system.debug('Exception in License Handler--' + e);
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_JITHelper', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
            return null;
        }  
       
    }
     /**
     * This method will accept federation ID and returns User associated to this.
     * @return - User
     * @see    - N/A
     * @param  - strFederationId
     * @throws - N/A
     */
    public static User fetchUserContext(string strFederationId)
    {
        List<User> lstUser = [Select id, isActive, WFG_Inactivated_Date__c, contactId, name, WFG_Agent_Code__c, CommunityNickname, username, profileId, userRoleId,FederationIdentifier
            FROM User WHERE FederationIdentifier = : strFederationId];
        if(lstUser != null && !lstUser.isEmpty())
        {
            return lstUser[0];
        }
            
        return null;
    }
    
    /**
     * This method will accept user record and a string and returns User associated to this.
     * @return - User
     * @see    - N/A
     * @param  - user record and a string
     * @throws - N/A
     */
    public static User removeAppendLogic(User currUser, String append){
        currUser.FederationIdentifier = currUser.FederationIdentifier.removeEndIgnoreCase(append);
        currUser.username = currUser.username.removeEndIgnoreCase(append);
        currUser.CommunityNickname = currUser.CommunityNickname.removeEndIgnoreCase(append);
        currUser.WFG_Agent_Code__c = currUser.WFG_Agent_Code__c.removeEndIgnoreCase(append);
        
        return currUser;
    }
    
    /**
     * 
     * @return - N/A
     * @see    - N/A
     * @param  - Contact instance
     * @throws - N/A
     */ 
    @future
    public static void fetchAndUpdateOnboardingCheckist(Id objConId){
        
        list<WFG_Onboarding_Checklist__c> lstOnboardingChecklisttoUpdate = new list<WFG_Onboarding_Checklist__c>();
        for(WFG_Onboarding_Checklist__c objOnboardingChecklist : [select Recruiting_Contact__c, Contact__c, Launch_Accessed__c, id from WFG_Onboarding_Checklist__c where Contact__c =:objConId]){
            
            objOnboardingChecklist.Launch_Accessed__c = true;
            lstOnboardingChecklisttoUpdate.add(objOnboardingChecklist);
        }
        if(!lstOnboardingChecklisttoUpdate.isEmpty())
            update lstOnboardingChecklisttoUpdate;
        
    }
    
}