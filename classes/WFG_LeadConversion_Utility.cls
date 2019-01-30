global with sharing class WFG_LeadConversion_Utility 
{
    public static boolean isFlowTriggered = false;
    
    public static Contact createIndividualRecord(Lead objLead)
    {
        ID rtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        List<WFG_Lead_Conversion_Mapping__mdt> leadConversionMappingLst = new List<WFG_Lead_Conversion_Mapping__mdt>(); 
        leadConversionMappingLst = [Select WFG_Contact_Field_API__c,WFG_Lead_Field_API__c from WFG_Lead_Conversion_Mapping__mdt];
         system.debug('@@@ leadConversionMappingLst  ->'+leadConversionMappingLst );
        Contact objContact = new Contact();
        String LeadFieldValue; 
        
        if(leadConversionMappingLst != null){
            for(WFG_Lead_Conversion_Mapping__mdt fieldMapping : leadConversionMappingLst){
                LeadFieldValue = (String)objLead.get(fieldMapping.WFG_Lead_Field_API__c);
                objContact.Put(fieldMapping.WFG_Contact_Field_API__c, LeadFieldValue);
            }
        }
        
        objContact.recordTypeId = rtId;
        system.debug('@@@ cont obj ->'+objContact);
        return objContact;       
    }
    
    public static WFG_POPWrapper convertLead(id idLead)
    {
        WFG_POPWrapper objWrapper = new WFG_POPWrapper();
        Contact objCon = new Contact();
        try{
            Lead objLead = [select id,Name, salutation, CountryCode, StateCode, PostalCode,firstName,lastName, city, country,
                            state, street, email, phone, WFG_CASL_Consent__c, ownerId, WFG_Lead_Type__c from Lead WHERE Id =:idLead ];
            system.debug('@@@ obj lead-->'+objLead );
            if(objLead != null){
                objCon = createIndividualRecord(objLead);
                if(isFlowTriggered)
                    objCon.OwnerId = objLead.OwnerId;
                    
                insert objCon;
                
                objCon = [Select id, name,FirstName, LastName, accountId from contact WHere Id = :objCon.id];
                
                system.debug('### ContactID :' + objCon + ' ### ACxcountID :: ' + objCon.accountID);
                
                objWrapper.convertedContact = objCon;
                
                LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];            
                Database.LeadConvert lc = new Database.LeadConvert();
                
                lc.setLeadId(idLead);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                
                lc.setDoNotCreateOpportunity(true);
                lc.setAccountId(objCon.accountId);
                lc.setContactId(objCon.Id);
                
                
                                
                lc.setConvertedStatus('Converted');                 
                Database.LeadConvertResult lcr = Database.convertLead(lc);
                
                objWrapper.recordId = objCon.Id;
                objWrapper.strSuccessMessage = objLead.Name + 'has been converted successfully!!!';
            }
            
            
        }
        catch(DMLException e){
            objWrapper.boolIsError = true;
            
            String message = 'This contact '+ objCon.FirstName + ' ' + objCon.LastName+ ' already exists.';
            
            if(e.getDmlMessage(0).contains(message)){
                objWrapper.strErrorMessage = 'Contact with similar credentials already exists. ' + objCon.FirstName + ' ' + objCon.LastName +' cannot be converted.';
            }
            else{
                 objWrapper.strErrorMessage = e.getDmlMessage(0);
                 system.debug('@@@ DML email error ->'+objWrapper.strErrorMessage);
            } 
        }
        catch(Exception e){
            objWrapper.boolIsError = true;
            objWrapper.strErrorMessage = e.getMessage();
            system.debug('@@@ generic email error ->'+objWrapper.strErrorMessage);
        }
        
        
        return objWrapper;
    }
    
    @InvocableMethod
    public static list<contact> convertLeadRecords(list<Id> leadIds)
    {
        isFlowTriggered = true;
        WFG_POPWrapper objWrapper = convertLead(leadIds[0]);
        if(objWrapper.boolIsError)
            return NULL;
        
        list<Contact> contactList = new list<Contact>{objWrapper.convertedContact};
        
        return contactList;
    }
}