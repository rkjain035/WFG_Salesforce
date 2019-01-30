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
Girish                  Mod-03          08/01/2018                  W-027449
Rashmi                  Mod-04          31/07/2018                  W-027449 - Wrote a method to fetch the spotlight video based on country 
and to show it in the dashboard based on logged in launch user country.
*/

public with sharing class WFG_Launch_Training_Controller {
    
    /**
* This method returns the list of launch training datacategory list
* @throws - N/A
* @author Saravanan
* @date 06-01-2018
*/
    @AuraEnabled
    public static list<WFG_Launch_Training__kav> getTrainingCategory(){
        
        try{            
            //Fetching profile name to pass it to the Training query.
            user usrCurr = [select id, WFG_Launch_Base_URL__c, Profile.Name from user where id =: userinfo.getUserId() limit 1];
            string strProfileName = usrCurr.Profile.Name;       
            List<WFG_Launch_Training__kav> lstDataCategories = new List<WFG_Launch_Training__kav>();  
            //Fetching document record from document object.
            Document objdocuments = [SELECT Id,Name FROM Document WHERE Name like '%Thumbnail%' LIMIT 1];
            string strBaseURL =  usrCurr.WFG_Launch_Base_URL__c +'servlet/servlet.ImageServer?id='+objdocuments.Id+'&oid='+UserInfo.getOrganizationId();    
            //Fetching Training and Datacategory related records from Article object using relationship query.
            List<WFG_Launch_Training__kav> lstTraining =[SELECT id, title,Summary, articleNumber, WFG_Launch_Duration__c, WFG_Launch_Profiles__c, WFG_Launch_Status__c, WFG_Launch_Thumbnail_Image__c, WFG_Launch_Video_URL__c,(select DataCategoryName from DataCategorySelections) FROM WFG_Launch_Training__kav where WFG_Launch_Profiles__c includes (: strProfileName) AND WFG_Launch_Status__c = true];
            system.debug('parent to child'+lstTraining);             
            //Looping over Article object to check if thumbnail image is proper
            // and assigning standard wfg image if no image is available
            // and adding training related data to lstDataCategories list.
            for(WFG_Launch_Training__kav category:lstTraining){                        
                if(category.WFG_Launch_Thumbnail_Image__c != NULL && category.WFG_Launch_Thumbnail_Image__c.contains('<img')){                    
                    category.WFG_Launch_Thumbnail_Image__c = category.WFG_Launch_Thumbnail_Image__c.substringBetween('<img', 'img>').substringBetween('src="', '"').replace('amp;', '');
                }
                else{
                    system.debug('entering else');
                    category.WFG_Launch_Thumbnail_Image__c = strBaseURL;                              
                }                    
                lstDataCategories.add(category);     
            }                                   
            return lstDataCategories; 
        }catch(Exception e)
        {
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_Launch_Training_Controller', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
            return null;
        }
        
    }   
    
    /**
* This method gets the existing spotlight video to be displayed in Dashboard
* @throws - N/A
* @author Rashmi
* @date 08-01-2018
*/
    @AuraEnabled
    public static WFG_Launch_Training__kav getVideoInfo(){
        
        try{
            
            //Fetching document record from document object.
            Document objdocuments = [SELECT Id,Name FROM Document WHERE Name like '%Thumbnail%' LIMIT 1];
            user usrCurr = [select id, WFG_Launch_Base_URL__c from user where id =: userinfo.getUserId()];            
            string strBaseURL = usrCurr.WFG_Launch_Base_URL__c +'servlet/servlet.ImageServer?id='+objdocuments.Id+'&oid='+UserInfo.getOrganizationId();
            system.debug('---' + Network.getNetworkId());
            system.debug('===' + Network.getLoginUrl(Network.getNetworkId()));
            //fetches the profilename of the loggedin user user for fetching the training spotlight record based on the country
            String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
            string strSpotlight = '';
            if(profileName.contains('US')){
                strSpotlight = 'US';
            }
            else if(profileName.contains('CAN')){
                strSpotlight = 'CAN';
            }
            WFG_Launch_Training__kav objSpotlightVideo = new WFG_Launch_Training__kav();
            
            //queries and stores the knowledge article record which is enabled for spotlight based on the country
            list<WFG_Launch_Training__kav> lstSpotlightVideo = [select title,Summary, articleNumber,WFG_Launch_Duration__c, WFG_Launch_Profiles__c, WFG_Launch_Status__c, WFG_Launch_Thumbnail_Image__c, WFG_Launch_Video_URL__c,(select DataCategoryName from DataCategorySelections) FROM WFG_Launch_Training__kav WHERE WFG_Launch_Status__c = true AND WFG_Launch_Profiles__c includes (: profileName) AND WFG_Launch_Spotlight_Video__c INCLUDES (:strSpotlight) LIMIT 1];
            
            if(lstSpotlightVideo.isEmpty()){
                
                list<WFG_Launch_Training__kav> lstRecentSpotlight = [select title,Summary, articleNumber,WFG_Launch_Duration__c, WFG_Launch_Profiles__c, WFG_Launch_Status__c, WFG_Launch_Thumbnail_Image__c, WFG_Launch_Video_URL__c,(select DataCategoryName from DataCategorySelections) FROM WFG_Launch_Training__kav WHERE WFG_Launch_Status__c = true AND  WFG_Launch_Profiles__c includes (: profileName) ORDER BY createddate desc LIMIT 1];
                if(!lstRecentSpotlight.isEmpty())
                    objSpotlightVideo = lstRecentSpotlight[0];
            }
            else{
                objSpotlightVideo = lstSpotlightVideo[0];
            }
            if(objSpotlightVideo.WFG_Launch_Thumbnail_Image__c != NULL && objSpotlightVideo.WFG_Launch_Thumbnail_Image__c.contains('<img'))
                objSpotlightVideo.WFG_Launch_Thumbnail_Image__c = objSpotlightVideo.WFG_Launch_Thumbnail_Image__c.substringBetween('<img', 'img>').substringBetween('src="', '"').replace('amp;', '');
            else
                objSpotlightVideo.WFG_Launch_Thumbnail_Image__c = strBaseURL;
            return objSpotlightVideo;
            
        }catch(Exception e)
        {
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_Launch_Training_Controller', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
            return null;
        }
    }
    
       
    /**
* This method updates the existing spotlight video article when new spotlight video is configured by Admin
* @throws - N/A
* @author Girish
* @date 08-01-2018
*/
    @InvocableMethod
    public static void updateSpotlightVideo(List<String> lstIds){
        
        try{            
            //Fetch the list of existing articles which are configured as Spotlight videos
            List<WFG_Launch_Training__kav> lstExistingSpotlightVideos = new List<WFG_Launch_Training__kav>( [select id,WFG_Launch_Spotlight_Video__c,PublishStatus,knowledgearticleId from WFG_Launch_Training__kav where PublishStatus='Online' and WFG_Launch_Spotlight_Video__c!=null] );
            
            //Fetch the current article which is being configured as Spotlight video by Admin
            List<WFG_Launch_Training__kav> lstCurrentSpotlightVideo =[SELECT id, title,WFG_Launch_Spotlight_Video__c, KnowledgeArticleId, WFG_Launch_Video_URL__c FROM WFG_Launch_Training__kav where id in :lstIds limit 1];                        
            List<WFG_Launch_Training__kav> lstSpotlightToUpdate = new List<WFG_Launch_Training__kav>();
            
            //Fetch the existing soptlight articles to be updated by comparing existing published articles & current article
            for(WFG_Launch_Training__kav objCurrentSpotlight : lstCurrentSpotlightVideo){                
                if(!lstExistingSpotlightVideos.isEmpty()){
                    for(WFG_Launch_Training__kav objExistingSpotlight : lstExistingSpotlightVideos){
                        if(objCurrentSpotlight.WFG_Launch_Spotlight_Video__c=='US'){
                            if(objExistingSpotlight.WFG_Launch_Spotlight_Video__c=='US' && objExistingSpotlight.KnowledgeArticleId != objCurrentSpotlight.KnowledgeArticleId){
                                objExistingSpotlight.WFG_Launch_Spotlight_Video__c=null;
                                lstSpotlightToUpdate.add(objExistingSpotlight);
                            }else if(objExistingSpotlight.WFG_Launch_Spotlight_Video__c=='US;CAN' && objExistingSpotlight.KnowledgeArticleId != objCurrentSpotlight.KnowledgeArticleId){
                                objExistingSpotlight.WFG_Launch_Spotlight_Video__c='CAN';
                                lstSpotlightToUpdate.add(objExistingSpotlight);
                            }
                        }else if(objCurrentSpotlight.WFG_Launch_Spotlight_Video__c=='CAN'){
                            if(objExistingSpotlight.WFG_Launch_Spotlight_Video__c=='CAN' && objExistingSpotlight.KnowledgeArticleId != objCurrentSpotlight.KnowledgeArticleId){
                                objExistingSpotlight.WFG_Launch_Spotlight_Video__c=null;
                                lstSpotlightToUpdate.add(objExistingSpotlight);
                            }else if(objExistingSpotlight.WFG_Launch_Spotlight_Video__c=='US;CAN' && objExistingSpotlight.KnowledgeArticleId != objCurrentSpotlight.KnowledgeArticleId){
                                objExistingSpotlight.WFG_Launch_Spotlight_Video__c='US';
                                lstSpotlightToUpdate.add(objExistingSpotlight);
                            } 
                        }else if(objCurrentSpotlight.WFG_Launch_Spotlight_Video__c=='US;CAN'){
                            if(objExistingSpotlight.KnowledgeArticleId != objCurrentSpotlight.KnowledgeArticleId && (objExistingSpotlight.WFG_Launch_Spotlight_Video__c=='US' ||objExistingSpotlight.WFG_Launch_Spotlight_Video__c=='CAN'||objExistingSpotlight.WFG_Launch_Spotlight_Video__c=='US;CAN')){
                                objExistingSpotlight.WFG_Launch_Spotlight_Video__c=null;
                                lstSpotlightToUpdate.add(objExistingSpotlight);
                            }
                        } 
                    }
                }
            }  
            
            if(!lstSpotlightToUpdate.isEmpty()){
                //unpublish the existing article to enable to update
                List<String> lstDraftArticleIds = new List<String>();
                for(WFG_Launch_Training__kav objSpotlightToUpdate:lstSpotlightToUpdate){
                    lstDraftArticleIds.add(KbManagement.PublishingService.editOnlineArticle(objSpotlightToUpdate.KnowledgeArticleId, true));
                }
                
                //Get the ids of unpublished version of articles
                List<WFG_Launch_Training__kav> lstArticlesToPublish = [SELECT id,title,KnowledgeArticleId,PublishStatus,Summary,articleNumber,WFG_Launch_Spotlight_Video__c FROM WFG_Launch_Training__kav where id in :lstDraftArticleIds and publishStatus='Draft'];
                
                for(WFG_Launch_Training__kav objArticleToPublish:lstArticlesToPublish){
                    for(WFG_Launch_Training__kav objSpotlightToUpdate:lstSpotlightToUpdate){
                        if(objArticleToPublish.KnowledgeArticleId==objSpotlightToUpdate.KnowledgeArticleId){
                            objArticleToPublish.WFG_Launch_Spotlight_Video__c = objSpotlightToUpdate.WFG_Launch_Spotlight_Video__c;
                        }
                    }
                }
                //update the unpublished version of articles
                Database.update(lstArticlesToPublish,false);
                
                //publish the updates
                for(WFG_Launch_Training__kav objDraftArticle:lstArticlesToPublish){
                    KbManagement.PublishingService.publishArticle(objDraftArticle.KnowledgeArticleId, true); 
                }
            }
            
            String strCurrentSpotlightVal = lstCurrentSpotlightVideo[0].WFG_Launch_Spotlight_Video__c;
            //Fetch the list of existing articles which are drafted as Spotlight videos, but not published
            List<WFG_Launch_Training__kav> lstDraftedSpotlightVideos = new List<WFG_Launch_Training__kav>( [select id,WFG_Launch_Spotlight_Video__c,PublishStatus,knowledgearticleId from WFG_Launch_Training__kav where PublishStatus='Draft' and WFG_Launch_Spotlight_Video__c!=null and id not in :lstIds] );
            List<WFG_Launch_Training__kav> lstSpotightToDraft = new List<WFG_Launch_Training__kav>();
            if(!lstDraftedSpotlightVideos.isEmpty()){
                for(WFG_Launch_Training__kav objDraftedSpotlight:lstDraftedSpotlightVideos){
                    if(strCurrentSpotlightVal=='US'){
                        if(objDraftedSpotlight.WFG_Launch_Spotlight_Video__c=='US'){
                            objDraftedSpotlight.WFG_Launch_Spotlight_Video__c=null;
                            lstSpotightToDraft.add(objDraftedSpotlight);
                        }else if(objDraftedSpotlight.WFG_Launch_Spotlight_Video__c=='US;CAN'){
                            objDraftedSpotlight.WFG_Launch_Spotlight_Video__c='CAN';
                            lstSpotightToDraft.add(objDraftedSpotlight);
                        }
                    }else if(strCurrentSpotlightVal=='CAN'){
                        if(objDraftedSpotlight.WFG_Launch_Spotlight_Video__c=='CAN'){
                            objDraftedSpotlight.WFG_Launch_Spotlight_Video__c=null;
                            lstSpotightToDraft.add(objDraftedSpotlight);
                        }else if(objDraftedSpotlight.WFG_Launch_Spotlight_Video__c=='US;CAN'){
                            objDraftedSpotlight.WFG_Launch_Spotlight_Video__c='US';
                            lstSpotightToDraft.add(objDraftedSpotlight);
                        }
                    }else if(strCurrentSpotlightVal=='US;CAN'){
                        if(objDraftedSpotlight.WFG_Launch_Spotlight_Video__c=='US' || objDraftedSpotlight.WFG_Launch_Spotlight_Video__c=='CAN' || objDraftedSpotlight.WFG_Launch_Spotlight_Video__c=='US;CAN'){
                            objDraftedSpotlight.WFG_Launch_Spotlight_Video__c=null;
                            lstSpotightToDraft.add(objDraftedSpotlight);
                        }
                    }
                }
                //Update the draft articles by removing spotlight config of current article
                Database.update(lstSpotightToDraft,false);
            }
            
        }catch(Exception e)
        {
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_Launch_Training_Controller', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
            
        }
    }
}