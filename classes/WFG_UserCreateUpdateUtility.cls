/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author N/A
* @date N/A
* @description - N/A

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Saravanan             Mod-01             02-MAR-2018             Updated the logic to update the user with the contacts updated information.
                                                                 Also update the profile information when the transformation happening 
                                                                 internally between FSC users.    
Rashmi                Mod-02             08-June-2018            Updated the logic to update the profile of the user when 
                                                                 transformation happens with in the community.                                                                       
*/ 
public without sharing class WFG_UserCreateUpdateUtility 
{
  /**
     * This method accepts contact and returns User fo it.
     * @return - User
     * @see    - N/A
     * @param  - Contact
     * @throws - N/A
     */
  public static User getUserForJITHandler(contact objContact)
  {
    List<Id> lstContactId = new List<Id>{objContact.id};
    Map<string, User> mapContactIdVsUser = new map<string, User>();
    mapContactIdVsUser = getUserInstances(lstContactId);
    if(mapContactIdVsUser != null && !mapContactIdVsUser.keyset().isEmpty()
      && mapContactIdVsUser.containskey(objContact.Id)
      && mapContactIdVsUser.get(objContact.Id) != null)
    {
      return mapContactIdVsUser.get(objContact.Id);
    }
    return null;
  }
  /**
     * This method accepts list of contact ID and fetches Profile for them and creates user instances.
     * @return - Map<string, User>
     * @see    - N/A
     * @param  - List Of contact Ids
     * @throws - N/A
     */
  public static Map<string, User> getUserInstances(List<Id> lstContactId)
  {
    List<User> lstUser = new List<User>();
    List<Contact> lstConTobeProcessed = new List<Contact>();
    Map<string, string> mapProfileVsContactID = new Map<string, string>();  
    Map<string, User> mapContactIdVsUser = new Map<string, User>();    
    if(lstContactId != null && !lstContactId.isEmpty())
    {  
      lstConTobeProcessed = [Select id, Name, WFG_CycleType__c,Account.WFG_BranchCode__c,
          WFG_Fiduciary_Advisor__c,WFG_AgentPayType__c,Email, phone,
          FirstName,LastName,title,mailingstreet,mailingstate,mailingCity,
          mailingPostalCode,mailingCountry,Fax,WFG_AgentCode__c,
          WFG_AlternateEmail__c, WFG_FederationId__c,WFG_Type__c,WFG_Email_Verification__c, WFG_SSNSIN__c, AgentOne__SSN_Tax_ID__c, WFG_Channel__c
        FROM Contact WHere ID IN : lstContactId];
      if(lstConTobeProcessed != null && !lstConTobeProcessed.isEmpty())
      {
        mapContactIdVsUser = getUserInstances(lstConTobeProcessed);
      }
    }
    return mapContactIdVsUser;
  }
  /**
     * This method accepts list of contact ID and fetches Profile for them and creates user instances.
     * @return - Map<string, User>
     * @see    - N/A
     * @param  - List Of contact
     * @throws - N/A
     */
  public static Map<string, User> getUserInstances(List<Contact> lstCon)
  {
    List<User> lstUser = new List<User>();
    Map<string, string> mapProfileVsContactID = new Map<string, string>();  
    Map<string, User> mapContactIdVsUser = new Map<string, User>();    
    if(lstCon != null && !lstCon.isEmpty())
    {  
      mapProfileVsContactID = WFG_profileIdentificationMatrix.getProfileId(lstCon);
      system.debug('===============mapProfileVsContactID ============='+mapProfileVsContactID );
      for(contact objCon : lstCon)
      {
        if(mapProfileVsContactID.containskey(objCon.id)
          && mapProfileVsContactID.get(objCon.id) != null)
        {
          User objUser = new User();
          objUser.profileId = mapProfileVsContactID.get(objCon.id);
          mapContactIdVsUser.put(objCon.Id, objUser);
        }
      }
      system.debug('====mapContactIdVsUser===='+mapContactIdVsUser);
    }
    
    return mapContactIdVsUser;
  }
  /**
     * This method accepts list of contact ID and fetches Profile for them and creates/updates users.
     * @return - Map<string, User>
     * @see    - future
     * @param  - List Of contact Ids
     * @throws - N/A
     */
  @future
  public static void insertUsers(List<Id> lstContactIds)
  {
    boolean boolIsError = false;
    Map<string, User> mapContactIdVsUser = new Map<string, User>();
    Set<String> setTermedStatus = new Set<String>{'TERMINATED','VESTED','TERM FOR CAUSE'};
    List<string> lstFedIds = new List<string>();
    List<User> lstuser = new List<User>();
    List<Contact> lstConToBeCreated = new List<Contact>(); 
    Map<Id, WFG_JITHelper.JITResponse> mapObjRes = new Map<Id, WFG_JITHelper.JITResponse>();
    List<User> lstUserToBeInserted = new List<User>();
    List<User> lstUpsertUsers = new List<User>();
    string strErrorMailString = 'Contact Id, Federation Id, User ID, Operation , Error \n';
    try
    {
      if(lstContactIds != null && !lstContactIds.isEmpty())
      {  
        List<Contact> lstConTobeProcessed = [Select id, Name, WFG_Status__c, WFG_CycleType__c,Account.WFG_BranchCode__c, 
          WFG_Fiduciary_Advisor__c,WFG_AgentPayType__c,Email, phone,accountId,
          FirstName,LastName,title,mailingstreet,mailingstate,mailingCity,
          mailingPostalCode,mailingCountry,Fax,WFG_AgentCode__c,WFG_SSNSIN__c,AgentOne__SSN_Tax_ID__c, 
          WFG_AlternateEmail__c, WFG_FederationId__c,WFG_Type__c, WFG_Email_Verification__c, WFG_Channel__c
          FROM Contact WHere ID IN : lstContactIds];
        if(lstConTobeProcessed != null && !lstConTobeProcessed.isEmpty())
        {
          for(Contact objCon : lstConTobeProcessed)
          {
            lstFedIds.add(objCon.WFG_FederationId__c);
          }
          if(lstFedIds != null && !lstFedIds.isEmpty())
          {
            for(User objUser : [Select id, Name, EMail, userName,FederationIdentifier
                from User WHere FederationIdentifier IN :lstFedIds])
            {
              mapContactIdVsUser.put(objUser.FederationIdentifier, objUser);
            }
          }
        }
        for(Contact objCon : lstConTobeProcessed)
        {            
          if(mapContactIdVsUser.containsKey(objCon.WFG_FederationId__c)
            && mapContactIdVsUser.get(objCon.WFG_FederationId__c) != null)
          {
            //Contact already exists for the User
            boolIsError = true;
            strErrorMailString += objCon.id + ',' +objCon.WFG_FederationId__c + ',' + ',Insert,User already exists for the contact. \n';
          }
          else
          {
            //Create User if doesnot exists.
            lstConToBeCreated.add(objCon);
          }
        }
        if(lstConToBeCreated != null && !lstConToBeCreated.isEmpty())
        {
          mapObjRes = WFG_JITHelper.createUser(lstConToBeCreated);
          system.debug('=========mapObjRes======='+mapObjRes);
          if(mapObjRes != null && !mapObjRes.keyset().isEmpty())
          {
            for(Contact objCon : lstConToBeCreated)
            {
              if(mapObjRes.containsKey(objCon.id)
                && mapObjRes.get(objCon.id) != null)
              {
                if(!mapObjRes.get(objCon.id).boolIsError 
                  && mapObjRes.get(objCon.id).objUser != null)
                {
                    User relateduser = mapObjRes.get(objCon.id).objUser;
                    //create user as inactive, if contact has a termed status
                    if(setTermedStatus.contains(objCon.WFG_Status__c)){
                        relateduser.isActive = false;
                    } else{                        
                        relateduser.isActive = true;
                    }

                    lstUserToBeInserted.add(relateduser);
                }
                else
                {
                  boolIsError = true;
                                    strErrorMailString += objCon.id + ',' +objCon.WFG_FederationId__c + ',' + ',Insert,'+ mapObjRes.get(objCon.id).strErrMsg + ' \n';
                }
              }
              else
              {
                boolIsError = true;
                                strErrorMailString += objCon.id + ',' +objCon.WFG_FederationId__c + ',' + ',Insert,User instance could not be generated properly \n';
              }
            }
            if(lstUserToBeInserted != null && !lstUserToBeInserted.isEmpty())
            {
              lstUpsertUsers.addAll(lstUserToBeInserted);
            }
          }
          else
          {
            boolIsError = true;
            for(Contact objCon : lstConTobeProcessed)
            {
              strErrorMailString += objCon.id + ',' +objCon.WFG_FederationId__c + ',' + ',Insert,User instance could not be generated properly \n';
            }
          }
        }
        if(lstUpsertUsers != null && !lstUpsertUsers.isEmpty())
        {
          Database.upsertResult[] lstSvRes = Database.upsert(lstUpsertUsers, false);
          // Iterate through each returned result
          integer intVar = 0;
          List<User> lstAssUser = new List<User>();
          for (Database.upsertResult objSvres : lstSvRes) 
          {
              if (!objSvres.isSuccess()) 
              {  
                boolIsError = true;
                string strErrors = '';            
                  for(Database.Error objError : objSvres.getErrors()) 
                  {
                      strErrors += objError.getStatusCode() + ' : ' + objError.getMessage();
                  }
                            strErrorMailString += ',' +lstUpsertUsers[0].Federationidentifier + ',' + ',Insert,'+strErrors+' \n';             
              }
              else
              {
                lstAssUser.add(lstUpsertUsers[intVar]);
              }
              intVar ++ ;
          }
          //if(lstAssUser != null && !lstAssUser.isEMpty()) assignPermissionset(lstAssUser);
        }
      }
    }
    catch(Exception e)
    {
      boolIsError = true;
      strErrorMailString = 'Error while Processing : "' + e.getMessage() +'"';
    }
    finally
    {
      exceptionHandler(boolIsError,strErrorMailString);
    }
  }
  /**
     * This method accepts list of contact IDs,Map of Old and New contact profiles and fetches Profile for contacts and creates/updates users.
     * @see    - future
     * @param  - List Of contact Ids,Map of Old and New contact profiles
     * @throws - N/A
     */
  @future
    public static void updateUser(Set<Id> contactIds, map<string, string> newContactProfiles)
    {
        system.debug('=====contactIds===='+contactIds);
        system.debug('=====newContactProfiles===='+newContactProfiles);

        boolean boolIsError = false;
        Map<String, User> mapFedUser = new Map<String, User>();
        Set<String> setTermedStatus = new Set<String>{'TERMINATED','VESTED','TERM FOR CAUSE'};
        set<String> setFedIds = new set<String>();
        list<User> lstUserUpsert = new list<User>();
        list<Contact> lstContactsWithoutUser = new list<Contact>();
        Map<Id, WFG_JITHelper.JITResponse> mapObjRes = new Map<Id, WFG_JITHelper.JITResponse>();
        Map<Id,Profile> mapProfiles = new Map<id,profile>([SELECT Id,UserLicense.Name FROM Profile]);
        string strErrorMailString = 'Contact Record ID, Federation ID, User ID,  Operation, Error \n';
        
        try{
            list<Contact> lstContact = new list<Contact>();
            
            //Used to fetch all the contacts for the specific ids of the set
            for(Contact con : [Select id, Name, WFG_CycleType__c, Account.WFG_BranchCode__c, WFG_Fiduciary_Advisor__c,WFG_AgentPayType__c,Email, phone,accountId, FirstName,LastName,title,mailingstreet,mailingstate,mailingCity, mailingPostalCode,mailingCountry,Fax,WFG_AgentCode__c, WFG_Status__c, WFG_AlternateEmail__c, WFG_FederationId__c,WFG_Type__c,WFG_Email_Verification__c,WFG_Home_Office_Agent__c, WFG_SSNSIN__c, AgentOne__SSN_Tax_ID__c, WFG_Channel__c FROM Contact WHere ID IN : contactIds]){
                lstContact.add(con);
                setFedIds.add(con.WFG_FederationId__c);
                setFedIds.add(con.WFG_FederationId__c+'_FSC');
                setFedIds.add(con.WFG_FederationId__c+'_comm');
            }
            
            system.debug('===setFedIds===='+setFedIds);
            Map<String, Id> mapRoles = new map<string, Id>();
            for(UserRole roleId : [select Id, name from UserRole WHere name = 'Registered Reps' OR name = 'Life License Agents'] ){
                mapRoles.put(roleId.Name, roleId.id);
            }
            
            //Used to query and fetch federationIdentifier of all the users and put them in the map
            for(User usr : [Select id, Name, ContactId, EMail, ProfileId, CommunityNickname, WFG_Agent_Code__c , userName,FederationIdentifier,isActive from User WHere FederationIdentifier IN :setFedIds])
                mapFedUser.put(usr.FederationIdentifier, usr);
                
            for(Contact con : lstContact){
                //fetches the related user for if the contact's federation id is present in the keyset of map.
                User relateduser = mapFedUser.get(con.WFG_FederationId__c);                
                system.debug('===relateduser==='+relateduser);
                if(relateduser == NULL){
                    //Satisfies if the contact's wfg type is associate/Launch and not fidicuary advisor checked
                    if((con.WFG_Type__c.containsIgnoreCase(Label.WFG_Associate) || (con.WFG_Type__c.containsIgnoreCase(Label.WFG_Launch))) && !con.WFG_Fiduciary_Advisor__c)
                        relateduser = mapFedUser.get(con.WFG_FederationId__c+'_comm');
                    else
                        relateduser = mapFedUser.get(con.WFG_FederationId__c+'_FSC');
                }
                if(relateduser != NULL){
                    //Satisfies if the contact's status is 'active' and fidicuary advisor checked and if true then activates the user
                    if(system.label.WFG_UserCreationContactStatus.containsIgnoreCase(con.WFG_Status__c) && con.WFG_Fiduciary_Advisor__c){
                        relateduser.isActive = true;
                        relateduser = WFG_JITHelper.removeAppendLogic(relateduser, '_FSC');
                    }
                    relateduser = WFG_JITHelper.fetchContactData(relateduser, con, NULL);
                    //system.debug('====relateduser ==22===='+relateduser.street);
                    //Satisfies if the related profile id is not equal to newer contact's profile id
                    if(relateduser.ProfileId != newContactProfiles.get(con.Id)){
                        relateduser.ProfileId = newContactProfiles.get(con.Id);
                        
                        //Satisfies if it is contact's fiduciary advisor is true and status is 'Active' and if true then activates the user and removes the FSC append else inactivate the user and append the FSC 
                        if((!con.WFG_Fiduciary_Advisor__c || !system.label.WFG_UserCreationContactStatus.containsIgnoreCase(con.WFG_Status__c)) && (!con.WFG_Type__c.containsIgnoreCase(Label.WFG_Associate) && (!con.WFG_Type__c.containsIgnoreCase(Label.WFG_Launch)))){
                            relateduser.isActive = false;
                            relateduser = WFG_UserLicense_Handler.appendLogic(relateduser, '_FSC');
                        }
                        else if(con.WFG_Type__c.containsIgnoreCase(Label.WFG_Associate) || (con.WFG_Type__c.containsIgnoreCase(Label.WFG_Launch))){
                            relateduser.isActive = false;
                            relateduser = WFG_UserLicense_Handler.appendLogic(relateduser, '_comm');
                        }
                    }
                                 
                    //Satisfies if any of the contact's status contains in setTermedStatus set and if true then inactivate the related user                                         
                    if(setTermedStatus.contains(con.WFG_Status__c)){
                        relateduser.isActive = false;
                        
                        //Satisfies if the user has contact and if true then appendlogic is updated to assoicate/launch users else FSC users
                        if(relateduser.ContactId != NULL)
                            relateduser = WFG_UserLicense_Handler.appendLogic(relateduser, '_comm');
                        else
                            relateduser = WFG_UserLicense_Handler.appendLogic(relateduser, '_FSC');
                    }
                    
                    if((!con.WFG_Type__c.ContainsIgnoreCase(Label.WFG_Associate)&& (!con.WFG_Type__c.ContainsIgnoreCase(Label.WFG_Launch))) && con.WFG_Type__c.ContainsIgnoreCase(Label.WFG_Contact_Agent) && !con.WFG_Fiduciary_Advisor__c){
                        relateduser.userRoleId = mapRoles.get('Life License Agents');
                    } else if(!con.WFG_Type__c.ContainsIgnoreCase(Label.WFG_Associate)&& (!con.WFG_Type__c.ContainsIgnoreCase(Label.WFG_Launch))){
                        relateduser.userRoleId = mapRoles.get('Registered Reps');
                    }
                    
                    system.debug('=====con.WFG_Home_Office_Agent__c===='+con.WFG_Home_Office_Agent__c);
                    if(con.WFG_Home_Office_Agent__c && con.WFG_AgentPayType__c!= 'TAN')
                        relateduser.UserPermissionsSupportUser = true;
                    else
                        relateduser.UserPermissionsSupportUser = false;
                    
                    lstUserUpsert.add(relateduser);
                } 
                else if(system.label.WFG_UserCreationContactStatus.containsIgnoreCase(con.WFG_Status__c) && ((!con.WFG_Type__c.containsIgnoreCase(Label.WFG_Associate) && !con.WFG_Type__c.containsIgnoreCase(Label.WFG_Launch)) || con.WFG_Fiduciary_Advisor__c))
                {
                    //When there are no users found then this list will be used to create the users
                    lstContactsWithoutUser.add(con);
                }
            }
                        
            if(lstContactsWithoutUser.size() > 0){
                mapObjRes = WFG_JITHelper.createUser(lstContactsWithoutUser);
                
                for(Contact con : lstContactsWithoutUser){
                    WFG_JITHelper.JITResponse res = mapObjRes.get(con.id);
                    
                    String strAppend = '';
                    
                    if(res != NULL && res.objUser != NULL && !res.boolIsError){
                        User relateduser = res.objUser;
                        
                        //Satisfies if the user contains the profile with license name as 'Community'
                        if(mapProfiles.get(relateduser.ProfileId).UserLicense.Name.contains('Community'))
                            strAppend = '_comm';
                        else
                            strAppend = '_FSC';
                        
                        //Satisfies if contact's fiduciary advisor is true and status is active and if true then activates the user else will deactivate the user by appending FSC to the respective fields
                        if(con.WFG_Fiduciary_Advisor__c)
                            relateduser.isActive = true;  
                        else {
                            relateduser = WFG_UserLicense_Handler.appendLogic(relateduser, strAppend);
                        }  
                        
                        //Satisfies if the contact's email verification is true and alternate email contains some value
                        if(con.WFG_Email_Verification__c && con.WFG_AlternateEmail__c != NULL){
                            relateduser.WFG_Email_Verification__c = true;
                            
                            //Satisifies if the sandbox type is PROD and the username is set accordingly
                            if(system.label.WFG_SandboxType != 'PROD')
                                relateduser.userName = con.WFG_AlternateEmail__c + '.' + system.label.WFG_SandboxType;
                            else
                                relateduser.userName = con.WFG_AlternateEmail__c;
                        }
                        lstUserUpsert.add(relateduser);
                    } else if(res != NULL && res.boolIsError){
                        boolIsError = true;
                        strErrorMailString += con.id + ',' +con.WFG_FederationId__c + ',' + ',Insert,'+ res.strErrMsg + ' \n';
                    } else {
                        boolIsError = true;
                        strErrorMailString += con.id + ',' +con.WFG_FederationId__c + ',' + ',Insert,User instance could not be generated properly \n';
                    }
                }
            }
            if(lstUserUpsert.size() > 0){
                Database.upsertResult[] lstSvRes = Database.upsert(lstUserUpsert, false);
                for (Database.upsertResult objSvres : lstSvRes) 
                {
                    if (!objSvres.isSuccess()) 
                    { 
                        boolIsError = true; 
                        string strErrors = ''; 
                        Integer intVar = 0;             
                        for(Database.Error objError : objSvres.getErrors()) 
                        {
                            strErrors += objError.getStatusCode() + ' : ' + objError.getMessage();
                        }
                        strErrorMailString +=   ',' +lstUserUpsert[intVar].federationidentifier + ',' + ',UPdate,"' + strErrors +'" \n';
                    }
                   
                    
                }
            }
        }
        catch(Exception e)
        {
            boolIsError = true;
            strErrorMailString = 'Error while Processing : "' + e.getMessage() +'"';
            system.debug('+++++++excep -' + e.getMessage());
            system.debug('+++++++excep -' + e.getStackTraceString());
        }
        finally
        {
           exceptionHandler(boolIsError,strErrorMailString);
        }
    }
    
  @TestVisible
  private static void exceptionHandler(boolean boolIsError,string strErrorMailString)
  { 
        if(boolIsError )
      {
        Integer used = Limits.getEmailInvocations();
        Integer emailLimit = Limits.getLimitEmailInvocations();
        if(used >= emailLimit){
          return;
        }
        if(System.Label.WFG_SendErrorEmail == 'true' || Test.isRunningTest())
        {
          Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
          blob csvBlob = Blob.valueOf(strErrorMailString);
          string csvname= 'Error_' + system.now() + '.csv';
          csvAttc.setFileName(csvname);
          csvAttc.setBody(csvBlob);
          Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
          String subject ='Contact Update Activity Status : ' + system.now();
          email.setSubject(subject);
          email.setTargetObjectId(system.Label.WFG_toAddresses);
          email.setSaveAsActivity(false);
          email.setPlainTextBody('Please find attached sheet containing error logs.');
          email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
          Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
      }  
  }
  
  
  /*public static void assignPermissionset(List<User> listUsers)
  {
    List<PermissionSetAssignment> lstPermissionsetAssignment = new List<PermissionSetAssignment>();
    List<PermissionSetAssignment> lstPermissionsetAssignmentExst = new List<PermissionSetAssignment>();
    set<Id> setProfileIds = new set<ID>();
    map <Id, PermissionSetAssignment> mapPermission = new map <Id, PermissionSetAssignment>();
    set<Id> setInternalProfileIds = new set<ID>();

    for(Profile objProfile : [Select id, Name from Profile Where (name IN : WFG_FAProfileNames__c.getAll().keyset()
        OR name IN : WFG_RRProfileNames__c.getAll().keyset())])
      setInternalProfileIds.add( objProfile.id );
    
    
    if(listUsers != null && !listUsers.isEmpty())
    {
      for(User objUser: listUsers)
      {
        mapPermission.put(objUser.id,null);        
      }
      if(mapPermission != null && !mapPermission.keyset().isEmpty())
      {
        for(PermissionSetAssignment objPerSet:[Select Id, PermissionSetId,AssigneeId
          from PermissionSetAssignment
          WHERE AssigneeId IN : mapPermission.keyset() AND PermissionSetId = :system.Label.WFG_Advisor_Access])
        {
          mapPermission.put(objPerSet.AssigneeId, objPerSet);
        }
      }
      for(User objUser: listUsers)
      {
        if(setInternalProfileIds.contains(objUser.profileId))
        {
          if(!mapPermission.containskey(objUser.id) || mapPermission.get(objUser.id) == null)
            lstPermissionsetAssignment.add(new PermissionSetAssignment(PermissionSetId = system.Label.WFG_Advisor_Access,
              AssigneeId = objUser.id));
        }
      }
      if(lstPermissionsetAssignment != null && !lstPermissionsetAssignment.isEmpty())
      {
        
        Database.saveResult[] lstSvRes = Database.insert(lstPermissionsetAssignment, false);
      }
    }
  }*/
  
  
}