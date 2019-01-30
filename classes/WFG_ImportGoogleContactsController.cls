public class WFG_ImportGoogleContactsController {
    
    public WFG_ImportGoogleContactsController(ApexPages.StandardSetController controller) {
        
    }
    
    public static void sendEmailUpdate(list<lead> leadFailed, list<Lead> listLeadSucceeded){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        String userName = UserInfo.getUserName();
        User loginUser = [Select Email From User where Username = : userName limit 1];
        String userEmail = loginUser.Email;
        System.debug('---userEmail---'+userEmail);
       // if(!leadFailed.isEmpty()){
            message.toAddresses = new String[] { userEmail };
                message.subject = 'Import Contact from Google';
            message.plainTextBody = 'Following Leads are inserted '+listLeadSucceeded +'\n'+'Following Leads are Failed '+leadFailed;
            Messaging.SingleEmailMessage[] messages = 
                new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } 
            else {
                System.debug('The email failed to send: '
                             + results[0].errors[0].message);
            }
      //  }
    }
    
    public static PageReference importContact(){
        String googleClientId = Label.WFG_GoogleClientId;
        String googleSecret = Label.WFG_GoogleSecret;
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        String redirectURI = sfdcBaseURL+'/apex/WFG_ImportGoogleContacts';
        String codeParam = ApexPages.currentPage().getParameters().get('code');
        
        if(codeParam==null){
            String contactScope = 'https://www.googleapis.com/auth/contacts.readonly';
            String parameters = 'client_id='+googleClientId+'&redirect_uri='+redirectURI+'&scope='+contactScope+'&access_type=offline&include_granted_scopes=true&response_type=code&prompt=consent';
            String codeEndPoint='https://accounts.google.com/o/oauth2/v2/auth?'+parameters;
            system.debug('========codeEndPoint======'+codeEndPoint);
            PageReference pageRef = new PageReference(codeEndPoint);
            pageRef.setRedirect(true);
            return pageRef;
        }else{
            String params = 'code='+codeParam+'&client_id='+googleClientId+'&client_secret='+googleSecret+'&redirect_uri='+redirectURI+'&grant_type=authorization_code';
            String tokenEndPoint = 'https://www.googleapis.com/oauth2/v4/token';
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(tokenEndPoint);
            request.setBody(params);
            request.setMethod('POST');
            request.setHeader('Content-Length', '512');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setTimeout(12000);
            system.debug('======request======='+request);
            HttpResponse response = http.send(request);
            
            String jsonSr = response.getBody();
            WFG_GoogleTokenWrapper deserJson = (WFG_GoogleTokenWrapper)JSON.deserialize(jsonSr, WFG_GoogleTokenWrapper.class);
            
            if(deserJson.access_token!=null){
                String contactApi = 'https://www.google.com/m8/feeds/contacts/default/full/';
                String contactEndPoint = contactApi+'?access_token='+deserJson.access_token;
                Http httpCon = new Http();
                HttpRequest requestCon = new HttpRequest();
                requestCon.setEndpoint(contactEndPoint);
                requestCon.setMethod('GET');
                HttpResponse responseCon = httpCon.send(requestCon);
                System.debug('Res:'+responseCon);
                System.debug('Response Con:'+responseCon.getBody());
                string res = responseCon.getBody();
                
                insertLeads(responseCon.getBody());
                
                String hostname = URL.getSalesforceBaseUrl().getHost();
                String mydomain = hostname.substring(0, hostname.indexOf('--c'));
                String redirectURL = 'https://' + mydomain + '.lightning.force.com/one/one.app';
                
                PageReference returnURL = new PageReference(redirectURL);
                returnURL.setRedirect(true);
                return returnURL;
            }
        }
        return null;
    }
    
    public static void insertLeads(String xmlResponse){
        Dom.Document doc = new Dom.Document();
        doc.load(xmlResponse);
        STring googleName = null;
        String phoneNumber = null;
        String strEmail = null;
        
        Dom.XMLNode googleResponse = doc.getRootElement();
        List<Lead> lstLeadtoInsert = new List<Lead>();
        String delimiter = ' ';
        for(Dom.XMLNode childEntryCon : googleResponse.getChildren()) {
            if(childEntryCon.getName()== 'entry'){
                Lead objLead = new Lead();
                for(Dom.XMLNode entryElements : childEntryCon.getChildren()){
                    if(entryElements.getName()=='title'){
                        googleName = entryElements.getText();
                        if(googleName.containsWhitespace()){
                            objLead.firstName= googleName.substringBefore(delimiter);
                            objLead.LastName = googleName.substringAfter(delimiter);
                        }else{
                        	objLead.firstName= googleName;
                            objLead.LastName = googleName;
                        }
                    }
                    
                    if(entryElements.getName()=='phoneNumber'){
                        phoneNumber = entryElements.getText();
                        objLead.Phone = phoneNumber;
                    }
                    
                    if(entryElements.getName()=='email'){
                        strEmail = entryElements.getAttribute('address', '');
                        objLead.Email = strEmail;
                    } 
                    objLead.LeadSource= 'Google Sync';
                    objLead.company= 'EVRY';
                }
                lstLeadtoInsert.add(objLead);
            }
        }
        
        List<lead> lstLeadSuccess = new List<Lead>();
        List<lead> lstLeadFailed = new List<Lead>();
        if(!lstLeadtoInsert.isEmpty()){
            string strErr='';
            Database.upsertResult[] lstLeadIns = Database.upsert(lstLeadtoInsert, false);
            integer intVar = 0;
            integer intFailedRecCount = 0;
            for (Database.upsertResult objSvres : lstLeadIns) 
            {
                if (!objSvres.isSuccess()) 
                {  
                    intFailedRecCount ++;
                    string strErrors = '';  
                    for(Database.Error objError : objSvres.getErrors()) 
                    {
                        system.debug('====objError===='+objError);
                        strErrors += objError.getStatusCode() + ' : ' + objError.getMessage();
                    } 
                    strErr +=lstLeadtoInsert[0].Lastname +' '+strErrors;
                    lstLeadfailed.add(lstLeadtoInsert[intVar]);
                }
                else
                {
                    lstLeadSuccess.add(lstLeadtoInsert[intVar]);
                }
                intVar ++ ;
            }
            system.debug('Following lead were successful '+lstLeadSuccess.size());
            system.debug('Following lead were failed '+intFailedRecCount);
        }
        sendEmailUpdate(lstLeadFailed, lstLeadSuccess);
    }
}