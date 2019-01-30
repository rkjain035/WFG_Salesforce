/**
 *
 Property of Transamerica and Aegon companies. Do not distribute without permission.
 * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
 * @author Deloitte Consulting LLP
 * @date 04/15/2016
 * @description US-1065: This class does below processing
                        - Process requests from ComplaintsPanelPage visualforce page
 Modification Log:
 -------------------------------------------------------------------------------------------------------
 Developer          ModNumber           Date                    Description
 -------------------------------------------------------------------------------------------------------
 Suhan Jain          M-001              04/21/2016              Added Contact name and Agent id 
                                                                to the case popup window name US-1195
 Madhurupa           M-002              04/22/2016              Added new search fields to 
                                                                contact and case search US-1136
 Madhurupa           M-003              04/29/2016              Code Review

 Suhan Jain          M-004              05/05/2016              Search method modified and Filter criteria 
                                                                for search changed. Case sorsing and listing changed.US-2274
 
 Suhan Jain          M-005              05/10/2016               Added autocompleteQuickText method for auto complete
                                                                 for quick text records US-1137 

 Suhan Jain          M-006              05/17/2016              Removed autofill method for contact US-2280

 Manuel Johnson      M-007              05/18/2016              Renamed WFG_BusinessEmail__c to WFG_AlternateEmail__c
 Madhurupa           M-007              05/20/2016              Added In Progress Status for color coding - US-2309
 Ramanarayanan P     M-009              05/30/2016              Modified create case method to use default(active) assignment rules.
 Suhan Jain          M-010              05/30/2016              Added label colour for Pending Response US-2325
 Ramanarayanan P     M-011              06/07/2016              Added logic to display case age by business hours
 Ramanarayanan P     M-012              07/06/2016              Modified search method to limit the display to 10 records
 Ramanarayanan P     M-013              07/18/2016              Tck-72 Search Result ordering
 *
 **/


global with sharing class WFG_ComplaintsPanelController {
    
    // Global variables
    public List<ContactWrapper> lstFoundContacts {get; set;}
    public String strSearchString {get; set;}
    public Integer searchCount {get;set;}
   
    /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Searches Cases
    * @author Deloitte Consulting LLP
    * @date 04/15/2016
    * @param No Parameter
    * @return Void
    * @description US-1065: Searches Cases.
    */
    
    public void search() {
        strSearchString = strSearchString.trim();
        strSearchString = strSearchString.replace('\'', '');
        String strLikeQuery = '%' + strSearchString + '%';
        String strQuery = 'FIND \'' + strSearchString + '\' IN ALL FIELDS RETURNING Contact(Id WHERE WFG_AgentCode__c LIKE \''+strSearchString+'\' OR Phone LIKE \''+strSearchString+'\' OR Email LIKE \''+strSearchString+'\' OR Name LIKE \''+strSearchString+'\' OR FirstName LIKE \''+strSearchString+'\' OR LastName LIKE \''+strSearchString+'\' ) ,Case(Id WHERE CaseNumber LIKE \''+strSearchString+'\' OR WFG_InteractingAboutCode__c LIKE \''+strSearchString+'\' OR type LIKE \''+strSearchString+'\' OR  Status LIKE \''+strSearchString+'\' OR Subject LIKE \''+strLikeQuery+'\'),WFG_AgentCode__c(Id, WFG_Contact__c WHERE (Name LIKE \''+strSearchString+'\'))';
        List<List<SObject>> lstDynamicSearchList = Search.query(strQuery); 
        Set<Id> setContactIds = new Set<Id>();
        Set<Id> setCaseIds = new Set<Id>();
        Integer intCount = 0;
        if(lstDynamicSearchList[1].size() >0)
        {
            for(Case objCaseRecord : (List<Case>) lstDynamicSearchList[1]) {
                          setCaseIds.add(objCaseRecord.Id);  
           
        }
            
        }
        
        if(lstDynamicSearchList[0].size() >0)
        {
            for(Contact objContactRecord : (List<Contact>) lstDynamicSearchList[0]) {
           
            setContactIds.add(objContactRecord.Id);
            
        }
            
        }
        if(lstDynamicSearchList[2].size() >0)
        {
            for(WFG_AgentCode__c objAgentRecord : (List<WFG_AgentCode__c>) lstDynamicSearchList[2]) {
           
            setContactIds.add(objAgentRecord.WFG_Contact__c);
            
        }
            
        }
        
       
        
        strLikeQuery = strLikeQuery.replaceAll('', '%');
         
       strQuery = 'FIND \'' + strLikeQuery + '\' IN ALL FIELDS RETURNING Case(Id WHERE CaseNumber LIKE \''+strLikeQuery+'\' OR type LIKE \''+strLikeQuery+'\'  OR Status LIKE \''+strLikeQuery+'\'  ), Contact(Id WHERE WFG_AgentCode__c LIKE \''+strLikeQuery+'\' OR Phone LIKE \''+strLikeQuery+'\' OR Email LIKE \''+strLikeQuery+'\' OR Name LIKE \''+strLikeQuery+'\' OR FirstName LIKE \''+strLikeQuery+'\' OR LastName LIKE \''+strLikeQuery+'\' )';
        lstDynamicSearchList = Search.query(strQuery);
        searchCount = lstDynamicSearchList[0].size()+lstDynamicSearchList[1].size();
        if(lstDynamicSearchList[0].size() >0)
        {
            for(Case objCaseRecord : (List<Case>) lstDynamicSearchList[0]) {
                setCaseIds.add(objCaseRecord.Id);
           
        }
            
        }
        if(lstDynamicSearchList[1].size() >0)
        {
            for(Contact objContactRecord : (List<Contact>) lstDynamicSearchList[1]) {
            
                setContactIds.add(objContactRecord.Id);
           
        }
            
        }
        // Getting records informaiton
        List<Case> lstCases = new List<Case>();
        
        //US-1136 [Madhu 4/22/2016]: Added Type, WFG_Case_Reason_2__c in query to display in search results
        //[Madhu 4/29/2016] Code Review Fix to move queries with for loop
        //Modified by Suhan US-2274
        if(!setCaseIds.isEmpty() || !setContactIds.isEmpty())
        {
            
        for(Case objCaseRecord : [SELECT Id, 
                                         CaseNumber, 
                                         Description, 
                                         Subject, 
                                         Status, 
                                         Owner.Name,
                                         ContactId, 
                                         Origin,
                                         WFG_Age__c,
                                         Priority, 
                                         CreatedDate, 
                                         Type, 
                                         WFG_Case_Reason_2__c,
                                         WFG_InteractingAbout__c,
                                         WFG_InteractingAbout__r.Name,
                                         Contact.Name
                                         FROM Case 
                                 WHERE (Id IN :setCaseIds OR ContactId IN :setContactIds)  
                                 AND ((WFG_Age__c<=14 AND STATUS = 'Closed') OR (Status != 'Closed')) Order By Status, WFG_Age__c ASC LIMIT 50] ){
            lstCases.add(objCaseRecord);
            setContactIds.add(objCaseRecord.ContactId);
        }
            
        }
  
        // Creating wrappers
        lstFoundContacts = new List<ContactWrapper>();
        
        //US-1136 [Madhu 4/22/2016]: Added WFG_BusinessEmail__c, MobilePhone, HomePhone, WFG_Status__c in 
        //query to display in search results
        //Modified by Suhan US-2274
        if(!setContactIds.isEmpty())
        {
            
            for(Contact objContactRecord : [SELECT Id, 
                                               Name, 
                                               FirstName, 
                                               LastName, 
                                               MailingStreet, 
                                               MailingCity, 
                                               Email, 
                                               Phone, 
                                               MailingState, 
                                               MailingPostalCode, 
                                               MailingCountry, 
                                               WFG_AgentCode__c, 
                                               //WFG_AlternateEmail__c, 
                                               MobilePhone,
                                               WFG_Res__c,
                                               WFG_BulletinName__c, 
                                               HomePhone, WFG_Status__c 
                                               FROM Contact 
                                       WHERE (Id IN :setContactIds  ) LIMIT 50 ] ) {
            ContactWrapper wrappedContactRecord = new ContactWrapper(objContactRecord);
            for(Case objCaseRecord : lstCases) {
                CaseWrapper wrappedCaseRecord = new CaseWrapper(objCaseRecord);
                if(objCaseRecord.ContactId != null && objCaseRecord.ContactId.equals(objContactRecord.Id)) {
                    wrappedContactRecord.lstCases.add(wrappedCaseRecord);
                }
            }
          
                 lstFoundContacts.add(wrappedContactRecord);   
        }
            
        }
        
        
    }
    
    /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Wrapper Class for Cases
    * @author Deloitte Consulting LLP
    * @date 04/15/2016
    * @param No Parameter
    * @return No Return
    * @description US-1065: Wrapper Class for Cases.
    */
    
    public class CaseWrapper {
        
        // Global variables
        public Case objCaseRecord {get; set;}
        public String strColorStatus {get; set;}
        public String strCaseCreatedDate {get; set;}
        
        /**
        *
        Property of Transamerica and Aegon companies.Do not distribute without permission.
        * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
        * Constructor of the class
        * @author Deloitte Consulting LLP
        * @date 04/15/2016
        * @param Case
        * @return No Return
        * @description US-1065: Constructor of the class.
        */
        
        public CaseWrapper(Case objCaseRecord) {
            this.objCaseRecord = objCaseRecord;

            //Modified by suhan jain for Us-2274
            if(objCaseRecord != null && objCaseRecord.Status != null) {
                //Madhu 5/20/2016: US-2309 Added color coding for In Progress
                if(objCaseRecord.Status == 'New' || objCaseRecord.Status == 'In Progress') {
                    strColorStatus = 'label-warning';
                } else if(objCaseRecord.Status == 'Research' || objCaseRecord.Status =='Pending Response') {
                    strColorStatus = 'label-primary';
                } else if(objCaseRecord.Status == 'Escalated') {
                    strColorStatus = 'label-danger';
                } else if(objCaseRecord.Status == 'Closed' || objCaseRecord.Status == 'Duplicate') {
                    strColorStatus = 'label-success';
                }
                
                strCaseCreatedDate = objCaseRecord.CreatedDate.month()+'/'+objCaseRecord.CreatedDate.day()+
                                     '/'+objCaseRecord.CreatedDate.year();             
                        
            }           
        }
    }
     
    /**
    *
    Property of Transamerica and Aegon companies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * Wrapper Class for Contacts
    * @author Deloitte Consulting LLP
    * @date 04/15/2016
    * @param No Parameter
    * @return No Return
    * @description US-1065: Wrapper Class for Contacts.
    */
    
    public class ContactWrapper {
        
        // Global variables
        public Contact objContact {get; set;}
        public List<CaseWrapper> lstcases {get; set;}
        
        /**
        *
        Property of Transamerica and Aegon companies.Do not distribute without permission.
        * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
        * Constructor of the class
        * @author Deloitte Consulting LLP
        * @date 04/15/2016
        * @param Contact
        * @return No Return
        * @description US-1065: Constructor of the class.
        */
        
        public ContactWrapper(Contact objContact) {
            lstcases = new List<CaseWrapper>();
            this.objContact = objContact;         
        }
    }
}