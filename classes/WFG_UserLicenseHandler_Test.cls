@isTest(seealldata=false)
private class WFG_UserLicenseHandler_Test {

private static Account testAcc;
private static Contact testContact1;
private static Contact testContact2;
private static Contact objctCon;
static List<Contact> lstContacts = new List<Contact>();
static List<Contact> lstCont = new List<Contact>();
    
@testSetup static void createTestData(){
    system.debug('Test Data');
    WFG_Test_Data_Utility.createTriggerActivationRecords(); // Added during Service Center changes before FSC Installation
    WFG_TestDataFactory.createWFGUtilityCustomSettingRecords();
    
            Account objAcc = WFG_Test_Data_Utility.createBranchOfficeTestRecord('AccountName', 'ACC12', 'USD');
            //objAcc.IsPartner = true;
            insert objAcc;
            //system.Label.WFG_BulkContactUpdate = 'OFF';
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
            objctCon.WFG_Channel__c = 'BLUE';           
            objctCon.email = 'testUser1@transamerica.com';
            insert objctCon;
            
            User objSAUser = WFG_Test_Data_Utility.createTestUser('System Administrator');
            user u = new user();
            system.RunAs(objSAUser)
            {   
                Test.startTest();    
                WFG_JITHelper.getUser('AX34121');
                Test.StopTest();        
            }
 }
 
    public static testMethod void testUserCreation()
       {     
            WFG_UserLicense_Handler.generateHexaDigitCode();
            //system.debug('profile--Test Class' + itmProfile);
            Account objAcc = WFG_Test_Data_Utility.createBranchOfficeTestRecord('AccountName', 'ACC121', 'USD');
            insert objAcc;
           
            Contact objCon = WFG_Test_Data_Utility.createContactTestRecord('ConF', 'ConL', objAcc.id, '00HA', 1);
            objCon = WFG_Test_Data_Utility.updateContactTestRecord(objCon, 'REGISTERED_REP');              
           

            insert objCon;     
           
           //objCon.WFG_Type__c = 'Agent';           
           //update objCon;
                       
           objCon.WFG_Type__c = 'Associate';            
           update objCon; 
            
           objCon.WFG_Type__c = 'LAUNCH';  
           objCon.WFG_Channel__c = 'GREEN';
           update objCon;
           
           objCon.WFG_Type__c = 'Agent';  
           update objCon;
           
           objCon.WFG_Fiduciary_Advisor__c = true;
           update objCon;
       }           
    
    public static testMethod void testUserCreationUpdate()
       {     
            WFG_UserLicense_Handler.generateHexaDigitCode();
            //system.debug('profile--Test Class' + itmProfile);
            Account objAcc = WFG_Test_Data_Utility.createBranchOfficeTestRecord('AccountName', '1234 RE', 'USD');
            insert objAcc;
           
            Contact objCon = WFG_Test_Data_Utility.createContactTestRecord('ConF', 'ConL', objAcc.id, '00HA', 1);
            objCon = WFG_Test_Data_Utility.updateContactTestRecord(objCon, 'REGISTERED_REP');
            insert objCon; 
           
           objCon.WFG_Type__c = 'LAUNCH';  
           objCon.WFG_Channel__c = 'BLUE';
           update objCon;
       }
    
  
}