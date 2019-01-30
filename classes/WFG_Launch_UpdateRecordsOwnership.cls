/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author : Rashmi Shet
* @date 08/09/2018
* @description  Restrict User from editing their records
Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Rashmi Shet           M-001             08-09-2018              W-027426 - To update the ownership of individual Account, Contact and 
                                                                Recruiting opportunity that is assigned to 'System' user when the users gets activated. 
.                                                                  
*/

public class WFG_Launch_UpdateRecordsOwnership{
    
    //to store the list of users that are activated
    /*public list<user> lstActivatedUsers = new list<user>();
    
    //constructor
    public WFG_Launch_UpdateRecordsOwnership(list<user> lstActivatedUsersFromTrigger){
    
       lstActivatedUsers.addAll(lstActivatedUsersFromTrigger); 
       system.debug('===lstActivatedUsers==='+lstActivatedUsers);
    }*/
    
     /**
    @author : Rashmi Shet
    @date : 08/09/2018
    @description : For all the users that are activated it fetches the onboarding checklist based on user's Agent code 
                   and updated the ownership of account, contact and opportunity that are related to onboarding checklist from 
                   system user to the activated user.
    @Return : none
    */
    @future
    public static void updateLaunchRelatedRecords(set<Id> Ids) {
        
        try
        {
            //map to store the activated user id and its corresponding Agent code
            map<string, User> mapAgentcodetoUser = new map<string, User>();
            //list to store the sObject whose ownership are to be updated
            list<sObject> lstRecordsOwnertobeUpdated = new list<sObject>();
            //map to contain record id and corresponding ownerId it has to be updated with
            map<Id,Id> mapSobjectIdtoNewOwnerId = new map<Id,Id>();
            
            //instance of system user
            User objSystemUser = [select id from User where lastName ='System' and Profile.name = 'API Only' limit 1];
            
            for(User objUser : [select WFG_Agent_Code__c from user where id=:Ids]){
                 
                mapAgentcodetoUser.put(objUser.WFG_Agent_Code__c, objUser);
            }
            
            system.debug('===mapAgentcodetoUser==='+mapAgentcodetoUser);
            //iterates over the onboarding checklist and fetches individual Accont, Contact and recruiting opportunity whose ownership has to be changed
            for(WFG_Onboarding_Checklist__c objOnboardingChecklist : [select id, Recruiting_Contact__c, Onboarding_Opportunity__c,   Onboarding_Opportunity__r.AccountId, Onboarding_Opportunity__r.Agent_Contact__c, WFG_Recruiting_Agent_Code__c, WFG_Agent_Code__c, Onboarding_Opportunity__r.OwnerId, Onboarding_Opportunity__r.Account.OwnerId, Onboarding_Opportunity__r.Agent_Contact__r.ownerId from WFG_Onboarding_Checklist__c where WFG_Recruiting_Agent_Code__c in: mapAgentcodetoUser.keyset()]){
                
                Id IdOppNewOwnerId = mapAgentcodetoUser.get(objOnboardingChecklist.WFG_Recruiting_Agent_Code__c).Id;
                if(objOnboardingChecklist.Onboarding_Opportunity__r.OwnerId == objSystemUser.Id){
                    
                    mapSobjectIdtoNewOwnerId.put(objOnboardingChecklist.Onboarding_Opportunity__c, IdOppNewOwnerId);
                }
                if(objOnboardingChecklist.Onboarding_Opportunity__r.Account.OwnerId == objSystemUser.Id){
                    
                    mapSobjectIdtoNewOwnerId.put(objOnboardingChecklist.Onboarding_Opportunity__r.AccountId, IdOppNewOwnerId);
                }
                if(objOnboardingChecklist.Onboarding_Opportunity__r.Agent_Contact__r.ownerId == objSystemUser.Id){
                    
                    mapSobjectIdtoNewOwnerId.put(objOnboardingChecklist.Onboarding_Opportunity__r.Agent_Contact__c, IdOppNewOwnerId);
                }
                
            }
            
            //updating the ownership of individual Account to new owner
            for(Account objAccount : [select id, ownerid from Account where id IN: mapSobjectIdtoNewOwnerId.keyset()]){
                
                objAccount.ownerId = mapSobjectIdtoNewOwnerId.get(objAccount.Id);
                lstRecordsOwnertobeUpdated.add(objAccount);
            }
            
            //updating the ownership of individual Contact to new owner
            for(Contact objContact : [select id, ownerid from Contact where id IN: mapSobjectIdtoNewOwnerId.keyset()]){
                
                objContact.ownerId = mapSobjectIdtoNewOwnerId.get(objContact.Id);
                lstRecordsOwnertobeUpdated.add(objContact);
            }
            //updating the ownership of recruiting opportunity to new owner
            for(Opportunity objOpportunity : [select id, ownerid from Opportunity where id IN: mapSobjectIdtoNewOwnerId.keyset()]){
            
                objOpportunity.ownerId = mapSobjectIdtoNewOwnerId.get(objOpportunity.Id);
                lstRecordsOwnertobeUpdated.add(objOpportunity);
            }
            
            //updates the sObject list if it is not empty
            if(!lstRecordsOwnertobeUpdated.isEmpty())
                update lstRecordsOwnertobeUpdated;
        }catch(Exception e)
        {
            
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_Launch_UpdateRecordsOwnership', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }                
    }
}