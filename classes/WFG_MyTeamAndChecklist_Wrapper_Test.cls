/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Rahul K Jain
* @date 30-Jul-2018
* @description  Test class for WFG_MyTeamAndChecklist_Wrapper

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Rahul K Jain           M-001             30-Jul-2018 			 Pretty much self explainatory      
*/
@isTest
public class WFG_MyTeamAndChecklist_Wrapper_Test {
	
    public static testMethod void testMethod1()
    {
        WFG_MyTeamAndChecklist_Wrapper wrapper = new WFG_MyTeamAndChecklist_Wrapper();
        wrapper.downlineImageURL = 'image Url';
        wrapper.downlineNames = 'Test Downline';
        wrapper.recruitedDate = 'Test Date';
        wrapper.prospectsUserId = 'Test Prospect Id';
        wrapper.inProgress = true;
        wrapper.completed = true;
    }   
}