/**--Property of Transamerica and Aegon companies. Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Ramanarayanan P
* @date 05-11-2016
* @description US-1149: Controller fetches contact based on agent code recireved from chat button page

Modification Log:
-------------------------------------------------------------------------------------------------------
Developer          ModNumber           Date                    Description
-------------------------------------------------------------------------------------------------------
**/

@isTest
public class WFG_PreChatPage_Controller_Test
{
      
    public static testMethod void PreChatController_Test_Method()
    {
        WFG_TestDataFactory.createTriggerActivationRecords(); // Added during Service Center changes before FSC Installation
        WFG_TestDataFactory.createWFGUtilityCustomSettingRecords(); // Nik - Fix for the null pointer exceptions due to WFG Utility references
        list<account> lstAcc = WFG_TestDataFactory.createAccounts(1);
        insert lstAcc;
        
        list<Contact> lstCon = WFG_TestDataFactory.createContacts(1, lstAcc);
        insert lstCon;
        
        list<Case> lstCase = WFG_TestDataFactory.createCases(1, lstCon);
        insert lstCase;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(lstCase[0]);
        WFG_PreChatPage_Controller controller = new WFG_PreChatPage_Controller(sc);
        controller.strAgentCode  = '00JRC';
        String AgentCode = '00JRC';
        Contact con =   WFG_TestDataFactory.getContact();
        insert con;
        WFG_PreChatPage_Controller.getContact(AgentCode);
    } 
    
}