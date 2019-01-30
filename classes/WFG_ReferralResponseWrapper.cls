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
Ninad Patil	           M-001			12-14-2016				Wrapper class for Referral Response
*/
public class WFG_ReferralResponseWrapper 
{
	@AuraEnabled
	public WFG_ComponentResponseWrapper objGenericRes = new WFG_ComponentResponseWrapper();
	
    @auraEnabled 
    public WFG_Referral__c objRefferal;
    
    @AuraEnabled
    public Contact objContact;
    
    @AuraEnabled
    public WFG_ReferralSelection_Wrapper objRefSelectfWrap = new WFG_ReferralSelection_Wrapper();
    
    @AuraEnabled
    public Boolean boolShowAcceptReject = FALSE;
    
    @auraEnabled
    public Boolean boolShowCancel = FALSE;
    
    @auraEnabled
    public Boolean boolShowComplete = FALSE;
    
    @auraEnabled
    public String strCustProfileId = '';
    
    @auraEnabled
    public User objUser;
    
}