/**
*
Property of Transamerica and Aegon companies. Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Leela Palani
* @date  01/01/2019
* @description  RedTail File Import

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number        Date                     Description
--------------------------------------------------------------------------------------------------------
Leela                 M-001             01-JAN-2019              W-028484 : Parse the file attached to contact record and store it in RedTail Object.
*/

public with sharing class Redtail_ParseCsvDataFile {
    
    /**
* This method will accept Blob data of uploaded file and parses the value.
* @return - Boolean
* @see    - N/A
* @param  - Blob - bodyVal
* @throws - N/A
*/
    
    public Static Boolean getAttachmentData(Blob bodyVal, string AgentCode, string agentOwnerId) {
        boolean readSuccess = FALSE;
        if(bodyVal == null){
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.FATAL,'There is no content in the File');ApexPages.addMessage(errormsg);
        } else if(bodyVal != null) {
            string strBodyValue = bodyVal.toString();
            Database.executeBatch(new Redtail_BatchProcessData(strBodyValue, AgentCode, agentOwnerId), 100);
            readSuccess = true;
        }
        
        return readSuccess;
    }
}