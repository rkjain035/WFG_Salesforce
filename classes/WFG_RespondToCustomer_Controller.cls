/**
*
Property of Transamerica and Aegon companies. Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Deloitte Consulting LLP
* @date 05/05/2016
* @description US-1128, US-2301: this class is controller for WFG_RespondToCustomer VF page

Modification Log:
-------------------------------------------------------------------------------------------------------
Developer          ModNumber           Date                    Description
-------------------------------------------------------------------------------------------------------
Suhan Jain          M-001              05/05/2016              Initial version

*
**/

global with sharing class WFG_RespondToCustomer_Controller {
    
    //variable declaration
    Public Case objCase {get;set;}
    Public string Body {get;set;}
    Public string strCaseID {get;set;}
    
    /**
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Which is the constructor methode
    * @author Deloitte Consulting LLP
    * @date 05/05/2016
    * @param No parameter
    * @return No Return
    * @description US-1128: 
    **/
    Public WFG_RespondToCustomer_Controller() {
        strCaseID = ApexPages.currentPage().getParameters().get('ID');
        if(strCaseID != null && strCaseID != ''){
            objCase = [Select ID, status, WFG_Resolution__c from Case where ID =: strCaseID];
        }
    }
    
    /**
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Which methode is called when Update button is clicked in the VF page
    * @author Deloitte Consulting LLP
    * @date 05/05/2016
    * @param No parameter
    * @return No Return
    * @description US-1128: 
    **/
    public pagereference doPost() {
        
        //feed item instance
        CaseComment objFItem = new CaseComment();
        
        objFItem.parentID = objCase.ID;
        objFItem.CommentBody = Body;
        //Evry - 12/21/2016: Below line is added to make the post public.
        objFItem.isPublished = true;
        //inserting the feed record        
        try {
            insert objFItem;  
        }
        catch (DMLException e){
            ApexPages.addMessages(e);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {System.Label.WFG_SupportEmail};
            mail.setToAddresses(toAddresses);
            mail.setReplyTo(System.Label.WFG_SupportEmail);
            mail.setSenderDisplayName('Apex error message');
            mail.setSubject('Error from Org&nbsp;: ' + UserInfo.getOrganizationName());
            mail.setPlainTextBody(e.getMessage());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
        return null;
    }
    
    /**
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Which methode is called when Close case button is clicked in the VF page
    * @author Deloitte Consulting LLP
    * @date 05/05/2016
    * @param No parameter
    * @return No Return
    * @description US-1128: 
    **/
    Public pagereference closeCase() {
        //Feed item instance
        CaseComment objFItem = new CaseComment();
        
        objFItem.parentID = objCase.ID;
        objFItem.CommentBody = Body;
        
        //inserting the record
        
        try {
            insert objFItem;  
        }
        catch (DMLException e){
            ApexPages.addMessages(e);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {System.Label.WFG_SupportEmail};
            mail.setToAddresses(toAddresses);
            mail.setReplyTo(System.Label.WFG_SupportEmail);
            mail.setSenderDisplayName('Apex error message');
            mail.setSubject('Error from Org&nbsp;: ' + UserInfo.getOrganizationName());
            mail.setPlainTextBody(e.getMessage());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        

        //updating the case record
        objCase.Status = 'Closed';
        objCase.WFG_Resolution__c = Body;
        
        try {
            update objCase;  
        }
        catch (DMLException e){
            ApexPages.addMessages(e);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {System.Label.WFG_SupportEmail};
            mail.setToAddresses(toAddresses);
            mail.setReplyTo(System.Label.WFG_SupportEmail);
            mail.setSenderDisplayName('Apex error message');
            mail.setSubject('Error from Org&nbsp;: ' + UserInfo.getOrganizationName());
            mail.setPlainTextBody(e.getMessage());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
            
        return null;
    }
    
    /**
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Which methode is called after clicked on close case or update button to refresh the page
    * @author Deloitte Consulting LLP
    * @date 05/05/2016
    * @param No parameter
    * @return Page URL
    * @description US-1128: 
    **/  
    Public pagereference reloadwindow() {
        
        //Redirect to case detail page
        PageReference acctPage = new PageReference('/' + objCase.ID);
        acctPage.setRedirect(true);
        return acctPage;
    }
    
    /**
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Which methode is called in the jQuery autocomplete
    * @author Deloitte Consulting LLP
    * @date 05/05/2016
    * @param Sring strResolution which is the input of textarea.
    * @return Quick text records
    * @description US-1128: 
    **/      
    @RemoteAction
    Global static List <QuickText> autocompleteComment(String strResolution) {
        strResolution = String.escapeSingleQuotes(strResolution);
        
        //Using SOSL to search resolution text in all fields
        String strQueryText = 'FIND \'' + strResolution + '\' IN ALL FIELDS RETURNING QuickText(message)';
        List <List<SObject>> lstDynamicSearchText = Search.query(strQueryText);
        List <QuickText> lstQuickText = new List <QuickText>();
        //return results
        if(lstDynamicSearchText.size() > 0) {
            
            for(QuickText objQuickTextRecord: (List <QuickText>) lstDynamicSearchText[0]) {
                lstQuickText.add(objQuickTextRecord);
            }
        }
        return lstQuickText;
    }
}