global class WFG_InsertRespectiveUserForCaseInfo implements  Database.Batchable<sObject> {
	
    Set<String> conList = new Set<String>();
    LIST<UserContact__c> userContactList = new LIST<UserContact__c>();
    Map<String, String> contactUserMap = new Map<String, String>();
    LIST<caseInfo__c> caseInfoToUpdate = new LIST<caseInfo__c>();
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
       	String query = 'select id, aboutId__c, Contact_Id__c from caseInfo__c';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<caseInfo__c> scope)
    {
        Database.delete(scope,false);
        /*for(caseInfo__c c : scope)
		{
    		System.debug('case Info id....'+c.Id);
  			conList.add(c.aboutId__c); 
  			conList.add(c.Contact_Id__c);
		}
        userContactList = [select Name, contactId__c from UserContact__c where contactId__c in: conList ];
		for(UserContact__c cu: userContactList)
		{
    		contactUserMap.put(cu.contactId__c, cu.name);
		} 
            for(caseInfo__c c : scope)
            {
                caseInfo__c caseInfo = new caseInfo__c();
                caseInfo.Id = c.Id;
        		if(c.aboutId__c != null)
                {        
                        caseInfo.aboutUser__c = contactUserMap.get(c.aboutId__c);        
                }
                if(c.Contact_Id__c != null)
                {       
                        caseInfo.ContactUser__c = contactUserMap.get(c.Contact_Id__c);       
                }
    		caseInfoToUpdate.add(caseInfo);
			}
        if(!caseInfoToUpdate.isEmpty())
        {
            Database.upsertResult[] upsertResult = Database.upsert(caseInfoToUpdate,false);
            for (Integer i = 0; i < upsertResult.size(); i++) {
                if (upsertResult[i].isSuccess()) {
                     System.debug('Successfully created ID: '
                          + upsertResult[i].getId());
                    } else {
                        System.debug('Error: could not create sobject '
                              + 'for array element ' + i + '.');
                        System.debug('   The error reported was: '
                              + upsertResult[i].getErrors()[0].getMessage() + '\n');
                        LogUtility.createLog('EXCEPTION','WFG_InsertRespectiveUserForCaseInfo','Error during Insert', 'Error', upsertResult[i].getErrors()[0].getMessage(), 'Error');   
                    
                    }
            }
        }
        */
    }
    global void finish(Database.BatchableContext bc)
    {
        
    }
}