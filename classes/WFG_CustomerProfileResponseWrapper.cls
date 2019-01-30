/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author tlowe
* @date   12-14-2016  
* @description  

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Travis Lowe             M-001      4-19-2016        Wrapper class for Customer Profile Response
*/
public class WFG_CustomerProfileResponseWrapper 
{
    public WFG_CustomerProfileResponseWrapper(string contactId)
    {
        objRefSelectfWrap = new WFG_CustomerProfileSelection_Wrapper(contactId);
    }
    
  	@AuraEnabled
  	public WFG_ComponentResponseWrapper objGenericRes = new WFG_ComponentResponseWrapper();
  
    @auraEnabled 
    public Opportunity objOppty;
    
    @auraEnabled 
    public String contactId;
    
    @AuraEnabled
    public WFG_CustomerProfileSelection_Wrapper objRefSelectfWrap;
    
    @AuraEnabled
    public Boolean boolShowAcceptReject = FALSE;
    
    @auraEnabled
    public Boolean boolShowCancel = FALSE;
    
    @auraEnabled
    public Boolean boolShowComplete = FALSE;
    
    @auraEnabled
    public String strCustProfileId = '';
    
    @auraEnabled
    public WFG_Customer_Profile__c objCustomerProfile;
    
}