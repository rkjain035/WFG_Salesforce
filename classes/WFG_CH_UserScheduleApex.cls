/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Karthik Raj
* @date 10-26-2018 
* @description - Schedule Apex class for Contact changes from Active to InActive or viceversa.

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Karthik Raj            Mod-01          10-26-2018            Schedule Apex class for User changes from InActive to Active.
*/
global class WFG_CH_UserScheduleApex implements Schedulable 
{
    global void execute(SchedulableContext SC) 
    {
        try{
       
            Map<String,Id> mapAgentCodeUserId = new Map<String,Id>();
            DateTime currentDate = System.now();
            //DateTime subtractedDate = System.now() - (1/12);
            for(User objUser : [SELECT Id,WFG_Agent_Code__c  
                                  FROM User 
                                  WHERE isActive = true and WFG_LastUpdatedDate__c < = :currentDate LIMIT 100])
            {
                mapAgentCodeUserId.put(objUser.WFG_Agent_Code__c,objUser.Id);         
            }
            System.debug('Active User List in User Schedule Apex------' + mapAgentCodeUserId);
            
            //check if there are 5 active batch jobs
            if(runningJobCount <5){
                 if(mapAgentCodeUserId.size() > 0){
                    Database.executeBatch(new WFG_CH_UserActiveBatch(mapAgentCodeUserId));
                }
            }
            else {
               //schedule this same schedulable class again in 15 mins
               WFG_CH_UserScheduleApex scheduledClass = new WFG_CH_UserScheduleApex();
               Datetime dt = Datetime.now().addMinutes(15);
               String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
               Id schedId = System.Schedule('WFG_CH_UserScheduleApex'+timeForScheduler,timeForScheduler,scheduledClass);
            }
        }catch(Exception e)
		{system.debug('Exception in User Schedule apex --' + e);LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_CH_UserScheduleApex', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);}
          
    }
    public Integer runningJobCount{
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