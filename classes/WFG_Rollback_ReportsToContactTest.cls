/*
Property of Transamerica and Aegoncompanies.Do not distribute without permission.
* Copyright (c) [2018] Transamerica Corporation, its affiliates and their licensors.
* @author Rahul K Jain
* @date 17-09-2018
* @description   Test Class for Batch class to rollback "ReportsTo" on Agent Contacts.
	record
Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Rahul K Jain           M-001             17-09-2018             Test Class for Batch class to rollback "ReportsTo" on Agent Contacts.
*/
@isTest
public class WFG_Rollback_ReportsToContactTest {
    
    @testSetup Static void testSetup()
    {       
        WFG_Test_Data_Utility.createTriggerActivationRecords();
        Account acc = WFG_Test_Data_Utility.createBranchOfficeTestRecord('Test Account', '0295V', 'USD');
        insert acc;
        
        Contact agentContact = 
            WFG_Test_Data_Utility.createContactTestRecord('Test', 'Agent', acc.Id, 'TS12212', 12);
        
        agentContact = WFG_Test_Data_Utility.updateContactTestRecord(agentContact, 'Agent');
        insert agentContact;
        
        Date d = Date.today();
        WFG_AgentCode__c agentContactAgentCode = 
            WFG_Test_Data_Utility.CreateAgentCode(agentContact.WFG_AgentCode__c, agentContact.Id, d, true);
        insert agentContactAgentCode;
        
        LIST<Contact> listDownlineContacts = new LIST<Contact>();
        for(integer i=1;i<150;i++)
        {
            Contact c = WFG_Test_Data_Utility.createContactTestRecord('Downline'+i, 'Agent'+i, acc.Id, 'MC122'+i, 12);
            c = WFG_Test_Data_Utility.updateContactTestRecord(c, 'Agent');
            c.WFG_AgentCode__c = 'MC122'+i;
            c.ReportsToId = agentContact.Id;
            listDownlineContacts.add(c);
        }
        insert listDownlineContacts;
        
        listDownlineContacts = new LIST<Contact>();
        LIST<WFG_AgentCode__c> listDownLineAgentCodes = new LIST<WFG_AgentCode__c>();
        for(Contact c : listDownlineContacts)
        {
            WFG_AgentCode__c downLineAgentCode = WFG_Test_Data_Utility.CreateAgentCode(c.WFG_AgentCode__c, c.Id, d, true);
            downLineAgentCode.WFG_UplineCode__c = agentContactAgentCode.Id;
            listDownLineAgentCodes.add(downLineAgentCode);
        }
        insert listDownLineAgentCodes;
        
        for(Contact c :listDownlineContacts)
        {
            System.debug('reports to....'+c.ReportsToId);
        }
    }
    static testMethod void testMethod1()
    {
        Test.startTest();
        	WFG_Rollback_ReportsToContact obj = new WFG_Rollback_ReportsToContact();
        	Database.executeBatch(obj);
        Test.stopTest();
    }
    
}