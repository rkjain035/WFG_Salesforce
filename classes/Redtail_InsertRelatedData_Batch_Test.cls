/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Saravanan
* @date 23-JAN-2019
* @description - Test class for Redtail_InsertRelatedData_Batch

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Saravanan             Mod-01             23-JAN-2019             Test Class for Redtail_InsertRelatedData_Batch
*/
@isTest
Private with sharing class Redtail_InsertRelatedData_Batch_Test 
{
    @testSetup static void setup() {
        list<user> userList = new list<User>();
        WFG_Test_Data_Utility.createTriggerActivationRecords();
        
        User usr = WFG_Test_Data_Utility.createTestUser('FA US');
        usr.WFG_Agent_Code__c =  'RED12';
        insert usr;
        
        Account testAccount = WFG_Test_Data_Utility.createBranchOfficeTestRecord('Test Account', 'bC0de', 'USD');
        insert testAccount;
        
        Contact con = WFG_Test_Data_Utility.createContactTestRecord('Test 1', 'Contact 1', testAccount.Id, 'RED12', 2);
        insert con; 
        
        Id recTypeId = Schema.SObjectType.FinServ__ReciprocalRole__c.getRecordTypeInfosByName().get('Contact Role').getRecordTypeId();
        FinServ__ReciprocalRole__c resRole = new FinServ__ReciprocalRole__c();
        resRole.FinServ__RelationshipType__c = 'Contact Contact Relation';
        resRole.Name = 'Spouse';
        resRole.RecordtypeId = recTypeId;
        resRole.FinServ__InverseRole__c = 'Spouse';
        insert resRole;
        
        list<Redtail_Object_Mappings__c> lstMapping = new list<Redtail_Object_Mappings__c>();
        lstMapping.add(getmappingData('mapping1','US',false,false,'Contact','Redtail_Mailing_Country__c','mailingCountry'));
        lstMapping.add(getmappingData('mapping2','',false,false,'Contact','Redtail_Primary_State__c','mailingState'));
        lstMapping.add(getmappingData('mapping3','',false,false,'Contact','Redtail_First_Name__c','FirstName'));
        lstMapping.add(getmappingData('mapping4','',false,false,'Contact','Redtail_Last_Name__c','LastName'));
        lstMapping.add(getmappingData('mapping5','example@example',false,false,'Contact','Redtail_Primary_Email__c','Email'));
        lstMapping.add(getmappingData('mapping6','0000000000',false,false,'Contact','Redtail_Primary_Phone__c','Phone'));
        
        lstMapping.add(getmappingData('mapping7','US',false,True,'Contact','Redtail_Mailing_Country__c','mailingCountry'));
        lstMapping.add(getmappingData('mapping8','',false,True,'Contact','Redtail_Spouse_State__c','mailingState'));
        lstMapping.add(getmappingData('mapping9','',True,True,'Contact','Redtail_Spouse_First_Name__c','FirstName'));
        lstMapping.add(getmappingData('mapping10','',True,True,'Contact','Redtail_Spouse_Last_Name__c','LastName'));
       lstMapping.add(getmappingData('mapping11','example@example.com',false,True,'Contact','Redtail_Spouse_Email__C','Email'));
        lstMapping.add(getmappingData('mapping12','0000000000',false,True,'Contact','Redtail_Spouse_Phone__c','Phone'));
        
        lstMapping.add(getmappingData('mapping13','',True,False,'Financial Account','Redtail_Account_Number__c','Name'));
        
        lstMapping.add(getmappingData('mapping14','',false,False,'Contact','Redtail_OwnerId__c','OwnerID'));
        lstMapping.add(getmappingData('mapping15','',false,True,'Contact','Redtail_OwnerId__c','OwnerID'));
        lstMapping.add(getmappingData('mapping16','',false,False,'Financial Account','Redtail_OwnerId__c','OwnerID'));
        
        lstMapping.add(getmappingData('mapping17','',false,False,'Contact','Redtail_ID__C','Redtail_ID__C'));
        lstMapping.add(getmappingData('mapping18','',false,False,'Contact','Redtail_ID__C','Redtail_ID__C'));
        
        insert lstMapping;
    }
    
    static testmethod void Batch_Insert(){
        
        user usr = [select id from user where WFG_Agent_Code__c =  'RED12' limit 1];
        Redtail__c redtail =  getmappingData(usr.Id);
        insert redtail;
        for(Contact con : [select id from contact]){
            if(redtail.Redtail_Created_ContactId__c == NULL)
                redtail.Redtail_Created_ContactId__c = con.Id;
            else if(redtail.Redtail_Created_SpouseConId__c == NULL)
                redtail.Redtail_Created_SpouseConId__c = con.Id;
        }
        update redtail;
        Redtail_createFinancialAccount.Redtail_createFinancialAccount(2);
        test.starttest();
            Database.executeBatch(new Redtail_InsertRelatedData_Batch(),30);
        test.stoptest();
        
    }
    
    static testmethod void Batch_Schedule(){
        String CRON_EXP = '0 0 0 3 9 ? 2052';
        String jobId = System.schedule('Redtail_Test_Schedule', CRON_EXP, new Redtail_InsertRelatedData_Schedule());
    }
    
    public static Redtail__c getmappingData(Id usrId)
    {
        Redtail__c redtail = new Redtail__c(); 
        redtail.Redtail_ID__C = '1123';
        redtail.Redtail_Mailing_Country__c = 'US'; 
        redtail.Redtail_Primary_State__c = 'FL';
        redtail.Redtail_First_Name__c = 'Test';
        redtail.Redtail_Last_Name__c = 'Test';
        redtail.Redtail_Primary_Email__c = 'test@email.com';
        redtail.Redtail_Primary_Phone__c = '0000000000';
        redtail.Redtail_Spouse_State__c = 'FL';
        redtail.Redtail_Spouse_First_Name__c = 'test Spouse';
        redtail.Redtail_Spouse_Last_Name__c = 'test Spouse';
        redtail.Redtail_Spouse_Email__C = 'test@email1.com';
        redtail.Redtail_Spouse_Phone__c = '0909090909';
        redtail.Redtail_Account_Number__c = '9988880';
        redtail.Redtail_OwnerId__c = usrId;
        redtail.Redtail_Agent_Id__c = 'RED12';
        redtail.Redtail_Last_Activity_Subject__c = 'test';
        redtail.Redtail_Last_Activity_Start_Date__c = system.today();
        redtail.Redtail_Next_Activity_Subject__c = 'test 1';
        Redtail.Redtail_Next_Activity_Start_Date__c = system.today();

        return redtail;
    }
    
    public static Redtail_Object_Mappings__c getmappingData(string strName, string strDefaultValue, Boolean isReq, Boolean isSpouse, string strObjName, string strFieldname, String strRelatedFieldName){
        Redtail_Object_Mappings__c mapping = new Redtail_Object_Mappings__c();
        mapping.Name = strName;
        mapping.Redtail_Default_Value__c = strDefaultValue;
        mapping.Redtail_Is_Required__c = isReq;
        mapping.Redtail_Is_Spouse__c = isSpouse;
        mapping.Redtail_Object_Name__c = strObjName;
        mapping.Redtail_Field_Name__c = strFieldname;
        mapping.Redtail_Related_Field_Name__c = strRelatedFieldName;
        
        return mapping;
    }
}