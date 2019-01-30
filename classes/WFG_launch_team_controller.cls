/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Rahul K Jain
* @date 25-Jul-2018
* @description  

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Rahul K Jain           M-001             25-Jul-2018            This class fetches downlines of the logged in User.
                                                                Can also be used to fetch downline's downline.
Hampesh G              M-002             14-Sep-2018            Added agent type information of agents  to the wrapper object.                        
*/
public without sharing class WFG_launch_team_controller {
    
    final static string loggedInUserName;
    static
    {
        loggedInUserName = [select Name from User where id= :UserInfo.getUserId()].Name;
    }
     /**
    @author Hampesh
    @date 22-Aug-2018
    @description returns logged in user agentcode
    */
    @AuraEnabled
    public static String loggedInUserAgentCode()
    {
        try
        {
        	return [select WFG_Agent_Code__c from user where id=:userinfo.getuserid()].WFG_Agent_Code__c;
        }
        catch (Exception e)
        {
            return '';
        }
    }
    
    @AuraEnabled
    public static Date agentCode_SMDApprovalDate(String agentCode)
    {
        try
        {
        	return [select WFG_SMDApprovalDate__c from WFG_AgentCode__c where WFG_AgentCode__c=:agentCode].WFG_SMDApprovalDate__c; 
        }
        catch (Exception e)
        {
            return Date.today();
        }
    }
    @AuraEnabled
    public static Date agentCode_CloseDate(String agentCode)
    {
        try
        {
            return [SELECT Onboarding_Opportunity__r.CloseDate FROM WFG_Onboarding_Checklist__c WHERE WFG_Agent_Code__c =:agentCode].Onboarding_Opportunity__r.CloseDate;
        }
        catch (Exception e)
        {
            return Date.today().addMonths(9);
        }
    }
    
    @AuraEnabled
    public static String loggedInUserName()
    {
        return loggedInUserName;
    }
    
    @AuraEnabled
    public static WFG_LaunchProfile_Wrapper getLaunchProfile()
    {
        String agentCode = loggedInUserAgentCode();
        String startDate = agentCode_SMDApprovalDate(agentCode).format();
        String endDate = agentCode_CloseDate(agentCode).format();
        WFG_LaunchProfile_Wrapper profile = new WFG_LaunchProfile_Wrapper();
        profile.AgentCode = agentCode;
        profile.StartDate = startDate;
        profile.EndDate = endDate;
        //List<WFG_LaunchProfile_Wrapper> profiles = new List<WFG_LaunchProfile_Wrapper>();
        //profiles.add(profile);
        return profile;
    }
    
    @AuraEnabled
    public static LIST<WFG_MyTeamAndChecklist_Wrapper> getImmediateDownlines(String agentCode)
    {
        List<WFG_MyTeamAndChecklist_Wrapper> myTeamWrapper = new List<WFG_MyTeamAndChecklist_Wrapper>();

        List<Contact> contactObj = new List<Contact>();
        
        if(agentCode == null){ // this signifies logged in user
            User agentCodeLoggedInUser = [select id, WFG_Agent_Code__c from user where id= :UserInfo.getUserId()];
            contactObj = [select id from Contact 
                          where WFG_AgentCode__c= :agentCodeLoggedInUser.WFG_Agent_Code__c];
        }
        else{ // this signifies a downline's user record when we click on any prospect's record to fetch his/her downline.
            contactObj = [select id from contact where WFG_AgentCode__c= :agentCode];
        }        
        
        Map<Id,String> mapContactIdToName = new Map<Id,String>();
        LIST<String> listDownlineAgentCodes = new LIST<String>();
        
        Map<Id, WFG_MyTeamAndChecklist_Wrapper> mapLaunchWrapper = new Map<Id, WFG_MyTeamAndChecklist_Wrapper>();
        
        try{
            LIST<WFG_Onboarding_Checklist__c> ListOnboarding = [select id, Contact__r.Name,Contact__r.WFG_AgentCode__c,Contact__c,
                                                            Agency_Agreement_Approved__c
                                                            from WFG_Onboarding_Checklist__c
                                                            WHERE Recruiting_Contact__c = :contactObj[0].id];
            //fetch all downline's Information that is stored n their checklist record
            
            System.debug('onboarding size....'+ListOnboarding+'...on whom....'+contactObj[0].id);
            
            if(ListOnboarding.size() > 0) // to check if there is a downline.
            {
                for(WFG_Onboarding_Checklist__c opp : ListOnboarding)
                {
                    WFG_MyTeamAndChecklist_Wrapper wrapperDummy = new WFG_MyTeamAndChecklist_Wrapper();
                    if(opp.Agency_Agreement_Approved__c == true) // here we assume that once agency agreement is approved the agent has completed 
                        // all the tasks.
                    {
                        wrapperDummy.completed = true;

                    }else
                    {
                        wrapperDummy.completed = false;
                    }
                    wrapperDummy.downlineNames = opp.Contact__r.Name;   
                    mapContactIdToName.put(opp.Contact__c,opp.Contact__r.Name);
                    mapLaunchWrapper.put(opp.Contact__c,wrapperDummy);

                    listDownlineAgentCodes.add(opp.Contact__r.WFG_AgentCode__c); // we need agent codes to fetch their user information
                }

                For(User u : [select id, smallPhotoUrl, ContactId, WFG_Agent_Code__c 
                              from User where WFG_Agent_Code__c IN :listDownlineAgentCodes] ) // User object is primarily used to 
                                                                                        // obtain profile picture
                {
                    WFG_MyTeamAndChecklist_Wrapper wrapperDummy = mapLaunchWrapper.get(u.ContactId);
                    wrapperDummy.downlineImageURL = u.SmallPhotoUrl;
                    wrapperDummy.prospectsUserId = u.Id;
                }
               
                // here we sort according to the recruited date
                for(AggregateResult ListOnboardingChecklistForCount : [select count(id) downlinesProspectCount , 
                                                                       Recruiting_Contact__c 
                                                                   from WFG_Onboarding_Checklist__c 
                                                                   where Recruiting_Contact__c in : mapContactIdToName.keySet()
                                                                   group by Recruiting_Contact__c]) // used for getting downline's
                                                                                                // recruit contact
                {
                    Id c = (Id) ListOnboardingChecklistForCount.get('Recruiting_Contact__c');
                    WFG_MyTeamAndChecklist_Wrapper wrapperDummy = mapLaunchWrapper.get(c);
                    if(ListOnboardingChecklistForCount.get('downlinesProspectCount') == null)
                    {
                        wrapperDummy.downlinesProspect = 0;
                    }
                    else
                    {
                        wrapperDummy.downlinesProspect = (Integer)ListOnboardingChecklistForCount.get('downlinesProspectCount');
                    }
                }
                
                 //changed field in query from WFG_StartDate__c to WFG_SMDApprovalDate__c as part of W-028270 
                 LIST<WFG_AgentCode__c> ListProspectsAgentCodes = [select name,WFG_Contact__c,WFG_Contact__r.WFG_Type__c, WFG_SMDApprovalDate__c, 
                                                                   WFG_Contact__r.MailingStreet,
                                                              WFG_Contact__r.MailingCity, WFG_Contact__r.MailingStateCode, 
                                                              WFG_Contact__r.HomePhone, WFG_Contact__r.MailingPostalCode, WFG_Contact__r.email  
                                                              from WFG_AgentCode__c
                                                              where WFG_AgentCode__c in :listDownlineAgentCodes 
                                                              order by WFG_SMDApprovalDate__c desc nulls last];
                
                For(WFG_AgentCode__c agent : ListProspectsAgentCodes)
                {
                    WFG_MyTeamAndChecklist_Wrapper wrapperDummy = mapLaunchWrapper.get(agent.WFG_Contact__c);
                    String dateText='';
                    if(agent.WFG_SMDApprovalDate__c !=null){
                       Datetime recruitedDate = datetime.newInstance(agent.WFG_SMDApprovalDate__c.year(), agent.WFG_SMDApprovalDate__c.month(),
                                                                  agent.WFG_SMDApprovalDate__c.day());
                       dateText= recruitedDate.format('MMM')+' '+recruitedDate.day()+', '+recruitedDate.year();
                     }
                    
                    wrapperDummy.recruitedDate = dateText;
                    wrapperDummy.street = agent.WFG_Contact__r.MailingStreet;
                    wrapperDummy.phone = agent.WFG_Contact__r.HomePhone;
                    wrapperDummy.email = agent.WFG_Contact__r.email;
                    wrapperDummy.city = agent.WFG_Contact__r.MailingCity;
                    wrapperDummy.state = agent.WFG_Contact__r.MailingStateCode;
                    wrapperDummy.pinCode= agent.WFG_Contact__r.MailingPostalCode;
                    wrapperDummy.strAgentCode = agent.Name;
                    wrapperDummy.strAgentType = agent.WFG_Contact__r.WFG_Type__c;  
                    
                    if(wrapperDummy.downlinesProspect == null)
                    {
                        wrapperDummy.downlinesProspect = 0;
                    }
                    
                    myTeamWrapper.add(wrapperDummy); 
                }
            }
            
        }catch(Exception e){
            system.debug('Exception in WFG_launch_team_controller class--' + e);
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_launch_team_controller', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }
        return myTeamWrapper; //finally you return the favour. Thank You.
    }   
}