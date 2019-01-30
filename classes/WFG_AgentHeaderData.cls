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
Madhurupa          M-001               06-15-2016              US-2287: Modified complaints management 
                                                               quick case with additional fields/actions
Madhurupa          M-002               06-28-2016              US-2374: Hide statuses that are null

*/

public class WFG_AgentHeaderData {
    @AuraEnabled 
    public Id contactId{set;get;}
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String AgentCode{set;get;}
    @AuraEnabled
    public Decimal AgentLevel{set;get;}
    @AuraEnabled
    public String AgId{set;get;}             
    @AuraEnabled
    public String Res{set;get;}               
    @AuraEnabled
    public String Birthdate{set;get;}                
    @AuraEnabled
    public String Spouse1{set;get;}   
    @AuraEnabled
    public String Spouse2Id{set;get;}
    @AuraEnabled
    public String Spouse2{set;get;}               
    @AuraEnabled
    public String LastContactDate{set;get;}
    @AuraEnabled
    public String Channel{set;get;}
    @AuraEnabled
    public String Email{set;get;}
    @AuraEnabled
    public String AlternateEmail{set;get;}             
    @AuraEnabled
    public Boolean Dedicated{set;get;}  
    @AuraEnabled
    public String MailingStreet{set;get;}
    @AuraEnabled
    public String MailingCity{set;get;}
    @AuraEnabled
    public String MailingState{set;get;}
    @AuraEnabled
    public String MailingPostalCode{set;get;}
    @AuraEnabled
    public Decimal MailingLatitude{set;get;}
    @AuraEnabled
    public Decimal MailingLongitude{set;get;}
    @AuraEnabled
    public String MailingCountry{set;get;}
    @AuraEnabled
    public String BillingStreet{set;get;}
    @AuraEnabled
    public String BillingCity{set;get;}
    @AuraEnabled
    public String BillingState{set;get;}
    @AuraEnabled
    public String BillingPostalCode{set;get;}
    @AuraEnabled
    public Decimal BillingLatitude{set;get;}
    @AuraEnabled
    public Decimal BillingLongitude{set;get;}
    @AuraEnabled
    public String BillingCountry{set;get;}
    @AuraEnabled
    public String Status{set;get;}
    @AuraEnabled
    public String TFAIAStatus{set;get;}
    @AuraEnabled
    public String TFAStatus{set;get;}
    @AuraEnabled
    public String WFGIAStatus{set;get;}
    @AuraEnabled
    public String TFAIAStartDate{set;get;}
    @AuraEnabled
    public String TFAStartDate{set;get;}
    @AuraEnabled
    public String WFGIAStartDate{set;get;}
    @AuraEnabled
    public String BulletinName{set;get;}
    @AuraEnabled
    public String WFGSStatus{set;get;}
    @AuraEnabled
    public String WFGSStartDate{set;get;}
    @AuraEnabled
    public String AMLStatus{set;get;}
    @AuraEnabled
    public String AMLStartDate{set;get;}
    @AuraEnabled
    public String EOStatus{set;get;}
    @AuraEnabled
    public String EOStartDate{set;get;}
    @AuraEnabled
    public String FirstName{set;get;}
    @AuraEnabled
    public String SSNSIN{set;get;}
    @AuraEnabled
    public String MobilePhone{set;get;}
    @AuraEnabled
    public String HomePhone{set;get;}
    @AuraEnabled
    public String BranchPhone{set;get;}
    @AuraEnabled
    public String Phone{set;get;}
    @AuraEnabled
    public Integer intPhoneCount{set;get;}
    @AuraEnabled
    public Integer intEmailCount{set;get;}
    @AuraEnabled
    public String OwnerName{set;get;}
    @AuraEnabled
    public String BrokerCRDNumber{set;get;}
    @AuraEnabled
    public String AgentLevelDescription{set;get;}
    @AuraEnabled
    public Boolean agentStatus;
    @AuraEnabled
    public Integer intAgentCodeCount{set;get;}
    @AuraEnabled
    public List<WFG_AgentRelatedCodeWrapper> lstAgentCodes{set;get;}
    @AuraEnabled
    public Map<String, WFG_AgentRelatedCodeWrapper> mapAgentCodes{set;get;}
    
}