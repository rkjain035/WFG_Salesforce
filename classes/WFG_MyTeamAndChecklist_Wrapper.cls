/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Rahul K Jain
* @date 25-Jul-2018
* @description  

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Rahul K Jain           M-001             25-Jul-2018            It's a wrapper class used for aggregating data
                                                                 from various objects.
Hampesh G              M-02              14-Sep-2018               Added new variable to store agent type                     
*/

public class WFG_MyTeamAndChecklist_Wrapper {   
    @AuraEnabled
    public String downlineImageURL {get;set;}
    @AuraEnabled
    public String downlineNames {get;set;}
     @AuraEnabled
    public String recruitedDate {get;set;}
    @AuraEnabled
    public String prospectsUserId {get;set;}
    @AuraEnabled
    public boolean inProgress {get;set;}
    @AuraEnabled
    public boolean completed {get;set;}
    @AuraEnabled
    public String phone {get;set;}
    @AuraEnabled
    public String email {get;set;}
     @AuraEnabled
    public String street {get;set;}
    @AuraEnabled
    public String city {get;set;}
    @AuraEnabled
    public String state {get;set;}
    @AuraEnabled
    public String pinCode {get;set;}
    @AuraEnabled
    public Integer downlinesProspect {get;set;}
    @AuraEnabled
    public String strAgentCode {get;set;}
    @AuraEnabled
    public String strAgentType {get;set;}
    
    
}