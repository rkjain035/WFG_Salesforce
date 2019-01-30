/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Saravanan Haldurai
* @date 06-01-2018
* @description  Controller class for Lightning component in the training Screen of WFG Launch

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Sarvanan                Mod-01          10/08/2018                  W-027435 - Fetch the Individual contact related to the recruting user in the Onboarding_Opportunity_Assignments flow.
Praveen                 Mod-02          22/08/2018                  W-027573 - Updating the lead information with the phone,country and state from the prospect contact.  
*/
public class WFG_Onboarding_Oppty_Process_Helper{

    @InvocableMethod
    public static list<Contact> checkRelatedData(list<String> lstUserIds)
    {
        system.debug('++ lstUserIds ++' + lstUserIds);
        list<String> lstUserIdValues = new list<String>();
        list<Contact> lstReturnContacts = new list<Contact>();
        
        list<sObject> lstData = new list<sObject>();
        Map<string, sObject> mapsObject = new Map<String, sObject>();
        
        string strContactId;
        for(string userId : lstUserIds[0].split(';'))
        {
            if(userId != '' && userId != NULL)
                lstUserIdValues.add(userId);
                
            strContactId = userId;
        }
        
        Contact prospectAgentContact = [select id, firstName, lastName, Email,homephone,mailingcountry,mailingstate from contact where Id =: strContactId limit 1];
        
        system.debug('++++ prospectAgentContact ++' + prospectAgentContact);
        
        lstData = [select id, firstName, owner.IsActive, LastName, AccountId from Contact where OwnerId IN: lstUserIdValues AND FirstName =: prospectAgentContact.FirstName AND lastName =: prospectAgentContact.LastName AND Email =: prospectAgentContact.Email AND recordType.Name = 'Individual'];
        
        if(lstData.size() == 0)
        {
            list<lead> lstOfLeads = new list<lead>();
            lstData = [select id, owner.IsActive,Phone,State,country from Lead where OwnerId IN: lstUserIdValues AND FirstName =: prospectAgentContact.FirstName AND lastName =: prospectAgentContact.LastName AND Email =: prospectAgentContact.Email];
            system.debug('data in the list = '+lstData);
            if(lstData.size() == 1){
                for(lead le:(List<Lead>)lstData){
                    if(le.Phone == null || le.Phone != prospectAgentContact.homephone)
                    {
                        le.Phone = prospectAgentContact.homephone;
                    }
                    if(le.Country == null){
                        le.country = prospectAgentContact.mailingcountry;
                    }
                    if(le.state == null){
                        le.state = prospectAgentContact.mailingstate;
                    }
                    lstOfLeads.add(le);
                }
                update lstOfLeads;
                system.debug('List of LEads = '+lstOfLeads);
            }   
        }
        
        system.debug('+++ lstData ++' + lstData);
        
        for(sObject rec : lstData)
        {
            Boolean isActiveUser = (boolean) rec.getSobject('owner').get('isActive');
            id ownerId = (String) rec.get('OwnerId');
            if(isActiveUser && lstUserIdValues[0] == OwnerId)
            {
                mapsObject.put('isActive', rec);
            } else if (isActiveUser) {
                mapsObject.put('isSystem', rec);
            } else {
                mapsObject.put('isInactive', rec);
            }
        }
        
        sObject so_currRec;
        if(mapsObject.containsKey('isActive')){
            so_currRec = mapsObject.get('isActive');
        } else if(mapsObject.containsKey('isInactive')){
            so_currRec = mapsObject.get('isInactive');
        } else if(mapsObject.containsKey('isSystem')){
            so_currRec = mapsObject.get('isSystem');
        }
        
        system.debug('+++ so_currRec +++' + so_currRec);
        system.debug('+++ mapsObject +++' + mapsObject);
        
        if(so_currRec == NULL)
            return NULL;
        
        if(string.valueOf(so_currRec.getSObjectType()).equalsIgnoreCase('Contact'))
            lstReturnContacts.add((Contact)so_currRec);
        else
            lstReturnContacts = WFG_LeadConversion_Utility.convertLeadRecords(new list<Id>{so_currRec.Id});
        system.debug('ContactList = '+lstReturnContacts);    
        return lstReturnContacts;
        
    } 
}