/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Saravanan Haldurai
* @date 03-JAN-2019
* @description - Schedule class to execute Redtail_InsertRelatedData_Batch batch class

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
Saravanan Haldurai    W-028484           03-JAN-2019             Schedule class to execute Redtail_InsertRelatedData_Batch batch class. 
--------------------------------------------------------------------------------------------------------
*/
global class Redtail_InsertRelatedData_Schedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        
        ID BatchId = Database.executeBatch(new Redtail_InsertRelatedData_Batch(), 200);
    }
}