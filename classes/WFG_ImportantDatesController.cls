/*
@author Mruga Shastri 
@date 07-Feb-2017
@description Controller for the Important Date & Add Important Date Components that display and Add Events related to given Contact respectively. 
*/
public with sharing class WFG_ImportantDatesController {
/*
@author Mruga Shastri 
@date 07-Feb-2017
@description Method to get the Events Records related to a given Contact Record.
*/  
    @AuraEnabled
    public static List<Event> getCustomerEvents(Id contactId){
        
        try{
	        List<Event> lstEvent = new List<Event>();
	        List<Contact> currentContact = new List<Contact>(); 
	        ID recTypeId =  Schema.SObjectType.Event.getRecordTypeInfosByName().get('Important Date').getRecordTypeId();
	        if(contactId!= null){
	        	currentContact = [Select Id, Name, AccountId from Contact where id=:contactID ];
	        }
		    System.debug('currentContact : ' + currentContact +  'currentContact AccountID : ' + currentContact[0].AccountId); 
	        if(!currentContact.isEmpty() && currentContact != null && currentContact[0].AccountID != null) {
	        	lstEvent = [SELECT Id, Subject, StartDateTime FROM Event WHERE  WhatId =: currentContact[0].AccountID AND RecordTypeId =: recTypeId ORDER BY StartDateTime DESC NULLS Last];
	            System.debug('lstEvent : ' + lstEvent); 
	        }
	
	        return lstEvent;
        }
     	catch(Exception ex){
        	LogUtility.createLog('EXCEPTION','Event','WFG_AgentEditCustomerDetails', 'Error', ex.getMessage(), 'Error');
        	return null;
        }  
    }
/*
@author Mruga Shastri 
@date 07-Feb-2017
@description Method to delete a given Event Record from the Contact Details page. 
*/
     @AuraEnabled
    public static void deleteCustomerEvent(Id eventId){
        
        List<Event> lstEvent = new List<Event>();
       if(eventId != null){
        	 lstEvent = [SELECT Id, Subject, StartDateTime FROM Event WHERE  Id =: eventId];
             System.debug('lstEvent to Delete' + lstEvent);
        }
        if(!lstEvent.isEmpty()){
        	try{
        		Database.Delete(lstEvent);
        	}catch(Exception ex){
        		System.Debug('Exception while deleting event : ' + ex);
        		LogUtility.createLog('EXCEPTION','Event','WFG_ImportantDates', 'Error', ex.getMessage(), 'Error');
        	}
        }  
    }

/*
@author Mruga Shastri 
@date 08-Feb-2017
@description Method to create an Event Record for the given Contact from Contact Details page. 
*/
     @AuraEnabled
    public static void createCustomerEvent(Id contactId, String subject, DateTime startDate){
        
        List<Contact> currentContact = new List<Contact>(); 
        ID recTypeId =  Schema.SObjectType.Event.getRecordTypeInfosByName().get('Important Date').getRecordTypeId();
        Event newEvent = new Event(); 
        if(contactId!= null){
            currentContact = [Select Id, Name, AccountId from Contact where id=:contactId ];
        }
        if(!currentContact.isEmpty() && currentContact != null && currentContact[0].AccountId != null){
             newEvent.Subject =  subject; 
             newEvent.IsAllDayEvent = true; 
             newEvent.StartDateTime = startDate; 
             newEvent.recordTypeId = recTypeId; 
             newEvent.WhatId = currentContact[0].AccountId; 
        }
            try{
                insert newEvent;
            }catch(Exception ex){
                System.Debug('Exception while creating event : ' + ex);
                LogUtility.createLog('EXCEPTION','Event','WFG_ImportantDates', 'Error', ex.getMessage(), 'Error');
            }
 
    }    
}