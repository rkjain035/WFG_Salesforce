/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Deepthi N
* @date 24-Feb-2017
* @description  Different object records owner transformation.

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Saravanan            M-001              21-FEB-2018              After PC to FSC conversion. We will not have any partner user using the
                                                                 Account, Contact, opportunity. So removed the logic that is used to update 
                                                                 the ownere to transformed user. Only case team member is taken care.
Saravanan            M-001              15-APR-2018              We are moving the logic to add case team member in the user trigger itself. So commented the class.
Praveen              M-001              13-JUN-2018              After CC to FSC conversion. We are updating the owners of Individual Accounts as contacts are controlled by parent. For USer story(W-026598)
*/

public with sharing class WFG_OwnershipUpdate {
    
     /**
     * This method updates the owners of transformed users
     * @return - N/A
     * @see    - N/A
     * @param  - N/A
     * @throws - Handled in Log Utility object
     */
    public static void UpdateOwners()
    {     
        try{
            set<String> setFedIDs = new set<String>();
            set<Id> setUserIds = new set<Id>();
            Map<string,Id> mapUserTobeTransformed = new map<string,Id>();           
            Map<string,Id> mapExistingUsers = new map<string,Id>(); 
            List<sObject> lstSobject = new List<sObject>();
            Set<string> oppRecordTypes = new Set<string>{'Insurance','InsuranceReadOnly','Recruitment','Onboarding','Onboarding CANADA'};
            // Query list of Old Users who are transformed         
            list<User> lstUsers = [select id,FederationIdentifier,isActive,Profile.UserLicense.Name, Profile.Name from user where WFG_UTCheck__c=true];

            if(lstUsers.size() > 0)
            {
                for(user usr : lstUsers){
                    setFedIDs.add(usr.FederationIdentifier.split('_')[0] + '%');
                    setUserIds.add(usr.Id);
                }
                //Query List of Users who are active and already transformed
                for(User usr : [select id,FederationIdentifier,isActive,Profile.UserLicense.Name, Profile.Name from user where FederationIdentifier Like :setFedIDs AND isActive = true]){
                    if(!usr.FederationIdentifier.contains('_')){
                        mapExistingUsers.put(usr.FederationIdentifier, usr.Id);
                    }
                }
            
                for(user usr : lstUsers){
                    string fedId = usr.FederationIdentifier.split('_')[0];
                    if(mapExistingUsers.get(fedId) != null)
                        mapUserTobeTransformed.put(usr.Id, mapExistingUsers.get(fedId));
                }
                
                if(mapUserTobeTransformed.size()>0)
                {
                    //Query Accounts of Old Users and update it with newer transformed users
                    system.debug('===mapUserTobeTransformed==='+mapUserTobeTransformed);
                    List<Account> lstAccount = [Select Id,ownerid from account where (recordtype.DeveloperName =:Label.WFG_Individual_RecordType) and ownerid IN: mapUserTobeTransformed.keyset()];
                    if(lstAccount.size() > 0)
                    {
                        for( Account acc : lstAccount )
                        {
                            acc.ownerid = mapUserTobeTransformed.get(acc.ownerid);   
                            lstSobject.add(acc);
                        }
                    }
                    
                    //Query Contacts of Old Users and update it with newer transformed users
                    List<contact> lstContact = [Select Id,ownerid from contact where (recordtype.DeveloperName =:Label.WFG_Individual_RecordType) and ownerid IN: mapUserTobeTransformed.keyset()];
                    if(lstContact.size() > 0)
                    {
                        for( Contact con : lstContact )
                        {
                            con.ownerid = mapUserTobeTransformed.get(con.ownerid);
                            lstSobject.add(con);
                        }
                    }
                    
                    //Query Opportunities of Old Users and update it with newer transformed users
                    List<Opportunity> lstOppty = [Select Id,ownerId from opportunity where recordtype.DeveloperName IN: oppRecordTypes and ownerid IN: mapUserTobeTransformed.keyset()];
                    if(lstOppty.size()>0)
                    {
                      for( Opportunity oppty : lstOppty)
                      {
                        System.debug('oppty Contains'+oppty);
                        oppty.ownerid = mapUserTobeTransformed.get(oppty.ownerid);
                        lstSobject.add(oppty);
                      }
                      system.debug(lstOppty);
                      //update lstOppty;
                      
                    }
                    
                    //Update the accounts,contacts and opportunities with newer transformed users
                    Database.SaveResult[] results = Database.update(lstSobject,false );
                    for (Integer i = 0; i < results.size(); i++) {
                        if (results[i].isSuccess()) {
                        System.debug('Successfully Updated ID: '
                              + results[i].getId());
                        } else {
                        System.debug('Error: could not create sobject ' + 'for array element ' + i + '.');
                        System.debug('   The error reported was: ' + results[i].getErrors()[0].getMessage() + '\n');
                        LogUtility.createLog('EXCEPTION','WFG_OwnershipUpdate','Error during update', 'Error', results[i].getErrors()[0].getMessage(), 'Error');   
                        }
                    }
                }
                updateUTCheck(setUserIds);
            }
        } catch(exception e) {
            system.debug('Exception--' + e.getmessage());
            LogUtility.createLog('EXCEPTION','WFG_OwnershipUpdate',e.getMessage(), 'Error', e.getStackTraceString(), 'Error');   
               
        }
    }
    
    
    /**
     * This future method updates the UT Check field of transformed users to false
     * @return - N/A
     * @see    - Future Method
     * @param  - Set of user ids
     * @throws - Handled in Log Utility object
     */
    @future
    public static void updateUTCheck(Set<Id> setUserIds)
    { 
        try
        {
            List<User> listOfUsers = [Select id,WFG_UTCheck__c from user where Id IN: setUserIds];
            for(User usr : listOfUsers)
                usr.WFG_UTCheck__c = false;
                
            update listOfUsers;
        } catch(exception e) {
            system.debug('Exception--' + e.getmessage()); 
            LogUtility.createLog('EXCEPTION','WFG_OwnershipUpdate',e.getMessage(), 'Error', e.getStackTraceString(), 'Error');        
        }
    }

    /**
     * This future method will delete the case team member for inactive users
     * @return - N/A
     * @see    - Future Method
     * @param  - Set of user ids
     * @throws - Handled in Log Utility object
     */
    @future
    public static void deleteCaseTeamMember(Set<Id> userIdSet)
    { 
        try
        {
            list<CaseTeamMember> caseTeamList = [select id from caseTeamMember where memberId IN: userIdSet];
            if(caseTeamList.size() > 0)
                delete caseTeamList;
        } catch(exception e) {
            system.debug('Exception--' + e.getmessage()); 
            LogUtility.createLog('EXCEPTION','WFG_OwnershipUpdate_CaseTeamDeletion',e.getMessage(), 'Error', e.getStackTraceString(), 'Error');        
        }
    }
 }