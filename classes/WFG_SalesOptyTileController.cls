/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2018] Transamerica Corporation, its affiliates and their licensors.
* @author Deepthi
* @date 05-08-2018
* @description - Class for custom Sales Opty tile in FSC Homepage

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Rahul Jain               Mod-01             05-08-2018              UserStoryNo - W-026161, W-026151
Hampesh                  Mod-02             08-17-2018              UserStoryNo - W-026061
Hampesh                  Mod-03             09-21-2018              UserStoryNo - W-026152
*/
public with sharing class WFG_SalesOptyTileController {
    
    @AuraEnabled private Map<String,String> recordTypeToId {get;set;}
    @AuraEnabled private LIST<Opportunity> salesOpty {get;set;}
    @AuraEnabled private boolean isUSorPR {get;set;}
    @AuraEnabled private boolean isCanada {get;set;}
    @AuraEnabled private string country {get;set;}
    
    @AuraEnabled
    public static WFG_SalesOptyTileController fetchRecordTypes()
    {
        WFG_SalesOptyTileController wfgSalesOptyController = new WFG_SalesOptyTileController();
        
        LIST<Schema.RecordTypeInfo> recordTypes = Opportunity.SObjectType.getDescribe().getRecordTypeInfos(); 
        // fetches all the opportunity record type from the org level.
        
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
                              ownerId=: UserInfo.getUserId() 
                              and 
                              (RecordType.name = 'Insurance' or RecordType.name = 'Investment/Savings')
                              order by CloseDate asc limit 3];
        
        if(wfgSalesOptyController.salesOpty.size() > 0)
        {
            wfgSalesOptyController.country = wfgSalesOptyController.salesOpty[0].owner.Country;
            if(wfgSalesOptyController.country == 'US' || wfgSalesOptyController.country == 'PR')
            wfgSalesOptyController.isUSorPR = true; // for the date formats

            if(wfgSalesOptyController.country == 'CA')
            wfgSalesOptyController.isCanada = true; // for the date formats
        }
        
        return wfgSalesOptyController;
    }
    
    @AuraEnabled
    public static String getSalesOptyListViewID(string listviewName)
    {
      if(listviewName =='sales'){
        return [select id from ListView where SObjectType = 'Opportunity' and DeveloperName = 'My_Sales_Opportunities'].Id;
      }
      else if(listviewName =='onboarding'){
        return [select id from ListView where SObjectType = 'Opportunity' and DeveloperName = 'Onboarding_Opportunities'].Id;
      }
      else if(listviewName =='recruitment'){
        return [select id from ListView where SObjectType = 'Opportunity' and DeveloperName = 'Recruiting_Opportunities'].Id;
      }
      
      return null;
    }
   
   /**
    @author Hampesh
    @date 17-Aug-2018
    @description Collects the list of Onboarding/Recruiting opportunity
    @Return WFG_SalesOptyTileController insatnce with records of Onboarding/Recruiting opportunity
    */
    
    @AuraEnabled
    public static WFG_SalesOptyTileController fetchOppRecords(string oppType)
    {
    
        String userCountry=[select country from user where id=:userinfo.getuserId()].country;
        WFG_SalesOptyTileController wfgSalesOptyController = new WFG_SalesOptyTileController();
        
        LIST<Schema.RecordTypeInfo> recordTypes = Opportunity.SObjectType.getDescribe().getRecordTypeInfos(); 
        // fetches all the opportunity record type from the org level.
        
        wfgSalesOptyController.recordTypeToId = new Map<String,String>();
        
        
         if(oppType =='Onboarding'){
              wfgSalesOptyController.salesOpty = [select id, name, CloseDate, owner.Country, WFG_CloseDaysRemainingDisplay__c from Opportunity 
                                  where 
                                  ownerId=: UserInfo.getUserId() 
                                  and 
                                  (RecordType.developername= 'Onboarding' or RecordType.developername= 'Onboarding_CANADA')
                                  order by CloseDate asc limit 3];
                
           }
           
           if(oppType =='Recruiting'){
               system.debug('country--'+userCountry);
               wfgSalesOptyController.salesOpty = [select id, name, CloseDate, owner.Country from Opportunity 
                                  where 
                                  ownerId=: UserInfo.getUserId() 
                                  and 
                                  (RecordType.developername= 'Recruitment' or RecordType.developername= 'Recruitment_CANADA')
                                  order by CloseDate asc limit 3];
                                  
                      for(RecordTypeInfo rt :recordTypes){
                         
                        if((userCountry =='US' || userCountry =='PR' ) && (rt.getdeveloperName() == 'Recruitment') && (rt.isAvailable()) ){ 
                             
                             wfgSalesOptyController.recordTypeToId.put(rt.getName(),''+rt.getRecordTypeId());
                        }
                        
                        if(userCountry =='CA' && rt.getdeveloperName() == 'Recruitment_CANADA' && rt.isAvailable() ){
                              
                             wfgSalesOptyController.recordTypeToId.put(rt.getName(),''+rt.getRecordTypeId());
                        }
                        
                     }
           }
        
        if(wfgSalesOptyController.salesOpty.size() > 0)
        {
            wfgSalesOptyController.country = wfgSalesOptyController.salesOpty[0].owner.Country;
            if(wfgSalesOptyController.country == 'US' || wfgSalesOptyController.country == 'PR')
            wfgSalesOptyController.isUSorPR = true; // for the date formats

            if(wfgSalesOptyController.country == 'CA')
            wfgSalesOptyController.isCanada = true; // for the date formats
        }
        
        return wfgSalesOptyController;
        
    }
  
    
}