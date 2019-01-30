@isTest(seeAllData=false)
public class WFG_CustomerProfileSelController_Test {

    /*
    Method to create test setup data
    */
    @testSetup static void createSetupData() {
        WFG_Test_Data_Utility.createTriggerActivationRecords();
    }
    
    /*
	Test Method to test customer profile positive scenarios
	*/
    static testMethod void testCPPositiveCases(){ 
        User testRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
            testRRUser.FirstName = 'Test RR';
            testRRUser.LastName = 'User';
            insert testRRUser;
            System.runAs(testRRUser){
            System.Test.StartTest();
            WFG_CustomerProfileSelectionController.isUSUser();
            
            Contact testIndividualContact = WFG_Test_Data_Utility.createIndividualRecord('Test', 'Contact', '1234567890', 'Single');
            INSERT testIndividualContact;
            WFG_Customer_Profile__c custProfile = WFG_Test_Data_Utility.createCustomerProfile(testIndividualContact.Id);
            System.Test.StopTest();
        } 
    }
    
    /*
    Test Method to test customer profile negative scenarios
    */
    static testMethod void testCPNegativeCases(){
        User testRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
            testRRUser.FirstName = 'Test RR';
            testRRUser.LastName = 'User';
            insert testRRUser;         
        
        test.startTest();
        //do test stuff  
        System.runAs(testRRUser)
        {       
            Contact objContact = WFG_Test_Data_Utility.createIndividualRecord('Test', 'Contact', '1234567890', 'Single');
            INSERT objContact;
            WFG_Customer_Profile__c custProfile = WFG_Test_Data_Utility.createCustomerProfile(objContact.Id); 
            custProfile.WFG_Status__c = 'Complete';
            custProfile.WFG_Contact__c = objContact.Id;
            INSERT custProfile; 
            System.Test.StopTest();
        } 
    }
    
    static testmethod void TestAsRRUser() 
	{
            User testRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
            testRRUser.FirstName = 'Test RR';
            testRRUser.LastName = 'User';
            //testRRUser.ContactId = partnerContact.Id;  
            insert testRRUser;         
        
        test.startTest();
        //do test stuff  
        System.runAs(testRRUser)
        {       
            Contact objContact = WFG_Test_Data_Utility.createIndividualRecord('Test', 'Contact', '1234567890', 'Single');
            INSERT objContact;
            WFG_Customer_Profile__c objCP = WFG_Test_Data_Utility.createCustomerProfile(objContact.Id); 
            objCp.WFG_Status__c = 'Complete';
            objCp.WFG_Contact__c = objContact.Id;
            INSERT objCP; 
            Opportunity objOpty = new Opportunity();
            objOpty.Name = 'Test 1';
            objOpty.StageName = 'Need Assesment';
            objOpty.WFG_CustomerProfile__c = objCP.Id;
            objOpty.WFG_Contact__c = objContact.Id;
            objOpty.CloseDate = Date.Today();
            objOpty.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_OpportunityQualifiedRetirement).getRecordTypeId();
            objOpty.WFG_Source__c = System.Label.WFG_OpportunitySourceReferral;
            INSERT objOpty;
            WFG_CustomerProfileResponseWrapper resp = WFG_CustomerProfileSelectionController.getCustomerProfiles(String.valueOf(objOpty.Id));
            WFG_CustomerProfileSelectionController.updateOpptyWithCP(objOpty.Id,objCP.Id);
            WFG_CustomerProfileSelectionController.isUSUser();
            
            WFG_CustomerProfileSelectionController.updateOpptyWithCP(objOpty.Id,'testCPNegativeCases'); 

            
            Opportunity opp = new Opportunity(Stagename='Sale Won', Name='Test', closedate=system.today()-2);
            insert opp;
            WFG_CustomerProfileSelectionController.getCustomerProfiles(String.valueOf(opp.Id));
            
            
        }      
        test.stopTest();
    }
}