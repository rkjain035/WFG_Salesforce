/****************************************************************************
Apex Class Name  : WFG_Referral_Test 
Version          : 1.0 
Created Date     : Jan 02, 2017
Function         : Test class to WFG_ReferralHomePage_Controller
Modification Log :
 * Modification ID		  Developer Name          Code Review                        Date                       Description
 *------------------------------------------------------------------------------------------------------------------------------
 * 1.0					  Bharat Madaan                                        	  01/02/2017                  Original Version
 * 2.0                    Karthik Raj                                             07/09/2018                  Add Test Method for ReferralListView All.
 **********************************************************************************************************************************/
@isTest
public class WFG_ReferralHomePage_Controller_Test {
	
    public static List<Contact> lstContacts = new List<Contact>();
    public static List<WFG_Customer_Profile__c> lstCustrofile = new List<WFG_Customer_Profile__c>();
    public static List<WFG_Referral__c> lstReferral = new List<WFG_Referral__c>();
    /**
    @author Ninad Patil
    @date 22-Dec-2016
    @description data Creation method
    @return - void
    @param  - NA
    @throws - N/A
    @author Ninad
    */
    static void craeteDataForReferral()
    {
       
        for(Integer intVar=0; intVar < 200; intVar++)
        {
            //WFG_Test_Data_Utility.createIndividualRecord('LL', 'Contact', '7878787878', 'Single');
            lstContacts.add(WFG_Test_Data_Utility.createIndividualRecord('firstName_' + intVar, 
            'lastName_' + intVar, '9867775643', 'Single'));
            lstContacts[intVar].email = 'asdfa_' + intVar + '@asdf.com'; 
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
    @description test methods for referral creation
    @return - void
    @param  - NA
    @throws - N/A
    @author Ninad
    */
    static testMethod void testMultipleActiveReferralADC() 
    {    
    	WFG_Test_Data_Utility.createTriggerActivationRecords();   
        User objRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
        User objFAUser = WFG_Test_Data_Utility.createTestUser('FA US');
        insert objFAUser;
        Test.startTest();
        system.runAs(objRRUser)
        {
            craeteDataForReferral();
            
            WFG_customer_Profile__c objProfile1 = WFG_Test_Data_Utility.createCustomerProfile(lstContacts[0].id);
            objProfile1.WFG_status__c = 'Complete';
            insert objProfile1;
                        
            WFG_ReferralResponseWrapper objRefRes = WFG_ReferralSelection_Controller.createReferral(objProfile1.id, true, objFAUser.id);
            WFG_ReferralHomePage_Controller.getReferrals();
            
            WFG_ReferralHomePage_Controller.checkNRFProfile();
            
        }
         
    }
    /**
    @author Karthik Raj
    @date 07-Jul-2018
    @description test methods for referral ListView 
    @return - void
    @param  - NA
    @throws - N/A
    @author Karthik
    */
    @isTest
    static void testAllListView()
    {
        String wfg_ReferralHomePage = WFG_ReferralHomePage_Controller.getReferralListViewID();
    }
}