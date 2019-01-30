@isTest
public class WFG_OwnershipUpdate_Test 
{      
    private static Contact objctCon;
    private static User userLL;
    private static User userRR;
    
    @testSetup static void createTestData()
    {
        system.debug('Test Data');
        WFG_Test_Data_Utility.createTriggerActivationRecords(); // Added during Service Center changes before FSC Installation
        WFG_TestDataFactory.createWFGUtilityCustomSettingRecords();
        
        Profile itmProfile = [Select id, name from Profile Where name =: 'LL US'];
        Profile itmRRProfile = [Select id, name from Profile Where name =: 'RR US'];
        Account objAcc = WFG_Test_Data_Utility.createBranchOfficeTestRecord('AccountName', '12345', 'USD');
        //objAcc.IsPartner = true;
        insert objAcc;
        
        Id RTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Agent').getRecordTypeId();  
        objctCon = WFG_Test_Data_Utility.createContactTestRecord('ConF', 'ConL', objAcc.id, '00HA1', 1);
        objctCon.WFG_AgentPayType__c = 'WFG';
        //objCon.WFG_Fiduciary_Advisor__c = true;
        objctCon.WFG_CycleType__c = 'US';
        objctCon.WFG_Type__c = 'Agent'; 
        objctCon.WFG_AgentId__c = 'X34121';
        objctCon.WFG_AgentCode__c = 'X34121';
        objctCon.WFG_Status__c = 'ACTIVE';
        objctCon.recordtypeId = RTId;    
        insert objctCon;
        
        //User userLL = WFG_Test_Data_Utility.createUserRecord('UNTestOwnershipUpdate1@testname.com', true, 'AX34121', null, itmProfile.Id);
        User userLL = WFG_Test_Data_Utility.createTestUser('LL US');
        userLL.federationIdentifier = 'AX34121';
        insert userLL ;
        
        /*User userLL1 = new User( alias = 'TsClsUsr', email='testUser1@transamerica.com',
                          emailencodingkey='UTF-8', lastname='TestUser11', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = itmProfile.Id,
                          timezonesidkey='America/Denver', 
                          username='testUserName@test1.com', isActive=true, federationIdentifier = 'AX34121');
        insert userLL1;*/
        userRR = new User( alias = 'TsClsUsr', email='testUser1@transamerica.com', 
                          emailencodingkey='UTF-8', lastname='TestUser11', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = itmRRProfile.Id,
                          timezonesidkey='America/Denver', 
                          username='testUserName@tesRR.com_fsc', isActive=false, federationIdentifier = 'AX34121_fsc');
        insert userRR;
    }
    
    public static testMethod void testMethod1()
    {
        
        List<User> user = [select id from user where federationIdentifier = 'AX34121'];
        System.runAs(user[0])
        {
            ID rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
            system.debug('rtId--' + rtId);
            Account acc = new Account();
            acc.Name = 'accountName';
            acc.recordTypeId = rtId;
            acc.FinServ__IndividualId__c = '10101010101';
            acc.FinServ__IndividualType__c = 'Individual';
            acc.FinServ__ClientCategory__c = 'Platinum';
            acc.FinServ__Status__c = 'Prospect';
            //insert acc;
            
            rtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
            Contact cont = new Contact();
            cont.FirstName = 'firstName';
            cont.LastName = 'lastName';
            cont.recordTypeId = rtId;
            cont.FinServ__IndividualType__c = 'Individual';
            cont.Birthdate = System.today() - 365;
            cont.MailingState = 'NY';
            cont.MailingStateCode = 'NY';
            cont.MailingCountry = 'US';
            cont.MailingCountryCode = 'US';
            cont.Phone = '(999) 999-9999';
            cont.FinServ__MaritalStatus__c = 'single';
            cont.Email = 'abc@transamerica.com';
            insert cont;
            
            WFG_Customer_Profile__c objCustomerProfile = new WFG_Customer_Profile__c();
            // objCustomerProfile.WFG_CoverageAmount__c = 100.00;
            objCustomerProfile.WFG_AnnualGrossIncome__c = 100.10;
            objCustomerProfile.WFG_OwnDI__c = 'Yes';
            objCustomerProfile.WFG_OwnLifeInsurance__c = 'Yes';  
            objCustomerProfile.WFG_OwnLTC__c = 'Yes';
            objCustomerProfile.WFG_EmploymentStatus__c = 'Employed'; 
            objCustomerProfile.WFG_GroupOrPersonal__c = 'Group';
            objCustomerProfile.WFG_HomeOwnership__c = 'Yes';
            objCustomerProfile.WFG_ListAccountTypes__c = 'Defined Benefit Plans';
            objCustomerProfile.WFG_NumberOfDependents__c = 12;
            objCustomerProfile.WFG_Contact__c = cont.id;
            objCustomerProfile.WFG_OwnQualifiedAssets__c = 'Yes';
            objCustomerProfile.WFG_advisors_to_contact_you__c = 'Yes';
            objCustomerProfile.WFG_Interested_in_discussing_options__c = 'Yes';
            objCustomerProfile.WFG_Consent_to_pass_contact_information__c = 'Yes';
            objCustomerProfile.WFG_Consent_for_FA_Contact__c  = 'Yes';
            objCustomerProfile.WFG_status__c = 'Complete';    
            insert objCustomerProfile;
            
            
            Opportunity objOpty = new Opportunity();
            objOpty.Name = 'Test 1';
            objOpty.StageName = 'Need Assesment';
            objOpty.WFG_CustomerProfile__c = objCustomerProfile.Id;
            objOpty.WFG_Contact__c = objCustomerProfile.WFG_Contact__c;
            objOpty.CloseDate = Date.Today() + 20;
            objOpty.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_OpportunityQualifiedRetirement).getRecordTypeId();
            objOpty.WFG_Source__c = System.Label.WFG_OpportunitySourceReferral;
            insert objOpty;
            
            Opportunity objInsuranceOpty = new Opportunity();
            objInsuranceOpty.Name = 'Test 2';
            objInsuranceOpty.StageName = 'Need Assesment';
            objInsuranceOpty.WFG_CustomerProfile__c = objCustomerProfile.Id;
            objInsuranceOpty.WFG_Contact__c = objCustomerProfile.WFG_Contact__c;
            objInsuranceOpty.CloseDate = Date.Today() + 20;
            objInsuranceOpty.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_OppRecType_Insurance).getRecordTypeId();            
            insert objInsuranceOpty;
            
            //objInsuranceOpty.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_Opportunity_RecordType_InsuranceReadOnly).getRecordTypeId();
            //update objInsuranceOpty;                                  
            /*
            Event objEvent = new Event();
            objEvent.Subject =  'test Event Subject';
            Account a = [select id from Account limit 1]; 
            objEvent.WhatID = a.id;
            objEvent.StartDateTime = System.today();
            objEvent.IsAllDayEvent = true; 
            insert objEvent;
            
            Task TaskObj = new Task();
            TaskObj.Subject =  'test Event Subject';
            Account aa = [select id from Account limit 1]; 
            TaskObj.WhatID = a.id;
            
            insert TaskObj;
            LIST<Contact> conid = [select id from Contact];
            List<Case> csList = WFG_TestDataFactory.createCases(1, conid);
            insert csList;  */
        }
        
        List<User> currUsers = [select id, federationidentifier from user where federationidentifier like : 'AX34121%'];
        system.debug('currUser---' + currUsers);
        List<User> usrUpdate = new List<user>();
        for(User u : currUsers)
        {
            if(!u.federationidentifier.contains('_fsc'))
            {
                u.federationIdentifier = 'AX34121_comm';
                u.isActive = false;
                u.WFG_UTCheck__c=true;
            }
            else
            {
                u.federationIdentifier = 'AX34121';
                u.isActive = true;
            }
            update u;
            //usrUpdate.add(u); 
        }
        // update usrUpdate;
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr)
        {
            WFG_schduleRecordOwnershipUpdate srou = new WFG_schduleRecordOwnershipUpdate();
            SchedulableContext sc;
            Test.startTest();
            WFG_OwnershipUpdate.UpdateOwners();
            srou.execute(sc);
            Test.stopTest();
        }
    }   
}