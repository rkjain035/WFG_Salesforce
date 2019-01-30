/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Deepthi Narayanappa
* @date 06-01-2018
* @description  This test class is for WFG_Launch_Training_Controller.

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Deepthi Narayanappa     Version 1.0     06/11/2018  This test class is for WFG_Launch_Training_Controller.
Girish S				Version 2.0		08/02/2018  Modified for updateSpotlightVideo() and getVideoInfo methods
*/
@isTest
public class WFG_Launch_Training_Controller_Test {
    
    static testMethod void GetTrainingMethod() {
        Test.startTest();
        //Insertion of Custom Setting WFG_TriggerActivation__c.
        WFG_TriggerActivation__c objTriggerActivation = new WFG_TriggerActivation__c(Object_Name__c = 'Account', Name ='WFG_Account', WFG_isActive__c = true);
        insert objTriggerActivation;  
        system.assert(objTriggerActivation != null);
        //Fetching Profile name from profile object.     
        Profile objProfileName = [Select id, name from Profile Where name =: 'Launch Blue US'];
        Profile objProfileNameCan = [Select id, name from Profile Where name =: 'Launch Blue CAN'];
        //Insertion of Account test record.
        Account objAcc = new Account();
        objAcc = WFG_Test_Data_Utility.createBranchOfficeTestRecord('AccountName', '12345', 'USD');        
        insert objAcc;
        system.assert(objAcc != null);
        Id RTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        //Insertion of Contact test record.
        Contact objctCon = new Contact();
        objctCon = WFG_Test_Data_Utility.createContactTestRecord('ConF', 'ConL', objAcc.id, '00HA1', 1);
        objctCon.WFG_AgentPayType__c = 'WFG';        
        objctCon.WFG_CycleType__c = 'US';
        objctCon.WFG_Type__c = 'Agent'; 
        objctCon.WFG_AgentId__c = 'X34121';
        objctCon.WFG_AgentCode__c = 'X34121';
        objctCon.WFG_Status__c = 'ACTIVE';
        objctCon.recordtypeId = RTId;    
        insert objctCon;
        system.assert(objctCon != null);
        // Insertion of User test record. 
        User objUser1 = WFG_Test_Data_Utility.createTestUser(objProfileName.Name);
        objUser1.FederationIdentifier = 'A12345'; 
        objUser1.contactid = objctCon.Id;
        insert objUser1;
        system.debug('UserName'+objUser1);
        system.assert(objUser1 != null);
        
        //Insertion of Article test record.
        WFG_Launch_Training__kav trainingUS = WFG_Test_Data_Utility.createKnowledgeArticle('TestOne', objProfileName.Name, 'US');
        insert trainingUS;
        
        system.debug('Training'+trainingUS);  
        system.assert(trainingUS != null); 
        //Fetching knowledgeArticleId from Article object to publish the article.       
        string articleId= [SELECT KnowledgeArticleId FROM WFG_Launch_Training__kav WHERE Id = :trainingUS.Id].KnowledgeArticleId ;
        KbManagement.PublishingService.publishArticle(articleId,true);   
        //Insertion of Datacategory test record.
        WFG_Launch_Training__DataCategorySelection dataCategory = new WFG_Launch_Training__DataCategorySelection();
        dataCategory.ParentId = trainingUS.Id;
        dataCategory.DataCategoryName = 'Sales_Basics';
        dataCategory.DataCategoryGroupName = 'Launch_Training';
        insert dataCategory;
        system.assert(dataCategory != null); 
        system.debug('dataCategory'+dataCategory);
        //Insertion of Document object test record.
        Document doc = new Document();
        doc.Body = Blob.valueOf('Some Text ');
        doc.ContentType = 'application/pdf';
        doc.DeveloperName = 'my_document';
        doc.IsPublic = true;
        doc.Name ='Thumbnail';
        doc.FolderId =objUser1.Id;
        insert doc;
        system.assert(doc != null); 
        //Fetching training related record by querying on Article object.
        List<WFG_Launch_Training__kav> lst_training = [SELECT id, title,Summary, WFG_Launch_Duration__c, WFG_Launch_Profiles__c, WFG_Launch_Status__c, WFG_Launch_Thumbnail_Image__c, WFG_Launch_Video_URL__c,(select DataCategoryName from DataCategorySelections) FROM WFG_Launch_Training__kav where WFG_Launch_Profiles__c includes (: trainingUS.WFG_Launch_Profiles__c) AND WFG_Launch_Status__c = true];
        system.debug('==training=='+lst_training);             
        system.assert(lst_training.size() > 0); 
        //Executing controller method as Launch US Test User.
        system.runAs(objUser1){               
            WFG_Launch_Training_Controller.getTrainingCategory();
            WFG_Launch_Training_Controller.getVideoInfo();
        }
        
        //insert of contact test record for CAN user
        Contact objctConCan = new Contact();
        objctConCan = WFG_Test_Data_Utility.createContactTestRecord('ConFN', 'ConLN', objAcc.id, '00HA1', 1);
        objctConCan.WFG_AgentPayType__c = 'WFG';        
        objctConCan.WFG_CycleType__c = 'CAN';
        objctConCan.WFG_Type__c = 'Agent'; 
        objctConCan.WFG_AgentId__c = 'X34121';
        objctConCan.WFG_AgentCode__c = 'X34121';
        objctConCan.WFG_Status__c = 'ACTIVE';
        objctConCan.recordtypeId = RTId;    
        insert objctConCan;
        system.assert(objctConCan != null);
        //insert of CAN user test record
        User objUserCan = WFG_Test_Data_Utility.createTestUser(objProfileNameCan.Name);
        objUserCan.FederationIdentifier = 'A12346'; 
        objUserCan.contactid = objctConCan.Id;
        insert objUserCan;
        //Executing controller method as Launch CAN Test User.
        system.runAs(objUserCan){               
            WFG_Launch_Training_Controller.getTrainingCategory();
            WFG_Launch_Training_Controller.getVideoInfo();
        }
        
        //Exceuting the method as System Admin
        WFG_Launch_Training_Controller.updateSpotlightVideo(new string[]{trainingUS.Id});
        
        WFG_Launch_Training__kav trainingCan =  WFG_Test_Data_Utility.createKnowledgeArticle('TestTwo', objProfileName.Name, 'CAN');            
        insert trainingCan;
        string articleCanId= [SELECT KnowledgeArticleId FROM WFG_Launch_Training__kav WHERE Id = :trainingCan.Id].KnowledgeArticleId ;
        KbManagement.PublishingService.publishArticle(articleCanId,true);
        WFG_Launch_Training_Controller.updateSpotlightVideo(new string[]{trainingCan.Id});
        
        WFG_Launch_Training__kav trainingUsCan =  WFG_Test_Data_Utility.createKnowledgeArticle('TestThree', objProfileName.Name, 'US;CAN');                       
        insert trainingUsCan;  
        string articleUsCanId= [SELECT KnowledgeArticleId FROM WFG_Launch_Training__kav WHERE Id = :trainingUsCan.Id].KnowledgeArticleId ;
        KbManagement.PublishingService.publishArticle(articleUsCanId,true); 
        WFG_Launch_Training_Controller.updateSpotlightVideo(new string[]{trainingUsCan.Id});
        
        WFG_Launch_Training__kav trainingCanOne =  WFG_Test_Data_Utility.createKnowledgeArticle('TestFour', objProfileName.Name, 'CAN');            
        insert trainingCanOne; 
                
        WFG_Launch_Training__kav trainingUSOne =  WFG_Test_Data_Utility.createKnowledgeArticle('TestFive', objProfileName.Name, 'US');            
        insert trainingUSOne; 
             
        WFG_Launch_Training__kav trainingUSCanOne =  WFG_Test_Data_Utility.createKnowledgeArticle('TestSeven', objProfileName.Name, 'US;CAN');            
        insert trainingUSCanOne; 
              
        Test.stopTest();
    }
}