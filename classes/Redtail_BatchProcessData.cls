/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Saravanan Haldurai
* @date 20-DEC-2018
* @description - Creates new Contact, Financial Account and spouse contact from the realted redtail record.

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
Saravanan Haldurai    W-028484           20-DEC-2018             Creates new Contact and spouse contact from the realted redtail record.
--------------------------------------------------------------------------------------------------------
*/ 
global with sharing class Redtail_BatchProcessData implements Database.batchable<String>, Database.Stateful
{   
    global map<string, string> mapCustomSetting;
    global map<Integer, string> mapHeaderValues;
    global map<string, Boolean> mapdateBoolean;
    global map<String, string> mapObjectInfo;
    global final string strValue;
    global final string strAgentCode;
    global final string strAgentOwnerId;
    
    global Redtail_BatchProcessData(string strBlobValue, string agentCode, string agentOwnerId){
        strValue = strBlobValue;
        strAgentCode = agentCode;
        strAgentOwnerId = agentOwnerId;
        system.debug('-- In Const--' + strBlobValue);
    }
    
    global Iterable<String> start(Database.batchableContext batchableContext){
        system.debug('---' + strValue);
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.PermissionSetId = [select id from permissionset where name = 'Redtail_Contact_Load_Permission'].Id;
        psa.AssigneeId = userinfo.getUserId();
        insert psa;
        return new Row_Iterator(strValue,'\n');
    }
    
    public void execute(Database.BatchableContext bc, List<String> scope)
    {
        system.debug('--strAgentCode--' + strAgentCode + '--strAgentOwnerId--' + strAgentOwnerId);
        boolean skipZeroIndex = false;
        
        if(mapHeaderValues == NULL){
            mapCustomSetting = new map<string, string>();
            mapHeaderValues = new map<integer, string>();
            mapdateBoolean = new map<string, Boolean>();
            mapObjectInfo = new map<String, string>();
            
            for(Redtail_Excel_Mappings__c mapping : Redtail_Excel_Mappings__c.getall().values())
            {
                mapCustomSetting.put(mapping.Redtail_Field_Label__c, mapping.Redtail_Field_API_Name__c);
                mapdateBoolean.put(mapping.Redtail_Field_API_Name__c, mapping.Redtail_IsDateTimeFormatChanged__c);
            }
            integer count = 0;
            for(string strHeader : scope[0].split(',')){
                system.debug('---Headers---' + strHeader);
                mapHeaderValues.put(count, strHeader);
                count++;
            }
            system.debug('--mapHeaderValues--' + mapHeaderValues.values().size()); 
            mapObjectInfo = getFieldDataType();
            skipZeroIndex = true;
        }
        list<Redtail__c> lstRedtailInsert = new list<Redtail__c>();
        set<String> setIds = new set<string>();
        for(string rowValue : scope){
            Integer countVal = 0;
            if(skipZeroIndex){
                skipZeroIndex = false;
                continue;
            }
            
            Integer startIndex;
            Integer endIndex;
            while(rowValue.indexOf('"') > -1){

                if(startIndex == null){
                    startIndex = rowValue.indexOf('"');
                    rowValue = rowValue.substring(0, startIndex) + ':quotes:' + rowValue.substring(startIndex+1, rowValue.length());
                }else{
                    if(endIndex == null){
                        endIndex = rowValue.indexOf('"');
                        rowValue = rowValue.substring(0, endIndex) + ':quotes:' + rowValue.substring(endIndex+1, rowValue.length());
                    }
                }
                
                if(startIndex != null && endIndex != null){
                    String sub = rowValue.substring(startIndex, endIndex);
                    sub = sub.replaceAll(',', ':comma:');
                    rowValue = rowValue.substring(0, startIndex) + sub + rowValue.substring(endIndex, rowValue.length());
                    startIndex = null;
                    endIndex = null;
                }
            }
            
            list<string> dataValues = new list<String>();
            boolean danger = true;
            string doubleQuoteValues = '';
            Redtail__c newRedtail = new Redtail__c();
            newRedtail.put('Redtail_Agent_Id__c',strAgentCode);
            newRedtail.put('Redtail_OwnerId__c',strAgentOwnerId);
            for(string doubleQu : rowValue.split(','))
            {
                try {
                    doubleQu = doubleQu.replaceAll(':quotes:', '').replaceAll(':comma:', ',');              
                    string headerLabel = mapHeaderValues.get(countVal).trim();
                    system.debug('--headerLabel--' + headerLabel + '--doubleQu--' +doubleQu);
                    string apiName = mapCustomSetting.get(headerLabel);
                    system.debug('--APIname--' + apiName);
                    if(apiName != NULL && doubleQu != NULL && doubleQu != '' && mapObjectInfo.containsKey(apiName)){
                        if(apiName.equalsIgnoreCase('Redtail_ID__c'))
                            setIds.add(doubleQu);
                            
                        string dataTypaVal = mapObjectInfo.get(apiName);
                        
                        if(dataTypaVal == 'STRING' || dataTypaVal == 'PICKLIST'){
                            newRedtail.put(apiName , doubleQu);
                        } else if(dataTypaVal == 'DOUBLE'){
                            newRedtail.put(apiName , decimal.valueOf(doubleQu));
                        } else if(dataTypaVal == 'NUMBER'){
                            newRedtail.put(apiName , Integer.valueOf(doubleQu));
                        } else if(dataTypaVal == 'BOOLEAN'){
                            newRedtail.put(apiName , Boolean.valueOf(doubleQu));
                        } else if(dataTypaVal == 'DATE'){
                            Date formattedDateVal = convertToFormattedDate(doubleQu);
                            newRedtail.put(apiName , formattedDateVal);
                        } else if(dataTypaVal == 'DATETIME'){
                            if(mapdateBoolean.containsKey(apiName) && mapdateBoolean.get(apiName)){
                                DateTime formattedDateTimeVal = convertToFormattedDateTime(doubleQu);
                                newRedtail.put(apiName , formattedDateTimeVal);
                            } else {
                                newRedtail.put(apiName , DateTime.valueOf(doubleQu));
                            }
                        } else {
                            newRedtail.put(apiName , doubleQu);
                        }
                    }
                    countVal++;
                } catch(Exception e) {
                    system.debug('-- Exception-- ' + e);
                }
            }
            lstRedtailInsert.add(newRedtail);
        }
        system.debug('-lstRedtailInsert-' + lstRedtailInsert.size());
        list<Database.SaveResult> lstRedtailInsertResule = Database.insert(lstRedtailInsert, false);
    }
    
    global void finish(Database.batchableContext info){   
        Id PermissionSet_Id = [select id from permissionset where name = 'Redtail_Contact_Load_Permission'].Id;
        delete [select id from PermissionSetAssignment where PermissionSetId =: PermissionSet_Id AND AssigneeId =: userinfo.getuserID()];
    }
    
    public static Map<String, String> getFieldDataType(){
        List<Schema.Sobjectfield> sObjectFieldsList = new List<Schema.Sobjectfield>();
        Map<string, String> fieldswithDataType = new Map<string, String>();
        Set<string> FieldNames = new Set<string>();
        sObjectFieldsList = Schema.getGlobalDescribe().get('Redtail__c').getDescribe().fields.getMap().values();
        for(Schema.Sobjectfield schemaField : sObjectFieldsList) {
            Schema.Describefieldresult FieldResult = schemaField.getDescribe();
            if( FieldResult.isUpdateable() && FieldResult.isCreateable()) {
                FieldNames.add(FieldResult.getName().toLowerCase());
                fieldswithDataType.put(FieldResult.getName(),String.ValueOf(FieldResult.getType()));
            }               
        }
        return fieldswithDataType;
    }
    
    public static Date convertToFormattedDate(String fieldDateValue){
        if(fieldDateValue != Null){
            List<String> splittedValues = fieldDateValue.split('/');
            Integer dateValue = Integer.valueOf(splittedValues[1]);
            Integer monthValue = Integer.valueOf(splittedValues[0]);
            Integer yearValue = Integer.valueOf(splittedValues[2]);
            Date formattedDateVal = Date.newInstance(yearValue, monthValue, dateValue);
            return formattedDateVal; 
        }else{
            return null;
        }
    }
    
    public static DateTime convertToFormattedDateTime(String fieldDateTimeValue){
        if(fieldDateTimeValue != Null){
            List<String> splittedValues = fieldDateTimeValue.split(' ');
            List<String> splittedDateValues = splittedValues[0].split('/');
            Integer dateValue = Integer.valueOf(splittedDateValues[1]);
            Integer monthValue = Integer.valueOf(splittedDateValues[0]);
            Integer yearValue = Integer.valueOf(splittedDateValues[2]);
            List<String> splittedTimeValues = splittedValues[1].split(':');
            Integer hourValue = Integer.valueOf(splittedTimeValues[0]);
            Integer minuteValue = Integer.valueOf(splittedTimeValues[1]);
            DateTime formattedDateTime = DateTime.newInstance(yearValue, monthValue, dateValue, hourValue, minuteValue, 00);
            System.debug('**formattedDateTime :'+formattedDateTime);
            return formattedDateTime;
        }else{
            return null;
        }
        
    }
}