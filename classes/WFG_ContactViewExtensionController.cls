/*
Property of Transamerica and Aegon companies. Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Nikhil More
* @date 05-20-2016
* @description US-2295: This page does below processing
  - Redierect users based on the record type to see the respective view

Modification Log:
__________________________________________________________________________________________________________
Developer          ModNumber           Date                    Description
__________________________________________________________________________________________________________
Nikhil             M-001               06-15-2016              Work Item #121 - Pre-FSC Installation changes
                                                               to allow co-existence of new apps with 
                                                               service center
*/
public class WFG_ContactViewExtensionController 
{
    private final Contact cont;

    public WFG_ContactViewExtensionController(ApexPages.StandardController stdController) 
    {
        this.cont = (Contact) stdController.getRecord();
    }
     /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Redirect users based on the record type of contact
    * @author Deloitte Consulting LLP
    * @date 05-20-2016
    * @param contactId
    * @return PageReference
    * @description This method is used as a page reference action to redirect users to respective view
    */
    public PageReference redirectToViewLinks() 
    {
        PageReference returnPage;
        Contact contact = [SELECT Id,RecordType.DeveloperName FROM Contact WHERE Id = :cont.Id];
        
        if(contact.RecordType.DeveloperName == 'Service_Center_Contact' && (UserInfo.getUserId() != '00544000008heaSAAQ' && UserInfo.getUserId() != '00544000008iBHxAAM') )
        {
            returnPage = new PageReference('/apex/WFG_Agent360Console?id='+contact.Id);
        }
        else
        {
            returnPage = new PageReference('/apex/WFG_StandardContactView?id='+contact.Id);
        }
        
        returnPage.setRedirect(true); 
        return returnPage;
    }
}