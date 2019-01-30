/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author bmadaan
* @date 12-08-2016
* @description  Profile Identification utility

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Ninad Patil           M-001             01-MAR-2017             US-707/709/710 Utility to indentify profile  
*/
@isTest
private class WFG_JITHelper_test 
{
    static List<Contact> lstContact = new List<Contact>();
    static Account objAcc = new Account();
    
    static void createTestData()
    {
    
        List<WFG_ReferralSwitch__c> lstRefSwitch = new List<WFG_ReferralSwitch__c>();
        List<Profile> lstProfile = [Select id, name from Profile Where name IN ('RR US',
            'RR US_NRF','RR PR','RR PR_NRF','RR TAN','RR TAN_NRF','FA US','FA US_NRF','FA TAN','FA TAN_NRF','FA PR','FA PR_NRF',
                'RR_IAR US','RR_IAR US_NRF','RR_IAR PR','RR_IAR TAN','RR_IAR TAN_NRF','LL US','LL CAN', 'LL PR',
                'LL US_NRF', 'LL PR_NRF','LL CAN_NRF')];
        map<id, id> mapRefNonrefIds = new map<Id, Id>();
        map<string, id> mapRefNonrefnames = new map<string, Id>();
        for(profile objProf : lstProfile) 
        {
            mapRefNonrefnames.put(objProf.name, objProf.id);
        }
        for(profile objProf : lstProfile) 
        {
            if(!objProf.name.contains('_NRF'))
            {
                mapRefNonrefIds.put(objProf.id, null);
            }
        }  
        for(profile objProf : lstProfile) 
        {
            if(objProf.name.contains('_NRF'))
            {
                string strWIthoutNRFName = objProf.name.replace('_NRF','');
                mapRefNonrefIds.put(mapRefNonrefnames.get(strWIthoutNRFName), objProf.id);
            }
        }
        for(string strId : mapRefNonrefIds.keyset()) 
        {
            lstRefSwitch.add(new WFG_ReferralSwitch__c(name= strId ,
                    WFG_NR_Profile_ID__c = mapRefNonrefIds.get(strId),
                    WFG_Referral_Switch__c = true));
        }
        insert lstRefSwitch;
        system.debug('## LIST' + lstRefSwitch);
    
        List<WFG_TriggerActivation__c> lsttrig = new List<WFG_TriggerActivation__c>();
        WFG_TriggerActivation__c referralTriggerActivation = new WFG_TriggerActivation__c(); 
        referralTriggerActivation.Name = 'WFG_Contact'; 
        referralTriggerActivation.WFG_isActive__c = false; 
        lsttrig.add(referralTriggerActivation);
        WFG_TriggerActivation__c objAcctrig = new WFG_TriggerActivation__c(); 
        objAcctrig.Name = 'WFG_Account'; 
        objAcctrig.WFG_isActive__c = false; 
        lsttrig.add(objAcctrig);
        insert lsttrig;
        
        List<WFG_RRProfileNames__c> lstRRProfileNames = new List<WFG_RRProfileNames__c>();
        lstRRProfileNames.add(new WFG_RRProfileNames__c(name = 'RR US')); 
        insert lstRRProfileNames;
        
        List<WFG_LLProfileNames__c> lstLLProfileNames = new List<WFG_LLProfileNames__c>();
        lstLLProfileNames.add(new WFG_LLProfileNames__c(name = 'LL US')); 
        insert lstLLProfileNames;
        
        
        objAcc = WFG_Test_Data_Utility.createBranchOfficeTestRecord('AccountName', '1234', 'USD');
        //objAcc.IsPartner = true;
        insert objAcc;
    }
    static testMethod void myUnitTest() 
    {
        createTestData();
        Contact objCon = WFG_Test_Data_Utility.createContactTestRecord('ConF', 'ConL', objAcc.id, '00HA', 1);
        objCon.WFG_AgentPayType__c = 'TAN';
        objCon.WFG_Fiduciary_Advisor__c = false;
        objCon.WFG_CycleType__c = 'US';
        objCon.WFG_Type__c = 'Registered_Rep;IAR'; 
        objCon.WFG_AgentId__c = '12345';
        objCon.WFG_Status__c = 'Active';
        insert objCon;
        
        AutocreatedRegHandler1479334445544 objJIT = new AutocreatedRegHandler1479334445544();
        User objSAUser1 = WFG_Test_Data_Utility.createTestUser('System Administrator');
        User objUser = new user();
        system.runAs(objSAUser1){
             objUser = objJIT.createUser(null, null, null,
            'A12345', null, null);
        
            objUser.communitynickname = objUser.communitynickname + '_FSC';
            objUser.federationIdentifier = objUser.federationIdentifier + '_FSC';
            objUser.username = objUser.username + '_FSC';
            objUser.wfg_agent_code__c = objUser.wfg_agent_code__c + '_FSC';
            update objUser;
        } 
        User objSAUser = WFG_Test_Data_Utility.createTestUser('System Administrator');
        system.RunAs(objSAUser)
        {   
            Test.startTest();    
            WFG_JITHelper.getUser('A12345');
            Test.StopTest();        
        }
    }
    static testMethod void myUnitTest_neg() 
    {
        createTestData();
        Contact objCon = WFG_Test_Data_Utility.createContactTestRecord('ConF', 'ConL', objAcc.id, '00HA', 1);
        objCon.WFG_AgentPayType__c = 'TAN';
        objCon.WFG_Fiduciary_Advisor__c = false;
        objCon.WFG_CycleType__c = '';
        objCon.WFG_Type__c = 'Registered_Rep;IAR'; 
        objCon.WFG_AgentId__c = '12345';
        objCon.WFG_Status__c = 'Active';
        insert objCon;
         
        User objSAUser = WFG_Test_Data_Utility.createTestUser('System Administrator');
        system.RunAs(objSAUser)
        {   
            Test.startTest();    
            WFG_JITHelper.getUser('A12345');
            Test.StopTest();        
        }
    }
    static testMethod void testLLUsers() 
    {
        createTestData();
        Contact objCon = WFG_Test_Data_Utility.createContactTestRecord('ConF', 'ConL', objAcc.id, '00HA', 1);
        objCon.WFG_AgentPayType__c = 'WFG';
        objCon.WFG_Fiduciary_Advisor__c = false;
        objCon.WFG_CycleType__c = 'US';
        objCon.WFG_Type__c = 'Agent'; 
        objCon.WFG_AgentId__c = '12345';
        objCon.WFG_Status__c = 'Active';
        insert objCon;
        
        Contact objCon1 = WFG_Test_Data_Utility.createContactTestRecord('ConF', 'ConL1', objAcc.id, '00HA', 1);
        objCon1.Email = 'asdf@asdf.com';
        objCon1.WFG_AgentPayType__c = 'WFG';
        objCon1.WFG_Fiduciary_Advisor__c = false;
        objCon1.WFG_CycleType__c = 'US';
        objCon1.WFG_Type__c = 'Agent'; 
        objCon1.WFG_AgentId__c = '12346';
        objCon.WFG_Status__c = 'Active';
        insert objCon1;
         
        User objSAUser = WFG_Test_Data_Utility.createTestUser('System Administrator');
        system.RunAs(objSAUser)
        {   
            Test.startTest();    
            WFG_JITHelper.getUser('A12345');
            Test.StopTest();        
        }
        WFG_JITHelper.getUser('A12346');
    }
    static testMethod void testRRUsers() 
    {
        createTestData();
        Contact objCon = WFG_Test_Data_Utility.createContactTestRecord('ConF', 'ConL', objAcc.id, '00HA', 1);
        objCon.WFG_AgentPayType__c = 'WFG';
        objCon.WFG_Fiduciary_Advisor__c = false;
        objCon.WFG_CycleType__c = 'US';
        objCon.WFG_Type__c = 'REGISTERED_REP'; 
        objCon.WFG_AgentId__c = '12345';
        objCon.WFG_Status__c = 'Active';
        insert objCon;
         
        User objSAUser = WFG_Test_Data_Utility.createTestUser('System Administrator');
        system.RunAs(objSAUser)
        {   
            Test.startTest();    
            WFG_JITHelper.getUser('A12345');
            Test.StopTest();        
        }
        WFG_JITHelper.getUser('A12346');
    }
    static testMethod void testRRUsers_Neg() 
    {
        createTestData();
        Contact objCon = WFG_Test_Data_Utility.createContactTestRecord('ConF', 'ConL', objAcc.id, '00HA', 1);
        objCon.WFG_AgentPayType__c = 'WFG';
        objCon.WFG_Fiduciary_Advisor__c = false;
        objCon.WFG_CycleType__c = 'US';
        objCon.WFG_Type__c = 'REGISTERED_REP'; 
        objCon.WFG_AgentId__c = '12345';
        objCon.WFG_Status__c = 'Active';
        insert objCon;
         
        User objSAUser = WFG_Test_Data_Utility.createTestUser('System Administrator');
        system.RunAs(objSAUser)
        {   
            Test.startTest();    
            WFG_JITHelper.getUser('A12345');
            Test.StopTest();        
        }
        WFG_JITHelper.getUser('A12346');
    }
    
    static testMethod void testAssociateUsers() 
    {
        createTestData();
        Contact objCon = WFG_Test_Data_Utility.createContactTestRecord('ConF', 'ConL', objAcc.id, '00HA', 1);
        objCon.WFG_AgentPayType__c = 'WFG';
        objCon.WFG_Fiduciary_Advisor__c = false;
        objCon.WFG_CycleType__c = 'US';
        objCon.WFG_Type__c = 'Associate'; 
        objCon.WFG_AgentId__c = '12345';
        objCon.WFG_Status__c = 'Active';
        insert objCon;
         
        User objSAUser = WFG_Test_Data_Utility.createTestUser('System Administrator');
        system.RunAs(objSAUser)
        {   
            Test.startTest();    
            WFG_JITHelper.getUser('A12345');
            Test.StopTest();        
        }
        WFG_JITHelper.getUser('A12346');
    }
    
    static testMethod void testFiduciaryUsers() 
    {
        createTestData();
        Contact objCon = WFG_Test_Data_Utility.createContactTestRecord('ConF', 'ConL', objAcc.id, '00HA', 1);
        objCon.WFG_AgentPayType__c = 'WFG';
        objCon.WFG_Fiduciary_Advisor__c = true;
        objCon.WFG_CycleType__c = 'US';
        objCon.WFG_Type__c = 'REGISTERED_REP'; 
        objCon.WFG_AgentId__c = '12345';
        objCon.WFG_Status__c = 'Active';
        insert objCon;
         
        User objSAUser = WFG_Test_Data_Utility.createTestUser('System Administrator');
        system.RunAs(objSAUser)
        {   
            Test.startTest();    
            WFG_JITHelper.getUser('A12345');
            Test.StopTest();        
        }
        WFG_JITHelper.getUser('A12346');
        
        objCon.WFG_Fiduciary_Advisor__c = false;
        update objCon;
        
        
    }
}