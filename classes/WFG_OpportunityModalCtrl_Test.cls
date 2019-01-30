/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Ninad
* @date 19-April-2017 
* @description  Test CLass for WFG_OpportunityModalController

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Ninad Patil          M-001             19-April-2017             Test CLass for WFG_OpportunityModalController
*/

@isTest(seeAllData = false)
private class WFG_OpportunityModalCtrl_Test 
{
    public static List<Contact> lstContacts = new List<Contact>();
    public static List<WFG_Customer_Profile__c> lstCustrofile = new List<WFG_Customer_Profile__c>();
    public static List<WFG_Referral__c> lstReferral = new List<WFG_Referral__c>(); 
    public static WFG_Customer_Profile__c custProfile = new WFG_Customer_Profile__c();
    public static Opportunity objOpty;
    
    /**
    @author Ninad Patil
    @date 19-April-2017
    @description data Creation method
    @return - void
    @param  - NA
    @throws - N/A
    @author Ninad
    */
    static void craeteDataForReferral()
    {
        System.debug('#jeff log cdfr 1 ');
        WFG_Test_Data_Utility.createTriggerActivationRecords();
        for(Integer intVar=0; intVar < 20; intVar++)
        {
            //WFG_Test_Data_Utility.createIndividualRecord('LL', 'Contact', '7878787878', 'Single');
            lstContacts.add(WFG_Test_Data_Utility.createIndividualRecord('firstName_' + intVar, 
            'lastName_' + intVar, '9867775643', 'Single'));
            lstContacts[intVar].email = 'asdfa_' + intVar + '@asdf.com'; 
        }
        System.debug('#jeff jeff log cdfr 2 ');
        // System.DmlException: Insert failed. First exception on row 0; first error: 
        // REQUIRED_FIELD_MISSING, Required fields are missing: [TestingExt__c]: [TestingExt__c]
        insert lstContacts;
        System.debug('#jeff jeff log cdfr 2b ');
        for(Integer intVar=0; intVar < lstContacts.size(); intVar++)
        {
            lstCustrofile.add(WFG_Test_Data_Utility.createCustomerProfile(lstContacts[intVar].id));
            System.debug('#jeff jeff log cdfr 2b loop ' + intVar);
        }
        System.debug('#jeff log cdfr 3 ');
        insert lstCustrofile;
        System.debug('#jeff log cdfr 4 ');
        objOpty = new Opportunity();
        objOpty.Name = 'Test 1';
        objOpty.StageName = 'Need Assesment';
        objOpty.WFG_CustomerProfile__c = lstCustrofile[0].Id;
        objOpty.WFG_Contact__c = lstCustrofile[0].WFG_Contact__c;
        objOpty.CloseDate = Date.Today();
        objOpty.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_OppRecType_Insurance).getRecordTypeId();
        objOpty.WFG_Source__c = 'Direct';
        
        INSERT objOpty;
        System.debug('#jeff log cdfr 5 ');
        custProfile = WFG_Test_Data_Utility.createCustomerProfile(lstContacts[0].id);
       // Opportunity opportunity = WFG_Test_Data_Utility.createOppty(custProfile);
      //  WFG_CreateCPResponseWrapper responseWrapper = WFG_AgentNewCustomerProfileController.createNewCustomerProfile(JSON.serialize(custProfile),lstContacts[0].id,objOpty.id);       
        
        WFG_OpportunityModalController.getcustomerProfile(lstCustrofile[0].id);
   		System.debug('#jeff log cdfr 6 ');
   		
   		List<WFG_Customer_Profile__c> lstCpProfile = new List<WFG_Customer_Profile__c>();
   		for(Integer intVar=0; intVar < lstContacts.size(); intVar++)
        {
            lstCpProfile.add(WFG_Test_Data_Utility.createCustomerProfile(lstContacts[intVar].id));
            System.debug('#jeff jeff log cdfr 2b loop ' + intVar);
        }
        lstCpProfile[0].WFG_status__c = 'Incomplete';
        
        List<WFG_Customer_Profile__c> lstCp12 = new List<WFG_Customer_Profile__c>();
        lstCp12.add(lstCpProfile[0]);
        lstCp12.add(lstCpProfile[2]);
   		insert lstCp12;
   		WFG_OpportunityModalController.createNewCustomerProfile(JSON.serialize(lstCpProfile[1]), lstContacts[0].id, objOpty.id);
        WFG_OpportunityModalController.updateNewCustomerProfile(JSON.serialize(lstCpProfile[0]));
		WFG_OpportunityModalController.updateNewCustomerProfile(JSON.serialize(lstCustrofile[0]));
		WFG_OpportunityModalController.updateNewCustomerProfile('asdfasdf');
		WFG_OpportunityModalController.createNewCustomerProfile('asdfasdf', lstContacts[0].id, objOpty.id);
        
    }
    /**
    @author Ninad Patil
    @date 19-April-2017
    @description test methods for User profile changes
    @return - void
    @param  - NA
    @throws - N/A
    @author Ninad
    */
    static testMethod void testisUSUser() 
    {       
        User objRRUser = WFG_Test_Data_Utility.createTestUser(System.Label.WFG_RR_Label);
        User objFAUser = WFG_Test_Data_Utility.createTestUser(System.Label.WFG_FA_Label);
        insert objFAUser;
        Test.startTest();
        system.runAs(objRRUser)
        {
            WFG_OpportunityModalController.getEmploymentStatus();
            WFG_OpportunityModalController.getInsuranceType();
            WFG_OpportunityModalController.getAssetList();
            boolean boolIsUser = WFG_OpportunityModalController.isUSUser();
            system.assert(boolIsUser);
            
        }
        Test.stopTest();
    }
    
    /**
    @author Ninad Patil
    @date 19-April-2017
    @description test methods for Modal Name Changes
    @return - void
    @param  - NA
    @throws - N/A
    @author Ninad
    */
    static testMethod void testchangeModalNameBack() 
    {       
        User objRRUser = WFG_Test_Data_Utility.createTestUser(System.Label.WFG_RR_Label);
        User objFAUser = WFG_Test_Data_Utility.createTestUser(System.Label.WFG_FA_Label);
        insert objFAUser;
        Test.startTest();
        System.debug('#jeff log1 ');
        system.runAs(objRRUser)
        {
            System.debug('#jeff log2 ');
            craeteDataForReferral();
            System.debug('#jeff log3 ');
            String strRetVal = WFG_OpportunityModalController.changeModalNameBack(objOpty.Id);
            System.debug('#jeff log4 ');
            system.assertEquals(strRetVal,'The Opportunity Modal Name change back to null');
            
            List<WFG_Customer_Profile__c> lstCp = WFG_OpportunityModalController.getCustomerProfiles(objOpty.Id);
            System.debug('#jeff log5 ');
            //system.assertEquals(lstCp[0].id,objOpty.WFG_CustomerProfile__c);
            
            strRetVal = WFG_OpportunityModalController.saveButtonAction(objOpty.Id, objOpty.WFG_CustomerProfile__c, objOpty.stageName);
            system.assertEquals(strRetVal,'Customer Profile Successfully related to this Opportunity');
        }
        Test.stopTest();
    }
        
}