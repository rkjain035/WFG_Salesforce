public with sharing class InsuranceApplication_Controller {
	
	@AuraEnabled
	public static InsuranceApplicationInfo getApplicationInfo(String recordId, String displayMode) {
       	Opportunity o = [SELECT Id, Name, Insurance_Case__c, accountId, StageName, OwnerId, WFG_Product_Type__c FROM Opportunity WHERE Id = :recordId LIMIT 1];
        AgentOne__InsuranceCase__c i;
        if(o.Insurance_Case__c != null) {
			i = [SELECT AgentOne__External_Id__c, AgentOne__Is_e_App_Archived__c FROM AgentOne__InsuranceCase__c WHERE Id = :o.Insurance_Case__c LIMIT 1];   
        }
        else {
            i = null;
        }
        User u = [SELECT ProfileId, AgentOne__IsAgentOne__c FROM User WHERE Id = :o.OwnerId];
        Profile p = [SELECT Name FROM Profile WHERE Id = :u.ProfileId];
        
        InsuranceApplicationInfo appInfo = new InsuranceApplicationInfo();
        appInfo.stageName = o.StageName;
        appInfo.isAgentOneUser = u.AgentOne__IsAgentOne__c;
        
        if(i != null) {
            appInfo.externalID = i.AgentOne__External_Id__c;
            appInfo.isEAppArchived = i.AgentOne__Is_e_App_Archived__c;            
        } else {
        	appInfo.externalID = '';
        	appInfo.isEAppArchived = false;            
        }

        if (p.Name.Contains('TAN')) {
            appInfo.isTanAgent = true;
        } else {
            appInfo.isTanAgent = false;
        }
        
		if (UserInfo.isCurrentUserLicensed('AgentOne')) {
            appInfo.isUserLicensed = true;
		} 
        else {
            appInfo.isUserLicensed = false;
		}
        
        //System.debug('appInfo.stageName: ' + appInfo.stageName);
        if (!appInfo.isAgentOneUser || appInfo.isUserLicensed == false) {
            appInfo.accessMessage = 'Oops! It looks like you are not an AgentOne user and therefore ' +
                                    'you do not have access to the iGO tab. Please contact your system ' +
                                    'administrator.';
        } else if (appInfo.isEAppArchived) {
            appInfo.accessMessage = 'Oops! It looks like the corresponding e-App record has been archived. ' +
                                    'If you feel you reached this message in error, please contact your system administrator. ';
        } else if (appInfo.stageName == 'Needs Assessment') {
            appInfo.accessMessage = 'The features of the iGO illustrations and iGO e-App are only available in ' +
                                    'the Recommendation or Application stage of the Opportunity. Please ' +
                                    'advance to the appropriate stage to continue.';
        } else if ((appInfo.stageName == 'Pending Sale' && appInfo.externalID == null) || (appInfo.stageName == 'Sale Accepted' && appInfo.externalID == null)) {
            appInfo.accessMessage = 'An application has already been created for this Opportunity and is in ' +
                                    'the Pending Policy process. Please create a new Opportunity if you wish ' +
                                    'to start a new iGO e-App.';
        } else if (appInfo.stageName == 'Recommendation' && !appInfo.isTanAgent) {
            appInfo.accessMessage = 'Oops! Only TAN Agents can access the Illustrations features of iGO. If ' +
                                    'you are a TAN Agent, please contact your administrator. If you are ' +
                                    'trying to start an iGO application, please advance to the Application ' +
                                    'stage of the Opportunity and try again.';
        } else {
            appInfo.accessMessage = '';
        }
 

        if(appInfo.accessMessage == '' && displayMode == 'trueApp') {
            if (o.Insurance_Case__c != null) {
                appInfo.caseId = o.Insurance_Case__c;
                appInfo.hasAccess = true;
                appInfo.isInsCaseNew = false;
            } else {
                // Create a new case and set it for the opportunity
                AgentOne__InsuranceCase__c c1 = OpportunityInsuranceService.setupInsuranceOpportunity(o.Id, o.AccountId, o.Name, o.WFG_Product_Type__c);
                appInfo.caseId = c1.Id;
                appInfo.hasAccess = true;
                appInfo.isInsCaseNew = true;
            }
        }
        else {
			appInfo.caseId = '';
            appInfo.hasAccess = false;
            appInfo.isInsCaseNew = false;
        }
        
        // Need to check if the Object has insurance case reference and if it does then return the query for it
        System.debug(appInfo);
        return appInfo;
	}


    @AuraEnabled
    public static InsuranceApplicationInfo updateApplicationInfo(String recordId, String caseId) {
        Opportunity o = new Opportunity();
        o.Id = recordId;
        o.Insurance_Case__c = caseId;
        
        update o;
        
        InsuranceApplicationInfo appInfo = new InsuranceApplicationInfo();
        appInfo.hasAccess = true;
        appInfo.caseId = caseId;
        
        return appInfo;
    }

    
	public class InsuranceApplicationInfo {
		@AuraEnabled
		public Boolean hasAccess {get;set;}

		@AuraEnabled
		public String accessMessage {get; set;}
        
        @AuraEnabled
        public String caseId {get; set;}
 
        @AuraEnabled
        public Boolean isTanAgent {get; set;}
        
        @AuraEnabled
        public String stageName {get; set;}

        @AuraEnabled
		public Boolean isAgentOneUser {get;set;}
        
        @AuraEnabled
        public String externalID {get; set;}
                
        @AuraEnabled
		public Boolean isEAppArchived {get;set;}
        
        @AuraEnabled
		public Boolean isInsCaseNew {get;set;}
        
        @AuraEnabled
		public Boolean isUserLicensed {get;set;}
        
		InsuranceApplicationInfo() {
			this.hasAccess = false;
		}
	}
}