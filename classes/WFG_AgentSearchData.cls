/*
Property of Transamerica and Aegon companies. Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Madhurupa Ghose Roy
* @date 06-15-2016
* @description US-2287: This page does below processing
  - View the 360 degree information for an Agent

Modification Log:
__________________________________________________________________________________________________________
Developer          ModNumber           Date                    Description
__________________________________________________________________________________________________________

*/

public class WFG_AgentSearchData {
    @AuraEnabled 
    public Id contactId;
    @AuraEnabled
    public String contactName;
    @AuraEnabled
    public String agentCode;
    @AuraEnabled
    public Decimal agentLevel;            
    @AuraEnabled
    public String ssn;
    
    public WFG_AgentSearchData(Id contId, String contName, String agentCode, Decimal agentLevel, String ssn){
        this.contactId = contId;
        this.contactName = contName;
        this.agentCode = agentCode;
        this.agentLevel = agentLevel;
        this.ssn = ssn;
    }
}