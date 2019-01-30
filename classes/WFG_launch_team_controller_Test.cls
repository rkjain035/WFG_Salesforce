/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Rahul K Jain
* @date 27-Jul-2018
* @description  Test class for WFG_launch_team_controller

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Rahul K Jain           M-001             27-Jul-2018
Rahul K Jain           M-002             06-Sep-2018             Change the test class to accomodate the changes of
                                                                 using agent code instead of user id.
*/
@isTest
public class WFG_launch_team_controller_Test {
      
    @testSetup public static void setup()
    {
        User thisUser = [select id from User where id= :UserInfo.getUserId()];        
        System.runAs(thisUser)
        {
             WFG_Test_Data_Utility.createTriggerActivationRecords();
            Account a = WFG_Test_Data_Utility.createBusinessAccountRecord('Acc1', '1234P', 'USD'); // the branch where the two...
                                                            //...contact will be associated.
            insert a;
            
            Contact con1 = WFG_Test_Data_Utility.createContactTestRecord('firstName', 'lastName', a.id, 'RC1233', 12);
            con1 = WFG_Test_Data_Utility.updateContactTestRecord(con1, 'Launch');
            con1.MailingCountry = 'US';
            con1.MailingState = 'AL';
            insert con1; // creating a launch contact.
             
            Date d = Date.today();
            WFG_AgentCode__c agentCode = WFG_Test_Data_Utility.CreateAgentCode('RC1233', con1.Id, d, true);
            agentCode.WFG_StartDate__c = date.today();
            agentCode.WFG_SMDApprovalDate__c = date.today();
            insert agentCode; // An agent needs to be created after creating an Agent Contact.
            
            Id profileId = [select id from Profile where name = 'Launch Blue US'].id;
            
            User u = WFG_Test_Data_Utility.createUserRecord('Username@name.com', true, 'ARC1233', con1.Id, profileId);
            insert u; // Create a Launch User. this helps in covering lines in Class
            
             Contact con2 = WFG_Test_Data_Utility.createContactTestRecord('firstName2', 'lastName2', a.id, 'RC1277', 12);
            con2 = WFG_Test_Data_Utility.updateContactTestRecord(con2, 'Launch');
            con2.MailingCountry = 'US';
            con2.MailingState = 'AL';
            insert con2; //this is the Contact that the above Contact will recruit.
            
            User u2 = WFG_Test_Data_Utility.createUserRecord('Username2@name.com', true, 'ARC1277', con2.Id, profileId);
            insert u2;
            
            WFG_AgentCode__c agentCode2 = WFG_Test_Data_Utility.CreateAgentCode('RC1277', con2.Id, d, true);
            agentCode2.WFG_StartDate__c = date.today();
            agentCode2.WFG_SMDApprovalDate__c = date.today();
            insert agentCode2;  
            
            Contact con3 = WFG_Test_Data_Utility.createContactTestRecord('firstName3', 'lastName3', a.id, 'RC1278', 12);
            con3 = WFG_Test_Data_Utility.updateContactTestRecord(con3, 'Launch');
            con3.MailingCountry = 'US';
            con3.MailingState = 'AL';
            insert con3; //this is the Contact that the above con2 will recruit.
            // this is done to cover a scenario of having downline's downline.
            
            WFG_AgentCode__c agentCode3 = WFG_Test_Data_Utility.CreateAgentCode('RC1278', con3.Id, d, true);
            agentCode3.WFG_StartDate__c = date.today();
            agentCode3.WFG_SMDApprovalDate__c = date.today();
            insert agentCode3; // it's a tradition to create agent code for agent contact. 
            
            insert new WFG_OnboardingOpptyRecordTypeID__c(
                Record_Type_ID__c = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Onboarding').getRecordTypeId(),
                Canada_Record_Type_Id__c = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Onboarding CANADA').getRecordTypeId()
            );
            // we insert custom setting because seeAllData cannot be used in setup methods.
            WFG_Onboarding_Checklist__c checklist = 
            WFG_Test_Data_Utility.createOnboardingChecklistRecord(con2.Id,con1.Id,con2.WFG_AgentCode__c,con1.WFG_AgentCode__c);
            insert checklist;
            
             WFG_Onboarding_Checklist__c checklistForDownlinesDownline = 
            WFG_Test_Data_Utility.createOnboardingChecklistRecord(con3.Id,con2.Id,con3.WFG_AgentCode__c,con2.WFG_AgentCode__c);
            insert checklistForDownlinesDownline;
        }            
    }
   
    public static testMethod void testMethod1()
    {
        User u = [select WFG_AgentCode__c from user where federationIdentifier = 'ARC1233'];
        WFG_launch_team_controller.loggedInUserAgentCode();
        WFG_launch_team_controller.loggedInUserName();
        WFG_launch_team_controller.getImmediateDownlines(u.WFG_AgentCode__c);
    }
    public static testMethod void testMethod2()
    {
       WFG_launch_team_controller.getImmediateDownlines(null);
    }
     public static testMethod void testMethod3()
    {
       WFG_launch_team_controller.getImmediateDownlines('RS122');
    }
}