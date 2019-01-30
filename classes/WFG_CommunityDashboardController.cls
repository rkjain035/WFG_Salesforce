public with sharing class WFG_CommunityDashboardController {
    
    public static boolean isRecruitingOpp;
    public static String recordTypeValue = '';
    
    @AuraEnabled
    public static List<OpportunityWrapper> getOpportunityList(String tableType, String filter, String ContactID) {
        
        List<OpportunityWrapper> OppWrapperList =  new List<OpportunityWrapper> ();
        List<Opportunity> opptList = new List<Opportunity>();

        String myQuery;

        try {
            Id currUserId = userInfo.getUserId();
            String oppQuery = 'SELECT Id, Name, Amount, Type, RecordTypeId, WFG_Contact__r.name, StageName, Is_the_person_licensed__c, CloseDate From Opportunity Where OwnerId =: currUserId';
            system.debug('+++++tb ++'  + tableType );
            if (tableType == 'contact-detail') {
                oppQuery += ' AND WFG_Contact__c = : ContactID ORDER BY CreatedDate DESC';
            
            } else if (tableType == 'Dashboard') {
                oppQuery += ' AND WFG_Contact__r.WFG_Contact_Indicator__c != \'Inactive\' AND StageName NOT IN (\''+system.label.WFG_OpportunityStage_CloseWon+'\', \''+system.Label.WFG_OpportunityStage_CloseLost+'\' )';
                
                if(filter != NULL && filter != '' && filter.contains('NOT IN')){
                    oppQuery += ' AND ' + filter + ' ORDER BY Amount DESC NULLS LAST LIMIT 5';
                }
                else
                {
                    oppQuery += ' AND ' + filter + ' ORDER BY CreatedDate DESC LIMIT 5';
                }
                    
            } else if (tableType == 'All Records') {
                
                if(filter != NULL && filter != ''){
                    oppQuery += ' AND ' + filter + ' ORDER BY Amount DESC';
                } else {
                    oppQuery +=' ORDER BY Amount DESC';
                }
            }
            
           
            system.debug('++++++++++' + oppQuery);
             opptList = database.query(oppQuery);
            system.debug('---------' + opptList.size());
        } catch (Exception e) {
            system.debug('# Opportunity query Error Message ' + e.getMessage());
        }

        for (Opportunity opp: opptList) {

            string recordtypename = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(opp.RecordTypeId).getname();
            
            //This chode has been writtent to avoide the issues came because of associate CP functionality.
            if(recordtypename == 'InsuranceReadOnly'){
                recordtypename = 'Insurance';
            }
            else if(recordtypename == 'Investment/Savings Read Only'){
                recordtypename = 'Investment/Saving';
            }
            else if(recordtypename == 'Recruiting CANADA'){
                recordtypename = 'Recruiting';
            }
            
            if (opp.WFG_Contact__c != null) {
                OppWrapperList.add(new OpportunityWrapper(opp, opp.WFG_Contact__r.Name, recordtypename));
            } else {
                OppWrapperList.add(new OpportunityWrapper(opp, null, recordtypename));
            }
        }
        
        return OppWrapperList;
    }
    
    @AuraEnabled
    public static List<OpportunityWrapper> getOppBasedOnRecType(String tableType, String filter, String ContactID, boolean isRecruiting){
        
        isRecruitingOpp = isRecruiting;
        return getOpportunityList(tableType, filter, ContactID);
    }
    
    @AuraEnabled
    public static List<ContactWrapper> getContBasedOnRecType(String tableType, String filter, String ContactID, String recTypeName){
        recordTypeValue = recTypeName;
        return getContactList(tableType, filter, ContactID);
    }
    
    @AuraEnabled
    public static List<WFG_Constants.ObjectTableColumns> getOppColumnBasedOnRecType(String ObjName, String tableType, boolean isRecruiting){
        isRecruitingOpp = isRecruiting;
        return getTableColumns(ObjName, tableType);
    }
    
    @AuraEnabled
    public static List<ContactWrapper> getContactList(String tableType, String filter, String ContactID) {
        
        List<ContactWrapper> ConWrapperList =  new List<ContactWrapper> ();
        List<Contact> conList = new List<Contact>();        
        
        String myQuery;

        try {

            if (tableType == 'Dashboard') {
                conList = [SELECT Id, Name, FirstName, LastName,  (SELECT Id FROM WFG_Opportunities__r 
                WHERE StageName NOT IN ( :system.Label.WFG_OpportunityStage_CloseLost, :system.label.WFG_OpportunityStage_CloseWon) AND WFG_Contact__r.WFG_Contact_Indicator__c != 'Inactive'), 
                (SELECT Id FROM Customer_Profiles__r), MailingState, Phone, WFG_CASL_Consent__c, CreatedDate FROM Contact 
                WHERE OwnerId =: userInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 5];
                
                for(Contact con : conList){
                    if(con.MailingState == 'PRC'){
                        con.MailingState = 'PR';
                    }
                }
                 
            } else {
                set<id> contactIds = new set<Id>();
                if(recordTypeValue == 'Recruiting'){
                    for(opportunity opp : [select id, WFG_Contact__c from opportunity where recordtype.Name IN (:System.Label.WFG_POP_OpportunityRecruitment, :System.Label.WFG_POP_OpportunityRecruitment_CAN) AND stageName != :system.Label.WFG_OpportunityStage_Opportunity_Lost AND OwnerId =: userInfo.getUserId()])
                    {
                        contactIds.add(opp.WFG_Contact__c);
                    }
                }
                conList = [SELECT Id, Name, FirstName, LastName, (SELECT Id FROM WFG_Opportunities__r 
                WHERE IsClosed = FALSE AND WFG_Contact__r.WFG_Contact_Indicator__c != 'Inactive'), 
                (SELECT Id FROM Customer_Profiles__r), MailingState, Phone, WFG_CASL_Consent__c, CreatedDate FROM Contact 
                WHERE OwnerId =: userInfo.getUserId() AND id NOT IN: contactIds ORDER BY CreatedDate DESC];
                
                for(Contact con : conList){
                    if(con.MailingState == 'PRC'){
                        con.MailingState = 'PR';
                    }
                }
            }
        } catch (Exception e) {
            system.debug('# Contact query Error Message ' + e.getMessage());
        }           
        try {           
            
            for(Contact objContactRecord :conList) {
                //in Contact object
                Boolean hasCustomerProfile = false;
                Integer totalOpportunities = objContactRecord.WFG_Opportunities__r.size();
                Id customerProfileId = null;
                if (objContactRecord.Customer_Profiles__r.size() > 0){
                    hasCustomerProfile = true;
                    customerProfileId = objContactRecord.Customer_Profiles__r.get(0).Id;
                }                                                
                //wrap each returned result and computed values in a wrapper class
                ContactWrapper wrappedContactRecord = new ContactWrapper(objContactRecord, totalOpportunities, customerProfileId, tableType);
                //add wrapped object to the results list
                ConWrapperList.add(wrappedContactRecord);   
            }
        } catch (Exception e) {
            system.debug('# Contact wrapper Error Message ' + e.getMessage());
        }
        
        return ConWrapperList;
    }
    
    @AuraEnabled
    public static List<ReferralWrapper> getReferralList(String tableType, String filter, String ContactID) {
        
        List<ReferralWrapper> refWrapperList =  new List<ReferralWrapper> ();
        List<WFG_Referral__c> refList = new List<WFG_Referral__c>();
        String myQuery;

        try {
            if (tableType == 'contact-detail') {
                list<WFG_Customer_Profile__C> lstCPs= new List<WFG_Customer_Profile__C>();
                set<Id> setCpId = new set<Id>();
                List<Contact> lstContact = [Select id, name,
                        (Select id, name
                        from Customer_Profiles__r)
                        FROM Contact WHere Id =: ContactID];
                for(Contact objCon : lstContact)
                {
                    if(objCon.Customer_Profiles__r != null && !objCon.Customer_Profiles__r.isEmpty())
                    {
                        lstCPs.addAll(objCon.Customer_Profiles__r);
                    }
                }
                if(lstCPs != null && !lstCPs.isEmpty())
                {
                    for(WFG_Customer_profile__c objCustProf : lstCPs)
                    {
                        setCpId.add(objCustProf.id);
                    }
                }

                refList = [SELECT Id, Name, WFG_Contact_First_Name__c, WFG_Contact_Last_Name__c, WFG_Customer_Profile__r.Name, CreatedDate, WFG_Referred_To__r.Name, WFG_Status__c 
                        FROM WFG_Referral__c WHERE WFG_Referred_By__c =: userInfo.getUserId() 
                        AND WFG_Customer_profile__r.Id IN: setCpId ORDER BY LastModifiedDate DESC];
                
            } else if (tableType == 'Dashboard') {
                refList = [SELECT Id, Name, WFG_Contact_First_Name__c, WFG_Contact_Last_Name__c, WFG_Customer_Profile__r.Name, CreatedDate, WFG_Referred_To__r.Name, WFG_Status__c 
                        FROM WFG_Referral__c WHERE WFG_Status__c IN ('Referred' , 'Rejected', 'Accepted') 
                        AND WFG_Referred_By__c =: userInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 5];

            } else if (tableType == 'All Records') {
                refList = [SELECT Id, Name, WFG_Contact_First_Name__c, WFG_Contact_Last_Name__c, WFG_Customer_Profile__r.Name, CreatedDate, WFG_Referred_To__r.Name, WFG_Status__c 
                        FROM WFG_Referral__c WHERE WFG_Referred_By__c = : userInfo.getUserId() 
                        ORDER BY LastModifiedDate DESC];
            
            }

        } catch (Exception e) {

            system.debug('# Referral query Error Message ' + e.getMessage());
        }
        
        for (WFG_Referral__c ref: refList) {
            
            refWrapperList.add(new ReferralWrapper(ref));
        }
        
        return refWrapperList;
    }

    @AuraEnabled
    public static List<CPWrapper> getCustomerProfileList(String tableType, String filter, String ContactID) {
        
        List<CPWrapper> cpWrapperList =  new List<CPWrapper> ();
        List<WFG_Customer_Profile__c> cpList = new List<WFG_Customer_Profile__c>();
        
        String myQuery;

        try {

            if (tableType == 'contact-detail') {
                set<String> setActiveReferralsStatus = WFG_Active_Referrals__c.getAll().keyset();
                cpList = [SELECT Id, Name, WFG_Status__c, CreatedDate, WFG_OwnQualifiedAssets__c, WFG_ListAccountTypes__c, 
                            WFG_Interested_in_discussing_options__c, WFG_advisors_to_contact_you__c, WFG_Consent_for_FA_Contact__c, 
                            WFG_Consent_to_pass_contact_information__c, (SELECT Id, name FROM Referrals__r WHERE WFG_Status__c IN :setActiveReferralsStatus) 
                            FROM WFG_Customer_Profile__c WHERE WFG_Contact__c = : ContactID AND WFG_Contact__r.OwnerId = : userInfo.getUserId() 
                            ORDER BY LastModifiedDate DESC, WFG_Status__c nulls last];
            
            } else {

                cpList = [SELECT Id, Name, WFG_Status__c,CreatedDate FROM WFG_Customer_Profile__c 
                        WHERE WFG_Contact__r.OwnerId = : userInfo.getUserId() ORDER BY LastModifiedDate DESC, WFG_Status__c nulls last];
            
            }
        } catch (Exception e) {
            system.debug('# my CP query Error Message: ' + e.getMessage());
        }
        
        for (WFG_Customer_Profile__c cp: cpList) {

            Boolean showReferButton = false;

            if (tableType == 'contact-detail') {

                if (cp.WFG_OwnQualifiedAssets__c == 'Yes' && cp.WFG_ListAccountTypes__c != NULL && 
                    cp.WFG_Interested_in_discussing_options__c == 'Yes' && cp.WFG_advisors_to_contact_you__c == 'Yes' && 
                    cp.WFG_Consent_for_FA_Contact__c == 'Yes' && cp.WFG_Consent_to_pass_contact_information__c == 'Yes' && 
                    cp.WFG_Status__c == 'Complete' && cp.Referrals__r.size() == 0 && isUSUser()
                    && WFG_AgentCustomerProfileDetailController.checkReferralAccess()) {

                    showReferButton = true;
                }
            }
            
            cpWrapperList.add(new CPWrapper(cp, showReferButton));
        }
        
        return cpWrapperList;
    }
    
    /*@AuraEnabled
    public static List<MyInvitationWrapper> getMyInvitationsList(String tableType, String filter, String ContactID) {
        
        List<MyInvitationWrapper> InvitationWrapperList =  new List<MyInvitationWrapper> ();
        List<Opportunity> invitationList = new List<Opportunity>();
        String myQuery;     
        try {
            Id idRecruitmentRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_POP_OpportunityRecruitment).getRecordTypeId();
            if (tableType == 'All Records') {
                invitationList = [SELECT Id,name, WFG_Contact__r.firstname, WFG_Contact__r.lastname, StageName,Invitation_sent__c,CloseDate,WFG_InvitationDate__c from Opportunity
                                  where recordtypeId =:idRecruitmentRTId and OwnerId =: userInfo.getUserId()];
            
            } 
        } catch (Exception e) {
            system.debug('# Invitation query Error Message ' + e.getMessage());
        }

        for (Opportunity inv: invitationList) 
        {
            InvitationWrapperList.add(new MyInvitationWrapper(inv));
        }
        system.debug('return statemnt:'+InvitationWrapperList.size());
        return InvitationWrapperList;
    }*/
    
     /*@AuraEnabled
    public static List<MyInvitationWrapperpoc> getMyInvitationsListPOC(String tableType, String filter, String InvitationId) {
         List<MyInvitationWrapperpoc> InvitationWrapperListPOC =  new List<MyInvitationWrapperpoc> ();
        List<Opportunity> invitationList = new List<Opportunity>();
        String myQuery;     
        try {

            if (tableType == 'All Records') {
                invitationList = [SELECT Id,name, WFG_Contact__r.firstname, WFG_Contact__r.lastname, StageName, CloseDate from Opportunity
                                  where recordtypeId = '012g00000009QNw' and OwnerId =: userInfo.getUserId() ];
            
            } 
        } catch (Exception e) {
            system.debug('# Invitation query Error Message ' + e.getMessage());
        }

        for (Opportunity inv: invitationList) 
        {
            InvitationWrapperListPOC.add(new MyInvitationWrapperpoc(inv));
        }
        return InvitationWrapperListPOC;
    }*/

    public static Boolean isUSUser(){
        
        Boolean isUSUser = false;
        String strProfileName = [SELECT Id, Name FROM Profile WHERE Id =: userInfo.getProfileId()].Name;
        List<WFG_ProfilesCountry__mdt> lstProfileCountry = [SELECT Country__c FROM WFG_ProfilesCountry__mdt WHERE MasterLabel =: strProfileName];
        
        if(!lstProfileCountry.isEmpty() && lstProfileCountry[0].Country__c == 'United States'){
           isUSUser = true; 
        }
        
        return isUSUser;
    }
    
    
    
    @AuraEnabled
    public static List<WFG_Constants.ObjectTableColumns> getTableColumns(String ObjName, String tableType) {
        
        List<WFG_Constants.ObjectTableColumns> columnList = new List<WFG_Constants.ObjectTableColumns>();
        
        if(ObjName == 'Contact') {

            if (tableType == 'choose-contact-opportunity' || tableType == 'choose-contact-customer-profile') {

                columnList.addAll(WFG_Constants.getContactLinkColumns());
                
            } else if (tableType == 'All Records') {

                columnList.addAll(WFG_Constants.getAllContactColumns());
            }
            else {
                
                columnList.addAll(WFG_Constants.getContactColumns());
            }
            
            
            
        } else if (ObjName == 'Opportunity') {
            if (tableType == 'contact-detail') {

                columnList.addAll(WFG_Constants.getOpportunityContactDetailColumns());
                
            } else {
                
                columnList.addAll(WFG_Constants.getOpportunityColumns());
                
            }
            
        } else if (ObjName == 'Referral') {
            
            if (tableType == 'contact-detail') {

                columnList.addAll(WFG_Constants.getReferralContactDetailColumns());

            } else {

                columnList.addAll(WFG_Constants.getReferralColumns());

            }
        } else if (ObjName == 'CustomerProfile') {

            if (tableType == 'contact-detail') {

                columnList.addAll(WFG_Constants.getCustomerProfileContactDetailColumns());

            } else {

                columnList.addAll(WFG_Constants.getCustomerProfileColumns());

            }

            
        }
        /*else if (ObjName == 'MyInvitations'){
            columnList.addAll(WFG_Constants.getMyInvitationsColumns());
        }*/
        /*else if (ObjName == 'MyInvitationsPOC'){
            columnList.addAll(WFG_Constants.getMyInvitationsColumnsPOC());
        }*/
        
        else if(ObjName == 'Lead'){
            columnList.addAll(WFG_Constants.getLeadColumns());
        }
        
        return columnList;
    }

        //POP Lead functionality
    
    
    @AuraEnabled
    public static List<LeadWrapper> getLeadList(String tableType, String filter, String ContactID) {
        List<LeadWrapper> leadListWrapper =  new List<LeadWrapper> ();
        List<Lead> leadList = new List<Lead>();   
        system.debug('+++ tabletype +' + tableType);
        system.debug('+++ table  size intial+' + leadList.size());
        if (tableType == 'Dashboard') {
            leadList = [SELECT Id, Email, Name,FirstName,WFG_CASL_Consent__c, LastName, Status, Phone, CreatedDate FROM Lead WHERE IsConverted = false AND Status = 'Qualified' AND OwnerId =: userInfo.getUserId() LIMIT 5];     
        }
        else{
            List<Lead> qualifiedLeads = new List<Lead>();
            List<Lead> nonQualifiedLeads = new List<Lead>();
            for(Lead objLead : [SELECT Id, Email, Name,FirstName, WFG_CASL_Consent__c, LastName, Status, Phone, CreatedDate FROM Lead WHERE IsConverted = false AND OwnerId =: userInfo.getUserId() ORDER BY Name ASC]){
                if(objLead.Status == 'Qualified'){
                    qualifiedLeads.add(objLead);
                }   
                else{
                    nonQualifiedLeads.add(objLead);
                }
            }
            leadList.addAll(qualifiedLeads);
            leadList.addAll(nonQualifiedLeads);
        }
        system.debug('+++ table  size Processed +' + leadList.size());
        for(Lead objLeadRecord :leadList) {
                LeadWrapper wrappedLeadRecord = new LeadWrapper(objLeadRecord);
                leadListWrapper.add(wrappedLeadRecord);   
        }
        return leadListWrapper;
    }  



    public static String formatPhone(String Phone) {
      string nondigits = '[^0-9]';
      string PhoneDigits;
        if(Phone != null) {
          // remove all non numeric
          PhoneDigits = Phone.replaceAll(nondigits,'');
          
          // 10 digit: reformat with dashes
          if (PhoneDigits.length() == 10) 
            return '(' + PhoneDigits.substring(0,3) + ') ' +
                   PhoneDigits.substring(3,6) + '-' +
                   PhoneDigits.substring(6,10);
          // 11 digit: 
          if (PhoneDigits.length() == 11) {
            if (PhoneDigits.substring(0,1) == '1') {
              //if starts with 1, format as 10 digit 
              return  '(' + PhoneDigits.substring(1,4) + ') ' +
                      PhoneDigits.substring(4,7) + '-' +
                      PhoneDigits.substring(7,11);
            }
            else{
              //otherwise, format as 11 digit
              return  '+' +
                      PhoneDigits.substring(0,1) + ' (' + 
                      PhoneDigits.substring(1,4) + ') ' +
                      PhoneDigits.substring(4,7) + '-' +
                      PhoneDigits.substring(7,11);
            }
          }
      }
      return( Phone );
    }
    
    public class ContactWrapper {        
        // Global variables
        @AuraEnabled public String chevron;
        @AuraEnabled public String name;
        @AuraEnabled public String fName;
        @AuraEnabled public String lName;
        @AuraEnabled public Integer numberOpportunities;
        @AuraEnabled public String customerProfile;
        @AuraEnabled public String state;
        @AuraEnabled public String phone;
        @AuraEnabled public String contactId;
        @AuraEnabled public String contactLink;
        @AuraEnabled public String caslConsent;
        
        public ContactWrapper(Contact contact, Integer totalOpportunities, Id customerProfileId, String tableType) { 
            string hasCP = 'No';
            string currentURL;
            if(customerProfileId != null) hasCP = 'Yes';
            name = contact.Name.trim();
            fName = contact.FirstName != NULL && !String.isBlank(contact.FirstName) ? contact.FirstName.trim() : '';
            lName = contact.LastName.trim();
            //numberOpportunities = string.valueof(totalOpportunities);
            numberOpportunities = totalOpportunities;
            customerProfile = hasCP;
            phone = formatPhone(contact.Phone);
            state = contact.MailingState;
            caslConsent = contact.WFG_CASL_Consent__c; 
            //caslConsent = 'AAAA';
            contactId = contact.Id;
            /*if (forCustomerProfile != NULL && forCustomerProfile && customerProfileId != null){
                contactLink = '/Sales/s/wfg-customer-profile/' + customerProfileId;
            }
            else if (forCustomerProfile != NULL && forCustomerProfile){
                contactLink = '/Sales/s/create-customer-profile?contactId=' + contact.Id ;
            } else */
            if (tableType == 'choose-contact-opportunity') {
            /*W-021888 : Redirection to Previouos Page -     
            //Find the URL of the cuurent page & send it as a parameter to the new page
               currentURL = ApexPages.currentPage().getUrl();
               this.contactLink = '/Sales/s/create-opportunity?contactId=' + contact.Id + '&recordId=' + contact.Id + '&retURL=' + currentURL ;
            */
                this.contactLink = '/Sales/s/create-opportunity?contactId=' + contact.Id + '&recordId=' + contact.Id; 
                if(WFG_CommunityDashboardController.recordTypeValue != NULL && WFG_CommunityDashboardController.recordTypeValue != ''){
                    this.contactLink += '&recordType='+WFG_CommunityDashboardController.recordTypeValue;
                }
                
            } else if (tableType == 'choose-contact-customer-profile') {

                this.contactLink = '/Sales/s/create-customer-profile?recordId=' + contact.Id + '&contactId=' + contact.Id;
                
            }
            else{
                contactLink = '/Sales/s/contact/' + contact.Id;
            }
            chevron = '>';
            
        }
    }
    
    public class OpportunityWrapper {        
        // Global variables
        @AuraEnabled public String chevron;
        @AuraEnabled public String name;
        @AuraEnabled public String contactName;
        @AuraEnabled public Decimal amount;
        @AuraEnabled public String type;
        @AuraEnabled public String stage;
        @AuraEnabled public String opportunityId;
        @AuraEnabled public String opportunityLink;
        @AuraEnabled public List<String> optRecordTypeList;
        @AuraEnabled public string oppCloseDate;
        @AuraEnabled public String isLicensed;
        
        public OpportunityWrapper(Opportunity oppt, String contactName, String recTypeName) { 
            this.name = oppt.Name.trim();
            this.contactName = contactName;
            this.amount = oppt.Amount;
            this.type = recTypeName;
            this.stage = oppt.StageName;
            this.opportunityId = oppt.Id;
            this.opportunityLink = '/Sales/s/create-opportunity?Id=' + oppt.Id;
            if(WFG_CommunityDashboardController.isRecruitingOpp != NULL && WFG_CommunityDashboardController.isRecruitingOpp){
                this.isLicensed = oppt.Is_the_person_licensed__c;
                if(oppt.CloseDate != NULL)
                    this.oppCloseDate = oppt.CloseDate.format();
            }
            this.chevron = '>';
            
        }
    }
    
    public class ReferralWrapper {        
        // Global variables
        @AuraEnabled public String chevron;
        @AuraEnabled public String name;
        @AuraEnabled public String cDate;
        @AuraEnabled public String contactName;
        @AuraEnabled public String customerProfileName;
        @AuraEnabled public String referredTo;
        @AuraEnabled public String status;
        @AuraEnabled public String referralId;
        @AuraEnabled public String referralLink;
        
        public ReferralWrapper(WFG_Referral__c ref) { 
            this.name = ref.Name;
            this.contactName = ref.WFG_Contact_First_Name__c + ' ' + ref.WFG_Contact_Last_Name__c;
            this.customerProfileName = ref.WFG_Customer_Profile__r.Name;
            this.referredTo = ref.WFG_Referred_To__r.Name;
            //this.cDate = String.valueOf(date.newinstance(ref.CreatedDate.year(), ref.CreatedDate.month(), ref.CreatedDate.day()));
            if(UserInfo.getLocale() == 'en_CA'){
            this.cDate = ref.CreatedDate.format('dd/MM/yyyy') ; 
            }
            else
            {
            this.cDate = ref.CreatedDate.format('MM/dd/yyyy') ; 
            }           
            this.status = ref.WFG_Status__c;
            this.referralId = ref.Id;
            this.referralLink = '/Sales/s/referral-detail?id=' + ref.Id;
            this.chevron = '>';
            
        }
    }

    public class CPWrapper {        
        // Global variables
        @AuraEnabled public String chevron;
        @AuraEnabled public String name;
        @AuraEnabled public String cDate;
        @AuraEnabled public String status;
        @AuraEnabled public String cpId;
        @AuraEnabled public String cpLink;
        @AuraEnabled public String referButton;
        
        public CPWrapper(WFG_Customer_Profile__c cp, Boolean showReferButton) { 
            this.name = cp.Name;
            //this.cDate = String.valueOf(date.newinstance(cp.CreatedDate.year(), cp.CreatedDate.month(), cp.CreatedDate.day()));
            if(UserInfo.getLocale() == 'en_CA'){
            this.cDate = cp.CreatedDate.format('dd/MM/yyyy') ;
            }
            else{
            this.cDate = cp.CreatedDate.format('MM/dd/yyyy') ;
            }
            this.status = cp.WFG_Status__c;
            this.cpId = cp.Id;
            this.cpLink = '/Sales/s/refer-customer-profile?recordId=' + cp.Id;
            this.chevron = '>';
            if (showReferButton == true) {
                this.referButton = 'Refer';
            } else {
                this.referButton = null;
            }
            
            
        }
    }
    
    /*public class MyInvitationWrapper {        
        // Global variables
        @AuraEnabled public String chevron;        
        @AuraEnabled public String fName;
        @AuraEnabled public String lName;        
        @AuraEnabled public String invitationId;
        @AuraEnabled public string invitationLink;
        //@AuraEnabled public Date inviteDate;
        @AuraEnabled public String inviteDate;
        @AuraEnabled public String status;
        @AuraEnabled public Decimal inviteSent;
        
        
        public MyInvitationWrapper(Opportunity invitation) { 
            System.debug('##########MyInvitationWrapper#############');
            System.debug(invitation.Id);
            List<Task> tasks = [select id from task where whatId in(select id from opportunity where id =:invitation.Id)];
            system.debug('Inv' + tasks.Size());
            fName = invitation.WFG_Contact__r.firstname;
            lName = invitation.WFG_Contact__r.lastname;
            inviteDate =invitation.WFG_InvitationDate__c.format('MMM dd, yyyy hh:mm a');

            inviteSent = tasks.Size();
            System.debug('contact Id = ' + invitation.WFG_Contact__r.Id);
            status = invitation.stagename;
            invitationId = invitation.Id;
            invitationLink = '/Prospects/s/invitation-details?recordId=' + invitationId;
            chevron = '>';
           
        }
    } */
    
    /*public class MyInvitationWrapperpoc {        
        // Global variables
        @AuraEnabled public String chevron;        
        @AuraEnabled public String fName;
        @AuraEnabled public String lName;        
        @AuraEnabled public String invitationId;
        @AuraEnabled public string invitationLink;
        @AuraEnabled public Date inviteDate;
        @AuraEnabled public String status;
        @AuraEnabled public Decimal inviteSent;
        
        
        public MyInvitationWrapperpoc(Opportunity invitation) { 
            
            
            fName = invitation.WFG_Contact__r.firstname;
            lName = invitation.WFG_Contact__r.lastname;
            inviteDate = invitation.closedate;
            inviteSent= 1;
            status = invitation.stagename;
            invitationId = invitation.Id;
            chevron = '>';
            if(UserInfo.getLocale() == 'en_CA'){
            inviteDate = invitation.INVITE_DATE__c.format('dd/MM/yyyy') ; 
            }
            else
            {
            this.inviteDate = invitation.INVITE_DATE__c.format('MM/dd/yyyy') ; 
            }  
            
        }
    }      
*/
    
    public class LeadWrapper {        
        // Global variables
        @AuraEnabled public String chevron;
        @AuraEnabled public String name;
        @AuraEnabled public String fName;
        @AuraEnabled public String lName;
        @AuraEnabled public String phone;
        @AuraEnabled public String email;
        @AuraEnabled public String leadstatus;
        @AuraEnabled public String createddate;
        @AuraEnabled public String leadId;
        @AuraEnabled public String caslConsent;
        
        
        public LeadWrapper(Lead objLead) { 
            this.name = objLead.Name;
            this.fName = objLead.FirstName;
            this.lName = objLead.LastName;
            this.phone = objLead.Phone;
            this.email = objLead.Email;
            this.leadstatus = objLead.Status;            
           
            if(UserInfo.getLocale() == 'en_CA'){
            this.createddate = objLead.CreatedDate.format('dd/MM/yyyy');
            this.caslConsent = objLead.WFG_CASL_Consent__c;
            }
            else{
            this.createddate = objLead.CreatedDate.format('MM/dd/yyyy');
            } 
            
            this.leadId = objLead.Id;
            this.chevron = '>';
            
        }
    }
    
    
    
}