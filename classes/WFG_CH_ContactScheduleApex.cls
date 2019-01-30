/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Rahul K Jain
* @date 10-24-2018 
* @description - Schedule Apex class for Contact changes from Active to InActive or viceversa.

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Rahul K Jain             Mod-01          10-24-2018            Schedule Apex class for Contact changes from Active to InActive or viceversa.
*/
global class WFG_CH_ContactScheduleApex implements Schedulable 
{
    global void execute(SchedulableContext SC) 
    {
        try{ 
            Set<Id> setContactIds = new Set<Id>();
            Set<Id> setContactInactiveToActive = new Set<Id>();
            Set<Id> setContactActiveToInActive = new Set<Id>();
            
            for(Contact objCon : [SELECT Id, WFG_IsNewlyCreatedContact__c  
                                  FROM Contact 
                                  WHERE WFG_IsNewlyCreatedContact__c = true])
            {
                setContactIds.add(objCon.Id);              
            }
            
            system.debug('Set ContactIds Status is true in Conatct Schedule Apex ---'+ setContactIds);
            
            //Check for 5 Batchs running
            if ( runningJobCount < 5){ 
                     if(setContactIds.size() > 0){ 
                         Database.executeBatch(new WFG_CH_ContactActivebatch(setContactIds));
                     }
            } else {
               //schedule this same schedulable class again in 15 mins
               WFG_CH_ContactScheduleApex scheduleClass = new WFG_CH_ContactScheduleApex();
               Datetime dt = Datetime.now().addMinutes(15);
               String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
               Id schedId = System.Schedule('WFG_CH_ContactScheduleApex'+timeForScheduler,timeForScheduler,scheduleClass);
            }
            
        }catch(Exception e){system.debug('Exception in Contact Schedule apex --' + e);LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_CH_ContactScheduleApex', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);}
    }
    public Integer runningJobCount
    {
    get{
        if(runningJobCount == null)
            return [Select count() FROM AsyncApexJob WHERE JobType='BatchApex' AND(Status = 'Processing' OR Status = 'Preparing' OR Status='Queued')];
        else
            return runningJobCount;
    }
    set{
        System.assert(Test.isRunningTest(),'This property may only be set in tests');
        runningJobCount = value;
    }
   }
    
}