/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Karthik Raj
* @date 10-17-2018 
* @description - Test class for WFG_ContactHierarchyManualSharing,WFG_Rollback_ManualSharing.

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Karthik Raj            Mod-01          10-17-2018            Test class for WFG_ContactHierarchyManualSharing,WFG_Rollback_ManualSharing.
*/

@isTest
private class WFG_ContactHierarchyManualSharing_Test {
    
    @testSetup 
    static void setup() {         
        
        WFG_Test_Data_Utility.createTriggerActivationRecords();
        
        List<Account> accList = WFG_Test_Data_Utility.createBranchOfficeTestData(2);
        insert accList;
        
        list<Contact> agentContactList = new list<Contact>();
        list<WFG_AgentCode__c> agentCodeList = new list<WFG_AgentCode__c>();
        
        for(integer i=0;i<=20;i++)
        {
            Contact c = new Contact();
            c = WFG_Test_Data_Utility.createContactTestRecord('UserTest '+i, 'Contact'+i, accList[0].Id, 'Te4t'+i, 2);
            c.WFG_AgentID__c = 'Te4t'+i;
            c.WFG_CycleType__c = 'US';
            c.WFG_Status__c = 'ACTIVE';
            c.WFG_Type__c = 'Agent';
            c.WFG_AgentPayType__c = 'WFG';
            c.WFG_AgentCode__c = 'Te4t'+i;
            c.WFG_Fiduciary_Advisor__c = true;
            agentContactList.add(c);
        }
        
        insert agentContactList;
        
        Date d = Date.today();
        for(Contact c : agentContactList)
        {
            WFG_AgentCode__c w = new WFG_AgentCode__c();
            w = WFG_Test_Data_Utility.CreateAgentCode(c.WFG_AgentCode__c,c.Id,d,true);
            w.WFG_Status__c = 'ACTIVE';
            agentCodeList.add(w);
        }
        insert agentCodeList;
        
        integer size = agentCodeList.size();
        integer count = 0;
        List<WFG_AgentCode__c> newAgentCodeList = new LIST<WFG_AgentCode__c>();
        
        while((count+1) < size)
        {
            WFG_AgentCode__c w = agentCodeList.get(count);
            w.WFG_UplineCode__c = agentCodeList.get(count+1).Id;
            count++;
            newAgentCodeList.add(w);
        }
        update newAgentCodeList;
        
    }
    
    static testMethod void createSharingMethod() 
    {      
        Test.startTest();     
            DataBase.executeBatch(new WFG_ContactHierarchyManualSharing());             
        Test.stopTest();               
    }  
      
    
    static testMethod void RollBackSharingMethod() 
    {      
        Test.startTest();     
            DataBase.executeBatch(new WFG_ContactHierarchyManualSharing());  
        Test.stopTest();               
        DataBase.executeBatch(new WFG_Rollback_ManualSharing());  
    }
    
}