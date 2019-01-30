/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author DHunter
* @date 11-22-2017
* @description  Opprtunity information

*/
public class WFG_OpportunityInfo {
    //MorningStar
    @AuraEnabled public String recordTypeName {get; set;}
    @AuraEnabled public String contactName {get; set;}
    @AuraEnabled public String customerProfileName {get; set;}
    @AuraEnabled public String referralName {get; set;}
    @AuraEnabled public String accountName {get; set;}
    @AuraEnabled public string contactID {get; set;}
    @AuraEnabled public string agentCode {get; set;}
    //General client data
    public String Salutation {get; set;}
    public String FirstName {get; set;}
    public String LastName {get; set;}
    public String PreferredName {get; set;} //TBD
    public String Gender {get; set;} //TBD
    public String Suffix {get; set;} //TBD
    public String MobilePhone {get; set;}
    public String HomePhone {get; set;}
    public String OtherPhone {get; set;}
    public String Fax {get; set;}
    public String Email {get; set;}
    public String AlternateEmail {get; set;}//TBD
    public String Facebook {get; set;} //TBD
    public String Tweeter {get; set;}//TBD
    public String LinkedIn {get; set;}//TBD
    public String MailingCountry {get; set;}
    public String MailingStreet {get; set;}
    public String MailingCity {get; set;}
    public String MailingState {get; set;}
    public String MailingZIP {get; set;}
    public String PrimaryAddress {get; set;}
    public String OtherAddress {get; set;}
    public String OtherCountry {get; set;}
    public String OtherStreet {get; set;}
    public String OtherCity {get; set;}
    public String OtherState {get; set;}
    public String OtherZIP {get; set;}
    public String PrimaryAddressOther {get; set;}//TBD
    public String Birthdate {get; set;}
    public String MaritalStatus {get; set;}//TBD
    public String Spouse {get; set;}//TBD
    public String WeddingAnniversary {get; set;}//TBD
    public String NumberofDependents {get; set;}//TBD
    public String SSN {get; set;}
    public String AnnualIncome {get; set;}//TBD
    public String TaxBracket {get; set;}//TBD
    public String Occupation {get; set;}//TBD
    public String CurrentEmployer {get; set;}//TBD
    public String Department {get; set;}//TBD
    public String EmployedSince {get; set;}//TBD
    public String ReportsTo {get; set;}//TBD
    public String Experience {get; set;}//TBD
    public String Assistant {get; set;}//TBD
    public String AsstPhone {get; set;}//TBD
    public String Citizenship {get; set;}//TBD
    public String CountryfBirth {get; set;}//TBD
    public String LanguagesSpoken {get; set;}//TBD
    public String PrimaryLanguage {get; set;}//TBD
    public String SecondaryLanguage {get; set;}//TBD
    public String OpportunityProductType {get; set;}
    public String Amount {get; set;}
    public String Product {get; set;}//TBD
    public String Status {get; set;}//TBD
    //for SSO
    @AuraEnabled public String contactFirstNameSSO {get; set;}
    @AuraEnabled public String contactLastNameSSO {get; set;}
    @AuraEnabled public String accountNameSSO {get; set;}
    @AuraEnabled public string contactIDSSO {get; set;}
    @AuraEnabled public string agentCodeSSO {get; set;}
    @AuraEnabled public string clientSSOData {get; set;}
    
    //lindaliu updated 1/10/2019
    @AuraEnabled public String opportunityId {get; set;}
    public WFG_OpportunityInfo(){}
    
    public WFG_OpportunityInfo(String oppId)
    {
        opportunityId = oppId;
	}
}