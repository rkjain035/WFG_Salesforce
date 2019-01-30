/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Saurabh Sharma
* @date 1-12-2017
* @description  Controller class for Lightning component to fetch and update Contact record

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Saurabh Sharma        M-001             1-12-2017         US-404: Show customer details on dashboard  
*/
public class WFG_CustomerDashboardController {
	
    /**
     * Method to fetch individual records
     * @return - Contact
     * @see    - N/A
     * @param  - id of Contact
     * @throws - N/A
    */  
    @auraEnabled
    public static Contact getContactDetails(String contId){
        return [SELECT Id, Name, FirstName, WFG_Middle_Name__c, LastName, Phone FROM Contact WHERE Id =: contId];
    }
    
    /**
     * Method to update individual records
     * @return - N/A
     * @see    - N/A
     * @param  - Contact
     * @throws - N/A
    */  
    @auraEnabled
    public static void updateContact(Contact cont){
        if(cont != null){
        	update cont;
    	}
    }
}