/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Samit
* @date 02-15-2017
* @description  test class for WFG_OpportunityHandler

*/
@isTest
public class WFG_OpportunitySalesToolControllerTest {
    public static testmethod void testOpportunitySalesTool()
    {
        WFG_Test_Data_Utility.createTriggerActivationRecords();
        WFG_OptySalesToolLink__c objConfig = new WFG_OptySalesToolLink__c();
        objConfig.Name = 'Test Name 1';
        objConfig.WFG_Active__c =  TRUE;  
        objConfig.WFG_Order__c = 1;
        objCOnfig.WFG_Profile__c = 'FA US';
        objCOnfig.WFG_SalesToolName__c = 'Test';
        objConfig.WFG_Stage__c = 'Need Assesment';
        objConfig.WFG_SalesToolURL__c = 'www.test.com';
        objConfig.WFG_SSO_Switch__c = FALSE;
        INSERT objCOnfig;

        WFG_OptySalesToolLink__c objConfig2 = new WFG_OptySalesToolLink__c();
        objConfig2.Name = 'Test Name 2';
        objConfig2.WFG_Active__c =  TRUE;  
        objConfig2.WFG_Order__c = 2;
        objCOnfig2.WFG_Profile__c = 'FA US';
        objCOnfig2.WFG_SalesToolName__c = 'Test2';
        objConfig2.WFG_Stage__c = 'Need Assesment';
        objConfig2.WFG_SalesToolURL__c = 'www.yahoo.com';
        objConfig2.WFG_SSO_Switch__c = FALSE;

        INSERT objConfig2; 
            
        WFG_OptySalesToolLink__c objConfig3 = new WFG_OptySalesToolLink__c();
        objConfig3.Name = 'Test Name 3';
        objConfig3.WFG_Active__c =  TRUE;  
        objConfig3.WFG_Order__c = 3;
        objCOnfig3.WFG_Profile__c = 'FA US';
        objCOnfig3.WFG_SalesToolName__c = 'Test3';
        objConfig3.WFG_Stage__c = 'Need Assesment';
        objConfig3.WFG_SSO_Link__c = 'www.test3.com';
        objConfig3.WFG_SSO_Switch__c = TRUE;
        INSERT objCOnfig3;
        User objFAUser = WFG_Test_Data_Utility.createTestUser('FA US');
        INSERT objFAUser;
        
        Test.startTest();
        System.runAs(objFAUser)
        {
            Contact objContact = WFG_Test_Data_Utility.createIndividualRecord('Test', 'Contact', '1234567890', 'Single');
            INSERT objContact;
            WFG_Customer_Profile__c objCP = WFG_Test_Data_Utility.createCustomerProfile(objContact.Id); 
            objCp.WFG_Status__c = 'Complete';
            INSERT objCP;
            Opportunity objOpty = new Opportunity();
            objOpty.Name = 'Test 1';
            objOpty.StageName = 'Need Assesment';
            objOpty.WFG_CustomerProfile__c = objCP.Id;
            objOpty.WFG_Contact__c = objCP.WFG_Contact__c;
            objOpty.CloseDate = Date.Today();
            objOpty.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_OpportunityQualifiedRetirement).getRecordTypeId();
            objOpty.WFG_Source__c = System.Label.WFG_OpportunitySourceReferral;
            INSERT objOpty;
            System.debug(objOpty.Id);

            
            WFG_OpportunitySalesToolWrapper objRes = WFG_OpportunitySalesToolController.loadSalesTool(objOpty.Id);
            System.debug(objRes.lstSalesTool.size());
            System.assert(!objRes.lstSalesTool.isEmpty());
            System.assert(objRes.lstSalesTool[0].strSalesToolName == 'Test');
            
            WFG_OpportunitySalesToolController.getProfileName('asdf_NRF');
        }
        Test.stopTest();
    }  
}