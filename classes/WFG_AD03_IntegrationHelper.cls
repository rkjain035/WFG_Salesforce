public with sharing class WFG_AD03_IntegrationHelper 
{
    public static WFG_ReferralResponseWrapper invokeCallout(WFG_AD03_AgentRequestWrapper objReq)
    {
        
        WFG_ReferralResponseWrapper objResWrap = new WFG_ReferralResponseWrapper();
        List<WFG_AD03_AgentsResponseWrapper> lstRes = new List<WFG_AD03_AgentsResponseWrapper>();
        string strResJSON = '';
        string strResBody = '';
        try
        {
            if(objReq != null)
            {
                system.debug('req----'+objReq);
                strResJSON = JSON.serialize(objReq);
                //Get integration custom setting information
                Map<string,WFG_Integration_Utility_Setup__c> mapCustset = WFG_Integration_Utility_Setup__c.getAll();
                if(mapCustset != null && !mapCustset.keyset().isEmpty()
                    && mapCustset.containskey('AD03')
                    && mapCustset.get('AD03') != null)
                {
                    //Creating HTTP request
                    HttpRequest objRequest = new HttpRequest();
                    objRequest.setMethod(mapCustset.get('AD03').WFG_Integration_Method__c);
                    objRequest.setEndpoint(mapCustset.get('AD03').WFG_EndPoint_URL__c);
                    objRequest.setHeader('content-type' , mapCustset.get('AD03').WFG_ContentType__c);
                    objRequest.setHeader('charset' , 'UTF-8');
                    objRequest.setBody(strResJSON);
                    objRequest.setClientCertificateName(mapCustset.get('AD03').WFG_Authentication_Provider__c);
                    system.debug('### Cert user is  : ' +  mapCustset.get('AD03').WFG_Authentication_Provider__c);
                    Http objHttp = new Http();
                    system.debug('### REQUEST : ' +  objRequest);
                    system.debug('### REQUEST Body : ' +  objRequest.getBody());
                    system.debug('### REQUEST header content type : ' +  objRequest.getHeader('content-type'));
                    
                    HTTPResponse objRes = objHttp.send(objRequest);
                    
                    system.debug('### RESPONSE : ' +  objRes.getbody());
                    strResBody = objRes.getbody();
                    JSONParser parser = JSON.createParser(objRes.getbody());
                    boolean isSuccess=false;
                    while (parser.nextToken() != null)
                    {
                        if (parser.getText() == 'agents')
                        {
                            // Get the value.
                            parser.nextValue();
                            lstres = 
                               (List<WFG_AD03_AgentsResponseWrapper>)parser.readValueAs(
                                  List<WFG_AD03_AgentsResponseWrapper>.class);
                            for(WFG_AD03_AgentsResponseWrapper objREs1 : lstres)
                            {
                                objREs1.boolIsSelect = false;
                            }
                            isSuccess = true;
                            break;
                        }
                    }
                    parser = JSON.createParser(objRes.getbody());
                    
                    if(!isSuccess)
                    {
                        while (parser.nextToken() != null)
                        {
                            
                            WFG_AD03_AgentsResponseWrapper objResErr = (WFG_AD03_AgentsResponseWrapper)parser.readValueAs(
                                WFG_AD03_AgentsResponseWrapper.class);
                                if(objResErr.status != '200')
                                {
                                    //objResWrap.objGenericRes.boolIsError = true;
                                    //objResWrap.objGenericRes.strErrorMessage = objResErr.error;
                                }
                                LogUtility.createLogs('Integration', 
                                                'ERROR', 
                                                'WFG_Customer_Profile__C', 
                                                'Apex Class', 
                                                'WFG_AD03_IntegrationHelper',
                                                 objResErr.status, 
                                                 objResErr.error,
                                                 strResJSON + objRes.getbody(),
                                                 'REST',
                                                 'Response',
                                                 true);
                            break;
                        }
                    }
                }
            }
            //return lstRes;
            objResWrap.objRefSelectfWrap.lstResWrapp = lstRes;
            return objResWrap;
        }
        catch (Exception e)
        {
            objResWrap.objGenericRes.boolIsError = true;
            objResWrap.objGenericRes.strErrorMessage = e.getMEssage();
            LogUtility.createLogs('Integration', 
                    'ERROR', 
                    'WFG_Customer_Profile__C', 
                    'Apex Class', 
                    'WFG_AD03_IntegrationHelper',
                     'Fail', 
                     objResWrap.objGenericRes.strErrorMessage,
                     strResJSON + strResBody,
                     'REST',
                     'Response',
                     true);
            return objResWrap;
        }
    }   
}