/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Saurabh Sharma
* @date 2-27-2017
* @description Community Header Utility class to construct data

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Saurabh Sharma        M-001             2-27-2017         Utility class to construct data
*/
public class WFG_CommunityHeaderUtility {
    
    /**
     * Method to fetch data for header
     * @return - WFG_CommunityHighlightPanel class object
     * @see    - N/A
     * @param  - String, String
     * @throws - N/A
    */ 
    public static WFG_CommunityHighlightPanel getHeaderData(String strRecordId, String strObject){

        String strQuery;
        sObject objRecord;
        
        WFG_CommunityHighlightPanel communityPanel;
        List<WFG_CommunityHeaderWrapper> lstHeaderData = new List<WFG_CommunityHeaderWrapper>();
        
        //get config setting from metadata
        List<WFG_CommunityHeaderConfig__mdt> lstHeaderConfig = [SELECT WFG_Field_API_Name__c, WFG_Field_Label__c, WFG_IsLookup__c, WFG_Lookup_Parent_Field__c, WFG_Object_API_Name__c, WFG_Order__c, WFG_Is_Hyperlink__c, 
                                                                WFG_Is_Field_Available_in_System__c FROM WFG_CommunityHeaderConfig__mdt WHERE WFG_Object_Name__c =: strObject ORDER BY WFG_Order__c];       
                
        //build query
        if(!lstHeaderConfig.isEmpty()){
            
            strQuery = 'SELECT Id, Name';
            strQuery += strObject.equalsIgnoreCase('Opportunity') ? ', RecordType.Name' : '';
            for(WFG_CommunityHeaderConfig__mdt fieldInfo : lstHeaderConfig){
                
                if(fieldInfo.WFG_Is_Field_Available_in_System__c){
                    if(!strQuery.containsIgnoreCase(fieldInfo.WFG_Field_API_Name__c)){
                        strQuery += ', ' + fieldInfo.WFG_Field_API_Name__c;
                    }                    
                    
                    if(fieldInfo.WFG_IsLookup__c){
                        strQuery += ', ' + fieldInfo.WFG_Lookup_Parent_Field__c;
                    }
                }               
            }
            
            strQuery += ' FROM '+ lstHeaderConfig[0].WFG_Object_API_Name__c + ' WHERE Id =: strRecordId';
        }
        
        System.debug('##Query -> '+strQuery);
        
        //fetch data
        if(strQuery != NULL && !String.isBlank(strQuery)){
            
            List<sObject> lstObject = Database.query(strQuery);
            
            if(!lstObject.isEmpty()){
                objRecord = lstObject[0];
            }
        }
        
        //reiterate on header config to create header data
        if(!lstHeaderConfig.isEmpty() && objRecord != NULL){
            
            for(WFG_CommunityHeaderConfig__mdt fieldInfo : lstHeaderConfig){
                String fieldLabel, fieldValue, lookupId;
                
                fieldLabel = fieldInfo.WFG_Field_Label__c;              
                
                if(fieldInfo.WFG_IsLookup__c){
                    if(!String.isBlank(String.valueOf(objRecord.get(fieldInfo.WFG_Field_API_Name__c)))){
                        fieldValue = String.valueOf(objRecord.getSobject(fieldInfo.WFG_Lookup_Parent_Field__c.substringBefore('.')).get(fieldInfo.WFG_Lookup_Parent_Field__c.substringAfterLast('.')));
                        if(fieldInfo.WFG_Is_Hyperlink__c){
                            lookupId = String.valueOf(objRecord.get(fieldInfo.WFG_Field_API_Name__c));
                        }                        
                    }
                }else if(fieldInfo.WFG_Is_Field_Available_in_System__c){
                    fieldValue = String.valueOf(objRecord.get(fieldInfo.WFG_Field_API_Name__c));
                
                }else if(!fieldInfo.WFG_Is_Field_Available_in_System__c){
                    if(strObject.equalsIgnoreCase('Contact') && fieldInfo.WFG_Field_Label__c.equalsIgnoreCase('Opportunities')){
                        fieldValue = getOpportunityCount(strRecordId);
                    }
                }
                
                if(strObject.equalsIgnoreCase('Opportunity') && (String.valueOf(objRecord.getSobject('RecordType').get('Name')).contains('Recruiting') && !fieldLabel.equalsIgnoreCase('Customer Profile') || (String.valueOf(objRecord.getSobject('RecordType').get('Name')).contains('Insurance')))){
                    lstHeaderData.add(new WFG_CommunityHeaderWrapper(fieldLabel, fieldValue, lookupId));
                }
                else if(!strObject.equalsIgnoreCase('Opportunity')){
                    lstHeaderData.add(new WFG_CommunityHeaderWrapper(fieldLabel, fieldValue, lookupId));
                }
            }
            
            String strRecordName = strObject.equalsIgnoreCase('Opportunity') ? String.valueOf(objRecord.getSobject('RecordType').get('Name')) : String.valueOf(objRecord.get('Name'));
            
            //issue fix related to record types of opportunity.
            if(strRecordName == 'InsuranceReadOnly'){
                strRecordName = 'Insurance';
            }
            else if(strRecordName == 'Investment/Savings Read Only'){
                strRecordName = 'Investment/Saving';
            }
             else if(strRecordName == 'Recruiting CANADA'){
                strRecordName = 'Recruiting';
            }
            
            communityPanel = new WFG_CommunityHighlightPanel(strRecordName, lstHeaderData);
        }        
        
        return communityPanel;
        
    }
    
    /**
     * Method to fetch Opportunity count
     * @return - String
     * @see    - N/A
     * @param  - String
     * @throws - N/A
    */ 
    private static String getOpportunityCount(String strRecordId){
        
        return String.valueOf([SELECT count() FROM Opportunity WHERE WFG_Contact__c =: strRecordId]);
    } 
}