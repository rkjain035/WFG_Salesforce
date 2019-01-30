@isTest
private class WFG_AD03_IntegrationHelper_test 
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
    static testMethod void testReferralCreationINT() 
    {       
        User objRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
        User objFAUser = WFG_Test_Data_Utility.createTestUser('FA US');
        insert objFAUser;
        
       
        
        system.runAs(objRRUser)
        {
            craeteDataForReferral();
            Map<string,WFG_IntegrationStubSwitch__c> mapCustset = WFG_IntegrationStubSwitch__c.getAll();
            WFG_IntegrationStubSwitch__c objCUST = mapCustset.get('AD03');
            objCUST.WFG_Stub_ON__c = false;
            update objCUST;
             Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new WFG_AD03_MockInterfcae());
            WFG_ReferralResponseWrapper objRefRes = WFG_ReferralSelection_Controller.getReferralSelectionWrap(lstCustrofile[0].id);
            system.assertNotEquals(objRefRes.objRefSelectfWrap, NULL);
             Test.stopTest();
        } 
       
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
    static testMethod void testReferralCreationINTNeg() 
    {       
        User objRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
        User objFAUser = WFG_Test_Data_Utility.createTestUser('FA US');
        insert objFAUser;
        system.runAs(objRRUser)
        {
            craeteDataForReferral();
            Map<string,WFG_IntegrationStubSwitch__c> mapCustset = WFG_IntegrationStubSwitch__c.getAll();
            WFG_IntegrationStubSwitch__c objCUST = mapCustset.get('AD03');
            objCUST.WFG_Stub_ON__c = false;
            update objCUST;
             Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new WFG_AD03_MOckInterfaceNeg());
            WFG_ReferralResponseWrapper objRefRes = WFG_ReferralSelection_Controller.getReferralSelectionWrap(lstCustrofile[0].id);
            system.assertNotEquals(objRefRes.objRefSelectfWrap, NULL);
             Test.stopTest();
        } 
       
    } 
}