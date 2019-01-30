/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author nipatil
* @date   12-14-2016	
* @description  

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Ninad Patil	           M-001			12-14-2016				Wrapper class for Contact creation Response
*/
public class WFG_CreateIndividualResponseWrapper 
{
	@AuraEnabled
	public WFG_ComponentResponseWrapper objGenericRes = new WFG_ComponentResponseWrapper();
	
    @AuraEnabled
    public Contact objContact;
    
}