/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Samit
* @date 02-15-2017
* @description  test class for WFG_OpportunityHandler

*/
@isTest
public class WFG_Opportunity_HandlerTest {
    
   
    public static testmethod void testOpportunityTrigger()
    {
        User objRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
		User objFAUser = WFG_Test_Data_Utility.createTestUser('FA US');
        INSERT objRRUser;
		INSERT objFAUser;
        WFG_Test_Data_Utility.createTriggerActivationRecords();
        
        Test.startTest();
        System.runAs(objRRUser)
        {          
            Contact objContact = WFG_Test_Data_Utility.createIndividualRecord('Test', 'Contact', '1234567890', 'Single');
            INSERT objContact;
            WFG_Customer_Profile__c objCP = WFG_Test_Data_Utility.createCustomerProfile(objContact.Id); 
            objCp.WFG_Status__c = 'Complete';
            INSERT objCP;
            WFG_ReferralSelection_Controller.createReferral(objCP.Id , TRUE, objFAUser.Id);            
        }
        System.runAs(objFAUser)
        {
            WFG_Referral__c objReferral = [SELECT Id FROM WFG_Referral__c LIMIT 1];
            WFG_ReferralUtility.acceptReferral(objReferral.Id);
            WFG_Customer_Profile__c objCP = [SELECT Id, WFG_Contact__c, WFG_Contact__r.AccountId FROM WFG_Customer_Profile__c LIMIT 1];
            Opportunity objOpty = new Opportunity();
            objOpty.Name = 'Test 1';
            objOpty.StageName = 'Need Assesment';
            objOpty.WFG_CustomerProfile__c = objCP.Id;
            objOpty.WFG_Contact__c = objCP.WFG_Contact__c;
            objOpty.CloseDate = Date.Today();
            objOpty.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_OpportunityQualifiedRetirement).getRecordTypeId();
            objOpty.WFG_Source__c = System.Label.WFG_OpportunitySourceReferral;
            INSERT objOpty;
            System.assertEquals([SELECT WFG_Referral__c FROM Opportunity WHERE Id=: objOpty.Id].WFG_Referral__c, objReferral.Id);

            Opportunity objOpty2 = new Opportunity();
            objOpty2.Name = 'Test 2';
            objOpty2.StageName = 'Need Assesment';
            objOpty2.WFG_Referral__c = objReferral.Id;
            objOpty2.WFG_Contact__c = objCP.WFG_Contact__c;
            objOpty2.CloseDate = Date.Today();
            objOpty2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_OpportunityQualifiedRetirement).getRecordTypeId();
            objOpty2.WFG_Source__c = System.Label.WFG_OpportunitySourceReferral;
            INSERT objOpty2;
			System.assertEquals([SELECT WFG_CustomerProfile__c FROM Opportunity WHERE Id=: objOpty2.Id].WFG_CustomerProfile__c, objCP.Id);  
            
            Opportunity objOpty3 = new Opportunity();
            objOpty3.Name = 'Test 3';
            objOpty3.StageName = 'Need Assesment';
            objOpty3.WFG_Contact__c = objCP.WFG_Contact__c;
            objOpty3.CloseDate = Date.Today();
            objOpty3.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_OpportunityQualifiedRetirement).getRecordTypeId();
            INSERT objOpty3;
            objOpty.WFG_CustomerProfile__c = objCP.Id;
            objOpty3.WFG_Source__c = System.Label.WFG_OpportunitySourceReferral;
            UPDATE objOpty3;
            
            List<Opportunity> lstOpty = [Select Id,StageName, Name From Opportunity];
        	Map<id,Opportunity> lstOptyMap = new Map<Id, Opportunity>([Select Id, StageName,Name From Opportunity]);
       		system.assertEquals(lstOpty.size(), 3);
        	WFG_Opportunity_Handler.setupOpptModal(lstOpty,lstOptyMap);
                
            
			//System.assertEquals([SELECT WFG_Referral__c FROM Opportunity WHERE Id=: objOpty3.Id].WFG_Referral__c, objReferral.Id); 
        }
        Test.stopTest();
    }
	
}