/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author bmadaan
* @date 12-08-2016
* @description  Wrapper class for Referral Selection screen

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Ninad Patil	         M-001             23-12-2016              Respomse wrapper from Apex to lightning component  
*/
public class WFG_ComponentResponseWrapper 
{
	@AuraEnabled
	public boolean boolIsError=false;
	
	@AuraEnabled
	public string strErrorMessage	;
	
	@AuraEnabled
	public string strSuccessMessage;
	
	@AuraEnabled
	public string strErrorCode;
	
	 
}