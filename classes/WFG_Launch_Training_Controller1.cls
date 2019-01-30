/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Saravanan Haldurai
* @date 06-01-2018
* @description  Controller class for Lightning component in the training Screen of WFG Launch

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Sarvanan                Mod-01          06/01/2018                  W-026549
Deepthi Narayanappa     Mod-02          06/11/2018                  W-026549
*/

public with sharing class WFG_Launch_Training_Controller1 {
    
    /**
* This method returns the list of launch training datacategory list
* @throws - N/A
* @author Saravanan
* @date 06-01-2018
*/
    @AuraEnabled
    public static list<WFG_Launch_Training__kav> getTrainingCategory(){
        
        //Fetching profile name to pass it to the Training query.
        string strProfileName = [select id, profile.Name from user where id =: userinfo.getuserId() limit 1].Profile.Name;        
        List<WFG_Launch_Training__kav> lstDataCategories = new List<WFG_Launch_Training__kav>();  
        //Fetching document record from document object.
        Document objdocuments = [SELECT Id,Name FROM Document WHERE Name like '%Thumbnail%' LIMIT 1];
        system.debug('profilename = '+strProfileName);
        //Fetching salesforce base url and splitting string to get only required url.
        string strBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        system.debug('==baseurl1=='+strBaseURL);
        list<string> lstUrl = strBaseURL.split('force.');
        system.debug('==baseurl2=='+lstUrl[0]);
        strBaseURL = lstUrl[0]+'content.force.com/servlet/servlet.FileDownload?file='+objdocuments.Id;    
        //Fetching Training and Datacategory related records from Article object using relationship query.
        List<WFG_Launch_Training__kav> lstTraining =[SELECT id, title,Summary, articleNumber, WFG_Launch_Duration__c, WFG_Launch_Profiles__c, WFG_Launch_Status__c, WFG_Launch_Thumbnail_Image__c, WFG_Launch_Video_URL__c,(select DataCategoryName from DataCategorySelections) FROM WFG_Launch_Training__kav where WFG_Launch_Profiles__c includes (: strProfileName) AND WFG_Launch_Status__c = true];
        system.debug('parent to child'+lstTraining); 
        
        //Looping over Article object to check if thumbnail image is proper
        // and assigning standard wfg image if no image is available
        // and adding training related data to lstDataCategories list.
        for(WFG_Launch_Training__kav category:lstTraining){                        
            if(category.WFG_Launch_Thumbnail_Image__c != NULL && category.WFG_Launch_Thumbnail_Image__c.contains('<img'))
                category.WFG_Launch_Thumbnail_Image__c = category.WFG_Launch_Thumbnail_Image__c.substringBetween('<img', 'img>').substringBetween('src="', '"').replace('amp;', '');
            else
                category.WFG_Launch_Thumbnail_Image__c = strBaseURL;
            system.debug('==URL=='+category.WFG_Launch_Thumbnail_Image__c);
            lstDataCategories.add(category); 
        }                                   
        return lstDataCategories;   
    }   
    
      @AuraEnabled
    public static WFG_Launch_Training__kav getVideoInfo(){
        
        string strBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        string strSpotlight = '';
        if(profileName.contains('US')){
            strSpotlight = 'US';
        }
        else if(profileName.contains('CAN')){
            strSpotlight = 'CAN';
        }
        WFG_Launch_Training__kav objSpotlightVideo = new WFG_Launch_Training__kav();
        list<WFG_Launch_Training__kav> lstSpotlightVideo = [select title,Summary, articleNumber,WFG_Launch_Duration__c, WFG_Launch_Profiles__c, WFG_Launch_Status__c, WFG_Launch_Thumbnail_Image__c, WFG_Launch_Video_URL__c,(select DataCategoryName from DataCategorySelections) FROM WFG_Launch_Training__kav WHERE WFG_Launch_Status__c = true AND WFG_Launch_Spotlight_Video__c INCLUDES (:strSpotlight) LIMIT 1];
        
        if(lstSpotlightVideo.isEmpty())
            objSpotlightVideo = [select title,Summary, articleNumber,WFG_Launch_Duration__c, WFG_Launch_Profiles__c, WFG_Launch_Status__c, WFG_Launch_Thumbnail_Image__c, WFG_Launch_Video_URL__c,(select DataCategoryName from DataCategorySelections) FROM WFG_Launch_Training__kav WHERE WFG_Launch_Status__c = true LIMIT 1];
        else
            objSpotlightVideo = lstSpotlightVideo[0];
        if(objSpotlightVideo.WFG_Launch_Thumbnail_Image__c != NULL && objSpotlightVideo.WFG_Launch_Thumbnail_Image__c.contains('<img'))
            objSpotlightVideo.WFG_Launch_Thumbnail_Image__c = objSpotlightVideo.WFG_Launch_Thumbnail_Image__c.substringBetween('<img', 'img>').substringBetween('src="', '"').replace('amp;', '');
        else
            objSpotlightVideo.WFG_Launch_Thumbnail_Image__c = strBaseURL;
        system.debug('==URL=='+objSpotlightVideo.WFG_Launch_Thumbnail_Image__c);
        system.debug('======objSpotlightVideo======='+objSpotlightVideo);
        return objSpotlightVideo;
    } 
    
}