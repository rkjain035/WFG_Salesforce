/***********************************************************************************************************************
	Name: MerrillSSOInfo.cls helper Class
	Purpose: Sending Contact, Account and User Information to Merrill SSO 
	Created By: Linda Liu
	Created Date: 2/14/2018
    Description: Added Agent information to the User custom fields 
***********************************************************************************************************************/
public with sharing class MerrillSSOInfo {
    @AuraEnabled

    //get the merrill SSO url from custom settings (list type)
    public static String GetMerrillSSOEndpoint(String orderNumber)
    {
        String updatedPayload = UpdateUserPayload(orderNumber);
        if(updatedPayload != 'Success')
        {
            return 'Error -'  + updatedPayload;
        }
        MerrillSsoOrgDefaults__c orgDefaults = MerrillSsoOrgDefaults__c.getValues('Merrill SSO');
		return orgDefaults.Merrill_SSO_URL__c;
    }
    public static String test(String orderNumber)
    {
        return 'return from test with ordernumber = '+ orderNumber;
    }
    
    public static String UpdateUserPayload(String orderNumber)
    {
        //string userId = '00544000008gkfWAAQ'; //'0052F00000199IqQAI';  
        string userId = UserInfo.getUserId();
        //string profileId = '00e44000000G2s3AAC'; 
        string profileId = Userinfo.getProfileId();
        
        //get collection contains agent profile name list
        Set<String> profiles = new Set<String>{'Administrator', 'FA Home Office','FA PR','FA TAN','FA US','IAR PR','IAR TAN','IAR US','LL CAN','LL CAN Home Office','LL PR','LL TAN','LL US','LL US Home Office','MF CAN','MF Home Office','RR Home Office','RR PR','RR TAN','RR US','RR_IAR PR','RR_IAR TAN','RR_IAR US'};
       
        //get the current login user profile name 
        String userProfileName = [Select Name from profile where id=:profileId].Name;
        
        //when current user not in profile list, return error
        //if(!profiles.contains(userProfileName))
        //{
        //    return 'Error: No permission to place order.' + userProfileName;
        //}
        
        //get current login user
        User user = [select Id,FederationIdentifier, ApplicationData__c, LastName, FirstName, Email, Profile.Name, UserRole.Name, ProfileId
						from User where id=:userId];
        System.debug('userid=' + userId + 'user profile=' + user.Profile.Name + ' and  role=' + user.UserRole.Name + ' profileid=' + user.ProfileId);
 		
		//define object to hold payload info
		SsoPayload payload = new SsoPayload();
        //read values from User Object
        payload.UserId = user.Id;
        payload.UserFirstName = user.FirstName;
        payload.UserLastName = user.LastName;
        payload.UserEmail = user.Email;
        payload.Profile = user.Profile.Name;
        payload.Role = user.UserRole.Name;
		                
        //get contact/account from federation id
        String fedId = user.FederationIdentifier;
        if(String.isBlank(fedId))
        {
            return 'Error: Can not place order, user data is missing.';
        }
        
        try
        {
            //ID contactId = [select id from contact where WFG_FederationId__c=:fedId].Id;
            ID contactId = [select id from contact where WFG_FederationId__c=:fedId].Id;
            System.debug('Contact Id - ' + contactId + 'fed Id - ' + fedId);
            Contact contact = [SELECT Id, AccountId, FirstName, LastName, Email, MailingState,
                              WFG_BulletinName__c, WFG_BrokerCRDNumber__c, WFG_AgentCode__c, WFG_AgentLevel__c   
                                    FROM Contact where Id = :contactId];            
            
            //read values from Contact Object
            payload.ContactCode = ''; //not applied to TFN
            payload.ContactId = contact.Id;
            payload.ContactFirstName = String.isBlank(contact.FirstName)?'': contact.FirstName ;
            payload.ContactLastName = String.isBlank(contact.LastName)?'': contact.LastName;
            payload.ContactEmail = String.isBlank(contact.Email)?'': contact.Email;
            payload.Contact_FINRA_CRD_Number = ''; //not applied to TFN
            payload.Account_FINRA_CRD_Number = ''; //not applied to TFN
            payload.PrimaryAgentIdCode = contact.WFG_AgentCode__c;
            payload.WfgCommissionLevel = String.valueOf(contact.WFG_AgentLevel__c);
            payload.SecuritiesRegistration = ''; //to be imported
            payload.IaLicense = ''; //to be imported
            payload.insuranceLicenseType = ''; //to be imported
            payload.AuthorizedStates = ''; //to be imported
            payload.Country = ''; //to be imported
            payload.Appointments = ''; //to be imported
                    
            //Use user FirstName as “UserFirstName” value, overwrite first name only if
            //if BullitinName is not “” and BullitinName not equal = FirstName, use BullitinName "UserFirstName” value. 
            if(contact.WFG_BulletinName__c != null && contact.WFG_BulletinName__c != '' && user.FirstName != contact.WFG_BulletinName__c){
                payload.UserFirstName = contact.WFG_BulletinName__c;
                payload.ContactFirstName = contact.WFG_BulletinName__c;
            }

            
            Account account = [SELECT Id, ParentId FROM Account where Id = :contact.AccountId];
            		
            if(account.ParentId == null)
                account = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode             
                                    FROM Account where Id = :contact.AccountId];
			else			       						
                account = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode
                                    FROM Account where Id = :account.ParentId];
           
            //read values from Account Object
            payload.AccountId = account.Id;
            payload.AccountName = account.Name;
            payload.ContactMailingStreet = account.BillingStreet;
            payload.ContactMailingCity = account.BillingCity;
            payload.ContactMailingState = account.BillingState;
            payload.ContactMailingZip = account.BillingPostalCode;
            payload.AccountProductLines = '';  //not applied to TFN
            payload.FirmId = account.Id;
            
            payload.OrderNumber = orderNumber;
            payload.IWEmail = '';  //not applied to TFN
            payload.IWLastName = '';  //not applied to TFN
            payload.IWFirstName = '';  //not applied to TFN
            payload.BrowseOnly = 'FALSE';
            
        }
        catch(Exception e)
        {
            return 'Error: can not place order, contact or account data is missing - ' + e.getStackTraceString();
        }       

        //read customsettings to file global info
        try{
            //MerrillSSOCustomSettings__c customSettings = MerrillSSOCustomSettings__c.getOrgDefaults();
            //System.debug(customSettings);
            MerrillSSOCustomSettings__c customSettings = MerrillSSOCustomSettings__c.getInstance(user.ProfileId);
            System.debug(customSettings);
            
            payload.SourceSFOrg = customSettings.Source_SF_Org__c;
            payload.Market = customSettings.Market__c;
            payload.MarketingCostCenter = customSettings.Marketing_Cost_Center__c;
            payload.MarketingOrg = customSettings.Marketing_Org__c;
            payload.StatutoryCompany = customSettings.Statutory_Company__c;
            payload.RVPCostCenter = ''; //not applied to TFN
                
        }
        catch(Exception e){
            return 'Error: can not place order, setting data is missing - ' + e.getStackTraceString();
        }
        
        try{
            System.debug('before calling getpayloadxml, payload object = ' + payload);
            String payloadXml = GetPayloadXML(payload);
            if(payloadXml.contains('Error'))
                return payloadXml;
            
        	user.ApplicationData__c = payloadXml; 
            update user;
            System.debug('User app data = ' + user.ApplicationData__c);
		}
        catch(Exception ex)
		{
			return ('Error getting payload xml - ' + ex.getStackTraceString());
		} 
		
	
		return 'Success';
    }
    
    public static String GetPayloadXML(SsoPayload payload){
        System.debug('inside getpayloadxml');
        try{
        XmlStreamWriter w =new XmlStreamWriter();
        w.writeStartDocument(null, '1.0');
            
        w.writeStartElement(null,'ApplicationData', null);
       		w.writeStartElement(null, 'SourceSFOrg', null);
        	w.writeCharacters(payload.SourceSFOrg);
			w.writeEndElement();
        
            w.writeStartElement(null, 'Market', null);
        	w.writeCharacters(payload.Market);
			w.writeEndElement();    
        
            w.writeStartElement(null, 'MarketingCostCenter', null);
        	w.writeCharacters(payload.MarketingCostCenter);
			w.writeEndElement();
                
            w.writeStartElement(null, 'RVPCostCenter', null);
        	w.writeCharacters(payload.RVPCostCenter);
			w.writeEndElement();    
        
            w.writeStartElement(null, 'MarketingOrg', null);
        	w.writeCharacters(payload.MarketingOrg);
			w.writeEndElement();
                
            w.writeStartElement(null, 'StatutoryCompany', null);
        	w.writeCharacters(payload.StatutoryCompany);
			w.writeEndElement();
                
            w.writeStartElement(null, 'UserId', null);
        	w.writeCharacters(payload.UserId);
			w.writeEndElement();
                
            w.writeStartElement(null, 'UserFirstName', null);
        	w.writeCharacters(payload.UserFirstName);
			w.writeEndElement();
                
            w.writeStartElement(null, 'UserLastName', null);
        	w.writeCharacters(payload.UserLastName);
			w.writeEndElement();
                
            w.writeStartElement(null, 'UserEmail', null);
        	w.writeCharacters(payload.UserEmail);
			w.writeEndElement();
                
            w.writeStartElement(null, 'ContactCode', null);
        	w.writeCharacters(payload.ContactCode);
			w.writeEndElement();
                
            w.writeStartElement(null, 'ContactId', null);
        	w.writeCharacters(payload.ContactId);
			w.writeEndElement();
                
            w.writeStartElement(null, 'ContactFirstName', null);
        	w.writeCharacters(payload.ContactFirstName);
			w.writeEndElement();
                
            w.writeStartElement(null, 'ContactLastName', null);
        	w.writeCharacters(payload.ContactLastName);
			w.writeEndElement();
                
            w.writeStartElement(null, 'Contact_FINRA_CRD_Number', null);
        	w.writeCharacters(payload.Contact_FINRA_CRD_Number);
			w.writeEndElement();
                
            w.writeStartElement(null, 'Account_FINRA_CRD_Number', null);
        	w.writeCharacters(payload.Account_FINRA_CRD_Number);
			w.writeEndElement();
                
            w.writeStartElement(null, 'AccountId', null);
        	w.writeCharacters(payload.AccountId);
			w.writeEndElement();
                
            w.writeStartElement(null, 'AccountName', null);
        	w.writeCharacters(payload.AccountName);
			w.writeEndElement();
                 
            w.writeStartElement(null, 'ContactMailingStreet', null);
        	w.writeCharacters(payload.ContactMailingStreet);
			w.writeEndElement();
                        
            w.writeStartElement(null, 'ContactMailingCity', null);
        	w.writeCharacters(payload.ContactMailingCity);
			w.writeEndElement();
                        
            w.writeStartElement(null, 'ContactMailingState', null);
        	w.writeCharacters(payload.ContactMailingState);
			w.writeEndElement();
                        
            w.writeStartElement(null, 'ContactMailingZip', null);
        	w.writeCharacters(payload.ContactMailingZip);
			w.writeEndElement();
                        
            w.writeStartElement(null, 'ContactEmail', null);
        	w.writeCharacters(payload.ContactEmail);
			w.writeEndElement();
                                
            w.writeStartElement(null, 'AccountProductLines', null);
        	w.writeCharacters(payload.AccountProductLines);
			w.writeEndElement();
                                
            w.writeStartElement(null, 'Profile', null);
        	w.writeCharacters(payload.Profile);
			w.writeEndElement();
                                
            w.writeStartElement(null, 'Role', null);
        	w.writeCharacters(payload.Role);
			w.writeEndElement();
                                
            w.writeStartElement(null, 'FirmId', null);
        	w.writeCharacters(payload.FirmId);
			w.writeEndElement();
                                
            w.writeStartElement(null, 'OrderNumber', null);
        	w.writeCharacters(payload.OrderNumber);
			w.writeEndElement();
                                
            w.writeStartElement(null, 'IWEmail', null);
        	w.writeCharacters(payload.IWEmail);
			w.writeEndElement();
                                
            w.writeStartElement(null, 'IWLastName', null);
        	w.writeCharacters(payload.IWLastName);
			w.writeEndElement();
                                        
            w.writeStartElement(null, 'IWFirstName', null);
        	w.writeCharacters(payload.IWFirstName);
			w.writeEndElement();
                                        
            w.writeStartElement(null, 'BrowseOnly', null);
        	w.writeCharacters(payload.BrowseOnly);
			w.writeEndElement();
                                        
            w.writeStartElement(null, 'PrimaryAgentIdCode', null);
        	w.writeCharacters(payload.PrimaryAgentIdCode);
			w.writeEndElement();
                                        
            w.writeStartElement(null, 'WfgCommissionLevel', null);
        	w.writeCharacters(payload.WfgCommissionLevel);
			w.writeEndElement();
                                          
            w.writeStartElement(null, 'SecuritiesRegistration', null);
        	w.writeCharacters(payload.SecuritiesRegistration);
			w.writeEndElement();
                                               
            w.writeStartElement(null, 'IaLicense', null);
        	w.writeCharacters(payload.IaLicense);
			w.writeEndElement();
                                                
            w.writeStartElement(null, 'insuranceLicenseType', null);
        	w.writeCharacters(payload.insuranceLicenseType);
			w.writeEndElement();
                                                
            w.writeStartElement(null, 'AuthorizedStates', null);
        	w.writeCharacters(payload.AuthorizedStates);
			w.writeEndElement();
                                                        
            w.writeStartElement(null, 'Country', null);
        	w.writeCharacters(payload.Country);
            w.writeEndElement();
            
		w.writeEndDocument();
        
        if(!String.isBlank(payload.Appointments))
        {
            //todo: after data import, loop to assign appointments
            w.writeStartElement(null, 'Appointments', null);
        		w.writeStartElement(null, 'Appointment', null);
        			w.writeStartElement(null, 'CompanyCode', null);
        			w.writeEndDocument(); 
        
                    w.writeStartElement(null, 'CompanyName', null);
        			w.writeEndDocument(); 
        
                	w.writeStartElement(null, 'LicenseType', null);
        			w.writeEndDocument(); 
        
                	w.writeStartElement(null, 'State', null);
        			w.writeEndDocument(); 
        		w.writeEndDocument();  
			w.writeEndDocument(); 
        }
		w.writeEndDocument();
		String xmlOutput = w.getXmlString();
    	w.close();
        	System.debug('The Output is' + xmlOutput); 
            return xmlOutput;
        }
        catch(Exception e){
            return 'Error - ' + e.getStackTraceString();
        }
        

    }
    
    //this object holds all the payload items
    public class SsoPayload{
        
       public String SourceSFOrg {
          get { return SourceSFOrg; }
          set { SourceSFOrg = value; }
       }    
       public String Market {
          get { return Market; }
          set { Market = value; }
       }    
       public String MarketingCostCenter {
          get { return MarketingCostCenter; }
          set { MarketingCostCenter = value; }
       }    
       public String RVPCostCenter {
          get { return RVPCostCenter; }
          set { RVPCostCenter = value; }
       }    
       public String MarketingOrg {
          get { return MarketingOrg; }
          set { MarketingOrg = value; }
       }
       public String StatutoryCompany{
            get{return StatutoryCompany;}
            set{StatutoryCompany=value;}
        }
        public String UserId{
            get{return UserId;}
            set{UserId=value;}
        }
        public String UserFirstName{
            get{return UserFirstName;}
            set{UserFirstName=value;}
        }
        public String UserLastName{
            get{return UserLastName;}
            set{UserLastName=value;}
        }
        public String UserEmail{
            get{return UserEmail;}
            set{UserEmail=value;}
        }
        public String ContactCode{
            get{return ContactCode;}
            set{ContactCode=value;}
        }
        public String ContactId{
            get{return ContactId;}
            set{ContactId=value;}
        }
        public String ContactFirstName{
            get{return ContactFirstName;}
            set{ContactFirstName=value;}
        }
        public String ContactLastName{
            get{return ContactLastName;}
            set{ContactLastName=value;}
        }           
        public String Contact_FINRA_CRD_Number{
            get{return Contact_FINRA_CRD_Number;}
            set{Contact_FINRA_CRD_Number=value;}
        }              
        public String Account_FINRA_CRD_Number{
            get{return Account_FINRA_CRD_Number;}
            set{Account_FINRA_CRD_Number=value;}
        }  
        public String AccountId{
            get{return AccountId;}
            set{AccountId=value;}
        }          
        public String AccountName{
            get{return AccountName;}
            set{AccountName=value;}
        }          
        public String ContactMailingStreet{
            get{return ContactMailingStreet;}
            set{ContactMailingStreet=value;}
        }
        public String ContactMailingCity{
            get{return ContactMailingCity;}
            set{ContactMailingCity=value;}
        }        
        public String ContactMailingState{
            get{return ContactMailingState;}
            set{ContactMailingState=value;}
        }  
        public String ContactMailingZip{
            get{return ContactMailingZip;}
            set{ContactMailingZip=value;}
        }  
        public String ContactEmail{
            get{return ContactEmail;}
            set{ContactEmail=value;}
        }         
        public String AccountProductLines{
            get{return AccountProductLines;}
            set{AccountProductLines=value;}
        }         
        public String Profile{
            get{return Profile;}
            set{Profile=value;}
        }         
        public String Role{
            get{return Role;}
            set{Role=value;}
        }         
        public String FirmId{
            get{return FirmId;}
            set{FirmId=value;}
        }                
        public String OrderNumber{
            get{return OrderNumber;}
            set{OrderNumber=value;}
        }                                 
        public String IWEmail{
            get{return IWEmail;}
            set{IWEmail=value;}
        }  
        public String IWLastName{
            get{return IWLastName;}
            set{IWLastName=value;}
        }          
        public String IWFirstName{
            get{return IWFirstName;}
            set{IWFirstName=value;}
        }         
         public String BrowseOnly{
            get{return BrowseOnly;}
            set{BrowseOnly=value;}
        }        
        public String PrimaryAgentIdCode{
            get{return PrimaryAgentIdCode;}
            set{PrimaryAgentIdCode=value;}
        }         
        public String WfgCommissionLevel{
            get{return WfgCommissionLevel;}
            set{WfgCommissionLevel=value;}
        }               
        public String SecuritiesRegistration{
            get{return SecuritiesRegistration;}
            set{SecuritiesRegistration=value;}
        }                 
        public String IaLicense{
            get{return IaLicense;}
            set{IaLicense=value;}
        }                 
        public String insuranceLicenseType{
            get{return insuranceLicenseType;}
            set{insuranceLicenseType=value;}
        }                 
        public String AuthorizedStates{
            get{return AuthorizedStates;}
            set{AuthorizedStates=value;}
        }                                                 
        public String Country{
            get{return Country;}
            set{Country=value;}
        }                                                 
        public String Appointments{
            get{return Appointments;}
            set{Appointments=value;}
        }                                                         
        
    }
}