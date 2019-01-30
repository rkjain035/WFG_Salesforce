/**
*
Property of Transamerica and Aegon companies. Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Leela Palani
* @date  01/09/2019
* @description  RedTail file import lightning component controller

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number        Date                     Description
--------------------------------------------------------------------------------------------------------
Leela                 M-001             09-JAN-2019              W-028484 : Search for Agent code and upload 
															     the RedTail file to the contact.
*/

public class Redtail_ImportCsvFilesCtrl {
    
    /**
     * This method fetches contact and user details based on agent code entered.
     * @return - fetchContactDetailsWrapper
     * @see    - N/A
     * @param  - String - contactAgentCode
     * @throws - N/A
     */
    @AuraEnabled
    public static fetchContactDetailsWrapper fetchContactId(String contactAgentCode){
        String returnValue;
        String agentOwnerId;
        Boolean isUserActive;
        
        if(contactAgentCode != Null && String.isNotBlank(contactAgentCode)){
            List<Contact> conRecList = [Select Id, WFG_AgentCode__c from Contact where WFG_AgentCode__c =: contactAgentCode];
            List<User> userList = [Select Id, WFG_Agent_Code__c, IsActive from User Where (WFG_Agent_Code__c =:contactAgentCode OR WFG_Agent_Code__c =:contactAgentCode+'_FSC')];
			
            if(!conRecList.isEmpty() && conRecList != Null){
                returnValue = conRecList[0].Id;
            }else{
                returnValue = null;
            }
            
            if(!userList.isEmpty() && userList != Null){
                isUserActive = userList[0].IsActive;
                agentOwnerId = userList[0].Id;
            }else{
                isUserActive = false;
                agentOwnerId = null;
            }
        }
        
        fetchContactDetailsWrapper wrapObj = new fetchContactDetailsWrapper(returnValue, isUserActive, false, agentOwnerId);
        return wrapObj;
    }
    
    public class fetchContactDetailsWrapper{
        @AuraEnabled
        public String contactId{get;set;}
        @AuraEnabled
        public Boolean isUserPresent{get;set;}
        @AuraEnabled
        public Boolean isAgentCodeBlank{get;set;}
        @AuraEnabled
        public String agentOwnerId{get;set;}
        
        
        public fetchContactDetailsWrapper(String contactId, Boolean isUserPresent, Boolean isAgentCodeBlank, String agentOwnerId){
            this.contactId = contactId;
            this.isUserPresent = isUserPresent;
            this.isAgentCodeBlank = isAgentCodeBlank;
            this.agentOwnerId = agentOwnerId;
        }
    }
    
    /**
     * This method uploads redTail file to the contact record.
     * @return - Boolean
     * @see    - N/A
     * @param  - List<String> - uploadedFilesList
     * @throws - N/A
     */
    @AuraEnabled
    public static Boolean uploadImportedFiles(List<String> uploadedFilesList, String agentCode, String agentOwnerId){
        
        Boolean isFileParsedToContact = FALSE;
        Boolean isFileUpdated = FALSE;
        List<Blob> uploadedFileDataList = new List<Blob>();
        List<ContentDocument> contentUpdateList = new List<ContentDocument>();
        
        if(uploadedFilesList != Null && uploadedFilesList.size() > 0){
            List<Attachment> attList = new List<Attachment>();
            
            for(ContentVersion cv : [SELECT Id, FileType, ContentDocumentId, Title, VersionData FROM ContentVersion where ContentDocumentId IN: uploadedFilesList]){
                uploadedFileDataList.add(cv.VersionData);
            }
            
            isFileParsedToContact = Redtail_ParseCsvDataFile.getAttachmentData(uploadedFileDataList[0], agentCode, agentOwnerId);
        }
        
        if(isFileParsedToContact){
            List<ContentDocument> conDocList = [Select Id, Title from ContentDocument where Id IN: uploadedFilesList];
                for(ContentDocument cdRec : conDocList){
                    cdRec.Title = cdRec.Title +'- File Parsed Successfully';
                    contentUpdateList.add(cdRec);
                }
            
            try{
            	update contentUpdateList;
                isFileUpdated = TRUE;
            }catch(Exception ex){
                System.debug('** caught exception :'+ex.getMessage());
                LogUtility.createLogs('EXCEPTION', 'ERROR', 'Redtail_ImportCsvFilesCtrl', 'EXCEPTION', 'APEX', ex.getMessage(), ex.getMessage(), null, null, null, true);
            }
        }
        return isFileUpdated;
    }
}