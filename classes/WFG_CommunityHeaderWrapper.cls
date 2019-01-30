/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Saurabh Sharma
* @date 2-27-2017
* @description Community Header Structure

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Saurabh Sharma        M-001             2-27-2017         Community Header Structure
*/
public class WFG_CommunityHeaderWrapper {
    
    @AuraEnabled
    public String strFieldName; 
    @AuraEnabled
    public String strFieldValue;    
    @AuraEnabled
    public String strlookupId;
    
    //constructor
    public WFG_CommunityHeaderWrapper(String strFieldName, String strFieldValue, String strlookupId){
        
        this.strFieldName = strFieldName;
        this.strFieldValue = strFieldValue;
        this.strlookupId = strlookupId;
    }
}