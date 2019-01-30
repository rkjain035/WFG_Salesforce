@isTest
    private class WFG_TEST_CLASS_1
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
            WFG_Test_Data_Utility.createTriggerActivationRecords();
            for(Integer intVar=0; intVar < 200; intVar++)
            {
                lstContacts.add(WFG_Test_Data_Utility.createIndividualRecord('firstName_' + intVar, 
                'lastName_' + intVar, '9867775643', 'Single'));
                lstContacts[intVar].email = 'asdfa_' + intVar + '@asdf.com'; 
            }
            //insert lstContacts;
            List<Contact> lstDupCon = new List<Contact>();
            for(Integer intVar=201; intVar < 300; intVar++)
            {
                lstDupCon.add(WFG_Test_Data_Utility.createIndividualRecord('firstName_' + intVar, 
                'lastName_' + intVar, '9867775643', 'Single'));
                lstDupCon[intVar-201].email = 'asdfa_' + (intVar-201) + '@asdf.com'; 
            }
            //insert lstDupCon;
        }
        
         static testMethod void testReferralCreation() 
        {       
            User objRRUser = WFG_Test_Data_Utility.createTestUser(System.Label.WFG_RR_Label);
            User objFAUser = WFG_Test_Data_Utility.createTestUser(System.Label.WFG_FA_Label);
            insert objFAUser;
            Test.startTest();
            system.runAs(objRRUser)
            {
                craeteDataForReferral();
            }
            Test.stopTest();
        }
 }