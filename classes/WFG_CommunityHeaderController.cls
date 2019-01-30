/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Saurabh Sharma
* @date 2-27-2017
* @description Community Header Controller for WFG_CommuityHeader lightning component

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Saurabh Sharma        M-001             2-27-2017         Community Header Controller
*/
public with sharing class WFG_CommunityHeaderController {
	
    @AuraEnabled
    public static WFG_CommunityHighlightPanel getHighlightPanelData(String strRecordId, String strObjectName){

        return WFG_CommunityHeaderUtility.getHeaderData(strRecordId, strObjectName);

        
    }
}