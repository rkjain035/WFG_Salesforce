/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Praveen
* @date 04-06-2017
* @description  Test class for WFG_Launch_LicenseReminderBarCtrl

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
*/
@isTest
public class WFG_Launch_LicenseReminderBarCtrl_Test {
    /**
     * This method is used to test the method calculateMonthAndDate from class WFG_Launch_license_reminder_bar
     * @throws - N/A
     * @author Praveen
     * @date 04-06-2017
     */
    static testMethod void testPositiveScenario(){
        WFG_Test_Data_Utility.createTriggerActivationRecords();
        account a = WFG_Test_Data_Utility.createBranchOfficeTestRecord('Test','121','USD');
        insert a;
        contact c = WFG_Test_Data_Utility.createContactTestRecord('Fname','Lname',a.Id,'123',12);  
        c.WFG_AgentPayType__c = 'WFG';
        c.WFG_AgentID__c = '123';
        c.WFG_Type__c = 'Associate';
        c.WFG_CycleType__c = 'US';
        insert c;
        date dt = system.today()-30;
        WFG_AgentCode__c agc = WFG_Test_Data_Utility.createAgentCode('123',c.Id,dt,false);
        agc.WFG_SMDApprovalDate__c = dt;
        insert agc;
        system.debug('AgentCode = '+agc);
        user u = WFG_Test_Data_Utility.createTestUser('Launch Blue US');
        u.WFG_Agent_Code__c = '123';
        u.ContactId = c.Id;
        insert u;
        system.runAs(u){
            WFG_Launch_LicenseReminderBarCtrl.calculateMonthAndDate(); 
        }
    }
    
    static testMethod void testNegativeScenario(){
        WFG_Test_Data_Utility.createTriggerActivationRecords();
        account a = WFG_Test_Data_Utility.createBranchOfficeTestRecord('Test','121','USD');
        insert a;
        Contact objCon = WFG_Test_Data_Utility.createContactTestRecord('ConF', 'ConL', a.id, '00HA', 1);
        objCon.WFG_AgentPayType__c = 'WFG';
        objCon.WFG_Fiduciary_Advisor__c = false;
        objCon.WFG_CycleType__c = 'US';
        objCon.WFG_Type__c = 'Associate'; 
        objCon.WFG_AgentId__c = '00HA';
        objCon.WFG_Status__c = 'Active';
        insert objCon;
        date dt = system.today()-30;
        user u = WFG_Test_Data_Utility.createTestUser('Launch Blue US');
        u.ContactId = objCon.Id;
        insert u;
        WFG_AgentCode__c agc = WFG_Test_Data_Utility.createAgentCode('KK1231',objCon.Id,dt,true);
        agc.WFG_SMDApprovalDate__c = dt;
        insert agc;
        system.runAs(u){
            WFG_Launch_LicenseReminderBarCtrl.calculateMonthAndDate(); 
        }
    }
}