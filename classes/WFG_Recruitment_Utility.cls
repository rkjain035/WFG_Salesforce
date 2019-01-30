public with sharing class WFG_Recruitment_Utility 
{
    public class WFG_OpportunityWrapp
    {
        @AuraEnabled
        public Opportunity objOpp;
        
        @AuraEnabled
        public boolean boolIsError;
        
        @AuraEnabled
        public string strError; 
    }
    public static WFG_OpportunityWrapp getRecruitmentOpportunity(Opportunity objOpp, Id idContact)
    {
        WFG_OpportunityWrapp objOppWrapp = new WFG_OpportunityWrapp();
        try
        {
            if(objOpp.WFG_Contact__c == null) objOpp.WFG_Contact__c = idContact;
            
            
            system.debug('@@@ for opt creation ->'+objOpp.Description + '  Locale -> ' + UserInfo.getLocale());
            Id recRecordTypeId;
            
            if(UserInfo.getLocale() == 'en_CA'){
            	recRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(system.Label.WFG_POP_OpportunityRecruitment_CAN).getRecordTypeId();
            	//recRecordTypeId = '012g00000009Z3gAAE';
            }
            else{
            	recRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(system.Label.WFG_POP_OpportunityRecruitment).getRecordTypeId();
        	}
            
            system.debug('recordtypeID ->'+ recRecordTypeId);
            
            objOpp.recordtypeID = recRecordTypeId;
            objOpp.Stagename = 'Business Presentation';

            insert objOpp;
            
            objOppWrapp.objOpp = objOpp;
            objOppWrapp.boolIsError = false;
            objOppWrapp.strError = '';
            return objOppWrapp;
        }
        catch(Exception e)
        {
            objOppWrapp.boolIsError = true;
            objOppWrapp.strError =  e.getMessage();
            objOppWrapp.objOpp = null;
            return objOppWrapp;
        }
            
    }    
}