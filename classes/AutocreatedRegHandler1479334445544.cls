/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author SF
* @date N/A
* @description - Called when user logged in through JIT.

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Saravanan             Mod-01             20-FEB-2018             Updated the logic to insert the Customer community user and activate the
                                                                 inactive FSC user when they login through JIT. Also enabled a boolean flag in user trigger to add caseteam member when user is activated.
*/

//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
global class AutocreatedRegHandler1479334445544 implements Auth.SamlJitHandler {
    //comment by michael pair
    public class JitException extends Exception{}

    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) 
    {
        User objUser = new User();
        Boolean isUsrActive = false;
        try
        {
            WFG_JITHelper.JITResponse objJITRes =  WFG_JITHelper.getUser(federationIdentifier);
            system.debug('===objJITRes===='+objJITRes);
            if(objJITRes != null)
            {
                System.debug('Matlab hein...');
                if(objJITRes.boolIsError) 
                {
                    throw new JitException(objJITRes.strErrMsg);
                }
                else
                {
                    WFG_userTriggerHandler.createCaseTeamMember = true;
                    if(objJITRes.objUser.Id == NULL){
                        insert  objJITRes.objUser;
                        isUsrActive = true;
                    }
                    else 
                    {
                        System.debug('i was there but no life...');
                        if(objJITRes.objUser.isActive != true){
                            objJITRes.objUser.isActive = true;
                            update objJITRes.objUser;
                            isUsrActive = true;
                        }
                    }
                    objUser = objJITRes.objUser;
                }
            }
            else
            {
                throw new JitException('Some Issue happend, please contact administrator');
            }
            list<contact> lstCon = [select id, WFG_Fiduciary_Advisor__c 
                                    from contact 
                                    where WFG_FederationId__c = : federationIdentifier 
                                    AND WFG_Fiduciary_Advisor__c = true];
            
			
            
            system.debug('---is FA Contact--' + lstCon.size());
            system.debug('--- is Activated --- ' + isUsrActive);
            if(isUsrActive == true || lstCon.size() != 0)
            {
                system.debug('=====objUser====='+objUser);
                system.debug('=====objUser.Id======'+objUser.id);
                updateCaseTeam(new set<Id>{objUser.Id});
                WFG_Launch_UpdateRecordsOwnership.updateLaunchRelatedRecords(new set<Id>{objUser.Id});
            }
        }
        catch(Exception e)
        {
            system.debug('+++ Execption ++' + e);
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'AutocreatedRegHandler1479334445544', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }
        return objUser;
    }

    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        system.debug('######### IN UPDATE JIT');
    }
    
    @future
    public static void updateCaseTeam(set<Id> setUserIds)
    {
        LIST<User> userList = [select id, WFG_Inactivated_Date__c, WFG_Agent_Code__c from user where Id IN: setUserIds];
        WFG_RecreateCaseTeamMemberBatch.updateCaseTeam( new list<User>{
            [select id, WFG_Inactivated_Date__c, WFG_Agent_Code__c from user where Id IN: setUserIds]
        });
    }
}