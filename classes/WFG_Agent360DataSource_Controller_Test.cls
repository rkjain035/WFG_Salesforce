/*
Property of Transamerica and Aegon companies. Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Madhurupa Ghose Roy
* @date 05-20-2016
* @description US-2295: This page does below processing
  - View the 360 degree information for an Agent

Modification Log:
__________________________________________________________________________________________________________
Developer          ModNumber           Date                    Description
__________________________________________________________________________________________________________
*/
@isTest(seeAllData=false)
public class WFG_Agent360DataSource_Controller_Test{
    
    static testmethod void TestAsSystemAdmin(){
        try
        {
        
        User Admin =WFG_TestDataFactory.user('System Administrator');
        insert Admin;
        
        system.runAs(Admin){

        WFG_TestDataFactory.createTriggerActivationRecords(); // Added during Service Center changes before FSC Installation
        WFG_TestDataFactory.createWFGUtilityCustomSettingRecords(); // Nik - Fix for the null pointer exceptions due to WFG Utility references
        list<account> lstaccount = WFG_TestDataFactory.createAccounts(6);
        insert lstaccount;
        
        //insert contactRecord
        list<Contact> lstContact= WFG_TestDataFactory.createContacts(6, lstaccount);
        insert lstContact;

        list<case> lstCase= WFG_TestDataFactory.createCases(6, lstContact);
        insert lstCase;
        System.debug('lstCase'+lstCase);
        LiveChatVisitor lChatVisitor = new LiveChatVisitor();
        insert lChatVisitor;
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(ContactID =lstContact[1].Id,LiveChatVisitorId = lChatVisitor.Id,StartTime = System.now(),EndTime = System.now() );
        insert liveChatTranscript;
        
        list<WFG_AgentStatus__c> lstAgentStatus = WFG_TestDataFactory.createWFG_AgentStatuss(6, lstContact);
        insert lstAgentStatus;
        
        list<WFG_AgentCode__c> lstAgentCodes = WFG_TestDataFactory.createAgentCodes(6, lstContact);
        insert lstAgentCodes;
        List<Id> agentCodeIds = new List<Id>();
        for(WFG_AgentCode__c codeIds: lstAgentCodes)
        {
            agentCodeIds.add(codeIds.Id);
        }
        List<WFG_AgentCode__c> lstUpdateAgentCodes = new List<WFG_AgentCode__c>();
        for(Integer i=0;i<lstAgentCodes.size();i++)
        {
           
            if(i < agentCodeIds.size()-1 )
            {
              lstAgentCodes[i].WFG_RegionalBranchManagerCode__c = agentCodeIds[i+1]; 
               lstAgentCodes[i].WFG_BranchOfficeManagerCode__c = agentCodeIds[i+1];
                lstAgentCodes[i].WFG_BranchOfficeSupervisorCode__c = agentCodeIds[i+1];
                lstAgentCodes[i].WFG_UplineCode__c = agentCodeIds[i+1];
            }
            else
            {
                
                lstAgentCodes[i].WFG_RegionalBranchManagerCode__c = agentCodeIds[0]; 
                lstAgentCodes[i].WFG_BranchOfficeManagerCode__c = agentCodeIds[0];
                lstAgentCodes[i].WFG_BranchOfficeSupervisorCode__c = agentCodeIds[0];
                lstAgentCodes[i].WFG_UplineCode__c = agentCodeIds[0];
            }
            lstUpdateAgentCodes.add(lstAgentCodes[i]);
            
        
        }
         if(!lstUpdateAgentCodes.isEmpty())
         {
             update lstUpdateAgentCodes;
         }

        lstContact[1].WFG_SpouseCode__c= lstAgentCodes[2].ID;
        update lstContact[1];
          Id [] fixedSearchResults= new Id[lstAgentCodes.size()+1];
            for(integer i=0; i<lstAgentCodes.size(); i++){
                fixedSearchResults[i] = lstAgentCodes[i].ID;  
            }
        Test.setFixedSearchResults(fixedSearchResults);  
        test.startTest();
        system.assertEquals(true, schema.sObjectType.Contact.isCreateable());
        system.assertEquals(True, schema.sObjectType.Case.isCreateable());
        WFG_Agent360DataSource_Controller.getCaseResults(lstContact[1].Id);
        WFG_Agent360DataSource_Controller.getContact(lstContact[1].Id);
        //WFG_Agent360DataSource_Controller.getAgentCodeData(lstContact[1].Id);
        WFG_Agent360DataSource_Controller.getCaseStatus();
        WFG_Agent360DataSource_Controller.getCaseSource();
        WFG_Agent360DataSource_Controller.getCaseReason();
        WFG_Agent360DataSource_Controller.getCaseType();
        WFg_Agent360DataSource_Controller.getDependentOptions1();
        //WFg_Agent360DataSource_Controller.getContacts('Contact0');
        WFG_Agent360DataSource_Controller.getCaseContact(lstCase[1].Id);
        WFG_Agent360DataSource_Controller.createNewCase(lstContact[1].Id, lstCase[1].subject, lstCase[1].Description, lstCase[1].Type, lstCase[1].Status, lstCase[1].WFG_Resolution__c, lstCase[1].Origin, lstCase[1].WFG_InteractingWith__c, lstContact[1].Id, lstCase[1].WFG_AgentCode__c, lstCase[1].WFG_InteractingAboutCode__c, lstCase[1].WFG_Case_Reason_2__c);
        WFG_Agent360DataSource_Controller.autocompleteComment();
        //Added By Ram
        
        WFG_Agent360DataSource_Controller.getContacts(lstAgentCodes[0].Name);
        WFG_Agent360DataSource_Controller.createNewCaseRecord(lstCase[1]);
        WFG_Agent360DataSource_Controller.getChatTranscripts(lstContact[1].Id);
        test.stopTest();
    }
        }
        catch(Exception e)
        {
        }
}
    
    static testmethod void TestAsElitePartner() 
    {
        WFG_TestDataFactory.createTriggerActivationRecords();
        User ElitePartner = WFG_TestDataFactory.user('Elite Partner');
        insert ElitePartner;
        WFG_TestDataFactory.createWFGUtilityCustomSettingRecords(); // Nik - Fix for the null pointer exceptions due to WFG Utility references
        // system.runAs(ElitePartner) - Nik
        {
            list<account> lstaccount = WFG_TestDataFactory.createAccounts(6);
            insert lstaccount;
            //insert contactRecord
            list<Contact> lstContact= WFG_TestDataFactory.createContacts(6, lstaccount);
             for(contact objCon : lstContact)
                {
                    objCon.WFG_AgentPayType__c = 'WFG';
                    objCon.WFG_Type__c = 'Registered_Rep';
                    objCon.WFG_cycletype__C = 'US';
                }
            //lstContact[0].AccountId = lstaccount[0].Id;
            System.Debug('lstContact'+lstContact);
            try
            {
                insert lstContact;
            }
            catch(Exception e){
                System.debug('Error while creating contacts '+e.getStackTraceString()+e.getCause()+e.getMessage());
            }
            
           list<case> lstCase= WFG_TestDataFactory.createCases(6, lstContact);
           insert lstCase;
           system.debug(lstCase);
            
            list<WFG_AgentStatus__c> lstAgentStatus = WFG_TestDataFactory.createWFG_AgentStatuss(6, lstContact);
            insert lstAgentStatus;
            
            list<WFG_AgentCode__c> lstAgentCodes = WFG_TestDataFactory.createAgentCodes(6, lstContact);
            insert lstAgentCodes;
            //Added By Ram
           lstAgentCodes[0].WFG_RegionalBranchManagerCode__c = lstAgentCodes[3].Id;
           lstAgentCodes[0].WFG_BranchOfficeManagerCode__c = lstAgentCodes[4].Id;
           lstAgentCodes[0].WFG_BranchOfficeSupervisorCode__c = lstAgentCodes[5].Id;
                
           update lstAgentCodes[0];
    
            lstContact[1].WFG_SpouseCode__c= lstAgentCodes[2].ID;
            update lstContact[1];
            Id [] fixedSearchResults= new Id[lstAgentCodes.size()+1];
                for(integer i=0; i<lstAgentCodes.size(); i++){
                    fixedSearchResults[i] = lstAgentCodes[i].ID;  
                }
            Test.setFixedSearchResults(fixedSearchResults);
            system.debug('contact record in test class'+lstContact);
            test.startTest();
            // system.assertEquals(false, schema.sObjectType.Contact.isCreateable()); - Nik
            // system.assertEquals(True, schema.sObjectType.Case.isCreateable()); - Nik
            WFG_Agent360DataSource_Controller.getCaseResults(lstContact[1].Id);
            WFG_Agent360DataSource_Controller.getContact(lstContact[1].Id);
            
            //WFG_Agent360DataSource_Controller.getAgentCodeData(lstContact[1].Id);
            WFG_Agent360DataSource_Controller.getCaseStatus();
            WFG_Agent360DataSource_Controller.getCaseSource();
            WFG_Agent360DataSource_Controller.getCaseReason();
            WFG_Agent360DataSource_Controller.getCaseType();
            WFg_Agent360DataSource_Controller.getDependentOptions();
            //WFg_Agent360DataSource_Controller.getContacts('Test');
            WFG_Agent360DataSource_Controller.getCaseContact(lstCase[1].Id);
            WFG_Agent360DataSource_Controller.createNewCase(lstContact[1].Id, lstCase[1].subject, lstCase[1].Description, lstCase[1].Type, lstCase[1].Status, lstCase[1].WFG_Resolution__c, lstCase[1].Origin, lstCase[1].WFG_InteractingWith__c, lstContact[1].Id, lstCase[1].WFG_AgentCode__c, lstCase[1].WFG_InteractingAboutCode__c, lstCase[1].WFG_Case_Reason_2__c);
            WFG_Agent360DataSource_Controller.autocompleteComment();
                 //Added By Ram
            WFG_Agent360DataSource_Controller.getContacts(lstAgentCodes[0].Name);
            WFG_Agent360DataSource_Controller.createNewCaseRecord(lstCase[1]);
            WFG_Agent360DataSource_Controller.getChatTranscripts(lstContact[1].Id);
                test.stopTest();

        }
    }
    
    static testmethod void TestAsSupportRepresentative()
    {
        try
        {
        WFG_TestDataFactory.createTriggerActivationRecords();
        WFG_TestDataFactory.createWFGUtilityCustomSettingRecords(); // Nik - Fix for the null pointer exceptions due to WFG Utility references
        User SupportRepresentative =WFG_TestDataFactory.user('Support Representative');
        insert SupportRepresentative; 
        
        system.debug('profile user id'+SupportRepresentative);
        // system.runAs(SupportRepresentative)
        {
        list<account> lstaccount = WFG_TestDataFactory.createAccounts(6);
        
        insert lstaccount;
        
        //insert contactRecord
        list<Contact> lstContact= WFG_TestDataFactory.createContacts(6, lstaccount);
        //lstContact[0].AccountId = lstaccount[0].Id;
        insert lstContact;
        LiveChatVisitor lChatVisitor = new LiveChatVisitor();
       insert lChatVisitor;
       LiveChatTranscript liveChatTranscript = new LiveChatTranscript(ContactID =lstContact[1].Id,LiveChatVisitorId = lChatVisitor.Id,StartTime = System.now(),EndTime = System.now() );
       insert liveChatTranscript;
       
       list<case> lstCase= WFG_TestDataFactory.createCases(6, lstContact);
       insert lstCase;
       system.debug(lstCase);
        
        list<WFG_AgentStatus__c> lstAgentStatus = WFG_TestDataFactory.createWFG_AgentStatuss(6, lstContact);
        insert lstAgentStatus;
        
        list<WFG_AgentCode__c> lstAgentCodes = WFG_TestDataFactory.createAgentCodes(6, lstContact);
        insert lstAgentCodes;
        
        //Added By Ram
       lstAgentCodes[0].WFG_RegionalBranchManagerCode__c = lstAgentCodes[3].Id;
       lstAgentCodes[0].WFG_BranchOfficeManagerCode__c = lstAgentCodes[4].Id;
       lstAgentCodes[0].WFG_BranchOfficeSupervisorCode__c = lstAgentCodes[5].Id;
       update lstAgentCodes[0];
   

        lstContact[1].WFG_SpouseCode__c= lstAgentCodes[2].ID;
        update lstContact[1];
        Id [] fixedSearchResults= new Id[lstAgentCodes.size()+1];
            for(integer i=0; i<lstAgentCodes.size(); i++){
                fixedSearchResults[i] = lstAgentCodes[i].ID;  
            }
        Test.setFixedSearchResults(fixedSearchResults);
        
        
        test.startTest();
        // system.assertEquals(false, schema.sObjectType.Contact.isCreateable()); - Nik
        // system.assertEquals(True, schema.sObjectType.Case.isCreateable()); - Nik
        WFG_Agent360DataSource_Controller.getCaseResults(lstContact[1].Id);
        WFG_Agent360DataSource_Controller.getContact(lstContact[1].Id);
        //WFG_Agent360DataSource_Controller.getAgentCodeData(lstContact[1].Id);
        WFG_Agent360DataSource_Controller.getCaseStatus();
        WFG_Agent360DataSource_Controller.getCaseSource();
        WFG_Agent360DataSource_Controller.getCaseReason();
        WFG_Agent360DataSource_Controller.getCaseType();
        WFg_Agent360DataSource_Controller.getDependentOptions1();
        //WFg_Agent360DataSource_Controller.getContacts('Test');
        WFG_Agent360DataSource_Controller.getCaseContact(lstCase[1].Id);
        WFG_Agent360DataSource_Controller.createNewCase(lstContact[1].Id, lstCase[1].subject, lstCase[1].Description, lstCase[1].Type, lstCase[1].Status, lstCase[1].WFG_Resolution__c, lstCase[1].Origin, lstCase[1].WFG_InteractingWith__c, lstContact[1].Id, lstCase[1].WFG_AgentCode__c,lstCase[1].WFG_InteractingAboutCode__c, lstCase[1].WFG_Case_Reason_2__c);
        WFG_Agent360DataSource_Controller.autocompleteComment();
             //Added By Ram
        WFG_Agent360DataSource_Controller.getContacts(+lstAgentCodes[0].Name);
        WFG_Agent360DataSource_Controller.createNewCaseRecord(lstCase[1]);
        WFG_Agent360DataSource_Controller.getChatTranscripts(lstContact[1].Id);
        test.stopTest();
       
    }  
        }
        catch(exception e)
        {
        }
}
}