/*
Property of Transamerica and Aegoncompanies.Do not distribute without permission.
* Copyright (c) [2018] Transamerica Corporation, its affiliates and their licensors.
* @author Rahul K Jain 
* @date 10-24-2018
* @description  Test Class for WFG_CH_ContactActivebatch.
Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Rahul K Jain           M-001             10-24-2018              Test Class for WFG_CH_ContactActivebatch.
*/
@isTest
public class WFG_CH_ContactActivebatchTest {
    
    @testSetup
    static void setup()
    {
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
        
        List<User> u = [select id,WFG_Agent_Code__c from User where isActive = true and UserRole.Name = 'Registered Reps' limit 1];
        if(u.size() > 0)
        {
            LIST<ContactShare> conShareList = new LIST<ContactShare>();
            for(Contact con : agentContactList)
            {
                ContactShare conShare = new ContactShare();
                conShare.ContactId = con.Id;
                conShare.UserOrGroupId = u[0].Id;
                conShare.RowCause = 'Manual';
                conShare.ContactAccessLevel = 'Read';
                conShareList.add(conShare);
            }
            insert conShareList; 
        }
        
    }
    
    static testMethod void createSharingMethod() 
    {      
        Test.startTest();  
        
        set<Id> conIds = new set<Id>();
        for(Contact c : [select id from Contact where WFG_AgentID__c like '%Te4t%'])
        {
            conIds.add(c.Id);
        }
        
        DataBase.executeBatch(new WFG_CH_ContactActivebatch(conIds));             
        Test.stopTest();          
    }  
    
}