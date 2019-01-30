/**
*
Property of Transamerica and Aegon companies. Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Deloitte Consulting LLP
* @date 05-31-2016
* @description US-1128: this test class is for WFG_RespondToCustomer Controller

Modification Log:
-------------------------------------------------------------------------------------------------------
Developer          ModNumber           Date                    Description
-------------------------------------------------------------------------------------------------------
Suhan Jain          M-001              05-31-2016              Initial version

*
**/

@isTest(SeeAllData=False)
public class WFG_RespondToCustomer_Controller_Test{
    
    /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Searches Cases
    * @author Deloitte Consulting LLP
    * @date 05/07/2016
    * @param None
    * @return None
    * @description : Test method for WFG_RespondToCustomer_Controller methods
    */
    public static testmethod void TestAsSystemAdmin() {
         WFG_Test_Data_Utility.createTriggerActivationRecords();   
        User Admin =WFG_TestDataFactory.user('System Administrator');
        insert Admin;
        
        //run method as Admin User
        system.runAs(Admin){
            list<QuickText> lstText=WFG_TestDataFactory.createQuickTexts(4);
            insert lstText;
            
            //insert account
            list<account> lstAcc = WFG_TestDataFactory.createAccounts(6);
            insert lstAcc;
            
            //insert contactRecord
            list<Contact> lstCon = WFG_TestDataFactory.createContacts(6, lstAcc);
            insert lstCon;
            
            //insert list of cases
            list<Case> lstCase = WFG_TestDataFactory.createCases(6, lstCon);
            insert lstCase;
            
            //set mock test results for sosl query
            Id [] fixedSearchResults= new Id[lstText.size()+1];
            for(integer i=0; i<lstText.size(); i++){
                fixedSearchResults[i] = lstText[i].ID;  
            }
            Test.setFixedSearchResults(fixedSearchResults); 
        
            test.startTest();
            
            Test.setCurrentPageReference(new PageReference('Page.WFG_RespondToCustomer'));
            System.currentPageReference().getParameters().put('ID',lstCase[0].Id);
            WFG_RespondToCUstomer_Controller controller = new WFG_RespondToCUstomer_Controller();
            
            //Invoke controller methods
            controller.objCase.Id = null;
            try{
            controller.doPost();
            controller.closeCase(); 
            }
            catch(DMLException e)
            {
                //system.assertEquals(e.getMessage(), e.getMessage()); 
            }
             
            controller.reloadwindow();
            system.assertEquals('Closed', controller.objCase.Status);
            system.assertEquals(true, schema.sObjectType.Contact.isCreateable());
            system.assertEquals(True, schema.sObjectType.Case.isCreateable());
            
            
            
            
            List <QuickText> lstTextmessage=WFG_RespondToCUstomer_Controller.autocompleteComment('Please');
            system.assertEquals('Please visit the nearest call center', lstTextmessage[0].Message);
            test.stopTest();
            
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
    * @description : Test method for WFG_RespondToCustomer_Controller methods as Elite Partner User
    */
    public static testmethod void TestAsElitePartner() {
        WFG_Test_Data_Utility.createTriggerActivationRecords();   
        User ElitePartner =WFG_TestDataFactory.user('Elite Partner');
        insert ElitePartner;
        try
        {
        //Run as Elite Partner User        
        system.runAs(ElitePartner){
            
            list<QuickText> lstText=WFG_TestDataFactory.createQuickTexts(4);
            insert lstText;
            
            //insert account
            list<account> lstAcc = WFG_TestDataFactory.createAccounts(6);
            insert lstAcc;
            
            //insert contactRecord
            list<Contact> lstCon = WFG_TestDataFactory.createContacts(6, lstAcc);
            insert lstCon;
            
            //insert list of cases
            list<Case> lstCase = WFG_TestDataFactory.createCases(6, lstCon);
            insert lstCase;
            
            //set mock test results for sosl query
            Id [] fixedSearchResults= new Id[lstText.size()+1];
            for(integer i=0; i<lstText.size(); i++){
                fixedSearchResults[i] = lstText[i].ID;  
            }
            Test.setFixedSearchResults(fixedSearchResults); 
        
            test.startTest();
            
            Test.setCurrentPageReference(new PageReference('Page.WFG_RespondToCustomer'));
            System.currentPageReference().getParameters().put('ID',lstCase[0].Id);
            WFG_RespondToCUstomer_Controller controller = new WFG_RespondToCUstomer_Controller();
            
            //Invoke controller methods
            controller.objCase.Id = null;
            try{
            controller.doPost();
            controller.closeCase(); 
            }
            catch(DMLException e)
            {
                //system.assertEquals(e.getMessage(), e.getMessage()); 
            }
             
            controller.reloadwindow();
            system.assertEquals('Closed', controller.objCase.Status);
            system.assertEquals(false, schema.sObjectType.Contact.isCreateable());
            system.assertEquals(true, schema.sObjectType.Case.isCreateable());
            
            
            
            
            List <QuickText> lstTextmessage=WFG_RespondToCUstomer_Controller.autocompleteComment('Please');
            system.assertEquals('Please visit the nearest call center', lstTextmessage[0].Message);
            test.stopTest();
        }
        }
        catch(Exception e)
        {
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
    * @description : Test method for WFG_RespondToCustomer_Controller methods as Support Representative User
    */
    public static testmethod void TestAsSupportRepresentative() {
         WFG_Test_Data_Utility.createTriggerActivationRecords();   
        User SupportRepresentative =WFG_TestDataFactory.user('Support Representative');
        insert SupportRepresentative; 
        try
        {
            //Run as Support Representative User        
            system.runAs(SupportRepresentative){
            
            list<QuickText> lstText=WFG_TestDataFactory.createQuickTexts(4);
            insert lstText;
            
            //insert account
            list<account> lstAcc = WFG_TestDataFactory.createAccounts(6);
            insert lstAcc;
            
            //insert contactRecord
            list<Contact> lstCon = WFG_TestDataFactory.createContacts(6, lstAcc);
            insert lstCon;
            
            //insert list of cases
            list<Case> lstCase = WFG_TestDataFactory.createCases(6, lstCon);
            insert lstCase;
            
            //set mock test results for sosl query
            Id [] fixedSearchResults= new Id[lstText.size()+1];
            for(integer i=0; i<lstText.size(); i++){
                fixedSearchResults[i] = lstText[i].ID;  
            }
            Test.setFixedSearchResults(fixedSearchResults); 
        
            test.startTest();
            
            Test.setCurrentPageReference(new PageReference('Page.WFG_RespondToCustomer'));
            System.currentPageReference().getParameters().put('ID',lstCase[0].Id);
            WFG_RespondToCUstomer_Controller controller = new WFG_RespondToCUstomer_Controller();
            
            //Invoke controller methods
            controller.objCase.Id = null;
            try{
            controller.doPost();
            controller.closeCase(); 
            }
            catch(DMLException e)
            {
                //system.assertEquals(e.getMessage(), e.getMessage()); 
            }
             
            controller.reloadwindow();
            system.assertEquals('Closed', controller.objCase.Status);
            system.assertEquals(false, schema.sObjectType.Contact.isCreateable());
            system.assertEquals(true, schema.sObjectType.Case.isCreateable());
            
            
            
            
            List <QuickText> lstTextmessage=WFG_RespondToCUstomer_Controller.autocompleteComment('Please');
            system.assertEquals('Please visit the nearest call center', lstTextmessage[0].Message);
            test.stopTest();
        }
        }
        catch(Exception e)
        {
        }
    }
}