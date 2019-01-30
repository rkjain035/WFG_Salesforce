/**
*
Property of Transamerica and Aegon companies. Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Leela Palani
* @date  01/11/2019
* @description  Test class for Redtail_ParseCsvDataFile 

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number        Date                     Description
--------------------------------------------------------------------------------------------------------
Leela                 M-001             11-JAN-2019              W-028484 : Test class for Redtail_ParseCsvDataFile.
*/

@isTest
public class Redtail_ParseCsvDataFile_Test {
   
    static testmethod void uploadImportedFiles_withProperBlobData()
    {
        WFG_Test_Data_Utility.createTriggerActivationRecords();

        Account accObj = RedTail_TestDataUtility.createBranchOfficeTestRecord('Test 1','RT456','USD');
        insert accObj;
        
        Contact conObj = RedTail_TestDataUtility.createContactTestRecord('test conFN', 'test conLN', accObj.id, 'RT001L', 1);
        conObj.WFG_AgentPayType__c = 'WFG';
        conObj.WFG_Fiduciary_Advisor__c = false;
        conObj.WFG_CycleType__c = 'US';
        conObj.WFG_Type__c = 'Agent'; 
        conObj.WFG_AgentId__c = 'RT001L';
        conObj.WFG_Status__c = 'Active';
        insert conObj;
        
        User usr = RedTail_TestDataUtility.createTestUser('LL US');
        usr.WFG_Agent_Code__c =  'RT001L';
        insert usr;
        
        Id recTypeId = Schema.SObjectType.FinServ__ReciprocalRole__c.getRecordTypeInfosByName().get('Contact Role').getRecordTypeId();
        FinServ__ReciprocalRole__c resRole = new FinServ__ReciprocalRole__c();
        resRole.FinServ__RelationshipType__c = 'Contact Contact Relation';
        resRole.Name = 'Spouse';
        resRole.RecordtypeId = recTypeId;
        resRole.FinServ__InverseRole__c = 'Spouse';
        insert resRole;
        
        RedTail_TestDataUtility.createRedTailCustomSettings();
        String contentDocId = RedTail_TestDataUtility.createContentDocumentRecord();
        
        List<String> conDocList = new List<String>();
        conDocList.add(contentDocId);
          
        ContentVersion testContentcv = [SELECT id, Title, ContentDocumentId FROM ContentVersion where ContentDocumentId =: contentDocId];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = conObj.Id;
        contentlink.ShareType = 'V';
        contentlink.ContentDocumentId = contentDocId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        Test.startTest();
        Redtail_ImportCsvFilesCtrl.uploadImportedFiles(conDocList,conObj.WFG_AgentCode__c,usr.Id);
        Test.stopTest();
    }
    
    static testmethod void uploadImportedFiles_withNoBlobData()
    {
        RedTail_TestDataUtility.createRedTailCustomSettings();
        String contentDocId = RedTail_TestDataUtility.createContentDocumentWithoutBlob();
        
        List<String> conDocList = new List<String>();
        conDocList.add(contentDocId);
       
        ContentVersion testContentcv = [SELECT id, Title, ContentDocumentId FROM ContentVersion where ContentDocumentId =: contentDocId];
        
        Test.startTest();
        Redtail_ImportCsvFilesCtrl.uploadImportedFiles(conDocList,'test123',null);
        system.assert(!testContentcv.Title.contains('File Parsed Successfully'));
        Test.stopTest();
        
    }
}