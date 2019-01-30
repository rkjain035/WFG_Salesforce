/*
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Mruga Shastri
* @date 7-Dec-2016
* @description - Trigger Handler for the Trigger WFG_Contact

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Saravanan             MOD-01             26-FEB-2018             Updated User Transformation logic for PC to FSC Conversion. Updated the 
                                                                 logic of user creation. Only FSC users will be created/Updated. Community 
                                                                 users will not be created from Contact.
Rashmi                MOD-02             11-June-2018            Updated user transformation logic with in the 
                                                                 customer community.   

Rashmi                MOD-03             14/11/2018              W-028007 Added logic to check duplicate individual within the list 
                                                                 of records inserted/updated, logic to check duplicate againt perticular record type 
                                                                 based on FirstName, LastName, Email and Owner for Individual and AgentCode for Agent. Also merged all the duplicate check methods.                                                          
*/      

public with sharing class WFG_Contact_Handler{
/**
@author Mruga Shastri
@date 7-Dec-2016
@description Executed on Trigger Context - Before Insert. Collects the list of Service center contacts being Inserted & checks for Duplicate Agent Code. 
*/
    public static void beforeInsert(){
        
        try{

          /*  //@samit: code added to check duplicate Contact
            checkDuplicateContact();
            //end of code to check duplicate Contact.

            //code added to insert state and country while improting
            
            //end of code to insert state and country code while importing
            List<Contact> lstContact = new List<Contact>();
            List<Contact> lstContactWhileUpload = new List<Contact>();
            lstContact =  getAgentContacts(Trigger.New);
            if(!lstContact.isEmpty()){
              System.debug('Trigger.NewMap : '+ trigger.newMap + ' Trigger.OldMap : ' + trigger.oldmap + 'trigger.New' + trigger.new);
              System.debug('Type casted Trigger Map : ' + (Map<Id, Contact>)Trigger.NewMap); 
              lstContactWhileUpload = checkWhileUpload(trigger.isUpdate, lstContact, (Map<Id, Contact>)trigger.newMap,(Map<Id, Contact>)trigger.oldMap);
            }
            if(!lstContactWhileUpload.isEmpty()){
              checkInDB(trigger.isInsert, trigger.isUpdate, lstContactWhileUpload, (Map<Id, Contact>)trigger.newMap,(Map<Id, Contact>)trigger.oldMap);*/
            CheckDuplicateForAgentandIndividualContacts(trigger.isInsert, false, trigger.new, new Map<Id, Contact>());
            insertStateCountryCode();
        }catch(Exception e){
            system.debug('Exception in License Handler--' + e);
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_Contact_Handler', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }
        
    }
    
    public static void afterInsert(List<Contact> lstContact, map<id, Contact> mapNewContact,  map<id, Contact> mapOldContact)
    {
      insertUsers(lstContact,mapNewContact,mapOldContact);
    }
    
    public static void afterupdate(List<Contact> lstContact, List<Contact> lstContactOld, map<id, Contact> mapNewContact, map<id, Contact> mapOldContact)
    {
      //updateUsers(lstContact,mapNewContact,mapOldContact);
      updateUsers(lstContact,lstContactOld,mapNewContact,mapOldContact);
      //Check for type UPdate
      //  if(system.Label.WFG_ContactTypeChangeNotification == 'true') notifyUserWhenContactUpdate((map<Id, Contact>)trigger.newMap, (map<Id, Contact>)trigger.oldMap);
    }

/**
@author Mruga Shastri
@date 7-Dec-2016
@description Executed on Trigger Context - Before Update. Collects the list of Service center contacts being Inserted & checks for Duplicate Agent Code. 
*/
    public static void beforeUpdate(){
    
        try{
        
          /*//@samit: code added to check duplicate Contact
          checkDuplicateContact();
          //end of code to check duplicate Contact.
          System.debug('Before contact update');
           //code added to insert state and country while improting
          insertStateCountryCode();
          //end of code to insert state and country code while importing
          List<Contact> lstContact = new List<Contact>();
          List<Contact> lstContactWhileUpload = new List<Contact>();
          lstContact =  getAgentContacts(Trigger.New);
          if(!lstContact.isEmpty()){
              System.debug('Before Contact Update List Empty');
              lstContactWhileUpload = checkWhileUpload(trigger.isUpdate, lstContact,(Map<Id, Contact>) trigger.newMap,(Map<Id, Contact>)trigger.oldMap);
          }
          if(!lstContactWhileUpload.isEmpty()){
              System.debug('Before Contact Update List While Upload');
              checkInDB(trigger.isInsert, trigger.isUpdate, lstContactWhileUpload, (Map<Id, Contact>)trigger.newMap,(Map<Id, Contact>)trigger.oldMap);
          }*/
          
          insertStateCountryCode();
            
          CheckDuplicateForAgentandIndividualContacts(false, trigger.isUpdate, trigger.new, (Map<Id, Contact>)trigger.oldMap);
          
          updateContactUserProfile((list<Contact>) trigger.new, (Map<Id, Contact>)trigger.oldMap);
        }catch(Exception e){
            system.debug('Exception in License Handler--' + e);
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_Contact_Handler', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }
    }

    
    /**
    @author Mruga Shastri
    @date 7-Dec-2016
    @description Collects the list of Service center contacts. (Contacts with RecordType - Agent)
    @Return List<Contact> - List of contacts with with RecordType - Agent
    */
 /*   private static List<Contact> getAgentContacts(List<Contact> lstnewContact){
    
        
      Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Label.WFG_Contact_Agent).getRecordTypeId();
      List<Contact> lstContacts = new List<Contact>();
     
        for(Contact co : lstnewContact){
            if(co.RecordTypeId == recordTypeId)
            {
                lstContacts.add(co);
            }
        }
        return lstContacts; 
    }*/

/**
@author Mruga Shastri
@date 7-Dec-2016
@description Makes a map of Contacts with a Unnique Agent code out of the list of Agent Contacts. 
@Return List<Contact> - List of contacts with Unique Agent codes. 
*/
   /* private static List<Contact> checkWhileUpload(boolean isUpdate, List<Contact> listCont, Map<Id, Contact> mapNew, map<Id, Contact> mapOLd){
        
                 List<Contact> listContValid = new List<Contact>();
                 Map<string, Integer> mapUniuqKey = new Map<string , Integer>();
                 for(Contact con : listCont){
                      if(!mapUniuqKey.containsKey(con.WFG_AgentCode__c)){
                        mapUniuqKey.put(con.WFG_AgentCode__c, 0);               
                        listContValid.add(con);
                      }
                      else{
                        con.AddError('Agent Code must be unique');
                      }                                                        
                 }
              return listContValid;
        
    }*/

/**
@author Mruga Shastri
@date 7-Dec-2016
@description Makes a map of Contacts with a Unnique Agent code out of the list of Agent Contacts.  
*/
/* private static void checkInDB(boolean boolIsInsert, boolean boolIsUpdate, List<Contact> lstContact, Map<Id, Contact> mapNewContact, Map<Id, Contact> mapOldContact){
    try{
         List<Contact> listContForNext = new List<Contact>();
         List<Contact> listEligible = new List<Contact>();
         Map<String, Integer> mapAgentCode = new map<String, Integer>();
         Contact oldContact = new Contact(); 
         Contact newContact = new Contact(); 
         for(Contact con: lstContact){
          if(boolIsUpdate){
              if(mapOldContact!= null && !mapOldContact.isEmpty() ){
               oldContact = (contact)mapOldContact.get(con.id);
              }
              if(!mapNewContact.isEmpty() && mapNewContact != null ){
                newContact = (contact)mapNewContact.get(con.id);
              }
            
              if(oldContact.WFG_AgentCode__c <> newContact.WFG_AgentCode__c){
                listEligible.add(con);
                mapAgentCode.put(con.WFG_AgentCode__c,0);

             }

          }

          if(boolIsInsert){
            
            listEligible.add(con);
            mapAgentCode.put(con.WFG_AgentCode__c,0);

          }


         }
         if(listEligible != null && !listEligible.isEmpty()){
                       for(Contact con: [Select id, Name, WFG_AgentCode__c from Contact WHere WFG_AgentCode__c IN : mapAgentCode.keyset()]){
                                      if(mapAgentCode.get(con.WFG_AgentCode__c) == 0){
                                                    Integer iCount = mapAgentCode.get(con.WFG_AgentCode__c);
                                                    mapAgentCode.put(con.WFG_AgentCode__c,++iCount);
                                      }
                       }
                       if(mapAgentCode != null && !mapAgentCode.isEMPty())
                       {
                                      for(Contact con: listEligible ){
                                                    if(mapAgentCode.containsKey(con.WFG_AgentCode__c) && mapAgentCode.get(con.WFG_AgentCode__c) > 0){
                                                                  con.WFG_AgentCode__c.AddError('Agent Code must be unique');
                                                    }
                                      }
                       }
                       
         }
        }catch(Exception e)
        {
            system.debug('Exception in License Handler--' + e);
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_Contact_Handler', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }                                   
    }
    */
    
    /**
    @author Samit Bhoumick
    @date 6-Jan-2017
    @description: Checks for Duplicate Contact.
    */
   /* private static void checkDuplicateContact()
    {
        try{
            Set<String> setFirstName = new Set<String>();
            Set<String> setLastName = new Set<String>();
            Set<String> setEmail = new Set<String>();
            List<Contact> lstApplicableContact = new List<Contact>();
            for(Contact objContact: (List<Contact>)Trigger.New)
            {
                if(Trigger.isInsert)
                {
                    setFirstName.add(objContact.FirstName);
                    setLastName.add(objContact.LastName);
                    setEmail.add(objContact.Email);
                    lstApplicableContact.add(objContact);
                }
                else if(Trigger.isUpdate)
                {
                    Contact objOldContact = (Contact)Trigger.oldMap.get(objContact.Id);
                    if(objContact.FirstName != objOldContact.FirstName || objContact.LastName != objOldContact.LastName
                            || objContact.Email != objOldContact.Email)
                    {
                        setFirstName.add(objContact.FirstName);
                        setLastName.add(objContact.LastName);
                        setEmail.add(objContact.Email);
                    }
                    lstApplicableContact.add(objContact);
                }
            }
                
            if(!lstApplicableContact.isEmpty())
            {
                for(Contact objAvailableContact: [SELECT Id, Name, FirstName, LastName, Email FROM Contact 
                                                    WHERE OwnerId =: UserInfo.getUserId() AND
                                                    FirstName IN : setFirstName AND
                                                    LastName IN: setLastName AND
                                                    Email IN: setEmail
                                                    AND RecordType.Name = 'Individual'])
                {
                    for(Contact objContact: lstApplicableContact)
                    {
                        if(objContact.FirstName == objAvailableContact.FirstName && objContact.LastName == objAvailableContact.LastName
                                && objContact.Email == objAvailableContact.Email)
                        {
                            objContact.addError(Label.WFG_DuplicateContactError.replace('[ContactName]',objAvailableContact.Name));
                        }
                    }
                }
            } 
        }catch(Exception e)
        {
            system.debug('Exception in License Handler--' + e);
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_Contact_Handler', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }   
    }*/
    
    /*
    This method is executed in the after update trigger.
    This methods check if the user name, email, phone is update and update the related user record. If no users found it will only create a inactive FSC users.
    */
    public static void updateUsers(List<Contact> lstContact, List<Contact> lstContactOld, map<id, contact> mapNewContact, map<id, contact> mapOldContact)
    {
        try{
            Id devRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            list<Contact> lstAgentNewContacts = new list<Contact>();
            list<Contact> lstAgentOldContacts = new list<Contact>();
            Map <String, String> mapNewContactProfiles = new map<String, String>();
            Map <String, String> mapOldContactProfiles = new map<String, String>();
            Map <Id, Profile> mapProfiles = new Map<id,profile>([SELECT Id,UserLicense.Name FROM Profile]);
            
            for(Contact con : lstContact){
                if(con.RecordTypeId == devRecordTypeId){
                    Contact newRefCon = new Contact(Id = con.Id);
                    newRefCon.WFG_Type__c = con.WFG_Type__c ;
                    newRefCon.WFG_AgentPayType__c = con.WFG_AgentPayType__c ;
                    newRefCon.WFG_CycleType__c = con.WFG_CycleType__c ;
                    newRefCon.WFG_Fiduciary_Advisor__c = con.WFG_Fiduciary_Advisor__c ; 
                    newRefCon.WFG_Home_Office_Agent__c = con.WFG_Home_Office_Agent__c; 
                    newRefCon.WFG_Channel__c = con.WFG_Channel__c;
                    
                    lstAgentNewContacts.add(newRefCon);
                    
                    Contact objOldCon = mapOldContact.get(con.Id);
                    Contact oldRefCon = new Contact(Id = objOldCon.Id);
                    oldRefCon.WFG_Type__c = objOldCon.WFG_Type__c ;
                    oldRefCon.WFG_AgentPayType__c = objOldCon.WFG_AgentPayType__c ;
                    oldRefCon.WFG_CycleType__c = objOldCon.WFG_CycleType__c ;
                    oldRefCon.WFG_Fiduciary_Advisor__c = objOldCon.WFG_Fiduciary_Advisor__c ; 
                    oldRefCon.WFG_Home_Office_Agent__c = objOldCon.WFG_Home_Office_Agent__c; 
                    oldRefCon.WFG_Channel__c = objOldCon.WFG_Channel__c;
                    
                    lstAgentOldContacts.add(oldRefCon);
                }
            }
            
            if(lstAgentNewContacts.size() > 0){
                //Retrive the old and new profiles for the respective contacts
                mapNewContactProfiles = WFG_ProfileIdentificationMatrix.getProfileId(lstAgentNewContacts);            
                mapOldContactProfiles = WFG_ProfileIdentificationMatrix.getProfileId(lstAgentOldContacts);
                
                system.debug('===mapNewContactProfiles==='+mapNewContactProfiles);
                system.debug('===mapOldContactProfiles==='+mapOldContactProfiles);
                set<Id> setUserToTransform = new set<Id>();
                set<Id> setUserToUpdate = new set<Id>();
                for(Contact conIns : lstAgentNewContacts){
                    Contact oldCon = mapOldContact.get(conIns.Id);
                    Contact con = mapNewContact.get(conIns.Id);
                    
                    if(con.WFG_AlternateEmail__c != oldCon.WFG_AlternateEmail__c
                    || con.WFG_Email_Verification__c != oldCon.WFG_Email_Verification__c
                    || con.WFG_AgentPayType__c != oldCon.WFG_AgentPayType__c || con.WFG_CycleType__c != oldCon.WFG_CycleType__c
                    || con.WFG_Type__c != oldCon.WFG_Type__c || con.WFG_Fiduciary_Advisor__c != oldCon.WFG_Fiduciary_Advisor__c
                    || con.WFG_Status__c != oldCon.WFG_Status__c || con.FirstName != oldCon.FirstName 
                    || con.LastName != oldCon.LastName || con.Phone != oldCon.Phone || con.Fax != oldCon.Fax
                    || con.mailingstreet != oldCon.mailingstreet || con.mailingstate != oldCon.mailingstate
                    || con.MailingCity != oldCon.MailingCity || con.mailingpostalCode != oldCon.mailingpostalCode
                    || con.MailingCountry != oldCon.MailingCountry 
                    || con.Email != oldCon.Email
                    || con.WFG_Home_Office_Agent__c != oldCon.WFG_Home_Office_Agent__c
                    || con.WFG_AgentCode__c!= oldCon.WFG_AgentCode__c
                    || con.WFG_SSNSIN__c !=  oldcon.WFG_SSNSIN__c 
                    || con.AgentOne__SSN_Tax_ID__c !=  oldcon.AgentOne__SSN_Tax_ID__c 
                    || con.WFG_Channel__c != oldCon.WFG_Channel__c)
                    {
                        system.debug('====in if====');
                        Id idCurrProfile = mapNewContactProfiles.get(conIns.Id);
                        Id idOldProfile = mapOldContactProfiles.get(oldCon.Id);
                        
                        //W-026598
                        if(idOldProfile == null && idCurrProfile != null)
                            setUserToTransform.add(conIns.Id);
                        
                        else{    
                            //Old profile not equal to new profile then true else false condition
                            if(idCurrProfile != idOldProfile && mapProfiles.get(idCurrProfile).UserLicense.Name != mapProfiles.get(idOldProfile).UserLicense.Name){
                                setUserToTransform.add(conIns.Id);
                            } else {
                                setUserToUpdate.add(conIns.Id);
                            }
                        }
                       
                    }
                    system.debug('===setUserToTransform==='+setUserToTransform);
                    system.debug('===setUserToUpdate==='+setUserToUpdate);
                }
                if(setUserToUpdate.size() > 0){
                    WFG_UserCreateUpdateutility.updateUser(setUserToUpdate, mapNewContactProfiles);
                }
                
                if(setUserToTransform.size() > 0){
                    WFG_UserLicense_Handler.LicenseUpdate(setUserToTransform);
                }
            }
        }catch(Exception e)
        {
            system.debug('Exception in License Handler--' + e);
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_Contact_Handler', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }       
    }
    /*
    This method is executed from after insert trigger
    It gets all the contact for which a new FSc user should be created and pass it to WFG_UserCreateUpdateUtility class to create users.
    */
    public static void insertUsers(List<Contact> lstContact, map<id, contact> mapNewContact,
                    map<id, contact> mapOldContact)
    {
        try{
        
          if(system.Label.WFG_UserCreationSwitch == 'ON')
          {
            Id devRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Label.WFG_Contact_Agent).getRecordTypeId();
            
            Map<Id, Contact> mapContact = new Map<Id, Contact>();
            Map <String, String> mapNewContactProfiles = new map<String, String>();
            
            for(contact con : lstContact){
                system.debug('==con.WFG_Status__c==='+con.WFG_Status__c);
                //If its Agent recordtype and LL,RR and FA then only enter if condition
                if(devRecordTypeId == con.RecordTypeId && con.WFG_Type__c != NULL && ((!con.WFG_Type__c.ContainsIgnoreCase(Label.WFG_Associate) || !con.WFG_Type__c.ContainsIgnoreCase(Label.WFG_Launch)) || (con.WFG_Fiduciary_Advisor__c))){
                
                    system.debug('=======in handler=========');
                    Contact newRefCon = new Contact(Id = con.Id);
                    newRefCon.WFG_Type__c = con.WFG_Type__c ;
                    newRefCon.WFG_AgentPayType__c = con.WFG_AgentPayType__c ;
                    newRefCon.WFG_CycleType__c = con.WFG_CycleType__c ;
                    newRefCon.WFG_Fiduciary_Advisor__c = con.WFG_Fiduciary_Advisor__c ; 
                    newRefCon.WFG_Home_Office_Agent__c = con.WFG_Home_Office_Agent__c; 
                    mapContact.put(Con.Id, newRefCon);
                }
            }
            
            if(!mapContact.isEmpty()){
                system.debug('==lst not empty===' + mapContact);
                //To retrieve the profile id for the criteria fetched from the contact 
                mapNewContactProfiles = WFG_ProfileIdentificationMatrix.getProfileId(mapContact.values());
                system.debug('====mapNewContactProfiles ===='+mapNewContactProfiles );
                WFG_UserCreateUpdateUtility.updateUser(mapContact.Keyset(), mapNewContactProfiles);
            }
          }
        }catch(Exception e)
        {
            system.debug('Exception in License Handler--' + e);
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_Contact_Handler', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }   
    }
    
    /**
    @author Girish.S
    @date 11-Dec-2017
    @description Executed on Trigger Context - Before Insert and Before Update.
    Added for import contacts functionality to fetch state code and country code from custom settings
    */
    public static void insertStateCountryCode(){
        try {
            Map<String, WFG_StateSynonyms__c> stateSyn = WFG_StateSynonyms__c.getAll();
            Map<String, WFG_CountrySynonyms__c> countrySyn = WFG_CountrySynonyms__c.getAll();
            
            for(Contact objCon: (List<Contact>)Trigger.New){
                if(Trigger.isInsert){
                    system.debug('==objCon.mailingState ==='+objCon.mailingState );
                    system.debug('==objCon.WFG_State_Province__c ==='+objCon.WFG_State_Province__c );
                    
                    if(objCon.mailingState  == null &&  objCon.WFG_State_Province__c != null){
                        //code adding for state synonyms
                        if(stateSyn.containskey(objCon.WFG_State_Province__c.toUpperCase()))
                        {
                            objCon.mailingState = WFG_PicklistFieldDescribeUtility.getPicklistValueCodes('Contact','MailingStateCode', WFG_StateSynonyms__c.getInstance(objCon.WFG_State_Province__c.toUpperCase()).State_Name__c);            
                        }
                        else
                        {
                            objCon.mailingState = WFG_PicklistFieldDescribeUtility.getPicklistValueCodes('Contact','MailingStateCode',objCon.WFG_State_Province__c);
                        }
                        //code ended for adding synonyms
                    } 
                    if(objCon.mailingCountry == null && objCon.WFG_Country__c != null) 
                    {
                        if(countrySyn.containskey(objCon.WFG_Country__c.toUpperCase()))
                        {
                            objCon.mailingCountry = WFG_PicklistFieldDescribeUtility.getPicklistValueCodes('Contact','MailingCountryCode', WFG_CountrySynonyms__c.getInstance(objCon.WFG_Country__c.toUpperCase()).Country_Name__c);            
                        }
                        else
                        {
                            objCon.mailingCountry = WFG_PicklistFieldDescribeUtility.getPicklistValueCodes('Contact','MailingCountryCode',objCon.WFG_Country__c);
                        }
                        if(objCon.mailingCountry == null)
                        {
                            objCon.addError(Label.WFG_CountryInvalid.replace('[Country]',objCon.WFG_Country__c));
                        }
                    }  
                }
                else if(Trigger.isupdate){
                    if(objCon.WFG_State_Province__c != null){
                        //code adding for state synonyms
                        if(stateSyn.containskey(objCon.WFG_State_Province__c.toUpperCase()))
                        {
                            objCon.mailingState = WFG_PicklistFieldDescribeUtility.getPicklistValueCodes('Contact','MailingStateCode', WFG_StateSynonyms__c.getInstance(objCon.WFG_State_Province__c.toUpperCase()).State_Name__c);            
                        }
                        else
                        {
                            objCon.mailingState = WFG_PicklistFieldDescribeUtility.getPicklistValueCodes('Contact','MailingStateCode',objCon.WFG_State_Province__c);
                        }
                        //code ended for adding synonyms
                    } 
                    if(objCon.WFG_Country__c != null) 
                    {
                        if(countrySyn.containskey(objCon.WFG_Country__c.toUpperCase()))
                        {
                            objCon.mailingCountry = WFG_PicklistFieldDescribeUtility.getPicklistValueCodes('Contact','MailingCountryCode', WFG_CountrySynonyms__c.getInstance(objCon.WFG_Country__c.toUpperCase()).Country_Name__c);            
                        }
                        else
                        {
                            objCon.mailingCountry = WFG_PicklistFieldDescribeUtility.getPicklistValueCodes('Contact','MailingCountryCode',objCon.WFG_Country__c);
                        }
                        if(objCon.mailingCountry == null)
                        {
                            objCon.addError(Label.WFG_CountryInvalid.replace('[Country]',objCon.WFG_Country__c));
                        }
                    }
                }
                if(objCon.mailingState != null && objCon.mailingState == 'PR')
                    {
                       objCon.mailingState = 'PRC'; 
                    }
            }
        }
        catch(Exception e)
        {
            system.debug('Exception caused---' + e);
        }
    }
    
    /**
    @author Rashmi
    @date 19-Jan-2018
    @description Executed on Trigger Context - After Update
    Added to store the current user profile in Contact record.
    */
    private static void updateContactUserProfile(List<Contact> lstContact, Map<Id, Contact> mapOldContact){
        
        try{
            Id devRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Label.WFG_Contact_Agent).getRecordTypeId();
            set<Id> setContactUnderWork = new set<Id>();
            List<Contact> agentContacts = new List<Contact>();
            
            for(Contact objCon : lstContact){
                
                if((objCon.WFG_AgentPayType__c <> mapOldContact.get(objCon.id).WFG_AgentPayType__c) ||
                    (objCon.WFG_Type__c <> mapOldContact.get(objCon.id).WFG_Type__c) ||
                    (objCon.WFG_CycleType__c <> mapOldContact.get(objCon.id).WFG_CycleType__c) ||
                    (objCon.WFG_Fiduciary_Advisor__c <> mapOldContact.get(objCon.id).WFG_Fiduciary_Advisor__c) ||
                    (objCon.WFG_Channel__c <> mapOldContact.get(objCon.id).WFG_Channel__c)){
                        
                    if(objCon.RecordTypeId == devRecordTypeId){
                        
                        setContactUnderWork.add(objCon.Id);
                        Contact newRefCon = new Contact(Id = objCon.Id);
                        newRefCon.WFG_Type__c = objCon.WFG_Type__c ;
                        newRefCon.WFG_AgentPayType__c = objCon.WFG_AgentPayType__c ;
                        newRefCon.WFG_CycleType__c = objCon.WFG_CycleType__c ;
                        newRefCon.WFG_Fiduciary_Advisor__c = objCon.WFG_Fiduciary_Advisor__c ;  
                        newRefCon.WFG_Home_Office_Agent__c = objCon.WFG_Home_Office_Agent__c;
                        newRefCon.WFG_Channel__c = objCon.WFG_Channel__c;
                        agentContacts.add(newRefCon);
                        
                    }    
                }
            }
            
            if(!agentContacts.isEmpty()){
                Map <String, String> NewcontactProfiles = WFG_ProfileIdentificationMatrix.getProfileId(agentContacts);  
                map<id, Profile> mapIdtoProfileName = new map<Id, Profile>();
                
                mapIdtoProfileName = new Map<id,profile>([SELECT Id,Name from Profile where Id in: NewcontactProfiles.values()]);
                
                for(Contact objContact : lstContact){
                    
                    if((!setContactUnderWork.isEmpty() || setContactUnderWork.size() > 0) && !mapIdtoProfileName.isEmpty() && !NewcontactProfiles.isEmpty()){
                        
                        if(setContactUnderWork.contains(objContact.id) && objContact.WFG_User_Profile_Name__c != mapIdtoProfileName.get(NewcontactProfiles.get(objContact.id)).Name)
                            objContact.WFG_User_Profile_Name__c = mapIdtoProfileName.get(NewcontactProfiles.get(objContact.id)).Name;
                    }
                }
            }
        }catch(Exception e)
        {
            system.debug('Exception in License Handler--' + e);
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_Contact_Handler', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }   
    }
    
    /*private static void notifyUserWhenContactUpdate(map<Id, contact>mapNewContact, map<Id, Contact>mapOldContact)
    {
        system.debug('#### in NOTIFY');
        if(mapNewContact != null && !mapNewContact.keyset().isEMpty())
        {
            List<Messaging.SingleEmailMessage> lstmail = new List<Messaging.SingleEmailMessage>();
            Id agentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Label.WFG_Contact_Agent).getRecordTypeId();
            List<contact> lstConToBeMailed = new List<Contact>();
            map <string, User> mapContactUser = new map<string, User>();
            for(Id idCon : mapNewContact.keyset())
            {
                if(mapNewContact.get(idCon).recordtypeId == agentRecordTypeId && 
                    (mapNewContact.get(idCon).WFG_Type__c != mapOldContact.get(idCon).WFG_Type__c
                        || mapNewContact.get(idCon).WFG_AgentPayType__c != mapOldContact.get(idCon).WFG_AgentPayType__c
                        || mapNewContact.get(idCon).WFG_CycleType__c != mapOldContact.get(idCon).WFG_CycleType__c
                        || mapNewContact.get(idCon).WFG_Fiduciary_Advisor__c != mapOldContact.get(idCon).WFG_Fiduciary_Advisor__c
                    ))
                {
                    lstConToBeMailed.add(mapNewContact.get(idCon));
                    mapContactUser.put(mapNewContact.get(idCon).WFG_AgentCode__c, null);
                }
            }
            for(user objUser : [Select id, name,WFG_Agent_Code__C  from User Where isActive = true and WFG_Agent_Code__C IN : mapContactUser.keyset()])
            {
                mapContactUser.put(objUser.WFG_Agent_Code__C, objUser);
            }
            for(Contact objCon : lstConToBeMailed)
            {
                Integer used = Limits.getEmailInvocations();
                Integer emailLimit = Limits.getLimitEmailInvocations();
                if(!(used >= emailLimit))
                {
                     Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage(); 
                     String subject ='Contact Type Updates : ' + system.now() ;
                     objEmail.setSubject(subject);
                     objEmail.setTargetObjectId(system.Label.WFG_SupportEmailAddress);
                     //objEmail.setToAddresses(new List<string>{system.Label.WFG_SupportEmailAddress});
                     objEmail.setSaveAsActivity(false);
                     String strBody= '<br/><br/> <B>Please see below agent contact type change in your org: </B><br/><br/>'; 
                     strBody += 'Contact Name   : ' + objCon.firstname +' ' + objCon.lastname + '<br/>';
                     strBody += 'Contact Id     : ' + objCon.Id + '<br/><br/>';
                         
                     if(objCon.WFG_Type__c <> mapOldContact.get(objCon.id).WFG_Type__c)
                     {
                        strBody += 'Contact TYPE OLD  : ' + mapOLDContact.get(objCon.id).WFG_Type__c + '<br/>';
                        strBody += 'Contact TYPE NEW  : ' + objCon.WFG_Type__c + '<br/> <br/>';
                     }
                     
                     if(objCon.WFG_AgentPayType__c <> mapOldContact.get(objCon.id).WFG_AgentPayType__c)
                     {
                        strBody += 'Contact Agent Pay Type OLD  : ' + mapOLDContact.get(objCon.id).WFG_AgentPayType__c + '<br/>';
                        strBody += 'Contact Agent Pay Type NEW  : ' + objCon.WFG_AgentPayType__c + '<br/> <br/>';
                     }
                     
                     if(objCon.WFG_CycleType__c <> mapOldContact.get(objCon.id).WFG_CycleType__c)
                     {
                        strBody += 'Contact Cycle Type OLD  : ' + mapOLDContact.get(objCon.id).WFG_CycleType__c + '<br/>';
                        strBody += 'Contact Cycle Type NEW  : ' + objCon.WFG_CycleType__c + '<br/> <br/>';
                     }
                         
                     if(objCon.WFG_Fiduciary_Advisor__c <> mapOldContact.get(objCon.id).WFG_Fiduciary_Advisor__c)
                     {
                        strBody += 'Contact Fiduciary flag OLD  : ' + mapOLDContact.get(objCon.id).WFG_Fiduciary_Advisor__c + '<br/>';
                        strBody += 'Contact Fiduciary flag NEW  : ' + objCon.WFG_Fiduciary_Advisor__c + '<br/> <br/>';
                     }
                     
                     strBody += 'Click to access the contact: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' +objCon.Id + '?nooverride=1 <br/>';
                     
                     if(mapContactUser.containsKey(objCon.WFG_AgentCode__c) && mapContactUser.get(objCon.WFG_AgentCode__c) != null)
                     strBody += 'Click to access the user: ' + URL.getSalesforceBaseUrl().toExternalForm()  + '/' + mapContactUser.get(objCon.WFG_AgentCode__c).Id + '?nooverride=1 <br/><br/>';
                     
                     objEmail.setHtmlBody(strBody); 
                     objEmail.setPlainTextBody('');
                     lstmail.add(objEmail);
                }
            }
            if(lstmail != null && !lstmail.isEmpty()) Messaging.SendEmailResult [] lstEMailRes = Messaging.sendEmail(lstmail);  
        }
    }*/
         /**
    @author : Rashmi
    @date 11/14/2018
    @description: Logic contains duplicate check for contacts based on FirstName, LastName, Email and OwnerID if the contact record type is Individual and based on AgentCode if the record type is Agent.
    */
    private static void CheckDuplicateForAgentandIndividualContacts(boolean isInsert, boolean isUpdate, list<Contact> lstNewContact, map<Id, Contact> MapOldContat)
    {
        try{
            set<string> setNameandEmail = new set<string>();
            
            map<string, Contact> mapConcatenatedValuestoContact  = new map<string, Contact>();
            map<string, Contact> mapAgentCodetoContact = new map<string, Contact>();
            set<string> setUniuqKeyIndividual = new set<string>();
            set<string> setUniuqKeyAgent = new set<string>();
            
            //variables to store the Id of individual and Agent Contacts
            Id recordTypeIdAgent = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Label.WFG_Contact_Agent).getRecordTypeId();
            Id recordTypeIdIndividual = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Label.WFG_Contact_Individual).getRecordTypeId();
            
            //Iterates over the new contacts, forms the string of FirstName, LastName and Email for Individual Contacts and Agentcode for Agent Contacts
            for(Contact objContact: lstNewContact)
            {
            
                if(isInsert)
                {   
                    if(objContact.RecordTypeId == recordTypeIdIndividual){
                        
                        string strConcatenatedVals = objContact.FirstName +','+objContact.LastName+','+objContact.Email +','+objContact.OwnerId;
                        
                        mapConcatenatedValuestoContact.put(strConcatenatedVals, objContact);
                        setNameandEmail.add(objContact.FirstName);
                        setNameandEmail.add(objContact.LastName);
                        setNameandEmail.add(objContact.Email);
                        setNameandEmail.add(objContact.OwnerId);
                        
                    }
                    if(objContact.RecordTypeId == recordTypeIdAgent){
                        
                        mapAgentCodetoContact.put(objContact.WFG_AgentCode__c,objContact);
                    }
                }
                else if(isUpdate)
                { 
                    
                    Contact objOldContact = MapOldContat.get(objContact.Id);
                    if(objContact.RecordTypeId == recordTypeIdIndividual){
                     
                        if(objContact.FirstName != objOldContact.FirstName || objContact.LastName != objOldContact.LastName
                                || objContact.Email != objOldContact.Email || objContact.OwnerId != objOldContact.OwnerId)
                        {
                            
                            string strConcatenatedVals = objContact.FirstName +','+objContact.LastName+','+objContact.Email +','+objContact.OwnerId;
                            mapConcatenatedValuestoContact.put(strConcatenatedVals, objContact);
                            setNameandEmail.add(objContact.FirstName);
                            setNameandEmail.add(objContact.LastName);
                            setNameandEmail.add(objContact.Email);
                            setNameandEmail.add(objContact.OwnerId);
                        }
                        
                    }
                    if(objContact.RecordTypeId == recordTypeIdAgent && objContact.WFG_AgentCode__c != objOldContact.WFG_AgentCode__c){
                        
                        mapAgentCodetoContact.put(objContact.WFG_AgentCode__c,objContact);
                    }
                }
            }
            
            //Checks if there are any existing record in database with dupicate value for individual anf Agent contacts. If exists, throws an error
            if(!mapConcatenatedValuestoContact.isEmpty() || !mapAgentCodetoContact.isEmpty())
            {
            
                for(Contact objAvailableContact: [SELECT Id, Name, FirstName, LastName, Email,RecordTypeId,WFG_AgentCode__c,OwnerId FROM Contact 
                                                    WHERE (OwnerId =: setNameandEmail AND
                                                    FirstName IN : setNameandEmail AND
                                                    LastName IN: setNameandEmail AND
                                                    Email IN: setNameandEmail
                                                    AND RecordTypeId =: recordTypeIdIndividual) OR (RecordTypeId =: recordTypeIdAgent AND WFG_AgentCode__c IN: mapAgentCodetoContact.keyset()) ])
                {   
                    if(objAvailableContact.RecordTypeId == recordTypeIdIndividual){
                    
                        string strConVal = objAvailableContact.FirstName +','+objAvailableContact.LastName +','+objAvailableContact.Email +','+objAvailableContact.OwnerId;
                        if(mapConcatenatedValuestoContact.containsKey(strConVal))
                            mapConcatenatedValuestoContact.get(strConVal).addError(Label.WFG_DuplicateContactError.replace('[ContactName]',mapConcatenatedValuestoContact.get(strConVal).LastName +' '+ mapConcatenatedValuestoContact.get(strConVal).FirstName));
                    }
                    if(objAvailableContact.RecordTypeId == recordTypeIdAgent){
                    
                        if(mapAgentCodetoContact.containsKey(objAvailableContact.WFG_AgentCode__c))
                            mapAgentCodetoContact.get(objAvailableContact.WFG_AgentCode__c).AddError('Agent Code must be unique');
                    }
                }     
            }
            
            //Checks if there are any existing record within list with dupicate value for individual anf Agent contacts. If exists, throws an error
            for(Contact objContact: lstNewContact){
             
                if(objContact.RecordTypeId == recordTypeIdIndividual){
                    string strConVal = objContact.FirstName +','+objContact.LastName +','+objContact.Email+','+ objContact.OwnerId;
                    
                    if(!setUniuqKeyIndividual.contains(strConVal)){
                        setUniuqKeyIndividual.add(strConVal);
                    }
                    else{
                        objContact.addError(Label.WFG_DuplicateContactError.replace('[ContactName]',objContact.LastName+' '+objContact.FirstName));
                    }    
                }
                if(objContact.RecordTypeId == recordTypeIdAgent){
                
                    if(!setUniuqKeyAgent.contains(objContact.WFG_AgentCode__c)){
                        setUniuqKeyAgent.add(objContact.WFG_AgentCode__c);
                    }
                    else{
                        objContact.AddError('Agent Code must be unique');
                    }  
                }
            }
        }catch(Exception e)
        {
            system.debug('Exception in Contact handler--' + e);
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_Contact_Handler', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }   
    }
}