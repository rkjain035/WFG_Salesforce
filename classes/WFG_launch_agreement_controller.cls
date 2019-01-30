public without sharing class WFG_launch_agreement_controller {
    @AuraEnabled
    public static String loggedInUserAgentCode()
    {
        //string test = [select WFG_Agent_Code__c from user where id=:userinfo.getuserid()].WFG_Agent_Code__c;
        //system.debug('inside agreement controller for agentcode=' + test);
        //system.debug('inside agreement controller for userid=' + userinfo.getuserid());
        return [select WFG_Agent_Code__c from user where id=:userinfo.getuserid()].WFG_Agent_Code__c;
    }
}