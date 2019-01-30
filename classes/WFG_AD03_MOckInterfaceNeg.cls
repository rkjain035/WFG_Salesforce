@isTest
global class WFG_AD03_MOckInterfaceNeg implements HttpCalloutMock  
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
	        res.setBody('{\"status\":\"500\",\"error\":\"some Issue in the int\"}');
	        res.setStatusCode(200);
	        return res;
        }
        return null;
    }
}