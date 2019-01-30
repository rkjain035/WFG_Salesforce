/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Karthik Raj
* @date 10-24-2018 
* @description - Test class for WFG_CH_UserActiveBatch.

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Karthik Raj             Mod-01          10-24-2018            Test class for WFG_CH_UserActiveBatch.
*/

@isTest
public class WFG_CH_UserActiveBatch_Test {
    
    @testSetup 
    static void setup() {         
         WFG_Test_Data_Utility.createTriggerActivationRecords();
        
        List<Account> accList = WFG_Test_Data_Utility.createBranchOfficeTestData(2);
        insert accList;
        
        list<Contact> agentContactList = new list<Contact>();
        list<WFG_AgentCode__c> agentCodeList = new list<WFG_AgentCode__c>();
        
        for(integer i=0;i<=3;i++)
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
        
        String agentCode = [select WFG_AgentCode__c from Contact where reportsToId = null limit 1].WFG_AgentCode__c;
        Profile p = [SELECT Id FROM Profile WHERE Name =: 'FA US'];        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',isActive = true, 
        EmailEncodingKey='UTF-8', LastName='test batch sharing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',
        UserName='testsharing@test1.com',FederationIdentifier='A'+agentCode, WFG_Agent_Code__c = agentCode);
        insert u;
        
        LIST<User> userId = [select id, isActive from User where FederationIdentifier= :u.FederationIdentifier limit 1];
        
        LIST<ContactShare> listCS = new LIST<ContactShare>();
        For(Contact c : [select id from Contact where WFG_AgentCode__c like '%Te4t%' and reportsToId != null])
        {
            ContactShare objContactShare = new ContactShare();
            objContactShare.ContactId = c.Id;
            objContactShare.ContactAccessLevel = 'Read';
            objContactShare.RowCause = 'Manual';
            objContactShare.UserOrGroupId = userId[0].id;
            listCS.add(objContactShare);
        }
        insert listCS;
    }
    
    static testMethod void createUserSharingMethod() 
    {   
        
        Test.startTest();
        Map<String,Id> mapAgentCodeUserId = new Map<String,Id>();
        String AgentCode = [Select WFg_AgentCode__c from Contact where ReportstoId = null limit 1].WFG_AgentCode__c;
        for(User objUser : [Select Id,WFG_Agent_Code__c from User
                            where WFG_Agent_Code__c = : AgentCode ]){
             
            mapAgentCodeUserId.put(objUser.WFG_Agent_Code__c,objUser.Id);
                                
         }
        DataBase.executeBatch(new WFG_CH_UserActiveBatch(mapAgentCodeUserId));             
        Test.stopTest();               
    }   
}