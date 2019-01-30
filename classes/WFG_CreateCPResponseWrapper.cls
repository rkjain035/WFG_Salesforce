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
Saurabh Sharma        M-001             1-30-2017         US-405: Create new Customer Profile for Customer 
*/
public class WFG_CreateCPResponseWrapper {
	
    @AuraEnabled
	public WFG_ComponentResponseWrapper objGenericRes = new WFG_ComponentResponseWrapper();
	
    @AuraEnabled
    public WFG_Customer_Profile__c objCustProfile;
}