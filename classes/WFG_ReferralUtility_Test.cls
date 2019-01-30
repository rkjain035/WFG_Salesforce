/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author bmadaan, samit
* @date 12-28-2016
* @description  Test class for Referral Utility

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Bharat Madaan          M-001             12-28-2016  
Samit Bhoumick                           12-29-2016

*/

@istest
public class WFG_ReferralUtility_Test 
{
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
        static testMethod void testReferralCreation() 
        {    
          WFG_Test_Data_Utility.createTriggerActivationRecords();   
            User objRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
            User objRRUser1 = WFG_Test_Data_Utility.createTestUser('RR US');
            User objFAUser = WFG_Test_Data_Utility.createTestUser('FA US');
            insert objFAUser;
            Test.startTest();
            system.runAs(objRRUser)
            {
                craeteDataForReferral();
                list <Id> lstId = new List<Id>();
                for(Contact objContact : lstContacts)
                {
                  lstId.add(objContact.id);
                }
                lstContacts = [Select id, name, firstName, lastName,
                    MailingCountry, MailingState,MailingCity, MailingPostalCode,
                    MailingStreet from Contact WHERE Id IN : lstId];  
                WFG_ReferralResponseWrapper objRefRes = WFG_ReferralSelection_Controller.createReferral(lstCustrofile[0].id, true, objFAUser.id);
              WFG_Referral__c objReferral = [Select id, name, WFG_customer_Profile__c FROM WFG_Referral__C 
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
            
            //objRefRes = WFG_ReferralSelection_Controller.getFiduciaryUser('654654');
          } 
          system.runAs(objRRUser1)
            {
                COntact objCon = WFG_Test_Data_Utility.createIndividualRecord('firstName_0' , 
              'lastName_0' , '9867775643', 'Single');
              objCon.email = 'asdfa_0@asdf.com';
              insert objCon;
              
              WFG_CUstomer_Profile__c objCUST = WFG_Test_Data_Utility.createCustomerProfile(objCon.id);
              insert objCUST;
              
                objCon = [Select id, name, firstName, lastName,
                    MailingCountry, MailingState,MailingCity, MailingPostalCode,
                    MailingStreet from Contact WHERE Id =:objCon.id];  
                    
                WFG_ReferralResponseWrapper objRefRes = WFG_ReferralSelection_Controller.createReferral(objCUST.id, true, objFAUser.id);
              WFG_Referral__c objReferral = [Select id, name, WFG_customer_Profile__c FROM WFG_Referral__C 
              WHERE ID = :objRefRes.objRefferal.id];
              system.assertEquals(objReferral.WFG_Customer_Profile__c,objCUST.id);
            }
            system.runAs(objFAUser)
          {
            WFG_Referral__c objRef = [Select id, name , WFG_status__c
              from WFG_Referral__C Where WFG_Referred_To__c = :objFAUser.id AND WFG_STatus__c = 'Referred'];
            system.assertNotEquals(objRef, null);
            
            WFG_ReferralResponseWrapper objRefRes = WFG_ReferralSelection_Controller.getPossibleActions(objRef.id);
            system.assertEquals(objRefRes.boolShowAcceptReject,true);  
            
            objRefRes.objRefferal.WFG_Home_Country__C = WFG_PicklistFieldDescribeUtility.getPicklistValueLabel('Contact','MailingCountryCode', 'US');
            update objRefRes.objRefferal;
            objRefRes = WFG_ReferralSelection_Controller.actionReferral(objRefRes.objRefferal.id, 'Accept');
            
          }
          system.runAs(objRRUser1)
            {
                COntact objCon = WFG_Test_Data_Utility.createIndividualRecord('firstName_1' , 
              'lastName_0' , '9867775643', 'Single');
              objCon.email = 'asdfa_0@asdf.com';
              insert objCon;
              
              WFG_CUstomer_Profile__c objCUST = WFG_Test_Data_Utility.createCustomerProfile(objCon.id);
              insert objCUST;
              
                objCon = [Select id, name, firstName, lastName,
                    MailingCountry, MailingState,MailingCity, MailingPostalCode,
                    MailingStreet from Contact WHERE Id =:objCon.id];  
                    
                WFG_ReferralResponseWrapper objRefRes = WFG_ReferralSelection_Controller.createReferral(objCUST.id, true, objFAUser.id);
              WFG_Referral__c objReferral = [Select id, name, WFG_customer_Profile__c FROM WFG_Referral__C 
              WHERE ID = :objRefRes.objRefferal.id];
              system.assertEquals(objReferral.WFG_Customer_Profile__c,objCUST.id);
            } 
            system.runAs(objFAUser)
          {
            WFG_Referral__c objRef = [Select id, name , WFG_status__c
              from WFG_Referral__C Where WFG_Referred_To__c = :objFAUser.id AND WFG_STatus__c = 'Referred'];
            system.assertNotEquals(objRef, null);
            
         /*   WFG_ReferralResponseWrapper objRefRes = WFG_ReferralSelection_Controller.getPossibleActions(objRef.id);
            system.assertEquals(objRefRes.boolShowAcceptReject,true);  
            
            objRefRes.objRefferal.WFG_Home_Country__C = 'US';
            update objRefRes.objRefferal;
            objRefRes = WFG_ReferralSelection_Controller.actionReferral(objRefRes.objRefferal.id, 'Accept');
            */
          }
            Test.stopTest();
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
    static testMethod void testCustomerProfileCheck() 
    {    
      WFG_Test_Data_Utility.createTriggerActivationRecords();   
        User objRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
        User objRRUser1 = WFG_Test_Data_Utility.createTestUser('RR US');
        User objFAUser = WFG_Test_Data_Utility.createTestUser('FA US');
        insert objFAUser;
        Test.startTest();
        system.runAs(objRRUser)
        {
            craeteDataForReferral();
            WFG_ReferralResponseWrapper objRES = WFG_ReferralUtility.checkCustomerProfiles(lstCustrofile[0].id);
            
            WFG_customer_Profile__c objProfile = WFG_Test_Data_Utility.createCustomerProfile(lstContacts[0].id);
            objProfile.WFG_STatus__c = 'Incomplete';
            insert objProfile;
            
            objRES = WFG_ReferralUtility.checkCustomerProfiles(objProfile.id);
            system.assertEquals(objRES.objGenericRes.boolIsError, true);
            
            WFG_customer_Profile__c objProfile1 = WFG_Test_Data_Utility.createCustomerProfile(lstContacts[0].id);
            objProfile1.WFG_advisors_to_contact_you__c = 'No';
            objProfile1.WFG_status__c = 'Complete';
            insert objProfile1;
            objRES = WFG_ReferralUtility.checkCustomerProfiles(objProfile1.id);
            system.assertEquals(objRES.objGenericRes.boolIsError, true);
        }
         
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
    static testMethod void testMultipleActiveReferral() 
    {    
      WFG_Test_Data_Utility.createTriggerActivationRecords();   
        User objRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
        User objRRUser1 = WFG_Test_Data_Utility.createTestUser('RR US');
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
            
            objRefRes = WFG_ReferralUtility.checkCustomerProfiles(objProfile1.id);
            system.assertEquals(objRefRes.objGenericRes.boolIsError, true);
        }
         
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
        User objRRUser1 = WFG_Test_Data_Utility.createTestUser('RR US');
        User objFAUser = WFG_Test_Data_Utility.createTestUser('FA US');
        insert objFAUser;
        Test.startTest();
        system.runAs(objRRUser)
        {
            craeteDataForReferral();
            
            WFG_customer_Profile__c objProfile1 = WFG_Test_Data_Utility.createCustomerProfile(lstContacts[0].id);
            objProfile1.WFG_status__c = 'Complete';
            insert objProfile1;
                        
            WFG_ReferralResponseWrapper objRefRes = WFG_ReferralSelection_Controller.createReferral(objProfile1.id, false, objFAUser.id);
            Id refId = objRefRes.objrefferal.id;
            objRefRes = WFG_ReferralUtility.checkCustomerProfiles(objProfile1.id);
            system.assertEquals(objRefRes.objGenericRes.boolIsError, true);
            
            WFG_ReferralResponseWrapper objRefRes1 = WFG_ReferralUtility.updateReferral(refId, 'Reject');
             objRefRes1 = WFG_ReferralUtility.updateReferral(refId, 'Cancel');
             objRefRes1 = WFG_ReferralUtility.updateReferral(refId, 'Completed – Sold');
             objRefRes1 = WFG_ReferralUtility.updateReferral(refId, 'Completed – Not Sold');
        }
         
    }
    /*public static testmethod void testReferralCreation_1()
    {
        //Create a Registered Representative user
        user objRRuser = WFG_Test_Data_Utility.createTestUser('Registered Representative');
        if(objRRuser != NULL)
            INSERT objRRUser;
        //Create a Fiduciary Advisor User
        user objFAUser = WFG_Test_Data_Utility.createTestUser('Fiduciary Advisor');
        if(objFAUser != NULL)
            INSERT objFAUser;
        WFG_Test_Data_Utility.createTriggerActivationRecords();
        
        WFG_Referral__c objRef1;
        WFG_Referral__c objRef2;
        WFG_Referral__c objRef3;
        
        Test.startTest();
        System.runAs(objRRuser)
        {
            Contact objContact = new Contact(LastName = 'Test', FirstName = '123', MailingCountry = 'US', email = 'abc@abc.com');
            if(objContact != NULL)
                INSERT objContact;
            
            WFG_Customer_Profile__c objCustPrfl = WFG_Test_Data_Utility.createCustomerProfile(objContact);
            if(objCustPrfl != NULL)
                INSERT objCustPrfl;          
            WFG_ReferralResponseWrapper res1 = WFG_ReferralUtility.initiateReferral(objCustPrfl.Id, TRUE, objFAUser.Id);
            //Checks if a valid referral record is created or not
            System.assert(!([SELECT Id FROM WFG_Referral__c WHERE WFG_Customer_Profile__c = :objCustPrfl.Id AND WFG_Referred_To__c = :objFAUser.Id].isEmpty()));
            
            WFG_ReferralResponseWrapper res2 = WFG_ReferralUtility.initiateReferral(objCustPrfl.Id, TRUE, objFAUser.Id);
            //Validates that a duplicate referral is not created for a Customer Profile, if there is already active referral
            //System.assert(res2.objGenericRes.boolIsError);
            
            WFG_ReferralUtility.updateReferral(res1.objRefferal.Id, 'Cancel');
            WFG_ReferralResponseWrapper res3 = WFG_ReferralUtility.initiateReferral(objCustPrfl.Id, TRUE, objFAUser.Id);
            //Checks that once the previous referral is cancelled, The end user can succesfully create another referral for that Customer Profile
            System.assert(!res3.objGenericRes.boolIsError);
            objRef1 = res3.objRefferal;
            
            WFG_Customer_Profile__c objCustPrfl2 = WFG_Test_Data_Utility.createCustomerProfile(objContact);
            if(objCustPrfl2 != NULL)
                INSERT objCustPrfl2;
            WFG_ReferralUtility.initiateReferral(objCustPrfl2.Id, FALSE, NULL);
            //Checks if the Referral to Advice Center is successful or not
            System.assert([SELECT Id, WFG_Referral_Nature__c FROM WFG_Customer_Profile__c WHERE Id= : objCustPrfl2.Id].WFG_Referral_Nature__c == 'Referred to Advice Center');
          
            WFG_ReferralResponseWrapper res4 = WFG_ReferralUtility.initiateReferral(NULL, TRUE, NULL);
            //Checks the validation that Customer profile Id can not be NULL
            System.assert(res4.objGenericRes.boolIsError);
            
            WFG_Customer_Profile__c objCustPrfl3 = WFG_Test_Data_Utility.createCustomerProfile(objContact);
            if(objCustPrfl3 != NULL)
                INSERT objCustPrfl3;
            WFG_ReferralResponseWrapper res5 = WFG_ReferralUtility.initiateReferral(objCustPrfl3.Id, TRUE, objFAUser.Id);
            objRef2 = res5.objRefferal;
        }
        
        System.runAs(objFAUser)
        {
            WFG_ReferralResponseWrapper res6 = WFG_ReferralUtility.updateReferral(objRef1.Id, 'Accept');
            System.debug(res6);
            Id IdContact = res6.objContact.Id;
            //Checks that the FA can succesfully accept a referral
            System.assert(!res6.objGenericRes.boolIsError);
            
            WFG_ReferralResponseWrapper res7 = WFG_ReferralUtility.updateReferral(objRef1.Id, 'Reject');
            //Checks the validation that once accepted, a referral can not be rejected
            System.assert(res7.objGenericRes.boolIsError);
            
            WFG_ReferralResponseWrapper res8 = WFG_ReferralUtility.updateReferral(objRef2.Id, 'Accept');
            //Checks the de duplicate contact functionality, in this case the Contact is not cloned bcoz it has already existing Contact
            System.assert(!res8.objGenericRes.boolIsError);
            System.assert(IdContact == res8.objContact.Id);
        }
        
        System.runAs(objRRUser)
        {
            //WFG_ReferralResponseWrapper res9 = WFG_ReferralUtility.updateReferral(objRef2.Id, 'Accept');
            //Checks that a referral can not be Accepted once it is already accepted
            //System.assert(res9.objGenericRes.boolIsError);
            
            Contact objContact2 = new Contact(LastName = 'Test 2');
            if(objContact2 != NULL)
                INSERT objContact2;
            WFG_Customer_Profile__c objCustPrfl4 = WFG_Test_Data_Utility.createCustomerProfile(objContact2);
            if(objCustPrfl4 != NULL)
                INSERT objCustPrfl4;
            WFG_ReferralResponseWrapper res10 = WFG_ReferralUtility.initiateReferral(objCustPrfl4.Id, TRUE, objFAUser.Id);
            objRef3 = res10.objRefferal;
            objRef3.WFG_Contact_Last_Name__c = '';
            if(objRef3 != NULL && objRef3.Id != NULL)
                UPDATE objRef3;
        }
        
        System.runAs(objFAUser)
        {
            WFG_ReferralResponseWrapper res11 = WFG_ReferralUtility.updateReferral(objRef3.Id, 'Accept');
            //checks the functionality that a Contact is not created if referral record have insufficient data
            System.assert(res11.objGenericRes.boolIsError);
        }
        Test.stopTest();
        
    }*/
}