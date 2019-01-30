/*
Property of Transamerica and Aegon companies. Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Nikhil More
* @date 16-03-2016
* @description US-2295: This class is test class for WFG_ContactViewExtController

Modification Log:
__________________________________________________________________________________________________________
Developer          ModNumber           Date                    Description
__________________________________________________________________________________________________________
Ninad             M-001               16-03-2016              Tesr class for WFG_ContactViewExtController
*/
@isTest
public class WFG_ContactViewExtController_Test 
{
    private static Account testAcc;
  	private static Contact testContact1;
    private static PageReference pageRef;
    
    /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Redirect users based on the record type of contact
    * @author Deloitte Consulting LLP
    * @date 16-03-2016 
    * @param None
    * @return void
    * @description Create data for test methods
    */
    static void createTestData()
    {
	    WFG_Test_Data_Utility.createTriggerActivationRecords();
	    Datetime d = System.now();
	    Time t = d.time();
	    String str = String.valueOf(t);    
	    testAcc = WFG_Test_Data_Utility.createBranchOfficeTestRecord('WFG11',str,'USD'); 
	    if(testAcc !=null){
	    insert testAcc;}
	    ID id = testAcc.Id; 
	    testContact1 =  WFG_Test_Data_Utility.createContactTestRecord('Loki','Gauren',id,'1234',20.10);
	        if(testContact1 !=null)
	        {insert testContact1;}    
	    ApexPages.StandardController stdController = new ApexPages.StandardController(testContact1);
	    WFG_ContactViewExtensionController contViewExtCont = new WFG_ContactViewExtensionController(stdController);
	    pageRef = contViewExtCont.redirectToViewLinks();
    }
    /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Redirect users based on the record type of contact
    * @author Deloitte Consulting LLP
    * @date 16-03-2016 
    * @param None
    * @return void
    * @description Create data for test methods
    */
    static void createTestDataNonAgent()
    {
	    WFG_Test_Data_Utility.createTriggerActivationRecords();
	    Datetime d = System.now();
	    Time t = d.time();
	    String str = String.valueOf(t);    
	    testContact1 = WFG_Test_Data_Utility.createIndividualRecord('firstName', 'LastName', '9867775632', 'Single');
	    insert testContact1;
	    ApexPages.StandardController stdController = new ApexPages.StandardController(testContact1);
	    WFG_ContactViewExtensionController contViewExtCont = new WFG_ContactViewExtensionController(stdController);
	    pageRef = contViewExtCont.redirectToViewLinks();
    }
    /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Redirect users based on the record type of contact
    * @author Deloitte Consulting LLP
    * @date 16-03-2016 
    * @param None
    * @return void
    * @description Create data for test methods
    */
    static testMethod void contactViewExtControllerTest()
    {
        Test.startTEst();
        createTestData();
        string strPageref = string.valueof(pageRef);
        Pagereference pg = new pagereference('/apex/WFG_Agent360Console?id='+testContact1.id);
        string strPG = string.valueOf(pg);
        system.assertEquals(strPageref,strPG);
        System.assertNotEquals(pageRef, null );
        Test.stopTest();
    }   
    
    /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Redirect users based on the record type of contact
    * @author Deloitte Consulting LLP
    * @date 16-03-2016 
    * @param None
    * @return void
    * @description Create data for test methods
    */
    static testMethod void contactViewExtControllerNonTest()
    {
        Test.startTEst();
        createTestDataNonAgent();
        string strPageref = string.valueof(pageRef);
        Pagereference pg = new pagereference('/apex/WFG_StandardContactView?id='+testContact1.id);
        string strPG = string.valueOf(pg);
        system.assertEquals(strPageref,strPG);
        System.assertNotEquals(pageRef, null );
        Test.stopTest();
    } 
}