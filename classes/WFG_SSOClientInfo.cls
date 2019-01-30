public class WFG_SSOClientInfo {
	public static WFG_OpportunityInfo getClientInfo(String optyId, WFG_OpportunityInfo thisOppInfo) {
        Try {
            Opportunity oppt = [select Amount, CloseDate, CreatedDate, Id, Name, Probability, RecordTypeId, StageName, 
                                Type, WFG_Contact__c, WFG_Contact__r.Name, WFG_Contact__r.Id, Account.Name,
                                WFG_Contact__r.Salutation, WFG_Contact__r.FirstName, WFG_Contact__r.LastName,
                                WFG_Contact__r.MobilePhone, WFG_Contact__r.HomePhone,
                                WFG_Contact__r.Fax, WFG_Contact__r.Email, 
                                WFG_Contact__r.MailingCountry, WFG_Contact__r.MailingStreet, WFG_Contact__r.MailingCity, 
                                WFG_Contact__r.MailingState, WFG_Contact__r.MailingStateCode, WFG_Contact__r.MailingPostalCode,
                                WFG_Contact__r.MailingAddress, WFG_Contact__r.OtherAddress, WFG_Contact__r.OtherCountry, 
                                WFG_Contact__r.OtherStreet, WFG_Contact__r.OtherCity, WFG_Contact__r.OtherStateCode, 
                                WFG_Contact__r.OtherPostalCode,
                                WFG_Contact__r.FinServ__PrimaryCitizenship__c,WFG_Contact__r.FinServ__NumberOfDependents__c,
                                WFG_Contact__r.FinServ__Gender__c,WFG_Contact__r.FinServ__MaritalStatus__c, WFG_Contact__r.FinServ__Occupation__c, 
                                WFG_Contact__r.FinServ__CurrentEmployer__c, WFG_Contact__r.FinServ__AnnualIncome__c,
                                WFG_Contact__r.Birthdate 
                                from Opportunity where Id =: optyId];
            
            
            
            
            thisOppInfo.Salutation = oppt.WFG_Contact__r.Salutation;
            thisOppInfo.FirstName = oppt.WFG_Contact__r.FirstName;
            thisOppInfo.LastName = oppt.WFG_Contact__r.LastName;
            thisOppInfo.MobilePhone = oppt.WFG_Contact__r.MobilePhone;
            thisOppInfo.HomePhone = oppt.WFG_Contact__r.HomePhone;
            
            //updates for firelight
            thisOppInfo.Gender = oppt.WFG_Contact__r.FinServ__Gender__c;
            thisOppInfo.Birthdate = String.valueOf(oppt.WFG_Contact__r.Birthdate);
            thisOppInfo.MaritalStatus = oppt.WFG_Contact__r.FinServ__MaritalStatus__c;
            thisOppInfo.Citizenship = oppt.WFG_Contact__r.FinServ__PrimaryCitizenship__c;
            thisOppInfo.NumberofDependents = String.valueOf(oppt.WFG_Contact__r.FinServ__NumberOfDependents__c);
            thisOppInfo.Occupation = oppt.WFG_Contact__r.FinServ__Occupation__c;
            thisOppInfo.CurrentEmployer = oppt.WFG_Contact__r.FinServ__CurrentEmployer__c;
            thisOppInfo.AnnualIncome = String.valueOf(oppt.WFG_Contact__r.FinServ__AnnualIncome__c);
            
            //thisOppInfo.OtherPhone = oppt.WFG_Contact__r.Phone;
            thisOppInfo.Fax = oppt.WFG_Contact__r.Fax;
            thisOppInfo.Email = oppt.WFG_Contact__r.Email;
            thisOppInfo.MailingCountry = oppt.WFG_Contact__r.MailingCountry;
            thisOppInfo.MailingStreet = oppt.WFG_Contact__r.MailingStreet;
            thisOppInfo.MailingCity = oppt.WFG_Contact__r.MailingCity;
            thisOppInfo.MailingState = oppt.WFG_Contact__r.MailingState;
            thisOppInfo.MailingZIP = oppt.WFG_Contact__r.MailingPostalCode;
            //thisOppInfo.PrimaryAddress = oppt.WFG_Contact__r.MailingAddress;
            //thisOppInfo.OtherAddress = oppt.WFG_Contact__r.OtherAddress;
            thisOppInfo.OtherCountry = oppt.WFG_Contact__r.OtherCountry;
            thisOppInfo.OtherStreet = oppt.WFG_Contact__r.OtherStreet;
            thisOppInfo.OtherCity = oppt.WFG_Contact__r.OtherCity;
            thisOppInfo.OtherState = oppt.WFG_Contact__r.OtherStateCode;
            thisOppInfo.OtherZIP = oppt.WFG_Contact__r.OtherPostalCode;
            //thisOppInfo.Birthdate = Date.format(oppt.WFG_Contact__r.Birthdate);
            //thisOppInfo.SSN = String.valueOf(oppt.WFG_SSNSIN__c);
            thisOppInfo.OpportunityProductType = oppt.Type;
            //thisOppInfo.Amount = oppt.Amount;
            
            thisOppInfo.agentCode = RunningUserCtrl.getCurrentUser().WFG_Agent_Code__c;
            
            //MorningStar SSO client data
            thisOppInfo.accountNameSSO = '&clientAccountName=' + oppt.Account.Name;
            thisOppInfo.contactIDSSO = '&clientID=' + oppt.WFG_Contact__r.Id;
            thisOppInfo.agentCodeSSO = '&agentCode=' + thisOppInfo.agentCode;
            thisOppInfo.contactFirstNameSSO = '&clientFirstName=' + thisOppInfo.FirstName;
            thisOppInfo.contactLastNameSSO = '&clientLastName=' + thisOppInfo.LastName; 
            //Construct LaserApp Client SSO data
            thisOppInfo.clientSSOData = '&clientData=clientID_' + oppt.WFG_Contact__r.Id +
                							',AgentCode_' + thisOppInfo.agentCode +
                							',Salutation_' + thisOppInfo.Salutation +
                							',FirstName_' + thisOppInfo.FirstName +
                							',LastName_' + thisOppInfo.LastName +
                							',MobilePhone_' + thisOppInfo.MobilePhone +
                							',HomePhone_' + thisOppInfo.HomePhone +
                							',Fax_' + thisOppInfo.Fax +
                							',Email_' + thisOppInfo.Email +
                							',MailingCountry_' + thisOppInfo.MailingCountry +
                							',MailingStreet_' + thisOppInfo.MailingStreet +
                							',MailingState_' + thisOppInfo.MailingState +
                							',MailingZIP_' + thisOppInfo.MailingZIP +
                							',OtherCountry_' + thisOppInfo.OtherCountry +
                							',OtherStreet_' + thisOppInfo.OtherStreet +
                							',OtherCity_' + thisOppInfo.OtherCity +
                							',OtherState_' + thisOppInfo.OtherState +
                							',OtherZIP_' + thisOppInfo.OtherZIP + 
                                            ',OpportunityProductType_' + thisOppInfo.OpportunityProductType;
            return thisOppInfo;

        } catch (Exception e) {
            return null;
        }
  }
}