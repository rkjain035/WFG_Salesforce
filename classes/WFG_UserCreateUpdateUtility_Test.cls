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
private class WFG_UserCreateUpdateUtility_Test 
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
    static testMethod void testCreateUser() 
    {
        User objUser1 = WFG_Test_Data_Utility.createTestUser('FA US');
        objUser1.FederationIdentifier = 'A12345';
        insert objUser1;
        // TO DO: implement unit test
        createTestData();
        Test.startTest();
        Contact objCon = WFG_Test_Data_Utility.createContactTestRecord('ConF', 'ConL', objAcc.id, '00HA', 1);
        objCon.WFG_AgentPayType__c = 'WFG';
        objCon.WFG_Fiduciary_Advisor__c = false;
        objCon.WFG_CycleType__c = 'US';
        objCon.WFG_Type__c = 'Registered_Rep'; 
        objCon.WFG_AgentId__c = '12345';
        insert objCon;
        List<Id> lstcontactId = new List<Id>();
        lstcontactId.add(objCOn.id);
        User objUser  = WFG_UserCreateUpdateUtility.getUserForJITHandler(objCon);
        WFG_UserCreateUpdateUtility.insertUsers(lstcontactId);
        
        map<string, string> mapContactProfileId = new map<string, string>();
        map<string, Id> mapProfileNameId = new map<string, Id>();
        for(profile objProf : [Select id, name from Profile])
        {
            mapProfileNameId.put(objProf.name, objProf.id);
        }         
        mapContactProfileId.put(objCOn.id, mapProfileNameId.get('RR US'));
        set<Id> setContactId = new set<Id>();
        setContactId.addAll(lstcontactId);
        WFG_UserCreateUpdateUtility.updateUser(setContactId, mapContactProfileId);
        
        Test.stopTest();
    }
    
    static testMethod void testCreateUser_1() 
    {
        // TO DO: implement unit test
        createTestData();
        Test.startTest();
        Contact objCon = WFG_Test_Data_Utility.createContactTestRecord('ConF', 'ConL', objAcc.id, '00HA', 1);
        objCon.WFG_AgentPayType__c = 'WFG';
        objCon.WFG_Fiduciary_Advisor__c = false;
        objCon.WFG_CycleType__c = 'US';
        objCon.WFG_Type__c = 'Registered_Rep'; 
        objCon.WFG_AgentId__c = '12345';
       // objCon.WFG_Status__c = 'Active';
        insert objCon;
        List<Id> lstcontactId = new List<Id>();
        lstcontactId.add(objCOn.id);
        User objUser  = WFG_UserCreateUpdateUtility.getUserForJITHandler(objCon);
        WFG_UserCreateUpdateUtility.insertUsers(lstcontactId);
        map<string, string> mapContactProfileId = new map<string, string>();
        map<string, Id> mapProfileNameId = new map<string, Id>();
        for(profile objProf : [Select id, name from Profile])
        {
            mapProfileNameId.put(objProf.name, objProf.id);
        }         
        mapContactProfileId.put(objCOn.id, mapProfileNameId.get('RR US'));
        set<Id> setContactId = new set<Id>();
        setContactId.addAll(lstcontactId);
        WFG_UserCreateUpdateUtility.updateUser(setContactId, mapContactProfileId);
        Test.stopTest();
    }
    
    static testMethod void testCreateUser_2() 
    {
        // TO DO: implement unit test
        createTestData();
        Test.startTest();
        Contact objCon = WFG_Test_Data_Utility.createContactTestRecord('ConF1', 'ConL1', objAcc.id, '00HA', 1);
        objCon.WFG_AgentPayType__c = 'WFG';
        objCon.WFG_Fiduciary_Advisor__c = false;
        objCon.WFG_CycleType__c = 'US';
        objCon.WFG_Type__c = 'Registered_Rep'; 
        objCon.WFG_AgentId__c = '123451';
       // objCon.WFG_Status__c = 'Active';
        insert objCon;
        List<Id> lstcontactId = new List<Id>();
        lstcontactId.add(objCOn.id);
        User objUser  = WFG_UserCreateUpdateUtility.getUserForJITHandler(objCon);
        WFG_UserCreateUpdateUtility.insertUsers(lstcontactId);
        map<string, string> mapContactProfileId = new map<string, string>();
        map<string, Id> mapProfileNameId = new map<string, Id>();
        for(profile objProf : [Select id, name from Profile])
        {
            mapProfileNameId.put(objProf.name, objProf.id);
        }         
        mapContactProfileId.put(objCOn.id, mapProfileNameId.get('FA US'));
        set<Id> setContactId = new set<Id>();
       
        setContactId.addAll(lstcontactId);
        WFG_UserCreateUpdateUtility.updateUser(setContactId, mapContactProfileId);
        Test.stopTest();
    }
    static testMethod void testCreateUser_3() 
    {
        // TO DO: implement unit test
        createTestData();
        Test.startTest();
        Contact objCon = WFG_Test_Data_Utility.createContactTestRecord('ConF2', 'ConL2', objAcc.id, '00HA', 1);
        objCon.WFG_AgentPayType__c = 'WFG';
        objCon.WFG_Fiduciary_Advisor__c = true;
        objCon.WFG_CycleType__c = 'US';
        objCon.WFG_Type__c = 'Registered_Rep'; 
        objCon.WFG_AgentId__c = '123411';
        objCon.WFG_Status__c = 'Active';
        insert objCon;
        List<Id> lstcontactId = new List<Id>();
        lstcontactId.add(objCOn.id);
        User objUser  = WFG_UserCreateUpdateUtility.getUserForJITHandler(objCon);
        WFG_UserCreateUpdateUtility.insertUsers(lstcontactId);
        map<string, string> mapContactProfileId = new map<string, string>();
        map<string, Id> mapProfileNameId = new map<string, Id>();
        for(profile objProf : [Select id, name from Profile])
        {
            mapProfileNameId.put(objProf.name, objProf.id);
        }         
        mapContactProfileId.put(objCOn.id, mapProfileNameId.get('RR US'));
        set<Id> setContactId = new set<Id>();
       
        setContactId.addAll(lstcontactId);
        WFG_UserCreateUpdateUtility.updateUser(setContactId, mapContactProfileId);
        Test.stopTest();
    }
    
}