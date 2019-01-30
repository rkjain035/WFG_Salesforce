/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Samit
* @date 02-09-2017
* @description  Wrapper Class for Opportunity Sales Tool Component

*/
public class WFG_OpportunitySalesToolWrapper
{
    @AuraEnabled
    public WFG_ComponentResponseWrapper objGenericRes = new WFG_ComponentResponseWrapper();
    
    @auraEnabled
    public List<WFG_OptySalesToolWrapper> lstSalesTool;
    
    @auraEnabled
    public String strSSOEndpoint;
    
    @AuraEnabled
    public WFG_OpportunityInfo objOpportunity = new WFG_OpportunityInfo();
}