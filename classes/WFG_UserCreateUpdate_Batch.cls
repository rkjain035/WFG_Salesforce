/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Deepthi
* @date 13-03-2018
* @description - This batch class contains logic to deactivate existing LL/MF users in the application and 
                 create new user records with profiles(FSC).

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Deepthi               Mod-01             13-03-2018              UserStoryNo - W025898,W025899
*/
global class WFG_UserCreateUpdate_Batch Implements Database.Batchable<sObject> {
    
    List<sObject> lstusersToDeactivate = new List<sObject>();
    List<User> lstcreateNewUsers = new List<User>();
    List<sObject> lstUsertobeInserted = new list<sObject>();
    List<sObject> lstUsertobeUpdated = new list<sObject>();
    Map<string, string> mapProfileVsContactID = new Map<string, string>();
    Map<string, User> mapFedIdVsUser = new Map<string, User>();
    Map<String, Id> mapRole = new map<string, Id>();        
    Set<Id> setcontactIds = new Set<Id>();
    set<string> setFedIds = new set<string>();
    set<id> setCommunityProfileId  = new set<Id>();
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Querying user records.
        String strVal = 'Partner Community';
        String strLimit = Label.WFG_UserCreateUpdateBatchLimit;
        String strQuery;
        if(test.isRunningTest())
            strLimit = '3';
           
        if(strLimit != '0'){
            system.debug('If');
            strQuery = 'Select id, FederationIdentifier, ProfileId, isActive,contactId, isPortalEnabled,Username,CommunityNickname,Email,Profile.UserLicense.Name, WFG_Agent_Code__c'+ 
            ' from user' +
            ' where Profile.UserLicense.Name=\''+ strVal +'\' AND isPortalEnabled=true AND FederationIdentifier!=null AND WFG_Agent_Code__c != NULL LIMIT' + ' '+strLimit;
            // fetching Partner community users
        }
        else{
            system.debug('Else');
            strQuery = 'Select id, FederationIdentifier, ProfileId, isActive,contactId, isPortalEnabled,Username,CommunityNickname,Email,Profile.UserLicense.Name, WFG_Agent_Code__c'+ 
            ' from user' +
            ' where Profile.UserLicense.Name=\''+ strVal +'\' AND isPortalEnabled=true AND FederationIdentifier!=null AND WFG_Agent_Code__c != NULL ';
        }                        
        system.debug('===queryStr==='+strQuery);
        return Database.getQueryLocator(strQuery);        
    }
    
    public void execute(Database.BatchableContext BC, List<User> scope){
                          
        User objCurrentUser = [Select id, name, LocaleSidKey, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey 
            FROM User WHERE user.name = 'System' limit 1];
                
        for(UserRole roleId : [select Id, name from UserRole WHere name ='Registered Reps' OR name ='Life License Agents'] ){
            mapRole.put(roleId.Name, roleId.id); //getting the role for creating new users
        }        
        
        for(Profile objProfile : [select id from Profile where Name ='WFG Support Customer Community Plus Login']){
            
            setCommunityProfileId.add(objProfile.id);
        }
                
        for(User uObj : scope){ //traversing the Partner community users
            System.debug('Is user comin.....'+uObj.Id);
            setcontactIds.add(uObj.ContactId); // Partner community contact
            
            if(uObj.FederationIdentifier.contains('_comm')){ // if there are inactive partner users
                setFedIds.add(uObj.FederationIdentifier.removeEnd('_comm') + '_fsc'); 
                setFedIds.add(uObj.FederationIdentifier.removeEnd('_comm')); 
                setFedIds.add(uObj.FederationIdentifier); // fetching both active and inActive FSC users
            }
            else { // if there are active partner users
                setFedIds.add(uObj.FederationIdentifier + '_fsc'); 
                setFedIds.add(uObj.FederationIdentifier);
            }
        }
        //Fetch all contacts in scope for User Transformation.
        List<Contact> Contacts = [select id, firstname, lastname,WFG_FederationId__c,WFG_AgentCode__c, mailingcountry, mailingstreet, mailingstate, WFG_AgentID__c,WFG_Type__c,WFG_AgentPayType__c,WFG_CycleType__c,mailingpostalCode, MailingCity, Fax, email, phone, 
                                       WFG_Fiduciary_Advisor__c,WFG_Email_Verification__c,WFG_AlternateEmail__c 
                                  from contact 
                                  where Id IN: setcontactIds];
        //Fetch if any existing FSC users to be updated
        List<User> lstExistingFSCUsers = [select id, name, federationidentifier from user 
                                          where 
                                          profile.userlicense.name = 'Salesforce' and federationidentifier IN: setFedIds];
        if(!lstExistingFSCUsers.isEmpty())
        {
            for(User exUser : lstExistingFSCUsers )
            {
                System.debug('users to be updated...'+exUser.id);
                mapFedIdVsUser.put(exUser.FederationIdentifier, exUser);
            }
        }
        
        //code to fetch list of user instances by passing contact list - Start.
        mapProfileVsContactID = WFG_profileIdentificationMatrix.getProfileId(Contacts);
        system.debug('ProfileId'+mapProfileVsContactID.keySet());
        for(contact objCon : Contacts)
          {
            if(mapProfileVsContactID.containskey(objCon.id) && !setCommunityProfileId.contains(mapProfileVsContactID.get(objCon.id)))//&& mapProfileVsContactID.get(objCon.id) != null
            {   
                
                User objUser = new User();
                objUser.userRoleId = mapRole.get('Life License Agents');
                objUser = WFG_JITHelper.fetchContactData(objUser,objCon,objCurrentUser);  
                objUser.profileId = mapProfileVsContactID.get(objCon.id);                        
                objUser.IsActive = true;
                //check if a FSC user exist with same federation Id or appended with _fsc
                if(mapFedIdVsUser.containsKey(objCon.WFG_FederationId__c) && mapFedIdVsUser.containsKey(objCon.WFG_FederationId__c)!= null )
                {
                    //User existingUser = mapFedIdVsUser.get(objCon.WFG_FederationId__c);
                    //existingUser.IsActive = true;
                    objUser.Id = mapFedIdVsUser.get(objCon.WFG_FederationId__c).id;
                    lstUsertobeUpdated.add(objUser);
                }
                else if(mapFedIdVsUser.containsKey(objCon.WFG_FederationId__c + '_fsc') && mapFedIdVsUser.containsKey(objCon.WFG_FederationId__c  + '_fsc')!= null )
                {
                    //User existingUser = mapFedIdVsUser.get(objCon.WFG_FederationId__c + '_fsc');
                    //existingUser.IsActive = true;
                    objUser.Id = mapFedIdVsUser.get(objCon.WFG_FederationId__c + '_fsc').id;
                    lstUsertobeUpdated.add(objUser);
                }
                else
                {                    
                    lstUsertobeInserted.add(objUser);                    
                    system.debug('Users to be inserted:'+lstUsertobeInserted);
                }
            }
          }
           system.debug('Users to be inserted:'+lstUsertobeInserted);   
          //code to fetch list of user instances by passing contact list - End.
                   
        //Deactivate users by appending user fields with hexadigit value.
        for(User usr: scope){            
                system.debug('Deactivate LL/MF Users');
                String strHexDigitAppend = generateHexaDigitCode();
                usr.isActive = false; 
                usr.isPortalenabled = false;
                
                usr.FederationIdentifier = usr.FederationIdentifier + strHexDigitAppend;
                usr.username = usr.username + strHexDigitAppend ;
                usr.CommunityNickname = usr.CommunityNickname + strHexDigitAppend;
                if(usr.CommunityNickname.length() >= 40)
                    usr.CommunityNickname = usr.CommunityNickname.substring(0,39);
                usr.WFG_Agent_Code__c = usr.WFG_Agent_Code__c + strHexDigitAppend;              
                usr.WFG_UTCheck__c = true;
                lstusersToDeactivate.add(usr);   
            system.debug('Users to Deactivate:'+lstusersToDeactivate);
        }        
        try{
            if(!lstusersToDeactivate.isEmpty()){
                 Database.SaveResult[] deactivateUser = Database.update(lstusersToDeactivate,false );
            for (Integer i = 0; i < deactivateUser.size(); i++) {
                if (deactivateUser[i].isSuccess()) {
                System.debug('Successfully Updated ID: ' + deactivateUser[i].getId());
                } else {
                System.debug('Error: could not update sobject ' + 'for array element ' + i + '.');
                System.debug('   The error reported was: ' + deactivateUser[i].getErrors()[0].getMessage() + '\n');
                LogUtility.createLog('EXCEPTION','WFG_UserCreateUpdate_Batch','Error during update', 'Error', deactivateUser[i].getErrors()[0].getMessage(), 'Error');   
                }
            }
                //update lstusersToDeactivate;
            }
                       
            if(!lstUsertobeUpdated.isEmpty()){
                //update lstUsertobeUpdated;
                Database.SaveResult[] updateUserresults = Database.update(lstUsertobeUpdated,false );
            for (Integer i = 0; i < updateUserresults.size(); i++) {
                if (updateUserresults[i].isSuccess()) {
                System.debug('Successfully Updated ID: '+ updateUserresults[i].getId());
                } else {
                System.debug('Error: could not update sobject ' + 'for array element ' + i + '.');
                System.debug('   The error reported was: ' + updateUserresults[i].getErrors()[0].getMessage() + '\n');
                LogUtility.createLog('EXCEPTION','WFG_UserCreateUpdate_Batch','Error during update', 'Error', updateUserresults[i].getErrors()[0].getMessage(), 'Error');   
                }
            }
            }
                       
            if(!lstUsertobeInserted.isEmpty()){
                //insert lstUsertobeInserted;
                Database.SaveResult[] insertUsersresult = Database.insert(lstUsertobeInserted, false);
                for (Integer i = 0; i < insertUsersresult.size(); i++) {
                    if (insertUsersresult[i].isSuccess()) {
                    System.debug('Successfully created ID: '
                          + insertUsersresult[i].getId());
                    } else {
                        System.debug('Error: could not create sobject '
                              + 'for array element ' + i + '.');
                        System.debug('   The error reported was: '
                              + insertUsersresult[i].getErrors()[0].getMessage() + '\n');
                        LogUtility.createLog('EXCEPTION','WFG_UserCreateUpdate_Batch','Error during Insert', 'Error', insertUsersresult[i].getErrors()[0].getMessage(), 'Error');   
                    }
                }
            }
         }catch(Exception e)
            {
                system.debug('Exception in User Create Update Batch--' + e);
                LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_UserCreateUpdate_Batch', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
            } 
    }
     
    public void finish(Database.BatchableContext BC){
        
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