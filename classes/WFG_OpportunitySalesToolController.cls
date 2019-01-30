/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Samit
* @date 02-09-2017
* @description  Controller for OpportunitySalesTool Lightning Component

*/
public class WFG_OpportunitySalesToolController
{
    /**
     * This Utility Method return all the List of Sales Tool according to Profile & Stage.
     * @return - New Instance of WFG_OpportunitySalesToolWrapper which contains list of Sales Tool.
     * @param  - idOpty:  The Opportunity Id
     * @throws - N/A
     * @author Samit
     * @date 02-09-2017
     */
    @auraEnabled
    public static WFG_OpportunitySalesToolWrapper loadSalesTool(Id idOpty)
    {
        WFG_OpportunitySalesToolWrapper objRes = new WFG_OpportunitySalesToolWrapper();
        Id rectruitmentUSRecTypeId, rectruitmentCANRecTypeId;
        try
        {
            objRes.objGenericRes.boolIsError = FALSE;
            objRes.lstSalesTool = new List<WFG_OptySalesToolWrapper>();
            if(idOpty != NULL)
            {
                //Query The Opportunity
                Opportunity objOpty = [SELECT Id, StageName, OwnerId, recordtypeId FROM Opportunity WHERE Id = :idOpty LIMIT 1];
                String strStage = objOpty.StageName;
                String strAgentCode = RunningUserCtrl.getCurrentUser().WFG_Agent_Code__c;
                String strPacLifeStatus = WFG_AgentAppointments.getUserPacLifeStatus();
                
                Id profileId=userinfo.getProfileId();
                String strProfile =[Select Id,Name from Profile where Id=:profileId].Name;
                //if(objOpty.OwnerId != UserInfo.getUserId())
                
                    //Call the Utility Method
                    strProfile = getProfileName(strProfile);
                System.debug(strProfile + strStage);
                    objRes.lstSalesTool = WFG_OptySalesToolUtility.getSalesTool(strProfile, strStage, strPacLifeStatus);
                	System.debug('added ok');
                	objRes.objOpportunity = WFG_OptySalesToolUtility.GetOpportunity(idOpty);
                //check if the opportunity recordtype is Recruiting, hide the Sales Tools section. 
                rectruitmentUSRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_POP_OpportunityRecruitment).getRecordTypeId();    
                rectruitmentCANRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_POP_OpportunityRecruitment_CAN).getRecordTypeId();
                   
               
                if(objOpty.recordtypeId == rectruitmentUSRecTypeId || objOpty.recordtypeId == rectruitmentCANRecTypeId){
                    objRes.objGenericRes.boolIsError = TRUE;
                    objRes.objGenericRes.strErrorMessage = 'NO_SHOW';
                }
                
            }
        }
        catch(Exception e)
        {
            //Assign Error variables
            objRes.objGenericRes.boolIsError = TRUE;
            objRes.objGenericRes.strErrorMessage = e.getMessage();
        }
        return objRes;
    }
    
     /**
     * This Utility Method execute SSO from Salesforce to 3rd party providers through ISAM
     * @return - String if error out
     * @param  - providerName -the provider SSO to
     * @throws - N/A
     * @author Linda Liu
     * @date 01-09-2019
     */
    @auraEnabled
    public static WFG_OpportunitySalesToolWrapper SSOtoProvider(String opportunityId, String providerName)
    {
        WFG_OpportunitySalesToolWrapper objRes = new WFG_OpportunitySalesToolWrapper();
               // objRes.objGenericRes.strErrorMessage = 'opportunityId=' + opportunityId + ' providerName=' + providerName;
        try
        {
            //todo: define SSO for providerName
            objRes.objGenericRes.boolIsError = FALSE;
            if(providerName != NULL)
            {
                objRes.strSSOEndpoint = WFG_OptySalesToolUtility.GetProviderSSO(opportunityId, providerName);
            }
            else
            {
                objRes.objGenericRes.boolIsError = TRUE;
            	objRes.objGenericRes.strErrorMessage = 'Error: Missing Provider';
            }
        }
        catch(Exception e)
        {
            //Assign Error variables
            objRes.objGenericRes.boolIsError = TRUE;
            objRes.objGenericRes.strErrorMessage = e.getMessage();
        }
        return objRes;
    }
    
    
    @TestVisible
    private static string getProfileName(String strProfilename){

        if(strProfilename != null || strProfilename != '')
        {
            if(strProfilename.contains(system.Label.WFG_NonReferralSuffix))
            {
                Integer intVal = strProfilename.lastIndexOf(system.Label.WFG_NonReferralSuffix);
                if(intVal != -1)
                {
                    strProfilename = strProfilename.substring(0,intVal);
                }
            }
        }
        return strProfilename;
    }
}