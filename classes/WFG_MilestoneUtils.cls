/*
Property of Transamerica and Aegon companies. Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Manuel Johnson
* @date 07-19-2016
* @description US-2365: This is a utility to update milestones to completed provided by SFDC

Modification Log:
__________________________________________________________________________________________________________
Developer          ModNumber           Date                    Description
__________________________________________________________________________________________________________
Manuel	           M-001               07-19-2016              Initial 

*/

public with sharing class WFG_MilestoneUtils {
    public static void completeMilestone(List<Id> caseIds, String milestoneName, DateTime complDate) {  
        List<CaseMilestone> cmsToUpdate = [select Id, completionDate
                from CaseMilestone cm
                where caseId in :caseIds and cm.MilestoneType.Name=:milestoneName 
                and completionDate = null limit 1];
        if (cmsToUpdate.isEmpty() == false){
            for (CaseMilestone cm : cmsToUpdate){
                cm.completionDate = complDate;
            }
            update cmsToUpdate;
        }
    }
}