/**--Property of Transamerica and Aegon companies. Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Ramanarayanan P
* @date 05-11-2016
* @description US-1149: Controller fetches contact based on agent code recireved from chat button page

Modification Log:
-------------------------------------------------------------------------------------------------------
Developer          ModNumber           Date                    Description
-------------------------------------------------------------------------------------------------------
**/

global class WFG_PreChatPage_Controller

{
    public String strAgentCode {get;set;}
    

    global WFG_PreChatPage_Controller(ApexPages.StandardController controller)
    {
     
    }
    /*
     * Method to get contacts with given agent code
     */
    @RemoteAction
    global static Contact getContact(String strAgentCode)
    {
       Contact con = [select Id,FirstName,LastName,WFG_AgentCode__c,WFG_AgentLevel__c from Contact where WFG_AgentCode__c =: strAgentCode limit 1];
       return con;
              
    }

}