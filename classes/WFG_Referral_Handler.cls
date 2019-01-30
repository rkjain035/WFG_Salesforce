/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Ninad
* @date 12-22-2016
* @description  handler class for Referral trigger

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Ninad Patil          M-001             12-22-2016              trigger handler
Ninad Patil          M-002             01-19-2017              Modified to include changes for W-000402/W-000403
Ninad Patil          M-003             04-07-2017              Modified to include changes for W-002049
Ninad Patil          M-004             13-07-2017              Modified to include changes for Source = Referral changes.
Ninad Patil          M-005             04-17-2017              Modified to include changes for Date of Acceptance.
*/
public without sharing class WFG_Referral_Handler {

    /**
    @author Ninad Patil
    @date 22-Dec-2016
    @description Executed on Trigger Context - After Insert. 
    @return - void
    @param  - List<WFG_Referral__c> list of referral records being inserted
    @throws - N/A
    @author Ninad
    */
    public static void beforeInsert(List < WFG_Referral__c > lstReferral) {
        //buildMapContact(Trigger.New);
        checkForActiveReferral(lstReferral);
        WFG_SystemModeHelper.populateReferralCountFields(lstReferral);
    }

    /**
    @author Ninad Patil
    @date 19-JAN-2017
    @description : This method is singel point if entry for all methods in Before update trigger event.
    @return - void
    @param  - List<WFG_Referral__c> list of referral records being updates
              Map<Id, WFG_Referral__c>mapNewReferral :New map of referral records,
              Map<Id, WFG_Referral__c>mapOldReferral :Old map of referral records.
    @throws - AddError of trigger exception
    @author Ninad
    */
    public static void beforeUpdate(List < WFG_Referral__c > lstReferral,
        Map < Id, WFG_Referral__c > mapNewReferral, Map < Id, WFG_Referral__c > mapOldReferral) {
        markCompleteReferral(lstReferral, mapNewReferral, mapOldReferral);
        markAcceptedReferral(lstReferral, mapNewReferral, mapOldReferral);
    }

    /**
    @author Ninad Patil
    @date 19-JAN-2017
    @description : This method is singel point if entry for all methods in After update trigger event.
    @return - void
    @param  - List<WFG_Referral__c> list of referral records being updates
              Map<Id, WFG_Referral__c>mapNewReferral :New map of referral records,
              Map<Id, WFG_Referral__c>mapOldReferral :Old map of referral records.
    @throws - AddError of trigger exception
    @author Ninad
    */
    public static void afterUpdate(List < WFG_Referral__c > lstReferral,
        Map < Id, WFG_Referral__c > mapNewReferral, Map < Id, WFG_Referral__c > mapOldReferral, boolean boolIsUpdate) {
        controlVisibilityUpdate(lstReferral, mapNewReferral, mapOldReferral, true);
        //WFG_SystemModeHelper.AcceptReferral(lstReferral,mapNewReferral,mapOldReferral);
    }

    /**
    @author Ninad Patil
    @date 19-JAN-2017
    @description : This method check pre-Qualifications for Referral status to complete-Close-Won 
    @return - void
    @param  - List<WFG_Referral__c> list of referral records being updates
              Map<Id, WFG_Referral__c>mapNewReferral :New map of referral records,
              Map<Id, WFG_Referral__c>mapOldReferral :Old map of referral records.
    @throws - AddError of trigger exception
    @author Ninad
    */
    public static void markCompleteReferral(List < WFG_Referral__c > lstReferral,
            Map < Id, WFG_Referral__c > mapNewReferral, Map < Id, WFG_Referral__c > mapOldReferral) {
            List < Id > lstReferralToBeChecked = new List < Id > ();
            set < Id > setReferralToBeCheckedComplete = new set < Id > ();
            set < Id > setReferralToBeCheckedNonComplete = new set < Id > ();
            for (WFG_Referral__c objReferral: lstReferral) {
                //fetching only those records which are supposed changed from any other to Complete Sold status.
                if (objReferral.WFG_Status__c == system.Label.WFG_ReferralStatus_CompleteSold &&
                    (mapNewReferral.get(objReferral.id).WFG_Status__c <> mapoldReferral.get(objReferral.id).WFG_Status__c)) {
                    setReferralToBeCheckedComplete.add(objReferral.id);
                }
                if (objReferral.WFG_Status__c == system.Label.WFG_ReferralStatus_CompleteNotSold &&
                    (mapNewReferral.get(objReferral.id).WFG_Status__c <> mapoldReferral.get(objReferral.id).WFG_Status__c)) {
                    setReferralToBeCheckedNonComplete.add(objReferral.id);
                }
                lstReferralToBeChecked.addAll(setReferralToBeCheckedComplete);
                lstReferralToBeChecked.addAll(setReferralToBeCheckedNonComplete);
            }
            if (lstReferralToBeChecked != null && !lstReferralToBeChecked.isEmpty()) {
                //Fetching pre qualified records along with associated Financial Accounts and oportunities.
                for (WFG_Referral__c objRef: [Select id, Name,
                        (Select id, name,
                            FinServ__FinancialAccountNumber__c,
                            recordtype.name FROM Financial_Accounts__r),
                        (Select id, name, WFG_Source__c, recordtype.name, StageName FROM Opportunities__r)
                        FROM WFG_Referral__c
                        WHERE Id IN: lstReferralToBeChecked
                    ]) {
                    if (setReferralToBeCheckedComplete.contains(objRef.id)) {
                        //If no Opportunities exists for referral, it should error out with proper error message to user.
                        if (objRef.Opportunities__r == null || objRef.Opportunities__r.size() == 0) {
                            mapNewReferral.get(objRef.id).addError(System.label.WFG_OpportunityForReferralCompletionErrMsg);
                        } else if (objRef.Opportunities__r.size() > 0) {
                            boolean boolIsOppClosed = false;
                            for (Opportunity objOpp: objRef.Opportunities__r) {
                                //if(objOpp.recordtype.name == 'Qualified Retirement' && StageName == 'Closed-Won')
                                if ((objOpp.recordtype.name == System.Label.WFG_OppRecType_QualifiedRet ||
                                        objOpp.recordtype.name == System.Label.WFG_Opportunity_RecordType_QualifiedRetirementReadOnly) &&
                                    objOpp.StageName == System.Label.WFG_OpportunityStage_CloseWon &&
                                    objOpp.WFG_Source__c == System.Label.WFG_OpportunitySourceReferral) {
                                    boolIsOppClosed = true;
                                    break;
                                }
                            }
                            if (boolIsOppClosed == false) {
                                mapNewReferral.get(objRef.id).addError(System.label.WFG_OpportunityForReferralCompletionErrMsg);
                            }
                        }
                    }
                    if (setReferralToBeCheckedNonComplete.contains(objRef.id)) {
                        //Check Opportunity condition, all opportunity should be in Sales Lost condition
                        if (objRef.Opportunities__r != null && objRef.Opportunities__r.size() > 0) {
                            boolean boolIsClosed = false;
                            for (Opportunity objOpp: objRef.Opportunities__r) {
                                if ((objOpp.recordtype.name == System.Label.WFG_OppRecType_QualifiedRet ||
                                        objOpp.recordtype.name == System.Label.WFG_Opportunity_RecordType_QualifiedRetirementReadOnly) &&
                                    objOpp.stageName != System.Label.WFG_OpportunityStage_CloseLost &&
                                    objOpp.WFG_Source__c == System.Label.WFG_OpportunitySourceReferral) {
                                    boolIsClosed = true;
                                    break;
                                }
                            }
                            if (boolIsClosed) mapNewReferral.get(objRef.id).addError(System.Label.WFG_OpportunityForReferralInCompletionErrMsg);
                        }
                    }
                }
            }
        }
        /**
        @author Ninad Patil
        @date 17-APRIL-2017
        @description : This method populates Date Of Acceptance. 
        @return - void
        @param  - List<WFG_Referral__c> list of referral records being updates
                  Map<Id, WFG_Referral__c>mapNewReferral :New map of referral records,
                  Map<Id, WFG_Referral__c>mapOldReferral :Old map of referral records.
        @throws - None
        @author Ninad
        */
    public static void markAcceptedReferral(List < WFG_Referral__c > lstReferral,
            Map < Id, WFG_Referral__c > mapNewReferral, Map < Id, WFG_Referral__c > mapOldReferral) {
            List < WFG_Referral__c > lstReferralToBeChecked = new List < WFG_Referral__c > ();

            for (WFG_Referral__c objReferral: lstReferral) {
                //fetching only those records which are supposed changed from any other to Complete Sold status.
                if (objReferral.WFG_Status__c == system.Label.WFG_ReferralStatus_Accepted &&
                    (mapNewReferral.get(objReferral.id).WFG_Status__c <> mapoldReferral.get(objReferral.id).WFG_Status__c)) {
                    lstReferralToBeChecked.add(objReferral);
                }
            }
            if (lstReferralToBeChecked != null && !lstReferralToBeChecked.isEmpty()) {
                for (WFG_Referral__c objRef: lstReferralToBeChecked) {
                    objRef.WFG_Date_of_Acceptance__c = system.today();
                }
            }
        }
        /**
        @author Ninad Patil
        @date 22-Dec-2016
        @description Executed on Trigger Context - After Insert. 
        @return - void
        @param  - List<WFG_Referral__c> list of referral records being inserted
        @throws - N/A
        @author Ninad
        */
    public static void afterInsert(List < WFG_Referral__c > lstTriggerNew) {
        List < WFG_Referral__c > lstReferralRecs = new List < WFG_Referral__c > ();

        for (WFG_Referral__c objRef: lstTriggerNew) {
            if (objRef.WFG_Status__c == System.Label.WFG_ReferralStatus_Referred)
                lstReferralRecs.add(objRef);
        }
        if (lstReferralRecs != null && !lstReferralRecs.isEmpty()) shareReferralRecord(lstReferralRecs);

    }

    /**
    @author Ninad Patil
    @date 22-Dec-2016
    @description Executed on Trigger Context - After Insert. 
    @return - void
    @param  - List<WFG_Referral__c> list of referral records being inserted
    @param  - Map<Id, WFG_Referral__c> map of referral records being inserted
    @param  - Map<Id, WFG_Referral__c> map of referral records being inserted
    @param  - isUpdate boolean to indicate whether insert or update
    
    @throws - N/A
    @author Ninad
    */
    public static void controlVisibilityUpdate(List < WFG_Referral__c > lstTriggerNew, Map < Id, WFG_Referral__c > mapTriggerNewMap,
        Map < Id, WFG_Referral__c > mapTriggerOldMap, boolean isUpdate) {
        savepoint sp = database.setSavepoint();
        try {
            List < WFG_Referral__c > lstReferralCanRecs = new List < WFG_Referral__c > ();
            List < WFG_Referral__c > lstReferralRecs = new List < WFG_Referral__c > ();
            for (WFG_Referral__c objRef: lstTriggerNew) {
                if ((isUpdate && mapTriggerNewMap.get(objRef.id).WFG_Status__c !=
                        mapTriggerOldMap.get(objRef.id).WFG_Status__c)) {

                    if (objRef.WFG_Status__c == System.Label.WFG_ReferralStatus_Cancelled ||
                        objRef.WFG_Status__c == System.Label.WFG_ReferralStatus_Rejected)
                        lstReferralCanRecs.add(objRef);

                    if (objRef.WFG_Status__c == System.Label.WFG_ReferralStatus_Referred)
                        lstReferralRecs.add(objRef);
                }
            }
            if (lstReferralCanRecs != null && !lstReferralCanRecs.isEmpty()) UnShareReferralRecord(lstReferralCanRecs);
            if (lstReferralRecs != null && !lstReferralRecs.isEmpty()) shareReferralRecord(lstReferralRecs);
        } catch (Exception e) {
            Database.Rollback(sp);
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_Referral__c', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
            Database.rollback(sp);
        }

    }

    /**
    @author Ninad Patil
    @date 22-Dec-2016
    @description Executed on Trigger Context - After Insert. 
    @return - void
    @param  - List<WFG_Referral__c> list of referral records being inserted
    @throws - N/A
    @author Ninad
    */
    private static Void shareReferralRecord(List < WFG_Referral__c > lstReferral) {
            List < WFG_Referral__Share > lstJobShare = new List < WFG_Referral__Share > ();
            WFG_Referral__Share jobShr;
            savepoint sp1 = database.setSavepoint();

            for (WFG_Referral__c objRef: lstReferral) {
                // Set the ID of record being shared.
                jobShr = new WFG_Referral__Share();
                jobShr.ParentId = objRef.id;

                // Set the ID of user or group being granted access.
                jobShr.UserOrGroupId = objRef.WFG_Referred_To__c;

                // Set the access level.
                jobShr.AccessLevel = 'Edit';
                lstJobShare.add(jobShr);
            }
            List < Database.saveResult > lstSaveRes = Database.insert(lstJobShare, false);
            // Iterate through each returned result
            boolean isError = false;
            for (Database.SaveResult objSvRES: lstSaveRes) {
                if (objSvRES.isSuccess()) {} else {
                    isError = true;
                    // Operation failed, so get all errors                
                    for (Database.Error err: objSvRES.getErrors()) {
                        System.debug(err.getMessage());
                        String strErr = err.getStatusCode() + ': ' + err.getMessage();
                        LogUtility.createLogs('DML', 'ERROR', 'WFG_Referral__c', 'DML', 'APEX', strErr, strErr, null, null, null, false);
                    }
                }
            }
            if (isError) {
                for (WFG_Referral__c objRef: lstReferral) {
                    objRef.addError(system.Label.WFG_ReferralSharing_Error);
                }
                LogUtility.commitLogs(true);
                Database.rollback(sp1);
            }
        }
        /**
        @author Ninad Patil
        @date 7-Dec-2016
        @description Executed on Trigger Context - After Insert. 
        @return - void
        @param  - List<WFG_Referral__c> list of referral records being inserted
        @throws - N/A
        @author Niand
        @date 12-22-2016
        */
    private static Void UnShareReferralRecord(List < WFG_Referral__c > lstReferral) {
            savepoint sp1 = database.setSavepoint();

            List < WFG_Referral__Share > lstJobShare = new List < WFG_Referral__Share > ();
            map < ID, WFG_Referral__c > mapShareReferral = new map < ID, WFG_Referral__c > ();
            for (WFG_Referral__c objRef: lstReferral) {
                mapShareReferral.put(objRef.id, objRef);
            }
            for (WFG_Referral__Share objRefShare: [Select id, ParentId,
                    UserOrGroupId, AccessLevel from WFG_Referral__Share
                    Where ParentId IN: mapShareReferral.keyset()
                ]) {
                if (objRefShare.UserOrGroupId == mapShareReferral.get(objRefShare.ParentId).WFG_Referred_To__c &&
                    objRefShare.AccessLevel == 'Edit') {
                    lstJobShare.add(objRefShare);
                }
            }
            if (lstJobShare != null && !lstJobShare.isEmpty()) {
                List < Database.DeleteResult > lstDeleteRes = DataBase.delete(lstJobShare, true);
                // Iterate through each returned result
                boolean isError = false;
                for (Database.DeleteResult objSvRES: lstDeleteRes) {
                    if (!objSvRES.isSuccess()) {
                        isError = true;
                        String strErr = '';
                        // Operation failed, so get all errors                
                        for (Database.Error err: objSvRES.getErrors()) {
                            strErr = err.getStatusCode() + ': ' + err.getMessage();
                        }
                        LogUtility.createLogs('DML', 'ERROR', 'WFG_Referral__c',
                            'DML', 'APEX', strErr, strErr, null,
                            null, null, false);
                    }
                }
                if (isError) {
                    for (WFG_Referral__c objRef: lstReferral) {
                        objRef.addError(system.Label.WFG_ReferralSharing_Error);
                    }
                    LogUtility.commitLogs(true);
                    Database.rollback(sp1);
                }
            }
        }
        /**
        @author Ninad Patil
        @date 22-Dec-2016
        @description Executed on Trigger Context - before Insert. 
        @return - void
        @param  - List<WFG_Referral__c> list of referral records being inserted
        @throws - N/A
        @author Ninad
        */
    public static void checkForActiveReferral(List < WFG_Referral__c > lstReferral) {
        //Get the list of referrals 
        List < Id > lstCustomerProfileIds = new List < Id > ();
        for (WFG_Referral__c objReferral: lstReferral) {
            if (objReferral.WFG_Customer_Profile__c != null) lstCustomerProfileIds.add(objReferral.WFG_Customer_Profile__c);
        }
        //Get Active Referrals
        set < String > setActiveReferralsStatus = WFG_Active_Referrals__c.getAll().keyset();
        if (lstCustomerProfileIds != null && !lstCustomerProfileIds.isEmpty()) {
            //This Map key is the Customer Profile Id, and value is a list of Active Referrals related to the Customer Profile
            Map < Id, List < WFG_Referral__c >> mapReferralList = new Map < Id, List < WFG_Referral__c >> ();
            //for loop to populate the Map mapReferralList.
            for (WFG_Customer_Profile__c objCustProfile: [SELECT Id, (SELECT Id, name FROM Referrals__r WHERE WFG_Status__c IN: setActiveReferralsStatus)
                    FROM WFG_Customer_Profile__c WHERE Id IN: lstCustomerProfileIds
                ]) {
                mapReferralList.put(objCustProfile.Id, objCustProfile.Referrals__r);
            }

            for (WFG_Referral__c objReferral: lstReferral) {
                //Checks if there is already active referrals for a Customer Profile, and puts values in the Map according to it.
                if (mapReferralList.containsKey(objReferral.WFG_Customer_Profile__c) &&
                    mapReferralList.get(objReferral.WFG_Customer_Profile__c) != Null &&
                    mapReferralList.get(objReferral.WFG_Customer_Profile__c).size() > 0) {
                    string strError = System.Label.WFG_AlreadyActiveReferral.replace('[Referral_ID]', mapReferralList.get(objReferral.WFG_Customer_Profile__c)[0].name);
                    objReferral.addError(strError);
                }
            }
        }
    }

    /**
    @author Ninad Patil
    @date 18-May-2017
    @description Executed on Trigger Context - before Insert. 
    @return - void
    @param  - List<WFG_Referral__c> list of referral records being inserted
    @throws - N/A
    @author Ninad
    */
    public static void populateActiveREferral(map < id, WFG_REferral__C > mapNewref, map < Id, WFG_Referral__c > mapOldRef, boolean boolIsUPdate) {
        try {
            System.debug('*********************Method Started************');
            map < string, WFG_Active_Referrals__c > mapSTatusActive = WFG_Active_Referrals__c.getAll();
            map < id, WFG_Customer_Profile__c > mapRefVsCP = new map < id, WFG_Customer_Profile__c > ();
            map < id, Id > mapRefVsCPID = new map < id, Id > ();
            map < id, WFG_Customer_Profile__c > mapCpIdvsCPObj = new map < id, WFG_Customer_Profile__c > ();

            List < WFG_Customer_Profile__c > lstCPToUpdate = new list < WFG_Customer_Profile__c > ();
            for (WFG_Referral__c ObjRed: mapNewref.values()) {
                if (!boolIsUPdate || (boolIsUPdate && mapNewref.get(ObjRed.id).WFG_Status__c <> mapOldRef.get(ObjRed.id).WFG_Status__c) &&
                    mapSTatusActive.containskey(mapNewref.get(ObjRed.id).WFG_Status__C) &&
                    !mapSTatusActive.containskey(mapOLDref.get(ObjRed.id).WFG_Status__C)) {
                    System.debug('*********************Inside If 1************' + mapNewref.get(ObjRed.id).WFG_Status__c);
                    mapRefVsCPID.put(objRed.id, ObjRed.WFG_Customer_Profile__c);
                    mapCpIdvsCPObj.put(ObjRed.WFG_Customer_Profile__c, null);
                }
            }

            if (mapCpIdvsCPObj != null && !mapCpIdvsCPObj.keyset().isEMPty()) {
                for (WFG_Customer_Profile__c objCP: [Select id, name, WFG_CP_Active_Referral__c from WFG_Customer_Profile__C
                        WHERE ID IN: mapCpIdvsCPObj.keyset()
                    ]) {
                    mapCpIdvsCPObj.put(objCP.id, objCP);
                }
                for (Id objId: mapRefVsCPID.keyset()) {
                    if ((mapCpIdvsCPObj.containskey(mapRefVsCPID.get(objId)) != null) && (mapCpIdvsCPObj.get(mapRefVsCPID.get(objId)) != null)) {
                        if (mapCpIdvsCPObj.containskey(mapRefVsCPID.get(objId)) &&
                            mapCpIdvsCPObj.get(mapRefVsCPID.get(objId)) != null) {
                            mapRefVsCP.put(objId, mapCpIdvsCPObj.get(mapRefVsCPID.get(objId)));
                        }
                    }
                }
                if (mapRefVsCP != null && !mapRefVsCP.keyset().isEMPty()) {
                    for (Id sId: mapRefVsCP.keyset()) {
                        if (mapRefVsCP.containskey(sId) && mapRefVsCP.get(sId) != null) {
                            WFG_Customer_Profile__C objCP = mapRefVsCP.get(sId);
                            objCP.WFG_CP_Active_Referral__c = sId;
                            lstCPToUpdate.add(objCP);
                        }
                    }
                    if (lstCPToUpdate != null && !lstCPToUpdate.isEMPty()) {
                        update lstCPToUpdate;
                    }
                }
            }
        } catch (Exception e) {
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_Customer_Profile__c', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }
    }

}