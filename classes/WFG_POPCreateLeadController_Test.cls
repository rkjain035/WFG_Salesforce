@isTest(seeAllData=false)
private class WFG_POPCreateLeadController_Test {
    
    @testSetup
    private static void setupData() {
        
        Contact partnerContact; 
        User testLLUser; 
        //Activate triggers
        WFG_Test_Data_Utility.createTriggerActivationRecords();
        
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
        
        /*
        List<WFG_Lead_Conversion_Mapping__mdt> lstConfigData = new List<WFG_Lead_Conversion_Mapping__mdt>();
        
        WFG_Lead_Conversion_Mapping__mdt configData1 = new WFG_Lead_Conversion_Mapping__mdt();
        configData1.Label = 'CASL_Mapping_for_CAN';	
        configData1.WFG_Contact_Field_API__c = 'WFG_CASL_Consent__c';
        configData1.WFG_Lead_Field_API__c = 'WFG_CASL_Consent__c';
        lstConfigData.add(configData1);
        
        
        
        WFG_Lead_Conversion_Mapping__mdt configData2 = new WFG_Lead_Conversion_Mapping__mdt();
        configData2.DeveloperName = 'Email';	
        configData2.WFG_Contact_Field_API__c = 'Email';
        configData2.WFG_Lead_Field_API__c = 'Email';
        lstConfigData.add(configData2);
        
        WFG_Lead_Conversion_Mapping__mdt configData3 = new WFG_Lead_Conversion_Mapping__mdt();
        configData3.DeveloperName = 'FirstName';	
        configData3.WFG_Contact_Field_API__c = 'FirstName';
        configData3.WFG_Lead_Field_API__c = 'FirstName';
        lstConfigData.add(configData3);
        
        
        WFG_Lead_Conversion_Mapping__mdt configData3 = new WFG_Lead_Conversion_Mapping__mdt();
        configData3.DeveloperName = 'Lastname';	
        configData3.WFG_Contact_Field_API__c = 'Lastname';
        configData3.WFG_Lead_Field_API__c = 'Lastname';
        lstConfigData.add(configData3);
        
        
        WFG_Lead_Conversion_Mapping__mdt configData3 = new WFG_Lead_Conversion_Mapping__mdt();
        configData3.DeveloperName = 'MailingCity';	
        configData3.WFG_Contact_Field_API__c = 'MailingCity';
        configData3.WFG_Lead_Field_API__c = 'MailingCity';
        lstConfigData.add(configData3);
        
        
        WFG_Lead_Conversion_Mapping__mdt configData3 = new WFG_Lead_Conversion_Mapping__mdt();
        configData3.DeveloperName = 'MailingCountryCode';	
        configData3.WFG_Contact_Field_API__c = 'MailingCountryCode';
        configData3.WFG_Lead_Field_API__c = 'MailingCountryCode';
        lstConfigData.add(configData3);
        
        
        WFG_Lead_Conversion_Mapping__mdt configData4 = new WFG_Lead_Conversion_Mapping__mdt();
        configData4.DeveloperName = 'MailingPostalCode';	
        configData4.WFG_Contact_Field_API__c = 'MailingPostalCode';
        configData4.WFG_Lead_Field_API__c = 'MailingPostalCode';
        lstConfigData.add(configData4);
        
        
        WFG_Lead_Conversion_Mapping__mdt configData5 = new WFG_Lead_Conversion_Mapping__mdt();
        configData5.DeveloperName = 'MailingStateCode';	
        configData5.WFG_Contact_Field_API__c = 'MailingStateCode';
        configData5.WFG_Lead_Field_API__c = 'MailingStateCode';
        lstConfigData.add(configData5);
        
        
        WFG_Lead_Conversion_Mapping__mdt configData6 = new WFG_Lead_Conversion_Mapping__mdt();
        configData6.DeveloperName = 'MailingStreet';	
        configData6.WFG_Contact_Field_API__c = 'MailingStreet';
        configData6.WFG_Lead_Field_API__c = 'MailingStreet';
        lstConfigData.add(configData6);
        
        WFG_Lead_Conversion_Mapping__mdt configData7 = new WFG_Lead_Conversion_Mapping__mdt();
        configData7.DeveloperName = 'Phone';	
        configData7.WFG_Contact_Field_API__c = 'Phone';
        configData7.WFG_Lead_Field_API__c = 'Phone';
        lstConfigData.add(configData7);
        
        
        WFG_Lead_Conversion_Mapping__mdt configData8 = new WFG_Lead_Conversion_Mapping__mdt();
        configData8.DeveloperName = 'Salutation';	
        configData8.WFG_Contact_Field_API__c = 'Salutation';
        configData8.WFG_Lead_Field_API__c = 'Salutation';
        lstConfigData.add(configData8);
        
        WFG_Lead_Conversion_Mapping__mdt configData9 = new WFG_Lead_Conversion_Mapping__mdt();
        configData9.DeveloperName = 'WFG_Lead_Type_c';	
        configData9.WFG_Contact_Field_API__c = 'WFG_Lead_Type_c';
        configData9.WFG_Lead_Field_API__c = 'WFG_Lead_Type_c';
        lstConfigData.add(configData9);
        
        insert lstConfigData;
        */
        testLLUser = WFG_Test_Data_Utility.createTestUser('LL US');
        testLLUser.FirstName = 'Test LL';
        testLLUser.LastName = 'User';
        //testLLUser.ContactId = objCon.Id;  
        insert testLLUser; 

        System.runAs(testLLUser){
            
            /*Contact objCon1 = WFG_Test_Data_Utility.createContactTestRecord('LeadFistName', 'LeadLastName', objAcc.id, '00HA123', 1);
            objCon1.MailingCountryCode = 'US';
            objCon1.MailingStateCode = 'CA';
            objCon1.Email = 'test@gmail.com';
            objCon1.Phone = '9879879877';
            insert objCon1;*/

            Lead tempLead = new Lead(); 
            tempLead = WFG_Test_Data_Utility.createLead();
            insert tempLead;  
        } 
    }
    
    private testMethod static void TestMethod_createUpdateLead_Posivite(){
        Profile LLprofile = [Select Id, Name from Profile where Name='LL US' limit 1]; 
        User LLUser = [Select ID, Name from User where ProfileId =: LLprofile.Id and FirstName = 'Test LL' and LastName = 'User' LImit 1];
        
        System.runAs(LLUser){
        
            Lead objLead = [SELECT Id, Salutation, Email, FirstName, LastName, Status, Phone, Street, City, State, Country, CountryCode, StateCode, PostalCode,WFG_Lead_Type__c
                            FROM Lead LIMIT 1];
            
            WFG_POPCreateLeadController.getCoutryStateDependency();
            WFG_POPCreateLeadController.getSalutation();
            WFG_POPCreateLeadController.getLeadTypes();
            WFG_POPCreateLeadController.getLeadStatusValues();
            WFG_POPCreateLeadController.getLeadRecord(objLead.Id,'leadEdit');
            WFG_POPCreateLeadController.saveUpdateLead(objLead);
            WFG_POPCreateLeadController.getCASLConsentValues();
            WFG_POPCreateLeadController.validateForConversion(objLead.Id);
            WFG_POPCreateLeadController.convertLead(objLead.Id);
        }
    }
    
    private testMethod static void TestMethod_createUpdateLead_Negative(){
        Profile LLprofile = [Select Id, Name from Profile where Name='LL US' limit 1]; 
        User LLUser = [Select ID, Name from User where ProfileId =: LLprofile.Id and FirstName = 'Test LL' and LastName = 'User' LImit 1];
        
        System.runAs(LLUser){
            
            Lead objLead = [SELECT Id, Salutation, Email, FirstName, LastName, Status, Phone, Street, City, State, Country, CountryCode, StateCode, PostalCode,WFG_Lead_Type__c
                            FROM Lead LIMIT 1];
            objLead.Company = null;
            WFG_POPCreateLeadController.saveUpdateLead(objLead);
            WFG_POPCreateLeadController.deleteLeadRecord(null);  
        }
    }
    
    private testMethod static void deleteLeadPositive(){
        Profile LLprofile = [Select Id, Name from Profile where Name='LL US' limit 1]; 
        User LLUser = [Select ID, Name from User where ProfileId =: LLprofile.Id and FirstName = 'Test LL' and LastName = 'User' LImit 1];
        
        System.runAs(LLUser){
            Lead objLead = [SELECT Id, Salutation, Email, FirstName, LastName, Status, Phone, Street, City, State, Country, CountryCode, StateCode, PostalCode,WFG_Lead_Type__c
                            FROM Lead LIMIT 1];
            objLead.Country = 'US';
            objLead.State = 'CA';
            WFG_POPCreateLeadController.deleteLeadRecord(objLead.Id); 
        }
    }
    
    
}