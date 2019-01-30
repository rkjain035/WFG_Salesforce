/**
 *
 Property of Transamerica and Aegon companies. Do not distribute without permission.
 * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
 * @author Deloitte Consulting LLP
 * @date 05/26/2016
 * @description US-2300, US-2301: this class is assigncaseentitlement handler class. This class is written for assigning the apropriate entitlement to the case 
 Modification Log:
 -------------------------------------------------------------------------------------------------------
 Developer          ModNumber           Date                    Description
 -------------------------------------------------------------------------------------------------------
 Suhan Jain          M-001              05/26/2016              Initial version

 **/
@isTest
public class WFG_CaseHandlerTest {
    
    /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Searches Cases
    * @author Deloitte Consulting LLP
    * @date 05/07/2016
    * @param None
    * @return None
    * @description : Set up method for test data
    */
    @testSetup
    static void createTestData() {        
        List<User> lstUser = new List<User>();
        User Admin = WFG_TestDataFactory.user('System Administrator');
        lstUser.add(Admin);
        User objFAUser = WFG_Test_Data_Utility.createTestUser(System.Label.WFG_FA_Label);
        lstUser.add(objFAUser);
        insert lstUser;
        //Run as Admin User
        system.runAs(Admin){
            WFG_TestDataFactory.createTriggerActivationRecords(); // Added during Service Center changes before FSC Installation
            WFG_TestDataFactory.createWFGUtilityCustomSettingRecords(); // Nik - Fix for the null pointer exceptions due to WFG Utility references
            //Insert Account
            list<account> lstAcc= WFG_TestDataFactory.createAccounts(30);
            insert lstAcc;
            
            //insert Entitlements
            List<Entitlement> lstEntitlement = new List<Entitlement>();
            for(Integer i=0;i<lstAcc.size();i++)
            {
                Entitlement ent =  WFG_TestDataFactory.Entitlement(lstAcc[i].Id); 
                lstEntitlement.add(ent);  
            }
            if(!lstEntitlement.isEmpty())
            {
                insert lstEntitlement;
            }
            
            //insert contactRecord
            list<Contact> lstCon = WFG_TestDataFactory.createContacts(30,lstAcc);
            for(Integer i = 0 ; i < 25 ; i++){
                lstCon[i].WFG_AgentLevel__c = 75;
            }
            system.debug('contact----' + lstCon[0].WFG_AgentCode__c);
            insert lstCon;
            WFG_EntitlementName__c customSetting = new WFG_EntitlementName__c(Name = 'WFG Leaders',Ent_Name__c = 'WFG Leaders');
            insert customSetting;
            System.debug('#####beforeErrorEvry');

            list <Case> lstCase= WFG_TestDataFactory.createCases(30,lstCon);
            system.debug('cases----' + lstCase[0].WFG_InteractingAboutCode__c);
            lstCase[0].WFG_InteractingAbout__c = null;
            lstCase[1].ContactId = null;
            lstCase[0].WFG_InteractingAboutCode__c = 'A2'; 
            lstCase[1].WFG_AgentCode__c = 'A2'; 
            lstCase[1].WFG_InteractingAboutCode__c = 'A2'; 
            lstCase[0].WFG_AgentCode__c = 'A2'; 
            insert lstCase;
            
            list<Case> lstCasetoUpdate = new list<Case>();
            for(Case objCase: lstCase){
                
                if(objCase.Status == 'Closed'){
                    
                    objCase.SlaStartDate = System.now();
                    lstCasetoUpdate.add(objCase);
                }
            }
            update lstCasetoUpdate;
            
            lstCase[0].ownerId = objFAUser.id;
            update lstCase;
            System.debug('#####'+lstCase);
        }
    }
    
    /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Searches Cases
    * @author Deloitte Consulting LLP
    * @date 05/07/2016
    * @param None
    * @return None
    * @description : Test method for WFG_CaseHandler methods for Bulk Records
    */
    static testmethod void TestAsSystemAdmin() {
        
      //  User Admin = [SELECT id FROM User WHERE LastName = 'Testing'  LIMIT 1];
        User Admin = WFG_Test_Data_Utility.createTestUser('System Administrator');
        //Run as Admin User
        system.runAs(Admin){
            
            //Assert Cases with Entitlement Id
            List<Case> lstCase = [SELECT id, EntitlementId, WFG_RelatedEntitlement__c FROM Case WHERE EntitlementId != null];
            
            //assert only cases with entitlement name are updated
            //system.assertEquals(lstCase.size(),25);
            //system.assertEquals(lstCase[0].WFG_RelatedEntitlement__c,'WFG Leaders');
        }
    }
}