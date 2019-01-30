/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Deloitte Consulting LLP
* @date 03-26-2015
* @description US-1065: Contains the test calss for WFG_ComplaintsPanelController class

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Suhan Jain            M-001              04-22-2016              US-1195: Quick create case  
Suhan Jain            M-002              05-06-2016              US-2274: Case search filters
Suhan Jain            M-003              05-10-2016              US-1137: Canned text for issues 
                                                                 and resolution
Suhan Jain            M-004              05-10-2016              US-2280: Removed autofill contact test 
Suhan Jain            M-005              05-10-2016              US-1136: Case search fields
Suhan Jain            M-006              05-13-2016              US-2285: Complaint Management 
                                                                 Compatibility

*/

@isTest(SeeAllData=False)
public class WFG_ComplaintsPanelTest {
    
    
    /**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* Method which triggers the corresponding handler method for After Insert event.
* @author Deloitte
* @date 26/03/2015 
* @param Main test Method
* @return Void
* @description US-1065: Contains the main test method for WFG_ComplaintsPanelController
*/
    
    static testmethod void TestAsSystemAdmin() {
        WFG_ComplaintsPanelController controller = new WFG_ComplaintsPanelController();
        
        User Admin =WFG_TestDataFactory.user('System Administrator');
        insert Admin;
        WFG_TestDataFactory.createTriggerActivationRecords(); // Added during Service Center changes before FSC Installation
        WFG_TestDataFactory.createWFGUtilityCustomSettingRecords(); // Nik - Fix for the null pointer exceptions due to WFG Utility references
        system.runAs(Admin){
            //Insert Account
            list<account> lstAcc= WFG_TestDataFactory.createAccounts(6);
            insert lstAcc;
 
            //insert contactRecord
            list<Contact> lstCon = WFG_TestDataFactory.createContacts(6,lstAcc);
            insert lstCon;
            
            list <Case> lstCase= WFG_TestDataFactory.createCases(6,lstCon);
            insert lstCase;
            //Added by Ram for covering agent code search
            List<WFG_AgentCode__c> lstAgtCode = WFG_TestDataFactory.createAgentCodes(6,lstCon);
            insert lstAgtCode;
            
            
            Id [] fixedSearchResults= new Id[lstCon.size()+1];
            for(integer i=0; i<lstCon.size(); i++){
                fixedSearchResults[i] = lstCon[i].ID;  
            }
            Test.setFixedSearchResults(fixedSearchResults);
            
            
            System.debug('####$$$$%%%%%'+lstAgtCode[0].Name);
            //Test methods.
            Test.startTest();     
            controller.strSearchString = ' Contact ';
            controller.search();
            controller.strSearchString = lstAgtCode[0].Name; //Added by Ram for covering agent code search
            controller.search();
            system.assertEquals(true, schema.sObjectType.Contact.isCreateable());
            system.assertEquals(True, schema.sObjectType.Case.isCreateable());
            Test.stopTest();
            
        }
    }
    static testmethod void TestAsElitePartner() {
        WFG_ComplaintsPanelController controller = new WFG_ComplaintsPanelController();
        User ElitePartner =WFG_TestDataFactory.user('Elite Partner');
        insert ElitePartner;
        WFG_TestDataFactory.createTriggerActivationRecords(); // Added during Service Center changes before FSC Installation
        WFG_TestDataFactory.createWFGUtilityCustomSettingRecords(); // Nik - Fix for the null pointer exceptions due to WFG Utility references
        // system.runAs(ElitePartner)
        {
            //Insert Account
            list<account> lstAcc= WFG_TestDataFactory.createAccounts(6);
            insert lstAcc;
            
            //insert contactRecord
            list<Contact> lstCon = WFG_TestDataFactory.createContacts(6,lstAcc);
            insert lstCon;
            
            list <Case> lstCase= WFG_TestDataFactory.createCases(6,lstCon);
            insert lstCase;
            
            Id [] fixedSearchResults= new Id[lstCase.size()+1];
            for(integer i=0; i<lstCase.size(); i++){
                fixedSearchResults[i] = lstCase[i].ID;  
            }
            Test.setFixedSearchResults(fixedSearchResults);
            
            //Test methods.
            Test.startTest();     
            controller.strSearchString = lstCase[0].Subject;
            controller.search();
            // system.assertEquals(false, schema.sObjectType.Contact.isCreateable()); - Nik
            // system.assertEquals(True, schema.sObjectType.Case.isCreateable()); - Nik
            Test.stopTest();
            
        }
    }
    static testmethod void TestAsSupportRepresentative() {
        WFG_ComplaintsPanelController controller = new WFG_ComplaintsPanelController();
        
        User SupportRepresentative =WFG_TestDataFactory.user('Support Representative');
        insert SupportRepresentative; 
        WFG_TestDataFactory.createTriggerActivationRecords(); // Added during Service Center changes before FSC Installation
        WFG_TestDataFactory.createWFGUtilityCustomSettingRecords(); // Nik - Fix for the null pointer exceptions due to WFG Utility references
        
        // system.runAs(SupportRepresentative)
        {
            list<account> lstAcc= WFG_TestDataFactory.createAccounts(6);
            insert lstAcc;
            
            //insert contactRecord
            list<Contact> lstCon = WFG_TestDataFactory.createContacts(6,lstAcc);
            insert lstCon;
            
            list <Case> lstCase= WFG_TestDataFactory.createCases(6,lstCon);
            insert lstCase;
            
            Id [] fixedSearchResults= new Id[lstCase.size()+1];
            for(integer i=0; i<lstCase.size(); i++){
                fixedSearchResults[i] = lstCase[i].ID;  
            }
            Test.setFixedSearchResults(fixedSearchResults);
            
            //Test methods.
            Test.startTest();     
            controller.strSearchString = lstCase[0].Subject;
            controller.search();
            // system.assertEquals(false, schema.sObjectType.Contact.isCreateable()); - Nik
            // system.assertEquals(True, schema.sObjectType.Case.isCreateable()); - Nik
            Test.stopTest();
            
        }
    }
}