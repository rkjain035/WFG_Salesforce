/*
Property of Transamerica and Aegon companies. Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Nikhil More
* @date 16-03-2016
* @description US-2295: Single Sign on : User JIT provision logic implementation

Modification Log:
__________________________________________________________________________________________________________
Developer          ModNumber           Date                    Description
__________________________________________________________________________________________________________
Ninad	            M-001                            		Single Sign on : User JIT provision logic implementation
*/
@isTest
private class AutocreatedRegHandler1479334445544_Test 
{
	private static Contact objRRCon = new Contact();
	private static Contact objLLCon = new Contact();
	
	private static void createTestData()
	{
		WFG_test_Data_Utility.createTriggerActivationRecords();
		WFG_LLProfileNames__c objLL = new WFG_LLProfileNames__c(name='LL US');
		insert objLL;
		Account objAcc = WFG_test_Data_Utility.createBranchOfficeTestRecord('TestACC', '100A', 'USD');
		insert objAcc;
		objLLCon = WFG_test_Data_Utility.createContactTestRecord('firstName', 'lastName', objAcc.id, '1234A', 1);
		objLLCon.WFG_AgentPayType__c = 'WFG';
		objLLCon.WFG_Fiduciary_Advisor__c = false;
		objLLCon.WFG_CycleType__c = 'US';
		objLLCon.WFG_Type__c = 'Agent';
		objLLCon.WFG_AgentId__c = 'test_1234';
		objLLCon.Email = 'asdf@asdd.com';
		objLLCon.WFG_Status__c = 'Active';
		insert objLLCon;
		
		
	}
	
	private static void createTestErrData()
	{
		WFG_test_Data_Utility.createTriggerActivationRecords();
		WFG_LLProfileNames__c objLL = new WFG_LLProfileNames__c(name='LL TAN');
		insert objLL;
		Account objAcc = WFG_test_Data_Utility.createBranchOfficeTestRecord('TestACC', '100A', 'USD');
		insert objAcc;
		objLLCon = WFG_test_Data_Utility.createContactTestRecord('firstName1', 'lastName1', objAcc.id, '1234A', 1);
		objLLCon.WFG_AgentPayType__c = 'TAN';
		objLLCon.WFG_Fiduciary_Advisor__c = false;
		objLLCon.WFG_CycleType__c = '';
		objLLCon.WFG_Type__c = '';
		objLLCon.WFG_AgentId__c = 'test_1234';
		objLLCon.Email = 'asdf@asdd.com';
		objLLCon.WFG_Status__c = 'Active';
		insert objLLCon;
	}
	
	private static testMethod void testUserUpdate()
	{
		createTestData();
		Test.startTest();
		AutocreatedRegHandler1479334445544 objJIT = new AutocreatedRegHandler1479334445544();
		User objSAUser = WFG_Test_Data_Utility.createTestUser('System Administrator');
		system.runAs(objSAUser){
    		User objUser = objJIT.createUser(null, null, null,
            'Atest_1234', null, null);
		}
        string fedId = 'A' + objLLCon.WFG_AgentId__c;
        List<User> lstUser = [Select id, name,username from User Where federationidentifier = :fedId];
        system.debug('===lstUser===='+lstUser);
        system.assert(lstUser[0].username.contains('@transamerica.com'));
        objJIT.updateUser(lstUser[0].id, null, null, null,
        'Atest_1234', null, null);

        Test.stopTest();
        
        //system.assertNOTEquals(lstUser[0].username, lstUser[0].username);
	}
	
	private static testMethod void testUserErrUpdate()
	{
		createTestErrData();
		Test.startTest();
		AutocreatedRegHandler1479334445544 objJIT = new AutocreatedRegHandler1479334445544();
		User objUser = objJIT.createUser(null, null, null,
        'Atest_1234', null, null);
        string fedId = 'A' + objLLCon.WFG_AgentId__c;
        

        Test.stopTest();
        
        //system.assertNOTEquals(lstUser[0].username, lstUser[0].username);
	}
}