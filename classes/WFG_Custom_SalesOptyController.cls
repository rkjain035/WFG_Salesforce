public class WFG_Custom_SalesOptyController {
	
    @AuraEnabled private Map<String,String> recordTypeToId {get;set;}
	@AuraEnabled private LIST<Opportunity> salesOpty {get;set;}
    @AuraEnabled private boolean isUSorPR {get;set;}
    @AuraEnabled private string country {get;set;}
    
    @AuraEnabled
    public static WFG_Custom_SalesOptyController fetchRecordTypes()
    {
        WFG_Custom_SalesOptyController wfgSalesOptyController = new WFG_Custom_SalesOptyController();
        
        LIST<Schema.RecordTypeInfo> recordTypes = Opportunity.SObjectType.getDescribe().getRecordTypeInfos();
        wfgSalesOptyController.recordTypeToId = new Map<String,String>();
        for(RecordTypeInfo rt :  recordTypes)
        {
            
           if((rt.getName() == 'Insurance' || rt.getName() == 'Investment/Savings') && rt.isAvailable() )
           { 
              wfgSalesOptyController.recordTypeToId.put(rt.getName(),''+rt.getRecordTypeId());
           }
        }
        
        wfgSalesOptyController.salesOpty = [select id, name, CloseDate, owner.Country from Opportunity 
                              where 
                              ownerId=: UserInfo.getUserId() and RecordType.name = 'Insurance' 
                              order by CloseDate desc limit 3];
        
        wfgSalesOptyController.country = wfgSalesOptyController.salesOpty[0].owner.Country;
        if(wfgSalesOptyController.country == 'US' || wfgSalesOptyController.country == 'PR')
           wfgSalesOptyController.isUSorPR = true;
        
        return wfgSalesOptyController;
    }
    
    @AuraEnabled
    public static String getSalesOptyListViewID()
    {
        return [select id from ListView where SObjectType = 'Opportunity' and DeveloperName = 'My_Sales_Opportunities'].Id;
    }
}