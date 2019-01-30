/*
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Saravanan Haldurai
* @date 05-Apr-2018
* @description - Schedule class to execute the WFG_RemoveAccountShare_Batch class. 

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description. 
--------------------------------------------------------------------------------------------------------
*/
global class WFG_RemoveAccountShare_schedule implements Schedulable {
    global void execute(SchedulableContext SC)
    {
        ID BatchId = Database.executeBatch(new WFG_RemoveAccountShare_Batch(), 5000);
    }
}