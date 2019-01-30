/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Praveen
* @date 04-06-2017
* @description Class to show license reminder for newly joined prospects

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
*/
public with Sharing class WFG_Launch_LicenseReminderBarCtrl {                                                                                                                                                                                                                                                        
    /**
     * This method returns the string which conisist of months and date remaining to apply for license
     * @throws - N/A
     * @author Praveen
     * @date 04-06-2018
     */
    @AuraEnabled 
    public static string calculateMonthAndDate(){
        string strFinal;
        String strMonths = System.Label.WFG_Launch_Months;
        String strDays = System.Label.WFG_Launch_Days;
        try
        {
            user u =[select contactId from user where id=:userinfo.getUserId() limit 1];            
            WFG_AgentCode__c agentcode = [select WFG_SMDApprovalDate__c from WFG_AgentCode__c where WFG_Contact__c =: u.ContactId and WFG_PrimaryCode__c = true limit 1];
            if(agentcode!=null){
                Date startdate=agentcode.WFG_SMDApprovalDate__c;
                //Adds 9 months to the start date
                date after9month=startdate.addmonths(9);                
                date logindate=system.today();
                integer daysBetween = logindate.daysBetween(after9month);                
                Integer numberOfDays = Date.daysInMonth(logindate.year(), logindate.month());                
                integer remainingdays = 0;
                integer monthbetween = 0;
                if(daysBetween == numberOfDays) {
                    remainingdays = 0;
                    monthbetween = 1;
                }
                else if(daysBetween < numberOfDays){
                    remainingdays = daysBetween;
                    monthbetween = 0;
                }
                else if(daysBetween > numberOfDays){
                    if(after9month.day()<logindate.day()){
                        remainingdays=(date.daysInMonth(logindate.year(),logindate.month())-logindate.day())+after9month.day();
                        monthbetween = logindate.monthsBetween(after9month)-1;
                    }
                    else
                    {
                        monthbetween = logindate.monthsBetween(after9month);
                        date newdate = logindate.addmonths(monthbetween);                        
                        remainingdays = newdate.daysBetween(after9month);
                    }
                }                
                strFinal = monthbetween +' '+strMonths 
                    + '/' +remainingdays+ ' '+ strDays;
            }
        }
        catch(Exception e){ 
            strFinal= strMonths+ '/' +strDays;            
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_Launch_LicenseReminderBarCtrl', 'EXCEPTION', 'APEX',e.getMessage(), e.getMessage(), null, null, null, true);                                  
        }        
        return strFinal;
    }
    
    /**
     * This method returns the string which is the country of logged on user
     * @throws - N/A
     * @author Girish
     * @date 07-13-2018
     */
    @AuraEnabled
    public static String getCurrentUserCountry(){
       return RunningUserCtrl.getProfileCountry();
    }
}