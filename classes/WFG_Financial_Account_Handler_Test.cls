/*
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2018] Transamerica Corporation, its affiliates and their licensors.
* @author Hampesh
* @date 4-Jul-2018
* @description - Test class for WFG_Financial_Account_Handler class 

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Hampesh               MOD-01             4-Jul-2018             Checks for duplicate product name
                                                              
*/
@isTest
private class WFG_Financial_Account_Handler_Test{
    //This method tests product name duplicate before insert
    static testmethod void testfinancialaccountCreation(){
        
        WFG_TriggerActivation__c objAccountTriggerActivation = new WFG_TriggerActivation__c(Object_Name__c = 'Account', Name ='WFG_Account', WFG_isActive__c = true);
        insert objAccountTriggerActivation;
        
        WFG_TriggerActivation__c objFinAccTriggerActivation = new WFG_TriggerActivation__c(Object_Name__c = 'FinServ__FinancialAccount__c', Name ='WFG_Financial_Account', WFG_isActive__c = true);
        insert objFinAccTriggerActivation; 
        
        Contact testContact1 =  WFG_Test_Data_Utility.createIndividualRecord('test1','Gauren1','99999999997','Married');
        testContact1.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        
        Contact testContact2 =  WFG_Test_Data_Utility.createIndividualRecord('test','Gauren','99999999998','Married');
        testContact2.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        
        List<contact> lstContact=new List<contact>();
        lstContact.add(testContact2);
        lstContact.add(testContact1);
        insert lstContact;
        
        List<FinServ__FinancialAccount__c> lstFinAcc=new List<FinServ__FinancialAccount__c>();
        List<contact> insertedConlist=[select id,AccountId from contact where ownerid=:userinfo.getUserId()] ;
        FinServ__FinancialAccount__c finAcc1=new FinServ__FinancialAccount__c();
        finAcc1.Name='testfinacc1';
        finAcc1.WFG_Product_Name__c='prod1';
        finAcc1.FinServ__PrimaryOwner__c=insertedConlist[0].AccountId ;
        lstFinAcc.add(finAcc1);
        
        FinServ__FinancialAccount__c finAcc2=new FinServ__FinancialAccount__c();
        finAcc2.Name='testfinacc2';
        finAcc2.WFG_Product_Name__c='prod2';
        finAcc2.FinServ__PrimaryOwner__c=insertedConlist[1].AccountId ;
        lstFinAcc.add(finAcc2);
        insert lstFinAcc;
        
        test.starttest();
        WFG_Financial_Account_Handler.checkduplicatebeforeInsert();
        test.stoptest();
        
    }
    
  //This method tests product name duplicate before update 
  static testMethod void testfinancialaccountUpdate() {
        WFG_TriggerActivation__c objAccountTriggerActivation = new WFG_TriggerActivation__c(Object_Name__c = 'Account', Name ='WFG_Account', WFG_isActive__c = true);
        insert objAccountTriggerActivation;
      
        WFG_TriggerActivation__c objFinAccTriggerActivation = new WFG_TriggerActivation__c(Object_Name__c = 'FinServ__FinancialAccount__c', Name ='WFG_Financial_Account', WFG_isActive__c = true);
        insert objFinAccTriggerActivation; 
      
        Contact testContact1 =  WFG_Test_Data_Utility.createIndividualRecord('test1','Gauren1','99999999997','Married');
        testContact1.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
            
        Contact testContact2 =  WFG_Test_Data_Utility.createIndividualRecord('test','Gauren','99999999998','Married');
        testContact2.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
      
        List<contact> lstContact=new List<contact>();
        lstContact.add(testContact2);
        lstContact.add(testContact1);
        insert lstContact;
        
        List<FinServ__FinancialAccount__c> lstFinAcc=new List<FinServ__FinancialAccount__c>();
        List<contact> insertedConlist=[select id,AccountId from contact where ownerid=:userinfo.getUserId()] ;
      
        FinServ__FinancialAccount__c finAcc1=new FinServ__FinancialAccount__c();
        finAcc1.Name='testfinacc1';
        finAcc1.WFG_Product_Name__c='prod1';
        finAcc1.FinServ__PrimaryOwner__c=insertedConlist[0].AccountId ;
        lstFinAcc.add(finAcc1);
      
        FinServ__FinancialAccount__c finAcc2=new FinServ__FinancialAccount__c();
        finAcc2.Name='testfinacc2';
        finAcc2.WFG_Product_Name__c='prod2';
        finAcc2.FinServ__PrimaryOwner__c=insertedConlist[1].AccountId ;
        lstFinAcc.add(finAcc2);
        insert lstFinAcc;
      
        lstFinAcc[0].WFG_Product_Name__c='prod4';
        update lstFinAcc;
        test.starttest();
        WFG_Financial_Account_Handler.checkduplicatebeforeInsert();
        test.stoptest();
  }
}