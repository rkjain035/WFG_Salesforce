@isTest
global class WFG_AD03_MockInterfcae implements HttpCalloutMock  
{
   // Implement this interface method
    global HTTPResponse respond(HTTPRequest objRequest) 
    {
        // Create a fake response
        Map<string,WFG_Integration_Utility_Setup__c> mapCustset = WFG_Integration_Utility_Setup__c.getAll();
        if(mapCustset != null && !mapCustset.keyset().isEmpty() 
        	&& mapCustset.containskey('AD03')
        	&& mapCustset.get('AD03') != null)
        {
        	HttpResponse res = new HttpResponse();
	        res.setHeader('Content-Type', mapCustset.get('AD03').WFG_ContentType__c);
	        res.setBody('{\"Agents\" : [ {\"ReferredBy_AgentCode\" : \"1300W\",\"FA_AgentCode\" : \"V9319\",\"FA_Name\" : \"HAECKEL, STEPHEN\",\"FA_Address\" : \"ST PETERSBURG, FL\",\"FA_Phone\" : \"(860) 227-8557\",\"FA_Email\" : \"\"}, {\"ReferredBy_AgentCode\" : \"1300W\",\"FA_AgentCode\" : \"0135B\",\"FA_Name\" : \"LsEWIS, JOSEPH\",\"FA_Address\" : \"ST PETERSBURG, FL\",\"FA_Phone\" : \"(727) 244-1340\",\"FA_Email\" : \"\"} ]}');
	        res.setStatusCode(200);
	        return res;
        }
        return null;
    }
}