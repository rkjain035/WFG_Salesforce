global class WFG_ParseCSVFileBatchClass implements Database.Batchable<sObject> {
    
    global string blobFileValue;
    global WFG_ParseCSVFileBatchClass(String blobFileValue11){
        blobFileValue = blobFileValue11;
        System.debug('**blobFileValue :'+blobFileValue11);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        string s = 'select id from user limit 2';
        return database.getQueryLocator(s);
    }
    
    global void execute(Database.BatchableContext bc, List<User> scope){
        string agentCode = '619MR';
        string agentOwnerId = '0052F000002ze8z';
        boolean readSuccess = false;
        Map <String, Integer > fieldNumberMap = new Map < String, Integer > ();
        List<String> lstFieldNames = new List<String>();
        List<String> DataLines = new List<String>();
        List<String> csvFieldNames = new List<String>();
        
        String fieldValue;
        Integer fieldNumber;
        String existingId;
        Integer startIndex;
        Integer endIndex;
        
        Map<string, String> fieldDataTypeMap = new Map<string, String>();
        
        List<Redtail__c> rdObjList = new List<Redtail__c>();
        Redtail__c rdObj;
        
        Map<string, string> redTailSettingMap = new Map<String,String>();
        Map<string, Boolean> redTailSettingMapForDateTime = new Map<String,Boolean>();
        System.debug('**blobFileValue in excute :'+blobFileValue);  
        
        DataLines = blobFileValue.split('\n');
        csvFieldNames = DataLines[0].split(',');
        for (Integer i = 0; i < csvFieldNames.size(); i++) {
            fieldNumberMap.put(csvFieldNames[i], i);
            lstFieldNames.add(csvFieldNames[i].trim());
        }
        for (Integer i = 1; i < DataLines.size(); i++) {
            System.debug('**DataLines :'+DataLines[i]);
            List<String> csvRecordProperData = new List<String>();
            rdObj = new Redtail__c();
            string[] csvRecordData = DataLines[i].split(',');
            for(String column : csvRecordData){
                column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',').replaceAll(':newLine:', '\n');
                csvRecordProperData.add(column.trim());
            }
            
            for (String fieldName: csvFieldNames) {
                if(redTailSettingMap.containsKey(fieldName.trim())){
                    fieldNumber = fieldNumberMap.get(fieldName);
                    fieldValue = csvRecordData[fieldNumber];
                    if(string.isNotBlank(fieldValue) && fieldDataTypeMap.containsKey(redTailSettingMap.get(fieldName.trim())) )
                    {
                        System.debug('**field name and value:'+fieldName.trim() +'::'+fieldValue.trim()); 
                        if(fieldDataTypeMap.get(redTailSettingMap.get(fieldName.trim())) == 'STRING' ||
                           fieldDataTypeMap.get(redTailSettingMap.get(fieldName.trim())) == 'PICKLIST'){
                               rdObj.put(redTailSettingMap.get(fieldName.trim()), fieldValue);
                           }
                        else if(fieldDataTypeMap.get(redTailSettingMap.get(fieldName.trim())) == 'DOUBLE'){
                            rdObj.put(redTailSettingMap.get(fieldName.trim()),decimal.valueOf(fieldValue));
                        }
                        else if(fieldDataTypeMap.get(redTailSettingMap.get(fieldName.trim())) == 'DATE'){
                            Date formattedDateVal = convertToFormattedDate(fieldValue);
                            rdObj.put(redTailSettingMap.get(fieldName.trim()), formattedDateVal);
                        }
                        else if(fieldDataTypeMap.get(redTailSettingMap.get(fieldName.trim())) == 'NUMBER'){
                            rdObj.put(redTailSettingMap.get(fieldName.trim()), Integer.ValueOf(fieldValue));
                        }
                        else if(fieldDataTypeMap.get(redTailSettingMap.get(fieldName.trim())) == 'BOOLEAN'){
                            rdObj.put(redTailSettingMap.get(fieldName.trim()), Boolean.ValueOf(fieldValue));
                        }
                        else if(fieldDataTypeMap.get(redTailSettingMap.get(fieldName.trim())) == 'DATETIME'){
                            if(redTailSettingMapForDateTime.get(fieldName.trim())){
                                DateTime formattedDateTimeVal = convertToFormattedDateTime(fieldValue);
                                rdObj.put(redTailSettingMap.get(fieldName.trim()),formattedDateTimeVal);
                            }else{
                                rdObj.put(redTailSettingMap.get(fieldName.trim()),DateTime.valueOf(fieldValue));
                            }
                        }
                        else{
                            rdObj.put(redTailSettingMap.get(fieldName.trim()), fieldValue);
                        }
                    }
                }
            }
            rdObj.put('Redtail_Agent_Id__c',AgentCode);
            rdObj.put('Redtail_OwnerId__c',agentOwnerId);
            rdObjList.add(rdObj); 
        }
        
        if(rdObjList.size() > 0){
            try{
                insert rdObjList;
                readSuccess = TRUE;
            }catch(Exception ex){
                System.debug('***caught exception :'+ex.getMessage());
                LogUtility.createLogs('EXCEPTION', 'ERROR', 'Redtail_ParseCsvDataFile', 'EXCEPTION', 'APEX', ex.getMessage(), ex.getMessage(), null, null, null, true);
            }
            
        }
        
    }
        
global void finish(Database.BatchableContext bc){
    // execute any post-processing operations
}
private static Map<String, String> getFieldDataType(){
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
    
    /**
     * This method will convert the string to salesforce date format.
     * @return - Date
     * @see    - N/A
     * @param  - String - fieldDateValue
     * @throws - N/A
     */
    
    private static Date convertToFormattedDate(String fieldDateValue){
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
   
    /**
     * This method will convert the string to salesforce dateTime format.
     * @return - DateTime
     * @see    - N/A
     * @param  - String - fieldDateTimeValue
     * @throws - N/A
     */
    
    private static DateTime convertToFormattedDateTime(String fieldDateTimeValue){
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