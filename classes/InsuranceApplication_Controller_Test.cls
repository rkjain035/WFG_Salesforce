@isTest
private class InsuranceApplication_Controller_Test {
	
    @isTest
    private static void getApplicationInfo_Test() {
        
        User u = new User();
        u.FirstName = 'Thomas';
        u.LastName = 'DiPaolo';
        u.Alias = 'tdipaolo';
        u.Email = 'tdipaolo@ipipeline.com';
        u.Username = 'tdipaolo@ipipeline.com';
        u.AgentOne__IsAgentOne__c = true;
        u.CommunityNickname = 'tdipaolo';
        u.UserRoleId = [SELECT Id FROM UserRole WHERE Name=:'System User'].Id;
        u.ProfileId = [SELECT Id FROM Profile WHERE Name=:'System Administrator'].Id;
        u.EmailEncodingKey = 'ISO-8859-1';
        u.TimeZoneSidKey = 'America/New_York';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        insert u;
        
		PackageLicense pl = [SELECT Id FROM PackageLicense WHERE NamespacePrefix = 'AgentOne'];
        User licUser = [SELECT Id FROM User WHERE LastName='DiPaolo'];
		insert new UserPackageLicense(UserId = licUser.id, PackageLicenseId = pl.id);
        
        System.runAs(u) {
            WFG_TriggerActivation__c wfgTrig = new WFG_TriggerActivation__c();
            wfgTrig.Name = 'WFG_Account';
            insert wfgTrig;
            
            Contact c1 = new Contact(FirstName='Ben', LastName='Garrison', Phone='0001113333', Email='benGarrison@mail.com', RecordTypeId='012440000002PZ9AAM', MailingCountry = 'US', MailingCountryCode = 'US');
            insert c1;
            
            AgentOne__InsuranceCase__c i1 = new AgentOne__InsuranceCase__c(Name='InsCase_BenGarrison');
            i1.AgentOne__External_Id__c = '';
            i1.AgentOne__Is_e_App_Archived__c = false;
            i1.AgentOne__Contact__c = [SELECT Id FROM Contact WHERE FirstName='Ben' AND LastName='Garrison'].Id;
            insert i1;
            
            Date d = Date.today();
            
            Opportunity o1 = new Opportunity(Name='Opp_BenGarrison');
            o1.Insurance_Case__c = [SELECT Id FROM AgentOne__InsuranceCase__c WHERE Name='InsCase_BenGarrison'].Id;
            o1.WFG_Contact__c = [SELECT Id FROM Contact WHERE FirstName='Ben' And LastName='Garrison'].Id;
            o1.StageName = 'Application';
            o1.OwnerId = [SELECT ID FROM User WHERE LastName='DiPaolo'].Id;
            o1.CloseDate = d.addDays(5);
            insert o1;
            
            Contact c2 = new Contact(FirstName='Pete', LastName='Maxwell', Phone='4445556666', Email='peteMaxwell@mail.com', RecordTypeId='012440000002PZ9AAM', MailingCountry = 'US', MailingCountryCode = 'US');
            insert c2;
            
            AgentOne__InsuranceCase__c i2 = new AgentOne__InsuranceCase__c(Name='InsCase_PeteMaxwell');
            i2.AgentOne__Contact__c = [SELECT Id FROM Contact WHERE FirstName='Pete' AND LastName='Maxwell'].Id;
            insert i2;
            
            Opportunity o2 = new Opportunity(Name='Opp_PeteMaxwell');
            o2.WFG_Contact__c = [SELECT Id FROM Contact WHERE FirstName='Pete' AND LastName='Maxwell'].Id;
            o2.StageName = 'Application';
            o2.OwnerId = [SELECT ID FROM User WHERE LastName='DiPaolo'].Id;
            o2.CloseDate = d.addDays(5);
            insert o2;

            Contact c3 = new Contact(FirstName='Bart', LastName='Williams', Phone='8884442222', Email='bartWilliams@mail.com', RecordTypeId='012440000002PZ9AAM', MailingCountry = 'US', MailingCountryCode = 'US');
            insert c3;
            
            AgentOne__InsuranceCase__c i3 = new AgentOne__InsuranceCase__c(Name='InsCase_BartWilliams');
            i3.AgentOne__Contact__c = [SELECT Id FROM Contact WHERE FirstName='Bart' AND LastName='Williams'].Id;
            insert i3;
            
            Opportunity o3 = new Opportunity(Name='Opp_BartWilliams');
            o3.Insurance_Case__c = [SELECT Id FROM AgentOne__InsuranceCase__c WHERE Name='InsCase_BartWilliams'].Id;
            o3.WFG_Contact__c = [SELECT Id FROM Contact WHERE FirstName='Bart' AND LastName='Williams'].Id;
            o3.StageName = 'Needs Assessment';
            o3.OwnerId = [SELECT ID FROM User WHERE LastName='DiPaolo'].Id;
            o3.CloseDate = d.addDays(5);
            insert o3;
            
            Contact c4 = new Contact(FirstName='Keri', LastName='Klum', Phone='2224448888', Email='keriKlum@mail.com', RecordTypeId = '012440000002PZ9AAM', MailingCountry = 'US', MailingCountryCode = 'US');
            insert c4;
            
            Opportunity o4 = new Opportunity(Name='Opp_KeriKlum');
            o4.WFG_Contact__c = [SELECT Id FROM Contact WHERE FirstName='Keri' AND LastName='Klum'].Id;
            o4.StageName = 'Application';
            o4.OwnerId = [SELECT ID FROM User WHERE LastName='DiPaolo'].Id;
            o4.CloseDate = d.addDays(5);
            insert o4;
            
            Opportunity opp1 = [SELECT ID FROM Opportunity WHERE Name='Opp_BenGarrison' LIMIT 1];
            Opportunity opp2 = [SELECT ID FROM Opportunity WHERE Name='Opp_PeteMaxwell' LIMIT 1];
            Opportunity opp3 = [SELECT ID FROM Opportunity WHERE Name='Opp_BartWilliams' LIMIT 1];
            Opportunity opp4 = [SELECT ID FROM Opportunity WHERE Name='Opp_KeriKlum' LIMIT 1];
            
            System.assertEquals(false, InsuranceApplication_Controller.getApplicationInfo(opp1.Id, 'falseApp').hasAccess);
            System.assertEquals(false, InsuranceApplication_Controller.getApplicationInfo(opp1.Id, 'falseApp').isInsCaseNew);
            System.assertEquals('', InsuranceApplication_Controller.getApplicationInfo(opp1.Id, 'falseApp').caseId);    
            System.assertEquals(true, InsuranceApplication_Controller.getApplicationInfo(opp1.Id, 'trueApp').hasAccess);
            
            System.assertEquals('', InsuranceApplication_Controller.getApplicationInfo(opp2.Id, 'trueApp').externalID);
            System.assertEquals(false, InsuranceApplication_Controller.getApplicationInfo(opp2.Id, 'trueApp').isEAppArchived);
            
            String str ='The features of the iGO illustrations and iGO e-App are only available in ' +
                        'the Recommendation or Application stage of the Opportunity. Please ' +
                        'advance to the appropriate stage to continue.';
            System.assertEquals(str, InsuranceApplication_Controller.getApplicationInfo(opp3.Id, 'trueApp').accessMessage);
            
            System.assertEquals(true, InsuranceApplication_Controller.getApplicationInfo(opp4.Id, 'trueApp').isInsCaseNew);
            System.assertEquals(true, InsuranceApplication_Controller.getApplicationInfo(opp4.Id, 'trueApp').hasAccess);
            System.assertEquals(false, InsuranceApplication_Controller.getApplicationInfo(opp4.Id, 'trueApp').isEAppArchived);    
        }
    }
    
    @isTest
    private static void updateApplicationInfo_Test() {
        WFG_TriggerActivation__c wfgTrig = new WFG_TriggerActivation__c();
        wfgTrig.Name = 'WFG_Account';
        insert wfgTrig;
        
        Contact c = new Contact(FirstName='Kim', LastName='Parker', Phone='1113335555', Email='kimParker@mail.com', RecordTypeId='012440000002PZ9AAM', MailingCountry = 'US', MailingCountryCode = 'US');
        insert c;
        
        AgentOne__InsuranceCase__c i = new AgentOne__InsuranceCase__c(Name='InsCase_KimParker');
        i.AgentOne__Contact__c = [SELECT Id FROM Contact WHERE FirstName='Kim' AND LastName='Parker'].Id;
        insert i;
        
        Date d = Date.today();
        
        Opportunity o = new Opportunity(Name='Opp_KimParker');
        o.accountId = [SELECT Id FROM Account WHERE Name='Kim Parker'].Id;
        o.StageName = 'Application';
        o.CloseDate = d.addDays(5);
        insert o;
        
        AgentOne__InsuranceCase__c insCase = [SELECT Id FROM AgentOne__InsuranceCase__c WHERE Name='InsCase_KimParker'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name='Opp_KimParker'];
        System.assertEquals(true, InsuranceApplication_Controller.updateApplicationInfo(opp.Id, insCase.Id).hasAccess);
        System.assertEquals(insCase.Id, InsuranceApplication_Controller.updateApplicationInfo(opp.Id, insCase.Id).caseId);
    }
}