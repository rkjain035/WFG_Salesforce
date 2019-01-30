/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Samit
* @date 02-09-2017
* @description  Wrapper Class for Sales tool Wrapper

*/
public class WFG_OptySalesToolWrapper implements Comparable
{
    @auraEnabled
    public String strSalesToolName;
    @auraEnabled
    public String strName;
    @auraEnabled
    public String strSalesToolURL;
    @auraEnabled
    public Boolean boolShowLink = TRUE;
    @auraEnabled
    public Decimal decOrder;
    @auraEnabled
    public Boolean useSplash;
    @auraEnabled
    public Boolean usePopupSplash = false;
    @auraEnabled
    public Boolean isMSWorkstation = false;
    @auraEnabled
    public Boolean isCustomUrl = false;
    @auraEnabled
    public String strSalesToolActualURL;
    @auraEnabled
    public Boolean isParamRequired = false;
    
    public WFG_OptySalesToolWrapper(WFG_OptySalesToolLink__c objSalesToolConfig)
    {
        this.strSalesToolName = objSalesToolConfig.WFG_SalesToolName__c;
        this.decOrder = objSalesToolConfig.WFG_Order__c;
   //     this.strName = objSalesToolsConfig.ID;
        if(objSalesToolConfig.WFG_SSO_Switch__c)
            this.strSalesToolURL = objSalesToolConfig.WFG_SSO_Link__c;
        else
            this.strSalesToolURL = objSalesToolConfig.WFG_SalesToolURL__c;
        if(this.strSalesToolURL == NULL || this.strSalesToolURL == '')
            this.boolShowLink = false;
        
        if(objSalesToolConfig.Wfg_Use_Splash__c)
            this.useSplash = true;
        if(objSalesToolConfig.WFG_SalesToolName__c.contains('Morningstar Advisor Workstation'))
        {
            this.isMSWorkstation = true;
        }
         
        if(strSalesToolURL.toUpperCase().contains('WFG_SSO_'))
        {
            this.isCustomUrl = true;
            try
            {
                //Get the custom settings for WFG_SSO_Links 
            	WFG_SSO_Links__c SSOLinks = WFG_SSO_Links__c.getValues(strSalesToolURL);
            	this.strSalesToolActualURL = (String)SSOLinks.Url__c;
                
                //get Salesforce popup splash
                if(this.strSalesToolActualURL.contains('popup'))
                {
                	this.usePopupSplash = true;
                }
            }
            catch(Exception e)
            {
                this.strSalesToolActualURL = e.getMessage();
            }
            
            //check if required query parameters
            if(!strSalesToolURL.toUpperCase().contains('WFG_SSO_NOPARAM_'))
            {
                this.isParamRequired = true;
            }
        }
        else
        {
           this.strSalesToolActualURL = strSalesToolURL; 
           this.isCustomUrl = false;
        }
    }
    
    public Integer compareTo(Object compareTo) {
        WFG_OptySalesToolWrapper objCompareTo = (WFG_OptySalesToolWrapper)compareTo;
        return Integer.valueOf(this.decOrder - objCompareTo.decOrder);
    }

}