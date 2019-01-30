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
Bharat Madaan          M-001             16-02-2017                
*/
@isTest
public class WFG_ReferralDetailController_Test {
    public static List<Contact> lstContacts = new List<Contact>();
    public static List<WFG_Customer_Profile__c> lstCustrofile = new List<WFG_Customer_Profile__c>();
    public static List<WFG_Referral__c> lstReferral = new List<WFG_Referral__c>();
	public static ID referralID;
 static void craeteDataForReferral()
    {
        WFG_Test_Data_Utility.createTriggerActivation();
        for(Integer intVar=0; intVar < 200; intVar++)
        {
            lstContacts.add(WFG_Test_Data_Utility.createContactTestRecord('firstName_' + intVar, 
            'lastName_' + intVar, null , '123' + intVar, 123 + intVar));
        }
        insert lstContacts;
        for(Integer intVar=0; intVar < lstContacts.size(); intVar++)
        {
            lstCustrofile.add(WFG_Test_Data_Utility.createCustomerProfile(lstContacts[intVar].id));
        }
        insert lstCustrofile;       
    }
    
    static testMethod void  testReturnReferral(){
        User objRRUser = WFG_Test_Data_Utility.createTestUser(System.Label.WFG_RR_Label);//'Registered Representative');
        User objFAUser = WFG_Test_Data_Utility.createTestUser(System.Label.WFG_RR_Label);//'Fiduciary Advisor');
        insert objFAUser;
        Test.startTest();
        system.runAs(objRRUser)
        {
            craeteDataForReferral();
            for(Integer intVar=0; intVar<lstCustrofile.size(); intVar ++)
            {
                lstReferral.add(WFG_Test_Data_Utility.createReferral(lstCustrofile[intVar], objFAUser.id));
            }
            lstReferral = WFG_SystemModeHelper.createReferralRecord(lstReferral); 
        }
        referralID = lstReferral[0].id;
        System.debug('#####################'+referralID);
        WFG_Referral__c referralObj = new WFG_Referral__c();
        referralObj = WFG_ReferralDetailController.getReferralDetail(referralID);
        System.assertNotEquals(null,referralObj);
        Test.stopTest();
    }  
    
    static testMethod void testcancelReferralAction(){
      WFG_ComponentResponseWrapper compRespWrapper =  WFG_ReferralDetailController.cancelReferralAction(referralID,'Cancel');
      System.assertNotEquals(null,compRespWrapper);  
    }
}