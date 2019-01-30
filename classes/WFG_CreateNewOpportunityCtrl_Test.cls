@isTest(seeAllData = false)
private class WFG_CreateNewOpportunityCtrl_Test {
    
    @testSetup static void createSetupData() {
        
        //activate triggers
        WFG_Test_Data_Utility.createTriggerActivationRecords();
        
        //inser account
        Account acc = WFG_Test_Data_Utility.createBusinessAccountRecord('Business Account', '13223', 'Primary');
        insert acc;
        
        //insert contact record
        Contact cont = WFG_Test_Data_Utility.createIndividualRecord('Test', 'Contact', '7878787878', 'Single');
        cont.WFg_AGentCode__C = '12MRan_ty';
        cont.WFG_AgentLevel__c = 2;
        insert cont;

        Contact cont1 = WFG_Test_Data_Utility.createPhoneIndividualRecord('Test1', 'Contact', '17878787878', 'Single');
        cont1.WFg_AGentCode__C = '12MRan_ty1';
        cont1.WFG_AgentLevel__c = 2;
        insert cont1;

        Contact cont2 = WFG_Test_Data_Utility.createPhoneIndividualRecord('Test2', 'Contact', '27878787878', 'Single');
        cont2.WFg_AGentCode__C = '12MRan_ty2';
        cont2.WFG_AgentLevel__c = 2;
        insert cont2;
        
        //insert customer profile
        WFG_Customer_Profile__c testCP = WFG_Test_Data_Utility.createCustomerProfile(cont.id);
        insert testCP;

        WFG_Customer_Profile__c testCP1 = WFG_Test_Data_Utility.createCustomerProfile(cont.id);

        testCP1.WFG_OwnQualifiedAssets__c = 'Yes';
        testCP1.WFG_ListAccountTypes__c = '401(k) Plans';
        testCP1.WFG_Interested_in_discussing_options__c = 'Yes';
        testCP1.WFG_advisors_to_contact_you__c = 'Yes';
        testCP1.WFG_Consent_for_FA_Contact__c = 'Yes';
        testCP1.WFG_Consent_to_pass_contact_information__c = 'Yes';
        testCP1.WFG_Status__c = 'Complete';

        insert testCP1;
        
        //insert CP
        insert WFG_Test_Data_Utility.createOppty(testCP);

        //insert referral
        User objFAUser = WFG_Test_Data_Utility.createTestUser(System.Label.WFG_FA_Label);
        insert objFAUser;
        insert WFG_Test_Data_Utility.createReferral(testCP, objFAUser.id);
    }
    
    static testMethod void testIsTANUser()
    {
        test.startTest();
        system.assertEquals(false, WFG_CreateNewOpportunityController.isTANUser());
        User testTANUser;
        
        // LL TAN
        /*
        Account objAcc = WFG_Test_Data_Utility.createBranchOfficeTestRecord('AccountName', '1234', 'USD');
        objAcc.WFG_BranchCode__c = '1234_test';
        insert objAcc;
        
        Contact objCon = WFG_Test_Data_Utility.createContactTestRecord('ConF', 'ConL', objAcc.id, '00HA', 1);
        objCon.WFG_AgentPayType__c = 'WFG';
        objCon.WFG_Fiduciary_Advisor__c = false;
        objCon.WFG_CycleType__c = 'US';
        objCon.WFG_Type__c = 'Registered_Rep'; 
        objCon.WFG_AgentId__c = '12345';
        insert objCon;
        
        testTANUser = WFG_Test_Data_Utility.createTestUser('LL TAN');
        testTANUser.FirstName = 'Test LL TAN';
        testTANUser.LastName = 'User';
        testTANUser.ContactId = objCon.Id;  
        insert testTANUser; 

        System.runAs(testTANUser)
        {
	        system.assertEquals(true, WFG_CreateNewOpportunityController.isTANUser());
        }
		*/
        test.stopTest();
    }
    
    static testMethod void testCreateOpportunityRecruit()
    {   test.startTest();
        List<Contact> lstContact = [SELECT Id, Name FROM Contact Where FirstName = 'Test'];
        List<WFG_Customer_Profile__c> lstCP = [Select Id, Name, WFG_Status__c From WFG_Customer_Profile__c Where WFG_Contact__c =: lstContact[0].Id];
        Opportunity opp = new Opportunity();
        opp.name = 'test Opp Rec';
        opp.CloseDate = Date.today();
        
        ApexPages.StandardController ctrl;
        WFG_CreateNewOpportunityController crNewOptycontroller = new WFG_CreateNewOpportunityController(ctrl);
        WFG_CreateNewOpportunityController.getCustomerProfiles(lstContact[0].Id);
        WFG_CreateNewOpportunityController.getProductType();
        WFG_CreateNewOpportunityController.getContactName(lstContact[0].Id);
        string RetMsg;
        RetMsg = WFG_CreateNewOpportunityController.createOpportunity(opp, lstCP[0].Id, lstContact[0].Id, system.Label.WFG_POP_OpportunityRecruitment);
        system.assert(RetMsg != null);
        test.stopTest();
    }
    
    static testMethod void testCheckOpportunityDuplication()
    {
        test.startTest(); 
        List<Contact> listContact = [SELECT Id, Name, LastName FROM Contact Where FirstName = 'Test'];
        Contact confromMethod = WFG_CreateNewOpportunityController.getContactDetails(listContact[0].id);
        system.assertEquals(listContact[0].LastName, confromMethod.LastName,'Contact does not match');
        
        Opportunity objOpty = new Opportunity();
            objOpty.Name = 'Test Rec 1';
            objOpty.StageName = 'Business Presentation';
            objOpty.WFG_Contact__c = listContact[0].id ;
            objOpty.CloseDate = Date.Today() + 20;
            objOpty.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_POP_OpportunityRecruitment).getRecordTypeId();
        Id recId = [SELECT DeveloperName,Id,Name,SobjectType FROM RecordType where Name = 'Recruiting'].Id;
        String createStrngRes = WFG_CreateNewOpportunityController.createOpportunity(objOpty, null, listContact[0].id, System.Label.WFG_POP_OpportunityRecruitment);
        system.assert(true,WFG_CreateNewOpportunityController.checkOpportunityDuplication(listContact[0].id));
        test.stopTest();

    }
  
    
    static testMethod void testOpportunityList(){
        //get Oppty id
        
        List<Contact> lstContact = [SELECT Id, Name FROM Contact Where FirstName = 'Test'];
        List<WFG_Customer_Profile__c> lstCP = [Select Id, Name, WFG_Status__c From WFG_Customer_Profile__c Where WFG_Contact__c =: lstContact[0].Id];
        Opportunity opp = new Opportunity();
        opp.name = 'testclass';
        opp.CloseDate = Date.today();


        test.startTest();
        if(!lstCP.isEmpty()){
            ApexPages.StandardController ctrl;
            WFG_CreateNewOpportunityController crNewOptycontroller = new WFG_CreateNewOpportunityController(ctrl);
            WFG_CreateNewOpportunityController.getCustomerProfiles(lstContact[0].Id);
            WFG_CreateNewOpportunityController.getProductType();
            WFG_CreateNewOpportunityController.getContactName(lstContact[0].Id);
            WFG_CreateNewOpportunityController.createOpportunity(opp, lstCP[0].Id, lstContact[0].Id, '');
            opp.WFG_CustomerProfile__c = lstCP[0].Id;
            WFG_CreateNewOpportunityController.createOpportunity(opp, lstCP[0].Id, lstContact[0].Id, '');
        }

        List<Opportunity> lstOpty = [Select Id, Name From Opportunity];
        system.assertEquals(lstOpty.size(), 3);
      
        test.stopTest();
        
    }
    
    static testMethod void testGetContactDetails(){
        test.startTest(); 
        List<Contact> listContact = [SELECT Id, Name, LastName FROM Contact Where FirstName = 'Test'];
        Contact confromMethod = WFG_CreateNewOpportunityController.getContactDetails(listContact[0].id);
        system.assertEquals(listContact[0].LastName, confromMethod.LastName,'Contact does not match');
        
        Id recId = [SELECT DeveloperName,Id,Name,SobjectType FROM RecordType where Name = 'Recruiting'].Id;
        system.assertNotEquals(null,WFG_CreateNewOpportunityController.getIsLicensedPicklistValues());
        system.assertNotEquals(null,WFG_CreateNewOpportunityController.getRecordTypeName(recId));
        test.stopTest();
    }

 static testMethod void testRecOpptyCreation(){
        test.startTest(); 
        List<Contact> listContact = [SELECT Id, Name, LastName FROM Contact Where FirstName = 'Test'];
        Contact confromMethod = WFG_CreateNewOpportunityController.getContactDetails(listContact[0].id);
        system.assertEquals(listContact[0].LastName, confromMethod.LastName,'Contact does not match');
        
        Opportunity objOpty = new Opportunity();
            objOpty.Name = 'Test Rec 1';
            objOpty.StageName = 'Business Presentation';
            objOpty.WFG_Contact__c = listContact[0].id ;
            objOpty.CloseDate = Date.Today() + 20;
            objOpty.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_POP_OpportunityRecruitment).getRecordTypeId();
        Id recId = [SELECT DeveloperName,Id,Name,SobjectType FROM RecordType where Name = 'Recruiting'].Id;
        String createStrngRes = WFG_CreateNewOpportunityController.createOpportunity(objOpty, null, listContact[0].id, System.Label.WFG_POP_OpportunityRecruitment);
        test.stopTest();
    }
    
    /*
     static testMethod void testTANuser(){
        test.startTest(); 
       
        Boolean isTANUser = WFG_CreateNewOpportunityController.isTANUser();
        test.stopTest();
    }
	*/
    
}