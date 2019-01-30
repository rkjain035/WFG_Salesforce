/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Nitesh Kumar
* @date 1-20-2017
* @description  Test Class for WFG_AgentCustomerProfileController

Modification Log:
-------------------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
-------------------------------------------------------------------------------------------------------------------
Nitesh Kumar          M-001             1-20-2017     Test class for unit testing WFG_AgentCustomerProfileController  
Bharat Madaan         M-002             12-04-2017    Test failures resolved and Improved coverage
Girish.S			  M-003				04-06-2018	  Test failures resolved after PC to FSC Conversion	
*/
@isTest
private class WFG_AgentCustomerProfileController_Test {
    
    private static Account testAcc;
    
    /*
Method to create test setup data
*/
    @testSetup
    public static void setupData(){
        Contact partnerContact;
        User currentUser;
        WFG_Test_Data_Utility.createTriggerActivationRecords();
        currentUser = [Select Id, Name from User where Id=: UserInfo.GetUserId()];
        System.runAs(currentUser){
            Account objAcc = WFG_Test_Data_Utility.createBranchOfficeTestRecord('AccountName', '1234', 'USD');
            objAcc.WFG_BranchCode__c = '1234_test';
            insert objAcc;
            
            Contact objCon1 = WFG_Test_Data_Utility.createContactTestRecord('ConF', 'ConL', objAcc.id, '00HA', 1);
            objCon1.WFG_AgentPayType__c = 'WFG';
            objCon1.WFG_Fiduciary_Advisor__c = false;
            objCon1.WFG_CycleType__c = 'US';
            objCon1.WFG_Type__c = 'Registered_Rep'; 
            objCon1.WFG_AgentId__c = '12345';
            insert objCon1;
            User objUser = WFG_Test_Data_Utility.createTestUser('LL US');
            objUser.FirstName = 'Test LL';
            objUser.LastName = 'User';    
            //objUser.ContactId = objCon1.Id;
            if(objUser != null){
                insert objUser;
            }
        }    
        
        Datetime d = System.now();
        Time t = d.time();
        String str = String.valueOf(t);
        //  WFG_Test_Data_Utility.createTriggerActivationRecords(); 
        testAcc = WFG_Test_Data_Utility.createBranchOfficeTestRecord('WFG11',str,'USD'); 
        if(testAcc !=null){
            insert testAcc;}
        ID id = testAcc.Id;  
        Contact ObjCon = WFG_Test_Data_Utility.createContactTestRecord('Loki','Gauren',id,'1234',20.10);
        if(ObjCon != null){
            insert ObjCon;
        }
        WFG_Customer_Profile__c  objCustProfile = WFG_Test_Data_Utility.createCustomerProfile(ObjCon.Id);
        
        if(objCustProfile != null){
            insert objCustProfile;
            system.assertEquals(objCustProfile.WFG_Contact__c,ObjCon.Id);
        }
    } 
    
    /*
	Method to test getCustomerProfiles method.
	*/
    static testMethod void getCustomerProfilesTest() {
        Profile LLprofile = [Select Id, Name from Profile where Name='LL US' limit 1]; 
        User objUser = new User();
        objUser = [select Id,Name from User where ProfileId =: LLprofile.Id and FirstName = 'Test LL' and LastName = 'User' LIMIT 1];
        System.runAs(objUser){
            System.Test.StartTest();
            Account objAcc = WFG_Test_Data_Utility.createBranchOfficeTestRecord('TestAccount', '1234', 'USD');
            objAcc.WFG_BranchCode__c = '1234_test';
            insert objAcc;
            
            Contact objContact = WFG_Test_Data_Utility.createContactTestRecord('ConF', 'ConL', objAcc.id, '00HA', 1);
            objContact.WFG_AgentPayType__c = 'WFG';
            objContact.WFG_Fiduciary_Advisor__c = false;
            objContact.WFG_CycleType__c = 'US';
            objContact.WFG_Type__c = 'Registered_Rep'; 
            objContact.WFG_AgentId__c = '12345';
            insert objContact; 
            //Contact objContact = [select id from Contact LIMIT 1];
            WFG_AgentCustomerProfileController.getCustomerProfiles(String.valueOf(objContact.Id));
            System.Test.StopTest();
        }     
    }
    
    /*
Method to test getBrandUser method.
*/
    static testMethod void getBrandUserTest() {
        Profile LLprofile = [Select Id, Name from Profile where Name='LL US' limit 1]; 
        User objUser = new User();
        objUser = [select Id,Name from User where ProfileId =: LLprofile.Id and FirstName = 'Test LL' and LastName = 'User' LIMIT 1];
        System.runAs(objUser){
            System.Test.StartTest();
            WFG_AgentCustomerProfileController.getBrandUser();   
            System.Test.StopTest();   
        }
    } 
    /*
Method to test isUSUser method.
*/
    static testMethod void isUSUserTest() {
        Profile LLprofile = [Select Id, Name from Profile where Name='LL US' limit 1]; 
        User objUser = new User();
        objUser = [select Id,Name from User where ProfileId =: LLprofile.Id and FirstName = 'Test LL' and LastName = 'User' LIMIT 1];
        System.runAs(objUser){
            System.Test.StartTest();
            Boolean isUSuser =  WFG_AgentCustomerProfileController.isUSUser();    
            System.assert(isUSUser != null);
            System.Test.StopTest();   
        }
    }
}