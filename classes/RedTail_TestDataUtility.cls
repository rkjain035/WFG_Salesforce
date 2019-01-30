/**
*
Property of Transamerica and Aegon companies. Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Leela Palani
* @date  01/11/2019
* @description  Utility class for RedTail import file controller

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number        Date                     Description
--------------------------------------------------------------------------------------------------------
Leela                 M-001             11-JAN-2019              W-028484 : Utility class for redTail import file controller
*/

public class RedTail_TestDataUtility {
    
    
    public static Account createBranchOfficeTestRecord(String accountName, String branchCode, String curr)
    {
        Account acc = new Account();
        ID rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch Office').getRecordTypeId();
        acc.Name = accountName;
        acc.WFG_BranchCode__c = branchCode;
        acc.recordTypeId = rtId;
        acc.CurrencyIsoCode = curr;
        return acc;       
    }
    
    public static Contact createContactTestRecord(String firstName, 
                                                  String lastName, 
                                                  ID accountId, 
                                                  String agentCode, 
                                                  Decimal agentLevel)
    {
        Contact testContact = new Contact();
        ID conId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        testContact.FirstName = firstName;
        testContact.LastName = lastName;
        testContact.RecordTypeId = conId;
        testContact.AccountId = accountId;
        testContact.WFG_AgentCode__c = agentCode;
        testContact.WFG_AgentLevel__c = agentLevel;
        return testContact;
    }
    
    public static User createTestUser(String profileName)
    {
        Profile p = [select name, id from profile where name= :profileName]; 
        String testUserName = String.valueOf(System.now().getTime()) + '@transamerica.com';
        User usr = new User( alias = 'TsClsUsr', email='testUser@transamerica.com',
                                emailencodingkey='UTF-8', lastname='TestUser1', languagelocalekey='en_US',
                                localesidkey='en_US', profileid = p.Id,
                                timezonesidkey='America/Denver', username=testUserName, isActive=true);
        return usr;
    }
    
    
    public static void createRedTailCustomSettings(){
        List<Redtail_Excel_Mappings__c> RedTailSetting = new list<Redtail_Excel_Mappings__c>{new Redtail_Excel_Mappings__c(Name = 'Data1',
                                                                                                                              Redtail_Field_Label__c = 'First Name', 
                                                                                                                              Redtail_Field_API_Name__c = 'Redtail_First_Name__c'),
                                                                                             new Redtail_Excel_Mappings__c(Name = 'Data2',
                                                                                                                               Redtail_Field_Label__c = 'Account Loan Balance', 
                                                                                                                               Redtail_Field_API_Name__c = 'Redtail_Account_Loan_Balance__c'),
                                                                                             new Redtail_Excel_Mappings__c(Name = 'Data3',
                                                                                                                               Redtail_Field_Label__c = 'Date Of Birth',
                                                                                                                               Redtail_Field_API_Name__c = 'Redtail_Date_Of_Birth__c'),
            																				 new Redtail_Excel_Mappings__c(Name = 'Data4',
                                                                                                                               Redtail_Field_Label__c = 'Input Date',
                                                                                                                               Redtail_Field_API_Name__c = 'Redtail_Input_Date__c'),
            																				 new Redtail_Excel_Mappings__c(Name = 'Data5',
                                                                                                                               Redtail_Field_Label__c = 'Is Smoker',
                                                                                                                               Redtail_Field_API_Name__c = 'Redtail_Is_Smoker__c'),
            																				 new Redtail_Excel_Mappings__c(Name = 'Data6',
                                                                                                                               Redtail_Field_Label__c = 'Account Company',
                                                                                                                               Redtail_Field_API_Name__c = 'Redtail_Account_Company__c'),
            																				 new Redtail_Excel_Mappings__c(Name = 'Data7',
                                                                                                                               Redtail_Field_Label__c = 'Experience Stocks',
                                                                                                                               Redtail_Field_API_Name__c = 'Redtail_Experience_Stocks__c'),
            																				 new Redtail_Excel_Mappings__c(Name = 'Data8',
                                                                                                                               Redtail_Field_Label__c = 'Bank Phone',
                                                                                                                               Redtail_Field_API_Name__c = 'Redtail_Bank_Phone__c'),
            																				 new Redtail_Excel_Mappings__c(Name = 'Data9',
                                                                                                                               Redtail_Field_Label__c = 'Next Activity Start Date',
                                                                                                                               Redtail_Field_API_Name__c = 'Redtail_Next_Activity_Start_Date__c',
                                                                                                                               Redtail_IsDateTimeFormatChanged__c = true),
            																				 new Redtail_Excel_Mappings__c(Name = 'Data10',
                                                                                                                               Redtail_Field_Label__c = 'ID',
                                                                                                                               Redtail_Field_API_Name__c = 'Redtail_ID__c'),
            																				 new Redtail_Excel_Mappings__c(Name = 'Data11',
                                                                                                                               Redtail_Field_Label__c = 'Full Name',
                                                                                                                               Redtail_Field_API_Name__c = 'Redtail_Full_Name__c'),
            																				 new Redtail_Excel_Mappings__c(Name = 'Data12',
                                                                                                                               Redtail_Field_Label__c = 'Spouse First Name',
                                                                                                                               Redtail_Field_API_Name__c = 'Redtail_Spouse_First_Name__c'),
            																				 new Redtail_Excel_Mappings__c(Name = 'Data13',
                                                                                                                               Redtail_Field_Label__c = 'Spouse Last Name',
                                                                                                                               Redtail_Field_API_Name__c = 'Redtail_Spouse_Last_Name__c'),
            																				 new Redtail_Excel_Mappings__c(Name = 'Data14',
                                                                                                                               Redtail_Field_Label__c = 'Account Number',
                                                                                                                               Redtail_Field_API_Name__c = 'Redtail_Account_Number__c'),
            																				new Redtail_Excel_Mappings__c(Name = 'Data15',
                                                                                                                               Redtail_Field_Label__c = 'Account Product',
                                                                                                                               Redtail_Field_API_Name__c = 'Redtail_Account_Product__c')
            
            
            
            
            
                                                                                                                               


            };
            insert RedTailSetting;
    }

    public static String createContentDocumentRecord(){
        Blob fileBodyVal = blob.valueOf('Name,Account Loan Balance,ID,Date Of Birth,Input Date,Is Smoker,Account Company,Experience Stocks,Bank Phone,Next Activity Start Date,Full Name,Spouse First Name,Spouse Last Name,Account Number,Account Product\n'+
                                                                           '""Test1,28371.00827,89896,9/10/1948,2014-02-11 21:09:22 UTC,True,Evry India,0,9898789789,3/2/2016 6:00,test1,test SpouseFN,test Spouse LN,CF12345,test Product 1\n'+
                                                                           'Test2,31977.25197,89897,9/10/1948,,False,Folio Institutional,0,9898789878,3/8/2016 6:00,test2,test Spouse,test Spouse,CF123,test Product 2\n'+
                                                                           'Test3,0,89898,9/10/1948,2018-06-18 18:20:33 UTC,True,American Funds,0,9878897898,3/9/2016 6:00,test3,test SpouseFN,test Spouse LN,CF1234,test Product 3\n');
        ContentVersion cv = new ContentVersion();
        cv.title = 'test redTail file upload';      
        cv.PathOnClient = 'test';           
        cv.VersionData = fileBodyVal;          
        insert cv;         

        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        return testContent.ContentDocumentId;
        
    }
    
    public static String createContentDocumentWithoutBlob(){
        ContentVersion cv = new ContentVersion();
        cv.title = 'test redTail file upload';      
        cv.PathOnClient = 'test';           
        cv.VersionData = blob.valueOf(' ');          
        insert cv;         

        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        return testContent.ContentDocumentId;
        
    }
}