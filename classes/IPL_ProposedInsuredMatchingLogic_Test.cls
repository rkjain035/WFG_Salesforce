@isTest
private class IPL_ProposedInsuredMatchingLogic_Test {
    @isTest
    private static void test_PIMatchingLogicString()
    {    
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
        u.AgentOne__iPipeline_User_Id__c = 'tdipaolo18';
        insert u;
        
        System.runAs(u){
            WFG_TriggerActivation__c wfgTrig = new WFG_TriggerActivation__c();
            wfgTrig.Name = 'WFG_Account';
            insert wfgTrig;
            
            //A List<> of Contacts needs to be created to replicate the process IPL_ProposedInsuredMatchingLogic
            //will do when it is given the piFirstName, piLastName, etc. to determine whether or not a Contact exists. 
            List<Contact> contacts = new List<Contact>();
            
            Contact contact1 = new Contact();
            contact1.FirstName = 'Adam';
            contact1.LastName = 'Apple';
            contact1.Birthdate = date.valueOf('1980-01-01');
            contact1.Email = 'contact1@mail.com';
            contact1.RecordTypeId = '012440000002PZ9AAM';
            contact1.MailingCountry = 'US';
            contact1.MailingCountryCode = 'US';
            
            Contact contact2 = new Contact();
            contact2.FirstName = 'Blase';
            contact2.LastName = 'Bull';
            contact2.Birthdate = date.valueOf('1981-02-02');
            contact2.Email = 'contact2@mail.com';
            contact2.RecordTypeId = '012440000002PZ9AAM';
            contact2.MailingCountry = 'US';
            contact2.MailingCountryCode = 'US';
            
            Contact contact3 = new Contact();
            contact3.FirstName = 'Chris';
            contact3.LastName = 'Carter';
            contact3.Birthdate = date.valueOf('1976-03-03');
            contact3.Email = 'contact3@mail.com';
            contact3.RecordTypeId = '012440000002PZ9AAM';
            contact3.MailingCountry = 'US';
            contact3.MailingCountryCode = 'US';
            
            Contact contact4 = new Contact();
            contact4.FirstName = 'Chris';
            contact4.LastName = 'Carter';
            contact4.Birthdate = date.valueOf('1976-03-03');
            contact4.Email = 'contact4@mail.com';
            contact4.RecordTypeId = '012440000002PZ9AAM';
            contact4.MailingCountry = 'US';
            contact4.MailingCountryCode = 'US';
            
            contacts.add(contact1);
            contacts.add(contact2);
            contacts.add(contact3);
            contacts.add(contact4);
            
            insert contacts;
            
            Contact contact5;
            contact5 = [SELECT Id, Owner.AgentOne__iPipeline_User_Id__c FROM Contact WHERE FirstName='Adam' AND LastName='Apple'];
            string ipipeUserId = contact5.Owner.AgentOne__iPipeline_User_Id__c;
                
            //TestCase 1
            System.assertEquals('1', IPL_ProposedInsuredMatchingLogic.PIMatchingLogicString('Chris', 'Carter', ipipeUserId, '3/3/1976', 'contact3@mail.com').get(0));
            System.assertEquals('N', IPL_ProposedInsuredMatchingLogic.PIMatchingLogicString('Chris', 'Carter', ipipeUserId, '3/3/1976', 'contact3@mail.com').get(1));
            
            //Test Case 2
            System.assertEquals(contact5.Id, IPL_ProposedInsuredMatchingLogic.PIMatchingLogicString('Adam', 'Apple', ipipeUserId, '1/1/1980', 'contact1@mail.com').get(0));
            System.assertEquals('N', IPL_ProposedInsuredMatchingLogic.PIMatchingLogicString('Adam', 'Apple', ipipeUserId, '1/1/1980', 'contact1@mail.com').get(1));
            
            //Test Case 3
            //System.assertEquals('Y', IPL_ProposedInsuredMatchingLogic.PIMatchingLogicString('Percy', 'Carter', ipipeUserId, '8/8/1982', '').get(1));
            System.assertEquals('Y', IPL_ProposedInsuredMatchingLogic.PIMatchingLogicString('Percy', 'Carter', ipipeUserId, '8/8/1982', 'contact1@mail.com').get(1));
            
            //Test Case 4
            System.assertEquals('4', IPL_ProposedInsuredMatchingLogic.PIMatchingLogicString('Willie', 'Andolini', 'adepaul', '1/21/1980', '').get(0));
            System.assertEquals('N', IPL_ProposedInsuredMatchingLogic.PIMatchingLogicString('Willie', 'Andolini', 'adepaul', '1/21/1980', '').get(1));
        }
    }
}