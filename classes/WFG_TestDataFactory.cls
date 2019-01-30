/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Deloitte Consulting LLP
* @date 03-26-2015
* @description Data Factory Class for Test Classes

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Suhan Jain            M-001              04-22-2016              US-1195: Quick create case  
Suhan Jain            M-002              05-06-2016              US-2274: Case search filters
Suhan Jain            M-003              05-10-2016              US-1137: Canned text for issues 
                                                                 and resolution 
Suhan Jain            M-005              05-10-2016              US-1136: Case search fields
Suhan Jain            M-006              05-13-2016              US-2285: Complaint Management 
                                                                 Compatibility
Suhan Jain            M-007              05-25-2016              US-2300: Case Milestone - Elite Partners
Suhan Jain            M-008              06-08-2016              US-2301: Define Case Milestone
                                                                 General Host
Mruga Shastri         M-009              08-12-2016              Added method for Trigger Activation Custom Setting. 

*/



@isTest

public class WFG_TestDataFactory {

    /*
    * Method Created By Mruga - to create the Trigger Activation Custom Setting Records
    * Before using any other methods to create account and contacts, call method as well
    * to create custom setting data. This is necessary for trigger to function without NULL POINTER EXCEPTION
    */
    public static void createTriggerActivationRecords(){
        
           List<WFG_TriggerActivation__c > lstTriggerActivation = new List<WFG_TriggerActivation__c>();
        WFG_TriggerActivation__c AccountTriggerActivation = new WFG_TriggerActivation__c(); 
        AccountTriggerActivation.Name = 'WFG_Account'; 
        AccountTriggerActivation.WFG_isActive__c = true; 
        lstTriggerActivation.add(AccountTriggerActivation );
    
        WFG_TriggerActivation__c contactTriggerActivation = new WFG_TriggerActivation__c(); 
        contactTriggerActivation.Name = 'WFG_Contact'; 
        contactTriggerActivation.WFG_isActive__c = true; 
        lstTriggerActivation.add(contactTriggerActivation );
        
        WFG_TriggerActivation__c referralTriggerActivation = new WFG_TriggerActivation__c(); 
        referralTriggerActivation.Name = 'WFG_Referral'; 
        referralTriggerActivation.WFG_isActive__c = true; 
        lstTriggerActivation.add(referralTriggerActivation );
        
         WFG_TriggerActivation__c optyTriggerActivation = new WFG_TriggerActivation__c(); 
        optyTriggerActivation.Name = 'WFG_Opportunity'; 
        optyTriggerActivation.WFG_isActive__c = true; 
        lstTriggerActivation.add(optyTriggerActivation );
    
      FinServ__IndustriesAppConfig__c objCUstSet = new FinServ__IndustriesAppConfig__c();
      objCUstSet.SetupOwnerId=UserInfo.getOrganizationId();
      objCUstSet.FinServ__AppName__c = 'Wealth';
      objCUstSet.FinServ__DefaultIndividualType__c = 'Individual';
      objCUstSet.FinServ__AutocreateIndividualAccount__c = true;
      
      List<WFG_Active_Referrals__c> lstActivereferral = new List<WFG_Active_Referrals__c>();
      lstActivereferral.add(new WFG_Active_Referrals__c(name=system.Label.WFG_ReferralStatus_Referred));
      lstActivereferral.add(new WFG_Active_Referrals__c(name=system.Label.WFG_ReferralStatus_Accepted));
      lstActivereferral.add(new WFG_Active_Referrals__c(name=system.Label.WFG_ReferralStatus_CompleteSold));
      lstActivereferral.add(new WFG_Active_Referrals__c(name=system.Label.WFG_ReferralStatus_CompleteNotSold));
      lstActivereferral.add(new WFG_Active_Referrals__c(name=system.Label.WFG_ReferralStatus_AdviceCenter));
      insert lstActivereferral;
      
      List<WFG_Integration_Utility_Setup__c> lstsetUp = new List<WFG_Integration_Utility_Setup__c>();
      lstsetUp.add(new WFG_Integration_Utility_Setup__c(name='AD03',WFG_Integration_Method__c='POST',WFG_EndPoint_URL__c='http://www.asdf.com',
          WFG_ContentType__c='Application/json',WFG_Authentication_Provider__c = 'SelfSignedCert_06Apr2016_165629'));
      insert lstsetUp;
      
      List<WFG_IntegrationStubSwitch__c> lstSwitch = New List<WFG_IntegrationStubSwitch__c>();
      lstSwitch.add(new WFG_IntegrationStubSwitch__c(name='Demo', WFG_Stub_ON__c = true));
      lstSwitch.add(new WFG_IntegrationStubSwitch__c(name='AD03', WFG_Stub_ON__c = true));
      insert lstSwitch;
      
      insert objCUstSet;
        insert lstTriggerActivation;
    }
    
    /*
    * Method Created By Nikhil - to create the WFG_Utility Custom Setting Records
    * Before using any other methods to create account and contacts, call method as well
    * to create custom setting data. This is necessary for trigger to function without NULL POINTER EXCEPTION
    */
    public static void createWFGUtilityCustomSettingRecords(){
        
        List<WFG_Utility__c> lstUtility = new List<WFG_Utility__c>();
        WFG_Utility__c utilityRec1 = new WFG_Utility__c(); 
        utilityRec1.Name = 'CaseNewStatus';
        utilityRec1.Value__c = 'New'; 
        lstUtility.add(utilityRec1);
        
        WFG_Utility__c utilityRec2 = new WFG_Utility__c(); 
        utilityRec2.Name = 'CaseProgStatus';
        utilityRec2.Value__c = 'In Progress'; 
        lstUtility.add(utilityRec2);
        
        WFG_Utility__c utilityRec3 = new WFG_Utility__c(); 
        utilityRec3.Name = 'CaseRschStatus';
        utilityRec3.Value__c = 'Research'; 
        lstUtility.add(utilityRec3);
        
        WFG_Utility__c utilityRec4 = new WFG_Utility__c(); 
        utilityRec4.Name = 'CaseEscStatus';
        utilityRec4.Value__c = 'Escalated'; 
        lstUtility.add(utilityRec4);
        
        WFG_Utility__c utilityRec5 = new WFG_Utility__c(); 
        utilityRec5.Name = 'NewCaseAgtWFGIAStatus';
        utilityRec5.Value__c = 'WFGIA'; 
        lstUtility.add(utilityRec5);
        
        WFG_Utility__c utilityRec6 = new WFG_Utility__c(); 
        utilityRec6.Name = 'NewCaseAgtWFG_IAStatus';
        utilityRec6.Value__c = 'WFG IA'; 
        lstUtility.add(utilityRec6);
        
        WFG_Utility__c utilityRec7 = new WFG_Utility__c(); 
        utilityRec7.Name = 'NewCaseAgtTFAStatus';
        utilityRec7.Value__c = 'TFA'; 
        lstUtility.add(utilityRec7);
        
        WFG_Utility__c utilityRec8 = new WFG_Utility__c(); 
        utilityRec8.Name = 'NewCaseAgtTFAIAStatus';
        utilityRec8.Value__c = 'TFAIA'; 
        lstUtility.add(utilityRec8);
        
        WFG_Utility__c utilityRec9 = new WFG_Utility__c(); 
        utilityRec9.Name = 'NewCaseAgtTFA_IAStatus';
        utilityRec9.Value__c = 'TFA IA'; 
        lstUtility.add(utilityRec9);
        
        WFG_Utility__c utilityRec10 = new WFG_Utility__c(); 
        utilityRec10.Name = 'NewCaseAgtWFGSStatus';
        utilityRec10.Value__c = 'WFGS'; 
        lstUtility.add(utilityRec10);
        
        WFG_Utility__c utilityRec11 = new WFG_Utility__c(); 
        utilityRec11.Name = 'NewCaseAgtAMLStatus';
        utilityRec11.Value__c = 'AML'; 
        lstUtility.add(utilityRec11);
        
        WFG_Utility__c utilityRec12 = new WFG_Utility__c(); 
        utilityRec12.Name = 'NewCaseAgtE_OStatus';
        utilityRec12.Value__c = 'E&O'; 
        lstUtility.add(utilityRec12);
        
        WFG_Utility__c utilityRec13 = new WFG_Utility__c(); 
        utilityRec13.Name = 'NewCaseTypeNone';
        utilityRec13.Value__c = '--None--'; 
        lstUtility.add(utilityRec13);
        
        WFG_Utility__c utilityRec14 = new WFG_Utility__c(); 
        utilityRec14.Name = 'NewCaseDepOptObj';
        utilityRec14.Value__c = 'Case'; 
        lstUtility.add(utilityRec14);
        
        WFG_Utility__c utilityRec15 = new WFG_Utility__c(); 
        utilityRec15.Name = 'NewCaseDepOptFld1';
        utilityRec15.Value__c = 'Type'; 
        lstUtility.add(utilityRec15);
        
        WFG_Utility__c utilityRec16 = new WFG_Utility__c(); 
        utilityRec16.Name = 'NewCaseDepOptFld2';
        utilityRec16.Value__c = 'WFG_Case_Reason_2__c'; 
        lstUtility.add(utilityRec16);
        
        try
        {
            insert lstUtility;
        }
        catch(Exception e)
        {
        
        }
        System.assert(!lstUtility.isEmpty(),true);
    }

    //Account creation
    public static List<Account> createAccounts( Integer numberOfAccounts) {
        List<Account> accounts = new List<Account>();
        ID rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch Office').getRecordTypeId();
        for ( Integer i = 0 ; i < numberOfAccounts ; i++ ) {
            Account account = new Account( name = 'Account'+i,
                                          WFG_BranchCode__c='Agent'+i,
                                          Phone ='1234565',
                                          RecordTypeId = rtId
                                         );
            accounts.add( account);
        }
        return accounts;
    }
    //Contact Creation
    public static List<Contact> createContacts( Integer numberOfContacts, list<Account> accId) {
        List<Contact> Contacts= new List<Contact>();
        ID rtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        for ( Integer i = 0 ; i < numberOfContacts ; i++ ) 
        {
            Contact Contact = new Contact( accountId =accId[i].ID,
                                          FirstName = 'Contact'+i, 
                                          LastName ='test', 
                                          Email ='Test@transamerica.com', 
                                          Phone ='1234567890',
                                          WFG_AgentCode__c= 'A'+i, 
                                          WFG_AgentLevel__c =17*i,
                                          AssistantPhone ='91'+i+'23'+i+'7890',
                                          HomePhone= '81'+i+'33'+i+'2698',
                                          OtherPhone ='88'+i+'33'+i+'2698',
                                          MobilePhone= '91'+i+'23'+i+'7890',
                                          WFG_AlternateEmail__c ='Test'+i+'@transamerica.com',
                                          Birthdate=system.today()-100,
                                          //WFG_SpouseCode__c= 'MS'+i,
                                          WFG_LastContactedDate__c= system.today(),
                                          WFG_Spouse__c= 'Test MS',
                                          RecordTypeId = rtId
                                         );
            Contacts.add( Contact);
        }
        return Contacts;
    }
    
    //Method Created By Ram for US-2314
    public static Contact getContact()
    {
        ID rtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        Contact Contacts = new Contact( FirstName = 'Contact1', 
                                       LastName ='test', 
                                       WFG_AgentCode__c= '00JRC', 
                                       WFG_AgentLevel__c =2,
                                       RecordTypeId = rtId
                                      );
        return Contacts;
    }
    
    //Case Creation
    public static List<Case> createCases( Integer numberOfCases, list<contact> conId) {
        
        string Status;
        
        List<Case> Cases= new List<Case>();
        for ( Integer i = 0 ; i < numberOfCases; i++ ) {
            if (i ==1){
                Status='New';
            }
            else if (i ==2){
                Status='Research';
            }
            else if (i ==3){
                Status= 'Escalated';
            }
            else if (i ==4){
                Status='Closed';
            }
            else if (i ==5) {
                Status='Duplicate';
            }
            
            else {
                Status='In Progress';
            }
            
            
            Case Case1= new Case(ContactID=conId[i].ID,
                                 Status= Status,
                                 Origin='phone',
                                 Subject='test case',
                                 Type='Analytics',
                                 WFG_Case_Reason_2__c='1099 Requests or Research',
                                 WFG_Resolution__c='Please go to SC',
                                 WFG_InteractingWith__c='Test User',
                                 WFG_InteractingAbout__c=conId[i].ID,
                                 WFG_InteractingAboutCode__c='AD'+i,
                                 WFG_AgentCode__c='AC'+i,
                                 Priority='high',
                                 Description='Test case Test case Test casev Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case v Test case Test case Test casev Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case v Test case Test case Test casev Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case Test case v'); 
            Cases.add(Case1);
            
        }
        return Cases;
    }
    
    public static List<FeedItem> createFeedItems( Integer numberOfFeeditem) {
        List<FeedItem> FeedItems = new List<FeedItem>();
        for ( Integer i = 0 ; i < numberOfFeeditem ; i++ ) {
            FeedItem FeedItem= new FeedItem( body='Test Body');
            FeedItems.add( FeedItem); 
        }
        return FeedItems;
        
    }
    
    public static List<Task> createTasks( Integer numberTasks) {
        List<Task> Tasks = new List<Task>();
        for ( Integer i = 0 ; i < numberTasks ; i++ ) {
            Task Task= new Task( Subject='Test Subject');
            Tasks.add( Task); 
        }
        return Tasks;
        
    } 
    
    public static List<QuickText> createQuickTexts( Integer numberQuickTexts) {
        List<QuickText> QuickTexts = new List<QuickText>();
        for ( Integer i = 0 ; i < numberQuickTexts ; i++ ) {
            QuickText QuickText= new QuickText( Name='Test text', Message = 'Please visit the nearest call center');
            QuickTexts.add( QuickText); 
        }
        return QuickTexts;
        
    } 
    
    public static List<WFG_AgentStatus__c> createWFG_AgentStatuss( Integer numberStatus, list<Contact> ConID) {
        
        String Name;
        
        List<WFG_AgentStatus__c> WFG_AgentStatuss = new List<WFG_AgentStatus__c>();
        for ( Integer i = 0 ; i < numberStatus ; i++ ) {
            if (i ==1){
                Name='WFGS';
            }
            else if (i ==2){
                Name='WFGIA';
            }
            else if (i ==3){
                Name= 'TFAIA';
            }
            else if (i ==4){
                Name='TFA';
            }
            else if (i ==5) {
                Name='E&O';
            }
            
            else {
                Name='AML';
            }
            
            WFG_AgentStatus__c WFG_AgentStatus= new WFG_AgentStatus__c (WFG_AgentCodeStatus__c='AN'+i, WFG_Contact__c= ConID[1].ID, Name = Name,
                                                                        WFG_StartDate__c = system.Today(), 
                                                                        WFG_Status__c = 'Active');
            WFG_AgentStatuss.add( WFG_AgentStatus); 
        }
        return WFG_AgentStatuss;
        
    } 
    
    public static List<WFG_AgentCode__c> createAgentCodes( Integer numberAgentCodes, list<Contact> conID) {
        List<WFG_AgentCode__c> AgentCodes = new List<WFG_AgentCode__c>();
        for ( Integer i = 0 ; i < numberAgentCodes ; i++ ) {
            WFG_AgentCode__c AgentCode= new WFG_AgentCode__c( Name=conID[i].FirstName, 
                                                             WFG_Contact__c= conID[i].ID, 
                                                             WFG_AgentCode__c = 'AC'+i,
                                                             WFG_StartDate__c =System.today(),
                                                             WFG_SMDApprovalDate__c= System.today(),
                                                             WFG_LevelStartDate__c= System.today(),
                                                             WFG_USStatusDate__c= System.today(),
                                                             WFG_PrimaryCode__c=True,
                                                             WFG_USStatus__c='Active',
                                                             WFG_CAStatus__c ='Active',
                                                             WFG_CAStatusDate__c=system.today(),
                                                             WFG_PRStatus__c='Active',
                                                             WFG_PRStatusDate__c=system.today()
                                                            
                                                            );
            AgentCodes.add( AgentCode); 
        }
        return AgentCodes;
        
    }
    
    public static User User(string name)
    {
        Profile p = [SELECT Id FROM Profile WHERE Name=:name]; 
        User u = new User(Alias = 'standt', Email='Testadminuser@transamerica.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='Testadminuser@wfgtest.com');
        system.debug('systemadmin'+u);
        return u;
    }
    
    public static Entitlement Entitlement(ID Account) {
       
        Entitlement lstEntitlement = new Entitlement (Name = 'WFG Leaders',
                                                      StartDate=system.today(),
                                                      AccountId=Account
                                                     );
        return lstEntitlement;
    }
    
    public static Account createBranchOfficeTestRecord(String accountName, String branchCode, String curr)
    {
        Account acc = new Account();
        ID rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch Office').getRecordTypeId();
        acc.Name = accountName;
        acc.WFG_BranchCode__c = branchCode;
        acc.recordTypeId = rtId;
        acc.CurrencyIsoCode = curr;
        return acc;       
    }
    
     public static Contact createContactTestRecord(String firstName, String lastName, ID accountId, String agentCode, Decimal agentLevel)
    {
        Contact testContact = new Contact();
        ID conId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        testContact.FirstName = firstName;
        testContact.LastName = lastName;
        testContact.RecordTypeId = conId;
        testContact.AccountId = accountId;
        testContact.WFG_AgentCode__c = agentCode;
        testContact.WFG_AgentLevel__c = agentLevel;
        return testContact;
    }
       public static User createTestUser(String profileName)
    {
        Profile p = [select name, id from profile where name= :profileName]; 
        system.assert(p.id != null);
        String testUserName = String.valueOf(System.now().getTime()) + '@transamerica.com';
        User usr = new User( alias = 'TestUser', email='testUser@transamerica.com',
                                emailencodingkey='UTF-8', lastname='TestUser1', languagelocalekey='en_US',
                                localesidkey='en_US', profileid = p.Id,
                                timezonesidkey='America/Denver', username=testUserName, isActive=true);
        //system.assert(usr.id!=null);
        return usr;
    }
    
}