@isTest
public class GetCarrierAppoinementInfo_Test 
{
    @isTest
    private static void transform_test() 
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
        u.AgentOne__Agent_Number__c = '12345';
        insert u;
        
        PackageLicense pl = [SELECT Id FROM PackageLicense WHERE NamespacePrefix = 'AgentOne'];
        User licUser = [SELECT Id FROM User WHERE LastName='DiPaolo'];
        insert new UserPackageLicense(UserId = licUser.id, PackageLicenseId = pl.id);
        
        System.runAs(u)
        {
            WFG_TriggerActivation__c wfgTrig = new WFG_TriggerActivation__c();
            wfgTrig.Name = 'WFG_Account';
            insert wfgTrig;
            
            AgentOne.InsuranceCaseEntry insCaseEntry = new AgentOne.InsuranceCaseEntry();
            
            AgentOne__Insurance_Product_Carrier__c prodCarrier1 = new AgentOne__Insurance_Product_Carrier__c();
            prodCarrier1.Name = 'Test Carrier One';
            insert prodCarrier1;
            
            AgentOne__Insurance_Product_Carrier__c prodCarrier2 = new AgentOne__Insurance_Product_Carrier__c();
            prodCarrier2.Name = 'Test Carrier Two';
            insert prodCarrier2;
            
            AgentOne__Insurance_Carrier_Code__c carrierCode1 = new AgentOne__Insurance_Carrier_Code__c();
            carrierCode1.AgentOne__Code__c = '07-86231';
            carrierCode1.AgentOne__Carrier__c = [SELECT Id FROM AgentOne__Insurance_Product_Carrier__c WHERE Name = 'Test Carrier One'].Id;
            carrierCode1.AgentOne__Type__c = 'iGO';
            insert carrierCode1;
            
            AgentOne__Insurance_Carrier_Code__c carrierCode2 = new AgentOne__Insurance_Carrier_Code__c();
            carrierCode2.AgentOne__Code__c = '09-9991';
            carrierCode2.AgentOne__Carrier__c = [SELECT Id FROM AgentOne__Insurance_Product_Carrier__c WHERE Name = 'Test Carrier Two'].Id;
            carrierCode2.AgentOne__Type__c = 'iGO';
            insert carrierCode2;
            
            AgentOne__Insurance_Carrier_Code__c[] carrierCodeArray = new AgentOne__Insurance_Carrier_Code__c[] 
            {
                carrierCode1,
                carrierCode2
            };
                
            AgentOne__Agent_Appointment__c apptCode1 = new AgentOne__Agent_Appointment__c();
            apptCode1.AgentOne__Appointed_Agent__c = [SELECT ID FROM User WHERE LastName='DiPaolo'].Id;
            apptCode1.AgentOne__Appointment_Code__c = '12345';
            apptCode1.AgentOne__Insurance_Product_Carrier__c = [SELECT Id FROM AgentOne__Insurance_Product_Carrier__c WHERE Name = 'Test Carrier One'].Id;
            insert apptCode1;
            
            apptCode1 = [SELECT Id, Name, AgentOne__Appointed_Agent__c, AgentOne__Appointed_Agent__r.AgentOne__Agent_Number__c, AgentOne__Appointment_Code__c, AgentOne__Insurance_Product_Carrier__c 
                           FROM AgentOne__Agent_Appointment__c  where Id = :apptCode1.Id];
                        
            AgentOne__Agent_Appointment__c[] apptArray = new AgentOne__Agent_Appointment__c[]
            {
                apptCode1
            };
                
            Map<String, Object> codesMap = new Map<String, Object>();
            codesMap.put('carriercodes', carrierCodeArray);
            codesMap.put('appointmentcodes', apptArray);
            
            System.Test.startTest();
            GetCarrierAppointmentInfo getInfo = new GetCarrierAppointmentInfo();
            System.assertEquals('07-86231|12345', getInfo.transform('agentone__agent_number__c', '12345', 'args', insCaseEntry, codesMap));
            System.Test.stopTest();
        }
    }
}