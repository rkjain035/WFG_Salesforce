global class ConnectedAppPluginSSO  extends Auth.ConnectedAppPlugin
{

    // Return a user application data
    global override Map<String,String> customAttributes(Id userId, Id connectedAppId, Map<String,String>
        formulaDefinedAttributes, Auth.InvocationContext context)        
    { 
        //string uid = UserInfo.getUserId();
        //User user = [select Id,ApplicationData__c from User where id=:userId];
        
        SSO_ApplicationData__c[] ssoDataList = [SELECT ApplicationData__c
                                                    FROM SSO_ApplicationData__c WHERE Provider__c='firelight' and UserId__c=:userId order by LastModifiedDate desc];
        if(ssoDataList.size()>0) {
                formulaDefinedAttributes.put('SSO_NB', ssoDataList[0].ApplicationData__c);
            }
        else
        {
            formulaDefinedAttributes.put('SSO_NB', '');
        }
        
        //String appdata = user.ApplicationData__c;
        return formulaDefinedAttributes;    
    }

}