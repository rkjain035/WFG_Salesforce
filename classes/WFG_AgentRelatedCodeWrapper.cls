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
*/

public class WFG_AgentRelatedCodeWrapper {
    @AuraEnabled 
    public String agentId;    
    @AuraEnabled
    public String agentName;   
    @AuraEnabled
    public String USStatus;   
    @AuraEnabled
    public String USStatusDate;
    @AuraEnabled 
    public String CAStatus;    
    @AuraEnabled
    public String CAStatusDate;   
    @AuraEnabled
    public String PRStatus;   
    @AuraEnabled
    public String PRStatusDate;
    @AuraEnabled 
    public Decimal Level;    
    @AuraEnabled
    public String LevelDescription;   
    @AuraEnabled
    public String StartDate;   
    @AuraEnabled
    public String SMDApprovalDate;
    @AuraEnabled 
    public String LevelStartDate;    
    @AuraEnabled
    public String RegionalBranchManagerCodeName;   
    @AuraEnabled
    public String BranchOfficeManagerCodeName;   
    @AuraEnabled
    public String BranchOfficeSupervisorCodeName; 
    @AuraEnabled
    public String UplineCodeName;
    @AuraEnabled
    public String RegionalBranchManagerCodeId;   
    @AuraEnabled
    public String BranchOfficeManagerCodeId;   
    @AuraEnabled
    public String BranchOfficeSupervisorCodeId; 
    @AuraEnabled
    public String UplineCodeId; 
    @AuraEnabled
    public String RegionalBranchManagerCode;   
    @AuraEnabled
    public String BranchOfficeManagerCode;   
    @AuraEnabled
    public String BranchOfficeSupervisorCode; 
    @AuraEnabled
    public String UplineCode;
    @AuraEnabled
    public Boolean PrimaryCode;
}