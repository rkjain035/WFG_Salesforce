public with sharing class WFG_AD03_AgentsResponseWrapper 
{
    @AuraEnabled
    public boolean boolIsSelect = true;
    @AuraEnabled
    public string llrr_agent_code;
    @AuraEnabled
    public string agent_code;
    @AuraEnabled
    public string first_name;
    @AuraEnabled
    public string last_name;
    @AuraEnabled
    public string email;
    @AuraEnabled
    public string phone;
    @AuraEnabled
    public WFG_AddressWrapper address;
    @AuraEnabled
    public string ReferredBy_AgentCode{get;set;}
    @AuraEnabled
    public string FA_AgentCode{get; set;}
    @AuraEnabled
    public string FA_Name{get; set;}
    @AuraEnabled
    public string FA_Address{get; set;}
    @AuraEnabled
    public string FA_Phone{get; set;}
    @AuraEnabled
    public string FA_Email{get; set;}
    @AuraEnabled
    public string timestamp{get; set;}
    @AuraEnabled
    public string status{get; set;}
    @AuraEnabled
    public string error{get; set;}
    @AuraEnabled
    public string message{get; set;}
    @AuraEnabled
    public string path{get; set;}
}