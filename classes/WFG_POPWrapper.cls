public class WFG_POPWrapper {
    @AuraEnabled
    public boolean boolIsError=false;
    
    @AuraEnabled
    public sObject objectName;
    
    @AuraEnabled
    public string strErrorMessage   ;
    
    @AuraEnabled
    public string strSuccessMessage;
    
    @AuraEnabled
    public string recordId;
    
    public contact convertedContact;
}