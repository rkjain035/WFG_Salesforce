/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Saurabh Sharma
* @date 2-27-2017
* @description  Test Class for WFG_CommunityHeader

Modification Log:
-------------------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
-------------------------------------------------------------------------------------------------------------------
Saurabh Sharma        M-001             2-27-2017     Test class for unit testing WFG_CommunityHeader  
*/
@isTest(seeAllData = false)
public class WFG_CommunityHeader_Test {
    
    /*
    Method to create test setup data
    */
    @testSetup static void createSetupData() {
        
        //activate triggers
        WFG_Test_Data_Utility.createTriggerActivationRecords();
        
        //inser account
        Account acc = WFG_Test_Data_Utility.createBusinessAccountRecord('Business Account', '13223', 'Primary');
        insert acc;
        
        //insert contact record
        Contact cont = WFG_Test_Data_Utility.createIndividualRecord('Test', 'Contact', '7878787878', 'Single');
        insert cont;
        
        //insert customer profile
        insert WFG_Test_Data_Utility.createCustomerProfile(cont.id);
        
        //insert opportunity
        insert WFG_Test_Data_Utility.createOppty(acc.Id);
    }
    
    /*
    Test method for Contact header
    */
    static testMethod void testContactHeader(){
        
        //get contact id
        List<Contact> lstContact = [SELECT Id, Name FROM Contact LIMIT 1];
        
        test.startTest();
        if(!lstContact.isEmpty()){
            WFG_CommunityHeaderController.getHighlightPanelData(lstContact[0].id, 'Contact');
        }
        test.stopTest();
    }
    
    /*
    Test method for Customer Profile header
    */
    static testMethod void testCPHeader(){
        //get CP id
        List<WFG_Customer_Profile__c> lstCP = [SELECT Id, Name FROM WFG_Customer_Profile__c LIMIT 1];
        
        test.startTest();
        if(!lstCP.isEmpty()){
            WFG_CommunityHeaderController.getHighlightPanelData(lstCP[0].id, 'Customer Profile');
        }
        test.stopTest();
    }
    
    /*
    Test method for Opportunity header
    */
    static testMethod void testOpportunityHeader(){
        //get Oppty id
        List<Opportunity> lstOpportunity = [SELECT Id, Name FROM Opportunity LIMIT 1];
        
        test.startTest();
        if(!lstOpportunity.isEmpty()){
            WFG_CommunityHeaderController.getHighlightPanelData(lstOpportunity[0].id, 'Opportunity');
        }
        test.stopTest();
    }

}