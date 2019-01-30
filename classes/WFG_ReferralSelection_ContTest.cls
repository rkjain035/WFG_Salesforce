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
Bharat Madaan          M-001             12-08-2016              US-185: List of available FA for referral  
*/
@isTest
private class WFG_ReferralSelection_ContTest 
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
        WFG_Test_Data_Utility.createTriggerActivationRecords();
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
    static testMethod void testReferralCreation() 
    {       
        User objRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
        User objFAUser = WFG_Test_Data_Utility.createTestUser('FA US');
        insert objFAUser;
        
        Test.startTest();
        system.runAs(objRRUser)
        {
            craeteDataForReferral();
            WFG_ReferralResponseWrapper objRefRes = WFG_ReferralSelection_Controller.getReferralSelectionWrap(lstCustrofile[0].id);
            system.assertNotEquals(objRefRes.objRefSelectfWrap, NULL);
            
            objRefRes = WFG_ReferralSelection_Controller.checkQualifiedMoney(lstCustrofile[0].id);
            system.assertNotEquals(objRefRes.objGenericRes.boolIsError, true);
            
            objRefRes = WFG_ReferralSelection_Controller.createReferral(lstCustrofile[0].id, true, objFAUser.id);
            WFG_Referral__c objReferral = [Select id, name, WFG_customer_Profile__c FROM WFG_Referral__C 
                WHERE ID = :objRefRes.objRefferal.id];
            system.assertEquals(objReferral.WFG_Customer_Profile__c,lstCustrofile[0].id);
            
            WFG_ReferralResponseWrapper objRef = WFG_ReferralSelection_Controller.actionReferral(objRefRes.objRefferal.id, 'Cancel');
            objReferral = [Select id, name, WFG_customer_Profile__c,WFG_status__c FROM WFG_Referral__C 
                WHERE ID = :objRefRes.objRefferal.id];
            system.assertEquals(objReferral.WFG_status__c,System.Label.WFG_ReferralStatus_Cancelled);
        } 
        Test.stopTest();
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
    static testMethod void testReferralAccept() 
    {       
        User objRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
        User objFAUser = WFG_Test_Data_Utility.createTestUser('FA US');
        insert objFAUser;
        
        Test.startTest();
        system.runAs(objRRUser)
        {
            craeteDataForReferral();
            WFG_ReferralResponseWrapper objRefRes = WFG_ReferralSelection_Controller.getReferralSelectionWrap(lstCustrofile[0].id);
            system.assertNotEquals(objRefRes.objRefSelectfWrap, NULL);
            
            objRefRes = WFG_ReferralSelection_Controller.checkQualifiedMoney(lstCustrofile[0].id);
            system.assertNotEquals(objRefRes.objGenericRes.boolIsError, true);
            
            objRefRes = WFG_ReferralSelection_Controller.createReferral(lstCustrofile[0].id, true, objFAUser.id);
            WFG_Referral__c objReferral = [Select id, name, WFG_customer_Profile__c FROM WFG_Referral__C 
                WHERE ID = :objRefRes.objRefferal.id];
            system.assertEquals(objReferral.WFG_Customer_Profile__c,lstCustrofile[0].id);
            
            objRefRes = WFG_ReferralSelection_Controller.getPossibleActions(objReferral.id);
            system.assertEquals(objRefRes.boolShowCancel,true); 
            
            objRefRes = WFG_ReferralSelection_Controller.actionReferral(objRefRes.objRefferal.id, 'Cancel');
            objReferral = [Select id, name, WFG_customer_Profile__c,WFG_status__c FROM WFG_Referral__C 
                WHERE ID = :objRefRes.objRefferal.id];
            system.assertEquals(objReferral.WFG_status__c,System.Label.WFG_ReferralStatus_Cancelled);
            
            objRefRes = WFG_ReferralSelection_Controller.getPossibleActions(objReferral.id);
            system.assertEquals(objRefRes.objGenericRes.strErrorMessage,system.Label.WFG_ReadOnly_Referral);
            
            objRefRes = WFG_ReferralSelection_Controller.createReferral(lstCustrofile[0].id, true, objFAUser.id);
            objReferral = [Select id, name, WFG_customer_Profile__c FROM WFG_Referral__C 
                WHERE ID = :objRefRes.objRefferal.id];
            system.assertEquals(objReferral.WFG_Customer_Profile__c,lstCustrofile[0].id);
        } 
        
        system.runAs(objFAUser)
        {
            WFG_Referral__c objRef = [Select id, name , WFG_status__c
                from WFG_Referral__C Where WFG_Referred_To__c = :objFAUser.id];
            system.assertNotEquals(objRef, null);
            
            WFG_ReferralResponseWrapper objRefRes = WFG_ReferralSelection_Controller.getPossibleActions(objRef.id);
            system.assertEquals(objRefRes.boolShowAcceptReject,true);   
            
            objRefRes.objRefferal.WFG_Home_Country__C = WFG_PicklistFieldDescribeUtility.getPicklistValueLabel('Contact','MailingCountryCode', 'US');
            update objRefRes.objRefferal;
            objRefRes = WFG_ReferralSelection_Controller.actionReferral(objRefRes.objRefferal.id, 'Accept');
            WFG_Referral__c objReferral = [Select id, name, WFG_customer_Profile__c,WFG_status__c FROM WFG_Referral__C];
            system.assertEquals(objReferral.WFG_status__c,System.Label.WFG_ReferralStatus_Accepted);
            
            objRefRes = WFG_ReferralSelection_Controller.getPossibleActions(objReferral.id);
            system.assertEquals(objRefRes.boolShowComplete,true);
            
         // objRefRes = WFG_ReferralSelection_Controller.getFiduciaryUser('551QQ',lstCustrofile[0].id);
        } 
        Test.stopTest();
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
    static testMethod void testReferralCreationINt() 
    {       
        User objRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
        User objFAUser = WFG_Test_Data_Utility.createTestUser('FA US');
        insert objFAUser;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WFG_AD03_MockInterfcae());
        system.runAs(objRRUser)
        {
            craeteDataForReferral();
            Map<string,WFG_IntegrationStubSwitch__c> mapCustset = WFG_IntegrationStubSwitch__c.getAll();
            WFG_IntegrationStubSwitch__c objCUST = mapCustset.get('AD03');
            objCUST.WFG_Stub_ON__c = false;
            update objCUST;
            
            WFG_ReferralResponseWrapper objRefRes = WFG_ReferralSelection_Controller.getReferralSelectionWrap(lstCustrofile[0].id);
            system.assertNotEquals(objRefRes.objRefSelectfWrap, NULL);
            
            /*objRefRes = WFG_ReferralSelection_Controller.checkQualifiedMoney(lstCustrofile[0].id);
            system.assertNotEquals(objRefRes.objGenericRes.boolIsError, true);
            
            objRefRes = WFG_ReferralSelection_Controller.createReferral(lstCustrofile[0].id, true, objFAUser.id);
            WFG_Referral__c objReferral = [Select id, name, WFG_customer_Profile__c FROM WFG_Referral__C 
                WHERE ID = :objRefRes.objRefferal.id];
            system.assertEquals(objReferral.WFG_Customer_Profile__c,lstCustrofile[0].id);
            
            WFG_ReferralResponseWrapper objRef = WFG_ReferralSelection_Controller.actionReferral(objRefRes.objRefferal.id, 'Cancel');
            objReferral = [Select id, name, WFG_customer_Profile__c,WFG_status__c FROM WFG_Referral__C 
                WHERE ID = :objRefRes.objRefferal.id];
            system.assertEquals(objReferral.WFG_status__c,System.Label.WFG_ReferralStatus_Cancelled);*/
        } 
        Test.stopTest();
    }
    
    static testMethod void testgetFiduciaryUser() 
    {       
        User objRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
        User objFAUser = WFG_Test_Data_Utility.createTestUser('FA US');
        insert objFAUser;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WFG_AD03_MockInterfcae());
        system.runAs(objRRUser)
        {
            craeteDataForReferral();
            Map<string,WFG_IntegrationStubSwitch__c> mapCustset = WFG_IntegrationStubSwitch__c.getAll();
            WFG_IntegrationStubSwitch__c objCUST = mapCustset.get('AD03');
            objCUST.WFG_Stub_ON__c = false;
            update objCUST;
            
            WFG_ReferralResponseWrapper objRefRes = WFG_ReferralSelection_Controller.getFiduciaryUser(null,lstCustrofile[0].id);
            WFG_ReferralResponseWrapper objRefRes1 = WFG_ReferralSelection_Controller.getFiduciaryUser('551QQ',lstCustrofile[0].id);
            system.assertNotEquals(objRefRes.objRefSelectfWrap, NULL);
            
            String ContactId = WFG_ReferralSelection_Controller.getContactId(lstCustrofile[0].id);
            system.assertEquals(ContactId, [select WFG_Contact__c from WFG_Customer_Profile__c where Id = :lstCustrofile[0].id].WFG_Contact__c);
            
            String CustomerProfileName = WFG_ReferralSelection_Controller.getCustomerProfileName(lstCustrofile[0].id);
            System.assertEquals(CustomerProfileName, [SELECT Name FROM WFG_Customer_Profile__c where Id = :lstCustrofile[0].id].Name);
            
            Boolean testIFFAUser = WFG_ReferralSelection_Controller.isFAUser();
            System.assertEquals(testIFFAUser, False);
        }
    Test.stopTest();
    } 
    
    static testMethod void testReferralRejection() 
    {       
        User objRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
        User objFAUser = WFG_Test_Data_Utility.createTestUser('FA US');
        insert objFAUser;
        Test.setMock(HttpCalloutMock.class, new WFG_AD03_MockInterfcae());
        Test.startTest();
        system.runAs(objRRUser)
        {
            craeteDataForReferral();
            Map<string,WFG_IntegrationStubSwitch__c> mapCustset = WFG_IntegrationStubSwitch__c.getAll();
            WFG_IntegrationStubSwitch__c objCUST = mapCustset.get('AD03');
            objCUST.WFG_Stub_ON__c = false;
            update objCUST;
            WFG_ReferralResponseWrapper objRefRes = WFG_ReferralSelection_Controller.getReferralSelectionWrap(lstCustrofile[0].id);
            system.assertNotEquals(objRefRes.objRefSelectfWrap, NULL);
            
            objRefRes = WFG_ReferralSelection_Controller.checkQualifiedMoney(lstCustrofile[0].id);
            system.assertNotEquals(objRefRes.objGenericRes.boolIsError, true);
            
            objRefRes = WFG_ReferralSelection_Controller.createReferral(lstCustrofile[0].id, true, objFAUser.id);
            WFG_Referral__c objReferral = [Select id,WFG_Status__c, name, WFG_customer_Profile__c FROM WFG_Referral__C 
                WHERE ID = :objRefRes.objRefferal.id];
            objReferral.WFG_Status__c = 'Rejected';
            update objReferral;
            WFG_ReferralSelection_Controller.RemoveAgentsWhomHaveRejectedCPRef(lstCustrofile[0].id, objRefRes);
            } 
        
        Test.stopTest();
    }     
}