/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Saurabh Sharma
* @date 1-30-2017
* @description  Wrapper class for WFG_AgentNewIndividualController to send status to Lightning Component

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Nitesh Kumar           M-001             3-1-2017            For Create/Update opportunity Controller
*/
public with sharing class WFG_OpportunityResponseWrapper {
    @AuraEnabled
	public WFG_ComponentResponseWrapper objGenericRes = new WFG_ComponentResponseWrapper();
	
    @AuraEnabled
    public Opportunity objOpportunity;
}