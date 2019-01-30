global without sharing class IPL_ProposedInsuredMatchingLogic {
    webservice static List<String> PIMatchingLogicString(String piFirstName, String piLastName, String iGoCaseOwner, String piDOB, String piEmail)
    {
        System.Debug('PIFirstName: ' + piFirstName);
        System.Debug('PILastName: ' + piLastName);
        System.Debug('iGOCaseOwner: ' + iGOCaseOwner);
        System.Debug('piDOB: ' + piDOB);
        System.Debug('piEmail: ' + piEmail);
        
        List<String> value = new List<String>();
        value = findContact(piFirstName, piLastName, iGoCaseOwner, piDOB, piEmail);        
        return value;
    }
    
    private static List<String> findContact(String piFirstName, String piLastName, String iGoCaseOwner, String piDOB, String piEmail) 
    {
        System.Debug('Enter findContact()');
        List<String> id_acctCreated = new List<String>();
        
        if (String.isNotEmpty(piDOB))
        {
            //Compare iGO case against AgentOne Contact for FirstName, LastName, and DOB
            Date DOB = Date.parse(piDOB);
			List<Contact> contacts = [SELECT Id, Owner.AgentOne__iPipeline_User_Id__c FROM Contact WHERE FirstName =: piFirstName AND LastName =: piLastName AND Birthdate =: DOB AND Owner.AgentOne__iPipeline_User_Id__c =: iGoCaseOwner];
            
            if (contacts.size() > 1)
            {
                System.Debug('First if statement');
                //Multiple Contact records with same FirstName and LastName
                id_acctCreated.add('1');
                id_acctCreated.add('N');
                return id_acctCreated;
            }    
            else if (contacts.size() == 1)
            {
                System.Debug('First else-if statement');
                if(contacts[0].Owner.AgentOne__iPipeline_User_Id__c == iGoCaseOwner)
                {
                    System.Debug('First else-if IF');
                    id_acctCreated.add(contacts[0].Id);
                    id_acctCreated.add('N');
                    return id_acctCreated;
                }
                else
                {   
                    System.Debug('First else-if ELSE'); 
                    //The Contact's Owner iPipeline User Id is not the same as the iGo Case Owner
                    id_acctCreated.add('2');
                    id_acctCreated.add('N');
                    return id_acctCreated;
                }
            }
        }
        
        //No matching AgentOne Contact was found - create a new one
        System.Debug('No Contacts found - create one');
        List<User> newOwner = [SELECT Id, Name FROM User WHERE AgentOne__iPipeline_User_Id__c =: iGoCaseOwner];
        
        if(newOwner.size() > 0 && String.isNotEmpty(piFirstName) && String.isNotEmpty(piLastName))
        {                     
            Contact newAcct = new Contact();
            newAcct.FirstName = piFirstName;
            newAcct.LastName = piLastName;
            newAcct.WFG_AgentCode__c = 'aaaa1111';
            newAcct.WFG_AgentLevel__c = 10;
            if(String.isNotEmpty(piDOB)) { Date DOB = Date.parse(piDOB); newAcct.Birthdate = DOB; }
            newAcct.OwnerId = newOwner[0].Id;
            if(String.isNotEmpty(piEmail)) { newAcct.Email = piEmail; }
            else { newAcct.Email = 'noiGo@email.com'; }
            
            try
            {   
                System.Debug('Contact creation - try');
                insert newAcct;      
                
                List<Contact> cont = [SELECT Id FROM Contact WHERE FirstName =: piFirstName AND LastName =: piLastName AND Id =: newAcct.Id];
                id_acctCreated.add(cont[0].Id);
                id_acctCreated.add('Y');
                System.Debug('Insert id_acctCreated');  
                return id_acctCreated;
            }
            catch(DmlException e)
            {
                System.Debug('Contact creation - catch');
                System.Debug('Contact creation cause: ' + e.getCause());
                System.Debug('Contact creation message: ' + e.getMessage());
                //There was an exception in Contact creation
                id_acctCreated.add('3');
                id_acctCreated.add('N');
                return id_acctCreated;
            }
        }
        else
        {
            System.Debug('Do NOT create a new Account/Contact in AgentOne');
            id_acctCreated.add('4');
            id_acctCreated.add('N');
            return id_acctCreated;
        }
    }        
}