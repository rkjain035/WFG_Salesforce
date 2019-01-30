/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Mruga Shastri
* @date 25-Feb-2017
* @description  Wrapper class for WFG_AgentNewIndividualController to send status to Lightning Component

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Mruga Shastri           M-001             25-Feb-2017         Class to create Test Data
Praveen                 M-002             5-June-2018         Method added for AgentCode
Rahul K Jain            M-002             27-Jul-18           Method added for Onboarding checklist and Modified
                                                              Agent contact create method and User create method
Girish					M-003			  09-aUG-2018         Method added to create knowledge article
*/
public class WFG_Test_Data_Utility{
   
    public static User createTestUser(String profileName)
    {
        Profile p = [select name, id from profile where name= :profileName]; 
        system.assert(p.id != null);
        String testUserName = String.valueOf(System.now().getTime()) + '@transamerica.com';
        User usr = new User( alias = 'TsClsUsr', email='testUser@transamerica.com',
                                emailencodingkey='UTF-8', lastname='TestUser1', languagelocalekey='en_US',
                                localesidkey='en_US', profileid = p.Id,
                                timezonesidkey='America/Denver', username=testUserName, isActive=true);
        //system.assert(usr.id!=null);
        return usr;
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
    
    public static Contact createContactTestRecord(String firstName, 
                                                  String lastName, 
                                                  ID accountId, 
                                                  String agentCode, 
                                                  Decimal agentLevel)
    {
        Contact testContact = new Contact();
        ID conId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        testContact.FirstName = firstName;
        testContact.LastName = lastName;
        testContact.RecordTypeId = conId;
        testContact.AccountId = accountId;
        testContact.WFG_AgentCode__c = agentCode;
        testContact.WFG_AgentId__c = agentCode;
        testContact.WFG_AgentLevel__c = agentLevel;
        testContact.email = 'test@con.com';
        return testContact;
    }
    
      public static Contact updateContactTestRecord(Contact objCon, String WFGAgentType)        
    {       
        Id RTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Agent').getRecordTypeId();     
        objCon.WFG_AgentPayType__c = 'WFG';     
        objCon.WFG_CycleType__c = 'US';     
        objCon.WFG_Type__c = WFGAgentType;      
        //objCon.WFG_AgentId__c = 'X3412';  Agent ID and Agent code are assigned when contact is created. why is this needed?      
        //objCon.WFG_AgentCode__c = 'X3412';      
        objCon.WFG_Status__c = 'ACTIVE';        
        objCon.recordtypeId = RTId;
        
        if(WFGAgentType == 'Launch')
            objCon.WFG_Channel__c = 'Blue';
        
        return objCon;              
    }       
    
    public static WFG_Onboarding_Checklist__c createOnboardingChecklistRecord
        (Id con, Id recruitingContact, String agentCode, String recruitingAgentCode)
    {
        WFG_Onboarding_Checklist__c checklist = new WFG_Onboarding_Checklist__c();
        checklist.Contact__c = con;
        checklist.WFG_Agent_Code__c = agentCode;
        checklist.Recruiting_Contact__c = recruitingContact;
        checklist.WFG_Recruiting_Agent_Code__c = recruitingAgentCode;
        return checklist;
    }
    
    public static User createUserRecord(String userName, boolean active, String FedIdentifier, Id contactId, Id ProfileId)      
    {      
        String agentCode = FedIdentifier.substring(1);
        User user2 = new User( alias = 'TsClsUsr', email='testUser3@transamerica.com', contactId = contactId,       
                                emailencodingkey='UTF-8', lastname='TestUser11', languagelocalekey='en_US',     
                                localesidkey='en_US', profileid = ProfileId, WFG_Agent_Code__c = agentCode,      
                                timezonesidkey='America/Denver', Country = 'US',    
                            username=userName, isActive=active, federationIdentifier = FedIdentifier);
        
        return user2;   
        
    }
    
    public static List<Account> createBranchOfficeTestData(Integer recordCount)
    {
        Account acc;
        List<Account> lstAccounts = new list<Account>();
        ID rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch Office').getRecordTypeId();

        for(Integer i=0; i<recordCount; i++){
            acc = new Account();
            acc.Name = ' Account Name ' + String.valueOf(i);
            acc.WFG_BranchCode__c = String.valueOf(i);
            acc.recordTypeId = rtId;
            lstAccounts.add(acc);
        } 
        return lstAccounts;       
    }
    
    /* 
     * Method to create the Trigger Activation Custom Setting Records.
     * Need to call this method before inserting records on which triggers are written. 
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
          WFG_ContentType__c='Application/json',WFG_Authentication_Provider__c = system.Label.WFG_certificationName));
      insert lstsetUp;
      
      List<WFG_IntegrationStubSwitch__c> lstSwitch = New List<WFG_IntegrationStubSwitch__c>();
      lstSwitch.add(new WFG_IntegrationStubSwitch__c(name='Demo', WFG_Stub_ON__c = true));
      lstSwitch.add(new WFG_IntegrationStubSwitch__c(name='AD03', WFG_Stub_ON__c = true));
      insert lstSwitch;
      
      insert objCUstSet;
        insert lstTriggerActivation;
    }
    
    public static Account createIndividualRecord(String accountName)
    {
        ID rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        Account acc = new Account();
        acc.Name = accountName;
        acc.recordTypeId = rtId;
        acc.FinServ__IndividualId__c = '10101010101';
        acc.FinServ__IndividualType__c = 'Individual';
        acc.FinServ__ClientCategory__c = 'Platinum';
        acc.FinServ__Status__c = 'Prospect';
        return acc;       
    }
    
    public static Contact createIndividualRecord(String firstName, String lastName, String phn, String maritalSts)
    {
        ID rtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        Contact cont = new Contact();
        cont.FirstName = firstName;
        cont.LastName = lastName;
        cont.recordTypeId = rtId;
        cont.FinServ__IndividualType__c = 'Individual';
        cont.Birthdate = System.today() - 365;
        cont.MailingState = 'NY';
        cont.MailingStateCode = 'NY';
        cont.MailingCountry = 'US';
        cont.MailingCountryCode = 'US';
        cont.Phone = '(999) 999-9999';
        cont.FinServ__MaritalStatus__c = maritalSts;
        cont.Email = 'abc@transamerica.com';
        return cont;       
    }

    public static Contact createPhoneIndividualRecord(String firstName, String lastName, String phn, String maritalSts)
    {
        ID rtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        Contact cont = new Contact();
        cont.FirstName = firstName;
        cont.LastName = lastName;
        //cont.recordTypeId = rtId;
        cont.FinServ__IndividualType__c = 'Individual';
        cont.Birthdate = System.today() - 365;
        cont.MailingState = 'NY';
        cont.MailingStateCode = 'NY';
        cont.MailingCountry = 'US';
        cont.MailingCountryCode = 'US';
        cont.Phone = phn;
        cont.FinServ__MaritalStatus__c = maritalSts;
        cont.Email = 'abc@transamerica.com';
        return cont;       
    }
    
    public static Account createHouseholdRecord(String accountName)
    {
        ID rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Account acc = new Account();
        acc.Name = accountName;
        acc.RecordTypeId = rtId;
        return acc;       
    }
    public static Account createBusinessAccountRecord(String accountName, String accountNumber, String accountType)
    {
        ID rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Account acc = new Account();
        acc.Name = accountName;
        acc.AccountNumber = accountNumber;
        acc.Type = accountType;
        acc.RecordTypeId = rtId;
        return acc;
    }
    public static Contact createBusinessContactRecord(String firstName, String lastName, String accountId, String emailId)
    {
        ID rtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Contact con = new Contact();
        con.FirstName = firstName;
        con.LastName = lastName;
        con.AccountId = accountId;
        con.Email = emailId;
        con.RecordTypeId = rtId;
        return con;
    }
    public static FinServ__ReciprocalRole__c createAccountReciprocalRoleRecord(String roleName, String inverseRoleName)
    {
        ID rtId = Schema.SObjectType.FinServ__ReciprocalRole__c.getRecordTypeInfosByName().get('Account Role').getRecordTypeId();
        FinServ__ReciprocalRole__c aRole = new FinServ__ReciprocalRole__c();
        aRole.Name = roleName;
        aRole.FinServ__InverseRole__c = inverseRoleName;
        aRole.RecordTypeId = rtId;
        aRole.FinServ__RelationshipType__c = 'Account Account Relation';
        aRole.FinServ__CreateInverseRole__c = true;
        aRole.CurrencyIsoCode = 'USD';
        return aRole;
    }
    public static FinServ__ReciprocalRole__c createContactReciprocalRoleRecord(String roleName, String inverseRoleName)
    {
        ID rtId = Schema.SObjectType.FinServ__ReciprocalRole__c.getRecordTypeInfosByName().get('Contact Role').getRecordTypeId();
        FinServ__ReciprocalRole__c cRole = new FinServ__ReciprocalRole__c();
        cRole.Name = roleName;
        cRole.FinServ__InverseRole__c = inverseRoleName;
        cRole.RecordTypeId = rtId;
        cRole.FinServ__RelationshipType__c = 'Contact Contact Relation';
        cRole.FinServ__CreateInverseRole__c = true;
        cRole.CurrencyIsoCode = 'USD';
        return cRole;
    }
    public static FinServ__AccountAccountRelation__c createAccountAccountRelationshipRecord(String accountId, String relatedAccountId, String reciprocalRoleId)
    {
        FinServ__AccountAccountRelation__c accRel = new FinServ__AccountAccountRelation__c();
        accRel.FinServ__Account__c = accountId;
        accRel.FinServ__RelatedAccount__c = relatedAccountId;
        accRel.FinServ__Role__c = reciprocalRoleId;
        accRel.FinServ__Active__c = true;
        accRel.CurrencyIsoCode = 'USD';
        return accRel;
    }
    public static FinServ__ContactContactRelation__c createContactContactRelationshipRecord(String contactId, String relatedContactId, String reciprocalRoleId)
    {
        FinServ__ContactContactRelation__c conRel = new FinServ__ContactContactRelation__c();
        conRel.FinServ__Contact__c = contactId;
        conRel.FinServ__RelatedContact__c = relatedContactId;
        conRel.FinServ__Role__c = reciprocalRoleId;
        conRel.FinServ__Active__c = true;
        conRel.CurrencyIsoCode = 'USD';
        return conRel;
    }    
    public static AccountContactRelation createAccountContactRelationshipRecord(String contactId, String accountId)
    {
        AccountContactRelation accRel = new AccountContactRelation();
        accRel.AccountId = accountId;
        accRel.ContactId = contactId;
        accRel.CurrencyIsoCode = 'USD';
        accRel.FinServ__Primary__c = true;
        return accRel;
    }
    public static FinServ__FinancialAccount__c createIndividualInvestmentAccountRecord(Id primaryOwnerId)
    {
        ID rtId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Investment Account').getRecordTypeId();
        FinServ__FinancialAccount__c finAcct = new FinServ__FinancialAccount__c();
        finAcct.Name = 'Bank Savings Account';
        finAcct.FinServ__PrimaryOwner__c = primaryOwnerId;
        return finAcct;
    }
    
    public static FinServ__FinancialAccount__c createIndividualCurrentProductRecord(Id primaryOwnerId)
    {
        ID rtId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Current Products').getRecordTypeId();
        FinServ__FinancialAccount__c finAcct = new FinServ__FinancialAccount__c();
        finAcct.Name = 'My Product';
        finAcct.WFG_Product_Type__c = 'Annuity';
        finAcct.FinServ__PrimaryOwner__c = primaryOwnerId;        
        return finAcct;
    }
    public static WFG_Customer_Profile__c createCustomerProfile(Id idContact)
    {
        WFG_Customer_Profile__c objCustomerProfile = new WFG_Customer_Profile__c();
       // objCustomerProfile.WFG_CoverageAmount__c = 100.00;
        objCustomerProfile.WFG_AnnualGrossIncome__c = 100.10;
        objCustomerProfile.WFG_OwnDI__c = 'Yes';
        objCustomerProfile.WFG_OwnLifeInsurance__c = 'Yes';  
        objCustomerProfile.WFG_OwnLTC__c = 'Yes';
        objCustomerProfile.WFG_EmploymentStatus__c = 'Employed'; 
        objCustomerProfile.WFG_GroupOrPersonal__c = 'Group';
        objCustomerProfile.WFG_HomeOwnership__c = 'Yes';
        objCustomerProfile.WFG_ListAccountTypes__c = 'Defined Benefit Plans';
        objCustomerProfile.WFG_NumberOfDependents__c = 12;
        objCustomerProfile.WFG_Contact__c = idContact;
        objCustomerProfile.WFG_OwnQualifiedAssets__c = 'Yes';
        objCustomerProfile.WFG_advisors_to_contact_you__c = 'Yes';
        objCustomerProfile.WFG_Interested_in_discussing_options__c = 'Yes';
        objCustomerProfile.WFG_Consent_to_pass_contact_information__c = 'Yes';
        objCustomerProfile.WFG_Consent_for_FA_Contact__c  = 'Yes';
        objCustomerProfile.WFG_status__c = 'Complete';    
        return objCustomerProfile;
    }  
    public static WFG_Referral__c createReferral(WFG_Customer_Profile__c objCustProfile, Id idReferredTo)
    {
        WFG_Referral__c objReferral = new WFG_Referral__c();
        objReferral.WFG_Customer_Profile__c = objCustProfile.id;
        objReferral.WFG_Referred_By__c = UserInfo.getUserId();
        objReferral.WFG_Referred_To__c = idReferredTo;
        objReferral.WFG_Status__c = 'Referred';
        objReferral.WFG_Contact_First_Name__c = objCustProfile.WFG_Contact__r.FirstName;
        objReferral.WFG_Contact_Last_Name__c = objCustProfile.WFG_Contact__r.LastName;
        objReferral.WFG_Email__c = objCustProfile.WFG_Contact__r.Email;
        objReferral.WFG_Primary_Phone__c = objCustProfile.WFG_Contact__r.Phone;
        objReferral.WFG_Home_Country__c = objCustProfile.WFG_Contact__r.MailingCountry;
        objReferral.WFG_City__c = objCustProfile.WFG_Contact__r.MailingCity;
        objReferral.WFG_Referred_From_Agent_Code__c = '1234';
        objReferral.WFG_Referred_To_Agent_Code__c = '1234';      
        return objReferral;
    }
     public static void createTriggerActivation()
    {
        WFG_TriggerActivation__c objTriggerActivation = new WFG_TriggerActivation__c();
        objTriggerActivation.Name = 'WFG_Contact';
        objTriggerActivation.WFG_isActive__c = TRUE;    
        insert objTriggerActivation;
    }
    
   public static WFG_Customer_Profile__c createCustomerProfile(Contact objContact)
    {
        WFG_Customer_Profile__c objCustPrfl = new WFG_Customer_Profile__c();
        objCustPrfl.Name = 'Test';
        objCustPrfl.WFG_AnnualGrossIncome__c = 1000;
        objCustPrfl.WFG_HomeOwnership__c = 'Yes';
        objCustPrfl.WFG_EmploymentStatus__c = 'Employed';
        objCustPrfl.WFG_OwnLifeInsurance__c = 'Yes';
        objCustPrfl.WFG_GroupOrPersonal__c = 'Group';
        objCustPrfl.WFG_OwnLTC__c = 'Yes';
        objCustPrfl.WFG_OwnDI__c = 'Yes';
        objCustPrfl.WFG_Contact__c = objContact.Id;
        objCustPrfl.WFG_OwnQualifiedAssets__c = 'Yes';
        objCustPrfl.WFG_ListAccountTypes__c = 'Defined Benefit Plans';
        return objCustPrfl;
    } 
    
    public static Opportunity createOppty(Id testAccountId){
        Opportunity objOppty = new Opportunity();
        objOppty.Name =  'Test Oppty : ' + testAccountId;
        objOppty.AccountId = testAccountId; 
        objOppty.Amount = 100;
        objOppty.Type = 'New Business'; 
        objOppty.StageName = 'Needs Assessment';
        objOppty.CloseDate = System.today() + 30; 
        return objOppty;
    } 

    public static Opportunity createOppty(WFG_Customer_Profile__c testCP){
      Opportunity objOpty = new Opportunity();
            objOpty.Name = 'Test 1';
            objOpty.StageName = 'Need Assesment';
            objOpty.WFG_CustomerProfile__c = testCP.Id;
            objOpty.WFG_Contact__c = testCP.WFG_Contact__c;
            objOpty.CloseDate = Date.Today() + 20;
            objOpty.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_OpportunityQualifiedRetirement).getRecordTypeId();
            objOpty.WFG_Source__c = System.Label.WFG_OpportunitySourceReferral;
            return objOpty;
    }
    
    public static Event createEvent(Id testAccountId){
        Event objEvent = new Event();
        objEvent.Subject =  'test Event Subject';
        objEvent.WhatID = testAccountId; 
        objEvent.StartDateTime = System.today();
        objEvent.IsAllDayEvent = true; 
        return objEvent;
    } 
    
     public static Lead createLead(){
        Lead objLead = new Lead();
        objLead.FirstName =  'LeadFistName';
        objLead.LastName = 'LeadLastName'; 
        objLead.Status = 'Active';
        objLead.Country = 'US'; 
        //objLead.Company = 'TransAmerica';
        objLead.Company = objLead.FirstName +' '+ objLead.LastName;
        objLead.State = 'CA';  
        objLead.Phone = '9879879877';   
        objLead.Email = 'test@transamerica.com'; 
        return objLead;
    } 
    
    /**
     * This method returns the agent code instance which can be used in test classes
     * @throws - N/A
     * @author Praveen
     * @date 05-June-2018
     */
    public static WFG_AgentCode__c CreateAgentCode(string strAgentcode,Id IdContact,date startdate,boolean primarycode){
        WFG_AgentCode__c agc = new WFG_AgentCode__c();
        agc.WFG_AgentCode__c = strAgentcode;
        agc.WFG_StartDate__c = startdate;
        agc.WFG_Contact__c = IdContact;
        agc.WFG_PrimaryCode__c = primarycode;
        agc.Name = strAgentcode;
        return agc;
    }
    
    /**
     * This method returns the knowledge article instance which can be used in test classes
     * @throws - N/A
     * @author Girish
     * @date 08-Aug-2018
     */
    public static WFG_Launch_Training__kav createKnowledgeArticle(String urlName,String profileNames, String spotlightVideo){
        WFG_Launch_Training__kav objLaunchKnowledgeArticle = new WFG_Launch_Training__kav();
        objLaunchKnowledgeArticle.title ='Test';
        objLaunchKnowledgeArticle.Summary ='Test';
        objLaunchKnowledgeArticle.WFG_Launch_Duration__c =5;
        objLaunchKnowledgeArticle.WFG_Launch_Profiles__c =profileNames;
        objLaunchKnowledgeArticle.WFG_Launch_Status__c = true;
        objLaunchKnowledgeArticle.WFG_Launch_Thumbnail_Image__c ='';
        objLaunchKnowledgeArticle.WFG_Launch_Video_URL__c ='www.test.salesforce.com';
        objLaunchKnowledgeArticle.UrlName = urlName;                     
        objLaunchKnowledgeArticle.IsVisibleInCsp=true;
        objLaunchKnowledgeArticle.Language = 'en_US';
        objLaunchKnowledgeArticle.WFG_Launch_Spotlight_Video__c = spotlightVideo;
        return objLaunchKnowledgeArticle;
    }
    /*public static WFG_Profile_Identification_Matrix__mdt createProfileIdentificationMatrix(string strAgentType,string strChannel,string strCycleType,boolean isFiduciary,string strProfileId,string strProfileName,string strSource,string strType){
        WFG_Profile_Identification_Matrix__mdt pim = new WFG_Profile_Identification_Matrix__mdt();
        pim.WFG_Agent_Type__c = strAgentType;
        pim.WFG_Launch_Channel__c = strChannel;
        pim.WFG_Cycle_Type__c = strCycleType;
        pim.WFG_Fiduciary_Flag__c = isFiduciary;
        pim.WFG_Profile_ID__c = strProfileId;
        
    }*/
      
}