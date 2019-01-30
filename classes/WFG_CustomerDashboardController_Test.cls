/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Nitesh Kumar
* @date 1-31-2017
* @description  Test Class for WFG_CustomerDashboardController

Modification Log:
-------------------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
-------------------------------------------------------------------------------------------------------------------
Nitesh Kumar          M-001             1-31-2017     Test class for unit testing WFG_CustomerDashboardController
Bharat Madaan		  M-002	            19-04-2017		Test failures resolved and Improved coverage
*/
@isTest
private class WFG_CustomerDashboardController_Test {
    
    /*
    Method to create test setup data
	*/
	@testSetup
	public static void setupData(){
		User currentUser = [Select Id, Name from User where Id=: UserInfo.GetUserId()];
        User objUser;
        Contact ObjCon;
        WFG_Test_Data_Utility.createTriggerActivationRecords();
		System.runAs(currentUser){
			ObjCon = WFG_Test_Data_Utility.createIndividualRecord('TestFname','TestLastName','9987988787','Single');
			if(ObjCon != null){
			insert ObjCon;
			}
            objUser = WFG_Test_Data_Utility.createTestUser('LL US');
            objUser.FirstName = 'Test LL';
        	objUser.LastName = 'User';  
			if(objUser != null){
			insert objUser;
			}
			WFG_Customer_Profile__c  objCustProfile = WFG_Test_Data_Utility.createCustomerProfile(ObjCon.Id);
			if(objCustProfile != null){
			insert objCustProfile;
			}
		}
	}
	
	/*
    Method to test getCustomerProfiles method.
	*/
    static testMethod void getContactDetailsTest() {
    	System.Test.StartTest();
    	User objUser = new User();    
    	objUser = [select Id from User where Profile.Name = 'LL US' LIMIT 1];
    	Contact objContact = [select id from Contact LIMIT 1];
	    Contact testCon = WFG_CustomerDashboardController.getContactDetails(String.valueOf(objContact.Id));    
    	System.assert(testCon != null);
        System.Test.StopTest();    
    }
    
    /*
    Method to test getCustomerProfiles method.
	*/
    static testMethod void updateContactTest() {
    	System.Test.StartTest();
    	User objUser = new User();
     	objUser = [select Id from User where Profile.Name = 'LL US' LIMIT 1];
       	Contact objContact = [select id from Contact LIMIT 1];
	   	WFG_CustomerDashboardController.updateContact(objContact);    
       	System.Test.StopTest();    
    }
}