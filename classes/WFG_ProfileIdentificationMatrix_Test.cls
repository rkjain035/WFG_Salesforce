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
private class WFG_ProfileIdentificationMatrix_Test 
{
    static List<Contact> lstContact = new List<Contact>();
    static void createTestData()
    {
    
        List<WFG_ReferralSwitch__c> lstRefSwitch = new List<WFG_ReferralSwitch__c>();
        List<Profile> lstProfile = [Select id, name from Profile Where name IN ('RR US',
            'RR US_NRF','RR PR','RR PR_NRF','RR TAN','RR TAN_NRF','FA US','FA US_NRF','FA TAN','FA TAN_NRF','FA PR','FA PR_NRF',
                'RR_IAR US','RR_IAR US_NRF','RR_IAR PR','RR_IAR TAN','RR_IAR TAN_NRF','LL US','LL CAN', 'LL PR',
                'LL US_NRF', 'LL PR_NRF','LL CAN_NRF','RR Home Office','FA Home Office','MF Home Office','LL CAN Home Office','LL US Home Office')];
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
        lstContact.add(new Contact(WFG_AgentPayType__c = 'TAN',WFG_Fiduciary_Advisor__c = false,WFG_CycleType__c = '',WFG_Type__c = 'Registered_Rep;IAR'));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'TAN',WFG_Fiduciary_Advisor__c = false,WFG_CycleType__c = '',WFG_Type__c = 'IAR'));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'TAN',WFG_Fiduciary_Advisor__c = false,WFG_CycleType__c = '',WFG_Type__c = 'Registered_Rep'));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'TAN',WFG_Fiduciary_Advisor__c = false,WFG_CycleType__c = '',WFG_Type__c = 'Agent'));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'TAN',WFG_Fiduciary_Advisor__c = true,WFG_CycleType__c = '',WFG_Type__c = ''));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'WFG',WFG_Fiduciary_Advisor__c = true,WFG_CycleType__c = 'US',WFG_Type__c = ''));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'WFG',WFG_Fiduciary_Advisor__c = true,WFG_CycleType__c = 'PR',WFG_Type__c = ''));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'WFG',WFG_Fiduciary_Advisor__c = false,WFG_CycleType__c = 'US',WFG_Type__c = 'Registered_Rep'));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'WFG',WFG_Fiduciary_Advisor__c = false,WFG_CycleType__c = 'CA',WFG_Type__c = 'Registered_Rep'));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'WFG',WFG_Fiduciary_Advisor__c = false,WFG_CycleType__c = 'PR',WFG_Type__c = 'Registered_Rep'));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'WFG',WFG_Fiduciary_Advisor__c = false,WFG_CycleType__c = 'US',WFG_Type__c = 'Agent'));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'WFG',WFG_Fiduciary_Advisor__c = false,WFG_CycleType__c = 'CA',WFG_Type__c = 'Agent'));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'WFG',WFG_Fiduciary_Advisor__c = false,WFG_CycleType__c = 'PR',WFG_Type__c = 'Agent'));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'WFG',WFG_Fiduciary_Advisor__c = false,WFG_CycleType__c = 'US',WFG_Type__c = 'IAR'));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'WFG',WFG_Fiduciary_Advisor__c = false,WFG_CycleType__c = 'PR',WFG_Type__c = 'IAR'));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'WFG',WFG_Fiduciary_Advisor__c = false,WFG_CycleType__c = 'US',WFG_Type__c = 'Registered_Rep;IAR'));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'WFG',WFG_Fiduciary_Advisor__c = false,WFG_CycleType__c = 'PR',WFG_Type__c = 'Registered_Rep;IAR'));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'WFG',WFG_Fiduciary_Advisor__c = true,WFG_CycleType__c = 'US',WFG_Type__c = '',WFG_Home_Office_Agent__c = true));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'WFG',WFG_Fiduciary_Advisor__c = true,WFG_CycleType__c = 'PR',WFG_Type__c = '',WFG_Home_Office_Agent__c = true));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'WFG',WFG_Fiduciary_Advisor__c = false,WFG_CycleType__c = 'US',WFG_Type__c = 'Registered_Rep',WFG_Home_Office_Agent__c = true));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'WFG',WFG_Fiduciary_Advisor__c = false,WFG_CycleType__c = 'CA',WFG_Type__c = 'Registered_Rep',WFG_Home_Office_Agent__c = true));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'WFG',WFG_Fiduciary_Advisor__c = false,WFG_CycleType__c = 'PR',WFG_Type__c = 'Registered_Rep',WFG_Home_Office_Agent__c = true));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'WFG',WFG_Fiduciary_Advisor__c = false,WFG_CycleType__c = 'US',WFG_Type__c = 'Agent',WFG_Home_Office_Agent__c = true));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'WFG',WFG_Fiduciary_Advisor__c = false,WFG_CycleType__c = 'CA',WFG_Type__c = 'Agent',WFG_Home_Office_Agent__c = true));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'WFG',WFG_Fiduciary_Advisor__c = false,WFG_CycleType__c = 'PR',WFG_Type__c = 'Agent',WFG_Home_Office_Agent__c = true));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'WFG',WFG_Fiduciary_Advisor__c = false,WFG_CycleType__c = 'US',WFG_Type__c = 'IAR',WFG_Home_Office_Agent__c = true));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'WFG',WFG_Fiduciary_Advisor__c = false,WFG_CycleType__c = 'PR',WFG_Type__c = 'IAR',WFG_Home_Office_Agent__c = true));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'WFG',WFG_Fiduciary_Advisor__c = false,WFG_CycleType__c = 'US',WFG_Type__c = 'Registered_Rep;IAR',WFG_Home_Office_Agent__c = true));
        lstContact.add(new Contact(WFG_AgentPayType__c = 'WFG',WFG_Fiduciary_Advisor__c = false,WFG_CycleType__c = 'PR',WFG_Type__c = 'Registered_Rep;IAR',WFG_Home_Office_Agent__c = true));
    }
    static testMethod void myUnitTest() 
    {
        // TO DO: implement unit test
        createTestData();
        Test.startTest();
        WFG_ProfileIdentificationMatrix.getProfileId(lstContact[0]);
        WFG_ProfileIdentificationMatrix.getProfileId(lstContact);
        Test.StopTest();
    }
}