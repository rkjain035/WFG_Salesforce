public with sharing class WFG_Constants {
    public WFG_Constants (){}

    // All the fields for SOQL
    public static List<String> CONTACTFIELDLIST = new List<String>{'Name', 'OwnerId', 'MailingState', 'Phone', 'WFG_CASL_Consent__c'};
    public static List<String> LEADFIELDLIST = new List<String>{'FirstName', 'LastName', 'Phone', 'Email', 'Status'};
    public static List<String> OPPORTUNITYFIELDLIST = new List<String>{'Name', 'OwnerId', 'Amount', 'Type', 'StageName'};
    public static List<String> TASKFIELDLIST = new List<String>{'Subject', 'ActivityDate'};
    public static List<String> CUSTOMERPROFILEFIELDLIST = new List<String>{'Name', 'CreatedDate'};
    
    
    // All the fields for showing on the table
    public static List<String> OPPORTUNITYFIELDS = new List<String>{'SobjectItem.Name', 'OwnerName', 'SobjectItem.Amount', 'SobjectItem.Type', 'SobjectItem.Status'};
    public static List<String> CONTACTFIELDS = new List<String>{'SobjectItem.FirstName','SobjectItem.LastName', 'SobjectItem.NumOfOpportunity', 'SobjectItem.HasCustomerProfile', 'SobjectItem.MailingState', 'SobjectItem.Phone', 'SobjectItem.WFG_CASL_Consent__c'};
    public static List<String> LEADTFIELDS = new List<String>{'SobjectItem.FirstName','SobjectItem.LastName', 'SobjectItem.Email', 'SobjectItem.Status','SobjectItem.Id'};
    public static List<String> TASKFIELDS = new List<String>{'SobjectItem.Subject', 'SobjectItem.ActivityDate'};
    public static List<String> CUSTOMERPROFILEFIELDS = new List<String>{'SobjectItem.Name', 'SobjectItem.CreatedDate'};
    //public static List<String> MYINVITATIONSFIELDS = new List<String>{'SobjectItem.WFG_Contact__r.firstname', 'SobjectItem.WFG_Contact__r.lastname','SobjectItem.WFG_InviataionDate__c','SobjectItem.Invitation_sent__c','SobjectItem.Stagename'};
    //public static List<String> MYINVITATIONSFIELDSPOC = new List<String>{'SobjectItem.WFG_Contact__r.firstname', 'SobjectItem.WFG_Contact__r.lastname','SobjectItem.closedate','SobjectItem.INVITES_SENT__c','SobjectItem.Stagename'};

    // All the Columns title
    public static List<String> OPPORTUNITYTITLES = new List<String>{'Name', 'Contact', 'Value', 'Type', 'Status'};
    public static List<String> CONTACTTITLES = new List<String>{'First Name', 'Last Name', 'Number Of Opportunities', 'Customer Profile?', 'State', 'Phone', 'View', 'CASL Consent'};
    public static List<String> TASKTITLES = new List<String>{'Name', 'Due Date'};
    public static List<String> CUSTOMERPROFILETITLES = new List<String>{'Name', 'Date'};
    //public static List<String> MYINVITATIONSTITLES = new List<String>{'First Name', 'Last Name','Invite Date','Invites Sent','Status'};
    //public static List<String> MYINVITATIONSTITLESPOC = new List<String>{'First Name', 'Last Name','Invite Date','Invites Sent','Status'};

    public static List<String> OPPORTUNITYCOLUMS = new List<String>{'Name', 'Contact', 'Value', 'Type', 'Status'};
    public static List<String> CONTACTCOLUMNS = new List<String>{'First Name', 'Last Name', 'Number Of Opportunities', 'Customer Profile?', 'State', 'Phone', 'View'};
    //public static List<String> MYINVITATIONSCOLUMNS = new List<String>{'First Name', 'Last Name','Invite Date','Invites Sent','Status'};
    //public static List<String> MYINVITATIONSCOLUMNSPOC = new List<String>{'First Name', 'Last Name','Invite Date','Invites Sent','Status'};    
    
    public static List<ObjectTableColumns> getContactLinkColumns() {

        List<ObjectTableColumns> columnList = new List<ObjectTableColumns>();

        columnList.add(new ObjectTableColumns('Name', 'name', 'String', ''));
        columnList.add(new ObjectTableColumns('# of Opportunities', 'numberOpportunities', 'Integer', ''));
        columnList.add(new ObjectTableColumns('Customer Profile?', 'customerProfile', 'String', ''));
        columnList.add(new ObjectTableColumns('State', 'state', 'String', ''));
        columnList.add(new ObjectTableColumns('Phone', 'phone', 'String', ''));
        if(userInfo.getLocale()=='en_CA')
            columnList.add(new ObjectTableColumns('CASL Consent', 'caslConsent', 'String', ''));
        columnList.add(new ObjectTableColumns('', 'chevron', 'url', 'contactLink'));

        return columnList;
    }

    public static List<ObjectTableColumns> getContactColumns() {

        List<ObjectTableColumns> columnList = new List<ObjectTableColumns>();

        columnList.add(new ObjectTableColumns('Name', 'name', 'String', ''));
        columnList.add(new ObjectTableColumns('# of Opportunities', 'numberOpportunities', 'Integer', ''));
        columnList.add(new ObjectTableColumns('Customer Profile?', 'customerProfile', 'String', ''));
        columnList.add(new ObjectTableColumns('State', 'state', 'String', ''));
        columnList.add(new ObjectTableColumns('Phone', 'phone', 'String', ''));
        if(userInfo.getLocale()=='en_CA')
        columnList.add(new ObjectTableColumns('CASL Consent', 'caslConsent', 'String', ''));
        columnList.add(new ObjectTableColumns('', 'chevron', 'reference', 'contactId'));

        return columnList;
    }

    public static List<ObjectTableColumns> getAllContactColumns() {

        List<ObjectTableColumns> columnList = new List<ObjectTableColumns>();
        ObjectTableColumns nameCol = new ObjectTableColumns('Name', 'name', 'String', '');
        nameCol.width = '1';
        columnList.add(nameCol);
        columnList.add(new ObjectTableColumns('First Name', 'fName', 'String', ''));
        columnList.add(new ObjectTableColumns('Last Name', 'lName', 'String', ''));
        columnList.add(new ObjectTableColumns('# of Opportunities', 'numberOpportunities', 'Integer', ''));
        columnList.add(new ObjectTableColumns('Customer Profile?', 'customerProfile', 'String', ''));
        columnList.add(new ObjectTableColumns('State', 'state', 'String', ''));
        columnList.add(new ObjectTableColumns('Phone', 'phone', 'String', ''));
        if(userInfo.getLocale()=='en_CA')
        columnList.add(new ObjectTableColumns('CASL Consent', 'caslConsent', 'String', ''));
        columnList.add(new ObjectTableColumns('', 'chevron', 'reference', 'contactId'));

        return columnList;
    }

    public static List<ObjectTableColumns> getOpportunityColumns() {

        List<ObjectTableColumns> columnList = new List<ObjectTableColumns>();

        columnList.add(new ObjectTableColumns('Name', 'name', 'String', ''));
        if(WFG_CommunityDashboardController.isRecruitingOpp != NULL && WFG_CommunityDashboardController.isRecruitingOpp){
            columnList.add(new ObjectTableColumns('Close Date', 'oppCloseDate', 'String', ''));
            columnList.add(new ObjectTableColumns('Is Licensed', 'isLicensed', 'String', ''));
        } else {
            columnList.add(new ObjectTableColumns('Contact', 'contactName', 'String', ''));
            columnList.add(new ObjectTableColumns('Amount', 'amount', 'currency', ''));
            columnList.add(new ObjectTableColumns('Type', 'type', 'String', ''));
        }
        columnList.add(new ObjectTableColumns('Stage', 'stage', 'String', ''));
        columnList.add(new ObjectTableColumns('', 'chevron', 'reference', 'opportunityId'));

        return columnList;
    }

    public static List<ObjectTableColumns> getOpportunityContactDetailColumns() {

        List<ObjectTableColumns> columnList = new List<ObjectTableColumns>();

        columnList.add(new ObjectTableColumns('Name', 'name', 'String', ''));
        columnList.add(new ObjectTableColumns('Amount', 'amount', 'currency', ''));
        columnList.add(new ObjectTableColumns('Type', 'type', 'String', ''));
        columnList.add(new ObjectTableColumns('Stage', 'stage', 'String', ''));
        columnList.add(new ObjectTableColumns('', 'chevron', 'reference', 'opportunityId'));

        return columnList;
    }

    public static List<ObjectTableColumns> getReferralColumns() {

        List<ObjectTableColumns> columnList = new List<ObjectTableColumns>();

        columnList.add(new ObjectTableColumns('Referral Name', 'name', 'String', ''));
        columnList.add(new ObjectTableColumns('Customer Profile Name', 'customerProfileName', 'String', ''));
        columnList.add(new ObjectTableColumns('Date', 'cDate', 'String', ''));
        columnList.add(new ObjectTableColumns('Contact', 'contactName', 'String', ''));
        columnList.add(new ObjectTableColumns('Referred To', 'referredTo', 'String', ''));
        columnList.add(new ObjectTableColumns('Status', 'status', 'String', ''));
        columnList.add(new ObjectTableColumns('', 'chevron', 'reference', 'referralId'));

        return columnList;
    }

    public static List<ObjectTableColumns> getReferralContactDetailColumns() {

        List<ObjectTableColumns> columnList = new List<ObjectTableColumns>();

        columnList.add(new ObjectTableColumns('Referral Name', 'name', 'String', ''));
        columnList.add(new ObjectTableColumns('Date', 'cDate', 'String', ''));
        columnList.add(new ObjectTableColumns('Status', 'status', 'String', ''));
        columnList.add(new ObjectTableColumns('', 'chevron', 'reference', 'referralId'));

        return columnList;
    }

    public static List<ObjectTableColumns> getCustomerProfileColumns() {

        List<ObjectTableColumns> columnList = new List<ObjectTableColumns>();

        columnList.add(new ObjectTableColumns('Name', 'name', 'String', ''));
        columnList.add(new ObjectTableColumns('Status', 'status', 'String', ''));
        columnList.add(new ObjectTableColumns('Date', 'cDate', 'String', ''));
        columnList.add(new ObjectTableColumns('', 'chevron', 'reference', 'cpId'));

        return columnList;
    }
     
    /*public static List<ObjectTableColumns> getMyInvitationsColumns() {

        List<ObjectTableColumns> columnList = new List<ObjectTableColumns>();

        columnList.add(new ObjectTableColumns('First Name', 'fName', 'String', ''));
        columnList.add(new ObjectTableColumns('Last Name', 'lName', 'String', ''));
        columnList.add(new ObjectTableColumns('Invite Date', 'inviteDate', 'Date', ''));
        columnList.add(new ObjectTableColumns('Invite Sent', 'inviteSent', 'String', ''));
        columnList.add(new ObjectTableColumns('Status', 'status', 'String', ''));
        columnList.add(new ObjectTableColumns('', 'chevron', 'url', 'invitationLink'));

        return columnList;
    }*/
       /*public static List<ObjectTableColumns> getMyInvitationsColumnsPOC() {

        List<ObjectTableColumns> columnList = new List<ObjectTableColumns>();

        columnList.add(new ObjectTableColumns('First Name', 'fName', 'String', ''));
        columnList.add(new ObjectTableColumns('Last Name', 'lName', 'String', ''));
        columnList.add(new ObjectTableColumns('Invite Date', 'inviteDate', 'String', ''));
         columnList.add(new ObjectTableColumns('Invite Sent', 'inviteSent', 'String', ''));
         columnList.add(new ObjectTableColumns('Status', 'status', 'String', ''));
        columnList.add(new ObjectTableColumns('', 'chevron', 'reference', 'invitationLink'));

        return columnList;
    }*/

    public static List<ObjectTableColumns> getCustomerProfileContactDetailColumns() {

        List<ObjectTableColumns> columnList = new List<ObjectTableColumns>();

        columnList.add(new ObjectTableColumns('Name', 'name', 'String', ''));
        columnList.add(new ObjectTableColumns('Status', 'status', 'String', ''));
        columnList.add(new ObjectTableColumns('Date', 'cDate', 'String', ''));
        columnList.add(new ObjectTableColumns('', 'referButton', 'url', 'cpLink'));
        columnList.add(new ObjectTableColumns('', 'chevron', 'reference', 'cpId'));

        return columnList;
    }

    //@Nitesh, have done this jusr for POC of 8a sprint. if this is fine then remove this comment and use the below code.
    public static List<ObjectTableColumns> getLeadColumns() {

        List<ObjectTableColumns> columnList = new List<ObjectTableColumns>();

        //columnList.add(new ObjectTableColumns('Name', 'name', 'String', ''));
        columnList.add(new ObjectTableColumns('First Name', 'fName', 'String', ''));
        columnList.add(new ObjectTableColumns('Last Name', 'lName', 'String', ''));
        columnList.add(new ObjectTableColumns('Phone', 'phone', 'String', ''));
        columnList.add(new ObjectTableColumns('Email', 'email', 'String', ''));
        columnList.add(new ObjectTableColumns('Lead Status', 'leadstatus', 'String', ''));
        columnList.add(new ObjectTableColumns('Created Date', 'createddate', 'String', ''));
        if(userInfo.getLocale()=='en_CA'){
            columnList.add(new ObjectTableColumns('CASL Consent', 'caslConsent', 'String', ''));
        }
        columnList.add(new ObjectTableColumns('', 'chevron', 'reference', 'leadId'));

        //columnList.add(new ObjectTableColumns('', 'deleteButton', 'url', 'leadLink'));
        return columnList;
    }



    // For WFG_ObjectWrapperList.ObjectWrapper columns

    /*public static List<ObjectTableColumns> getContactColumns() {

        List<ObjectTableColumns> columnList = new List<ObjectTableColumns>();

        columnList.add(new ObjectTableColumns('Name', 'SobjectItem.Name', 'String', 'Id'));
        columnList.add(new ObjectTableColumns('Number Of Opportunities', 'NumOfOpportunity', 'String', ''));
        columnList.add(new ObjectTableColumns('Customer Profile?', 'HasCustomerProfile', 'String', ''));
        columnList.add(new ObjectTableColumns('State', 'SobjectItem.MailingState', 'String', ''));
        columnList.add(new ObjectTableColumns('Phone', 'SobjectItem.Phone', 'String', ''));
        columnList.add(new ObjectTableColumns('View', 'SobjectItem.Email', 'String', ''));

        return columnList;
    }

    public static List<ObjectTableColumns> getOpportunityColumns() {

        List<ObjectTableColumns> columnList = new List<ObjectTableColumns>();

        columnList.add(new ObjectTableColumns('Name', 'SobjectItem.Name', 'String', ''));
        columnList.add(new ObjectTableColumns('Contact', 'OwnerName', 'String', ''));
        columnList.add(new ObjectTableColumns('Value', 'SobjectItem.Amount', 'String', ''));
        columnList.add(new ObjectTableColumns('Type', 'SobjectItem.Type', 'String', ''));
        columnList.add(new ObjectTableColumns('Status', 'SobjectItem.Status', 'String', ''));
        //columnList.add(new ObjectTableColumns('>', 'SobjectItem.Id', 'url', 'www.google.com'));

        return columnList;
    }

    public static List<ObjectTableColumns> getTaskColumns() {

        List<ObjectTableColumns> columnList = new List<ObjectTableColumns>();

        columnList.add(new ObjectTableColumns('Name', 'SobjectItem.Subject', 'String', 'Id'));
        columnList.add(new ObjectTableColumns('Due Date', 'SobjectItem.ActivityDate', 'String', ''));

        return columnList;
    }*/


    public class ObjectTableColumns {
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public String type {get;set;}
        @AuraEnabled public String value {get;set;}
        @AuraEnabled public String width {get;set;}
        @AuraEnabled public String target {get;set;}
        @AuraEnabled public Id recId{get;set;}
        //@AuraEnabled public String href {get;set;}
    

        public ObjectTableColumns(String Label, String Name, String Type, String Value) {

            this.label = Label;
            this.name = Name;
            this.type = Type;
            this.value = Value;
            this.width = null;
            this.target = '_self';
           
        }

    }
}