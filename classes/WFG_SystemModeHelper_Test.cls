/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author bmadaan
* @date 12-08-2016
* @description  Controller class for Referral Selection screen

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Ninad Patil          M-001             07-April-2016              Test CLass for WFG_SystemModeHepler Class
*/
@isTest
private  with sharing class WFG_SystemModeHelper_Test 
{
    public static List<Contact> lstContacts = new List<Contact>();
    public static List<WFG_Customer_Profile__c> lstCustrofile = new List<WFG_Customer_Profile__c>();
    public static List<WFG_Referral__c> lstReferral = new List<WFG_Referral__c>();
    /**
    @author Ninad Patil
    @date 22-Dec-2016
    @description create data for testing
    @return - WFG_ReferralResponseWrapper
    @param  - N/A
    @throws - N/A
    @author Ninad
    */
    static void craeteDataForReferral()
    {
        for(Integer intVar=0; intVar < 200; intVar++)
        {
            lstContacts.add(WFG_Test_Data_Utility.createContactTestRecord('firstName_' + intVar, 
            'lastName_' + intVar, null , '123' + intVar, 123 + intVar));
            lstContacts[intVar].Email = 'hgfdhgdf_'+ intvar + '@jhfg.com';
        }
        
        insert lstContacts;
        for(Integer intVar=0; intVar < lstContacts.size(); intVar++)
        {
            lstCustrofile.add(WFG_Test_Data_Utility.createCustomerProfile(lstContacts[intVar].id));
        }
        insert lstCustrofile;
        
    }
    /**
    @author Ninad Patil
    @date 22-Dec-2016
    @description testmethods for referral selection
    @return - WFG_ReferralResponseWrapper
    @param  - strReferralRecordId : referral ID
    @param  - actionName : Action performed on Referral record
    @throws - N/A
    @author Ninad
    */
    static testMethod void createReferralRecord_Test() 
    {       
        User objRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
        User objFAUser = WFG_Test_Data_Utility.createTestUser('FA US');
        insert objFAUser;
        
        system.runAs(objRRUser)
        {
            craeteDataForReferral();
            test.startTest();
            WFG_ReferralResponseWrapper objRefRes = WFG_ReferralSelection_Controller.getReferralSelectionWrap(lstCustrofile[0].id);
            
            objRefRes = WFG_ReferralSelection_Controller.createReferral(lstCustrofile[0].id, true, objFAUser.id);
            WFG_Referral__c objReferral = [Select id, name, WFG_customer_Profile__c FROM WFG_Referral__C 
                WHERE ID = :objRefRes.objRefferal.id];
            system.assertEquals(objReferral.WFG_Customer_Profile__c,lstCustrofile[0].id);
            test.stopTest();
        } 
    }
    
    /**
    @author Ninad Patil
    @date 04-April-2017
    @description testmethods for referral selection
    @return - None
    @param  - None
    @throws - N/A
    @author Ninad
    */
    static testMethod void getReferralRecord_Test() 
    {       
        User objRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
        User objFAUser = WFG_Test_Data_Utility.createTestUser('FA US');
        insert objFAUser;
        
        system.runAs(objRRUser)
        {
            craeteDataForReferral();
            test.startTest();
            
            WFG_Referral__c objref = WFG_Test_data_Utility.createReferral(lstCustrofile[0], objFAUser.id);
            lstReferral.add(objref);
            WFG_SystemModeHelper.createReferralRecord(lstReferral);
            test.stopTest();
        } 
    }
    /**
    @author Ninad Patil
    @date 04-April-2017
    @description testmethods for referral selection
    @return - None
    @param  - None
    @throws - N/A
    @author Ninad
    */
    static testMethod void getAgentCode_Test() 
    {   
        List<User> lstUsers = new List<User>();    
        User objRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
        objRRuser.WFG_Agent_Code__c = 'ABCD';
        lstUsers.add(objRRuser);
        
        User objFAUser = WFG_Test_Data_Utility.createTestUser('FA US');
        objFAUser.WFG_Agent_Code__c = 'PQRS';
        lstUsers.add(objFAUser);
        
        insert lstUsers;
        
        List<WFG_FAProfileNames__c > lstFAProfileName = new List<WFG_FAProfileNames__c>();
        WFG_FAProfileNames__c objName = new WFG_FAProfileNames__c(); 
        objName.Name = 'FA US'; 
        lstFAProfileName.add(objName);
        insert lstFAProfileName;
        
        system.runAs(objRRUser)
        {
            craeteDataForReferral();
            test.startTest();
            List<string> lstAgentCode = new List<String> {'ABCD','PQRS'};
            WFG_SystemModeHelper.getUserRecords(lstAgentCode);
            test.stopTest();
        } 
    }
    
    @testSetup static void setup() {
        list<user> userList = new list<User>();
        WFG_Test_Data_Utility.createTriggerActivationRecords();
        userList.add(WFG_Test_Data_Utility.createTestUser('RR US'));
        userList.add(WFG_Test_Data_Utility.createTestUser('FA US'));
        userList.add(WFG_Test_Data_Utility.createTestUser('RR TAN'));
        
        userList[0].WFG_Agent_Code__c =  'Te4t1';
        userList[1].WFG_Agent_Code__c =  'Te4t2';
        userList[2].WFG_Agent_Code__c =  'Te4t3';
        
        insert userList;
        
        Account testAccount = WFG_Test_Data_Utility.createBranchOfficeTestRecord('Test Account', 'bC0de', 'USD');
        insert testAccount;
        
        list<Contact> contactList = new list<Contact>();
        contactList.add(WFG_Test_Data_Utility.createContactTestRecord('Test 1', 'Contact 1', testAccount.Id, 'Te4t1', 2));
        contactList.add(WFG_Test_Data_Utility.createContactTestRecord('Test 2', 'Contact 2', testAccount.Id, 'Te4t2', 2));
        contactList.add(WFG_Test_Data_Utility.createContactTestRecord('Test 3', 'Contact 3', testAccount.Id, 'Te4t3', 2));
        
        insert contactList;
        
        WFG_EntitlementName__c entName = new WFG_EntitlementName__c(Name = 'WFG Leaders');
        insert entName;
        
        Id entitlementProcessId = [SELECT Id FROM SlaProcess WHERE SObjectType = 'Case' limit 1].Id;
                           
        Entitlement ent = new Entitlement (AccountId=testAccount.Id, SLAProcessId = entitlementProcessId, Name = 'WFG Leaders');
        insert ent;
    }
    
    static testMethod void scenario1()
    {
        list<Contact> contactList = [select id, WFG_AgentCode__c from Contact];
        case testCase = insertCase(contactList[0],contactList[1]);
        insert testCase;

        testCase.Status = 'Closed';
        testCase.WFG_Resolution__c = 'Case is resolved';
        testCase.SlaStartDate = system.today().adddays(-1);
        
        update testCase;
    }
    
    static testMethod void scenario2()
    {
        list<Contact> contactList = [select id, WFG_AgentCode__c from Contact];
        
        case testCase = insertCase(contactList[0],contactList[1]);
        testCase.ContactId = NULL;
        testCase.WFG_InteractingAbout__c = NULL;
        insert testCase;
        
        list<CaseTeamMember> caseTeamList = [select id from caseTeamMember Where ParentId =: testCase.Id];
        System.assertEquals(2, caseTeamList.size());
        
        Case insertedCase = [select id, ContactId, WFG_InteractingAbout__c, WFG_InteractingAboutCode__c, WFG_AgentCode__c from Case where id =: testCase.Id];
        
        insertedCase.ContactId = contactList[2].Id;
        insertedCase.WFG_AgentCode__c = contactList[2].WFG_AgentCode__c;
        insertedCase.WFG_InteractingAbout__c = contactList[2].Id;
        insertedCase.WFG_InteractingAboutCode__c = contactList[2].WFG_AgentCode__c;
        
        Test.startTest();
            update insertedCase;
        Test.stopTest();
        
        list<CaseTeamMember> caseTeamList_1 = [select id from caseTeamMember Where ParentId =: insertedCase.Id];
        System.assertEquals(1, caseTeamList_1.size());
    }
    
    static testMethod void scenario3()
    {
        list<Contact> contactList = [select id, WFG_AgentCode__c from Contact];
        
        case testCase = insertCase(contactList[0],contactList[1]);
        testCase.ContactId = NULL;
        testCase.WFG_InteractingAbout__c = NULL;
        insert testCase;
        
        list<CaseTeamMember> caseTeamList = [select id from caseTeamMember Where ParentId =: testCase.Id];
        System.assertEquals(2, caseTeamList.size());

        Case insertedCase = [select id, ContactId, WFG_InteractingAbout__c, WFG_InteractingAboutCode__c, WFG_AgentCode__c from Case where id =: testCase.Id];
        
        insertedCase.WFG_InteractingAbout__c = contactList[2].Id;
        insertedCase.WFG_InteractingAboutCode__c = contactList[2].WFG_AgentCode__c;
        
        Test.startTest();
            update insertedCase;
        Test.stopTest();
        
        list<CaseTeamMember> caseTeamList_1 = [select id from caseTeamMember Where ParentId =: insertedCase.Id];
        System.assertEquals(2, caseTeamList_1.size());
    }
    
    static testMethod void scenario4()
    {
        list<Contact> contactList = [select id, WFG_AgentCode__c from Contact];
        
        case testCase = insertCase(contactList[0],contactList[1]);
        testCase.ContactId = NULL;
        testCase.WFG_InteractingAbout__c = NULL;
        insert testCase;
        
        list<CaseTeamMember> caseTeamList = [select id from caseTeamMember Where ParentId =: testCase.Id];
        System.assertEquals(2, caseTeamList.size());

        Case insertedCase = [select id, ContactId, WFG_InteractingAbout__c, WFG_InteractingAboutCode__c, WFG_AgentCode__c from Case where id =: testCase.Id];
        
        Id contId = insertedCase.ContactId;
        String agentCode = insertedCase.WFG_AgentCode__c;
        
        insertedCase.ContactId = insertedCase.WFG_InteractingAbout__c;
        insertedCase.WFG_AgentCode__c = insertedCase.WFG_InteractingAboutCode__c;
        insertedCase.WFG_InteractingAbout__c = contId;
        insertedCase.WFG_InteractingAboutCode__c = agentCode;
        
        Test.startTest();
            update insertedCase;
        Test.stopTest();
        
        list<CaseTeamMember> caseTeamList_1 = [select id from caseTeamMember Where ParentId =: insertedCase.Id];
        System.assertEquals(2, caseTeamList_1.size());
    }
    
    static Case insertCase(Contact onbehalfOf, Contact aboutTo){
        Case testCase = new case();
        testCase.Origin = 'Phone';
        testCase.Type = 'Commissions';
        testCase.WFG_Case_Reason_2__c = 'Chargebacks';
        testCase.Subject = 'Test Subject';
        testCase.Description = 'Test Description';
        testCase.Status = 'New';
        testCase.ContactId = onbehalfOf.Id;
        testCase.WFG_AgentCode__c = onbehalfOf.WFG_AgentCode__c;
        testCase.WFG_InteractingAbout__c = aboutTo.Id;
        testCase.WFG_InteractingAboutCode__c = aboutTo.WFG_AgentCode__c;
        
        return testCase;
    }
}