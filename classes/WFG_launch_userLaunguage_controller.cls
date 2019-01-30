/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Hampesh
* @date 16-Oct-2018
* @description  

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------

Hampesh G              M-001             16-Oct-2018            To get logged in user default language and update language preference  
Hampesh G              M-002             30-Oct-2018            Added code to get language values from custom setting                    
*/
public without sharing class WFG_launch_userLaunguage_controller {

/**
    @author Hampesh
    @date 16-Oct-2018
    @description returns logged in user language
    */
    @AuraEnabled
    public static Languagewrapper loggedInUserLanguage()
    {
      try{
         Languagewrapper objWrapper=new Languagewrapper();
         Map<String,WFG_Language_Preferences__c> mcs = WFG_Language_Preferences__c.getAll();
         User objUser= [select LanguageLocaleKey,profile.name from user where id=:userinfo.getuserid()];
         objWrapper.lstLanguage=mcs.values();
         objWrapper.languageKey=objUser.LanguageLocaleKey;
         objWrapper.profileName=objUser.profile.name;
         return objWrapper;
       }catch(Exception e){
            system.debug('Exception in WFG_launch_userLaunguage_controller class--' + e);
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_launch_userLaunguage_controller', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }
        
        return null;
    }
 
 /**
    @author Hampesh
    @date 16-Oct-2018
    @description sets logged in user language based on the selection
    */
    @AuraEnabled
    public static void setuserLanguage(string userlanguage)
    {
        try{
            system.debug('selected language--'+userlanguage);
            if(!string.isEmpty(userlanguage) && userlanguage !='' && userlanguage !=null){
              User usr=[select Id, LanguageLocaleKey from user where id=:userinfo.getuserid()];
              usr.LanguageLocaleKey=userlanguage;
              update usr;
              
            }
         }catch(Exception e){
            system.debug('Exception in WFG_launch_userLaunguage_controller class--' + e);
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_launch_userLaunguage_controller', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }
    }
    
    public class Languagewrapper{
     @AuraEnabled
     public List<WFG_Language_Preferences__c> lstLanguage;
     @AuraEnabled
     public string  languageKey;
     @AuraEnabled
     public string  profileName;
     
    }

}