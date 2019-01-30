/*
Property of Transamerica and Aegoncompanies.Do not distribute without permission.
* Copyright (c) [2018] Transamerica Corporation, its affiliates and their licensors.
* @author Karthik Raj
* @date 10-24-2018
* @description  Test Class for WFG_CH_ContactActivebatch.
Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Karthik Raj           M-001             10-26-2018              Test Class for WFG_CH_UserScheduleApex.
*/
@isTest
public class WFG_CH_UserScheduleApex_Test {
    
     public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    
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
            c.WFG_Status__c = 'TERMINATED';
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
            w.WFG_Status__c = 'TERMINATED';
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
        
         List<User> listUpdatedUser = new List<User>();
        List<Contact> listUpdatedContact = new List<Contact>();
        for(Contact objCon : [select Id from Contact where WFG_AgentID__c like '%Te4t%' Limit 4])
        {
            Contact objContact = new Contact(Id = objCon.Id);
            objContact.WFG_Status__c = 'ACTIVE';
            listUpdatedContact.add(objContact);
        }
        update listUpdatedContact;
        System.debug('listUpdatedContact - --- ' + listUpdatedContact);
        
        
    }
    
    static testMethod void createSharingMethod() 
    {      
        Test.startTest();
        WFG_CH_UserScheduleApex userSchedule = new WFG_CH_UserScheduleApex();
        userSchedule.runningJobCount = null;
        System.schedule('Schedule class',CRON_EXP,userSchedule);           
        Test.stopTest();          
    }
   static testmethod void testMyException()
    {
        Test.startTest();
        WFG_CH_UserScheduleApex userSchedule = new WFG_CH_UserScheduleApex();
        userSchedule.runningJobCount = 5;
        System.schedule('Schedule class',CRON_EXP,userSchedule);
        Test.stopTest(); 
    }
    
}