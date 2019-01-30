public class WFG_Agent_PreLicense_Education {
	@AuraEnabled 
    public Boolean visibleKaplan = TRUE;
    @AuraEnabled 
    public Boolean visibleADBanker = TRUE;
    @AuraEnabled 
    public Boolean visibleExamFX = TRUE;
    @AuraEnabled 
    public Boolean visibleOliver = TRUE;
    @AuraEnabled 
    public Boolean visibleiVari = TRUE;
    @AuraEnabled 
    public string urlKaplan = '';
    @AuraEnabled 
    public string urlADBanker = '';
    @AuraEnabled 
    public string urlExamFX = '';
    @AuraEnabled 
    public string urlOliver = '';
    @AuraEnabled 
    public string urliVari = '';
    @AuraEnabled 
    public string urlCampaignManger = '';
    
    
    /**
    * This method sets SSO links visibility.
    * @return - N/A.
    * @throws - N/A
    * @author DHunter
    * @date 04-05-2017
    */
    public void setEducationLinks() {
        try
        {
            String agentCode = RunningUserCtrl.getCurrentUser().WFG_Agent_Code__c;
            //construct the url
            try
            {
                //Get the custom settings for WFG_SSO_Links 
            	WFG_SSO_Links__c SSOLinkSAML = WFG_SSO_Links__c.getValues('WFG_SSO_BaseSAML');
                WFG_SSO_Links__c SSOLink = WFG_SSO_Links__c.getValues('WFG_SSO_Base');
            	this.urlKaplan = (String)SSOLinkSAML.Url__c + '16' + '&AgentCode=' + agentCode;
                this.urlADBanker = (String)SSOLinkSAML.Url__c + '20' + '&AgentCode=' + agentCode;
                this.urlExamFX = (String)SSOLink.Url__c + '21' + '&AgentCode=' + agentCode;
                this.urlOliver = (String)SSOLinkSAML.Url__c + '23' + '&AgentCode=' + agentCode;
                this.urliVari = (String)SSOLink.Url__c + '25' + '&AgentCode=' + agentCode;
                this.urlCampaignManger = (String)SSOLink.Url__c + '26' + '&AgentCode=' + agentCode;
              }
            catch(Exception e)
            {
                this.urlKaplan = e.getMessage();
                this.urlADBanker = e.getMessage();
                this.urlExamFX = e.getMessage();
                this.urlOliver = e.getMessage();
                this.urliVari = e.getMessage();
                this.urlCampaignManger = e.getMessage();
            }
            String strProfileName = [SELECT Id, Name FROM Profile WHERE Id =: userInfo.getProfileId()].Name;
            System.debug('strProfileName: ' + strProfileName);
            if(strProfileName.toUpperCase().contains('CAN'))
            {
                visibleKaplan = false;
                visibleADBanker = false;
                visibleExamFX = false;
            }
            else
            {
                visibleOliver = false;
                visibleiVari = false;
            }
        }
        catch(Exception e)
        {
            System.debug('setEducationLinks error: ' + e.getMessage());
        }
  }
}