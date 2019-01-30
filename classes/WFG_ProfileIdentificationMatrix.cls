/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author bmadaan
* @date 12-08-2016
* @description  Profile Identification utility

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Ninad Patil           M-001             01-MAR-2017             US-707/709/710 Utility to indentify profile
Praveen Lakkundi      M-002             16-MAR-2018             Changes to Home Office Profiles  
Rashmi                M-003             11-June-2018            Changes to accomodate launch profiles when type is launch and channel is blue/green
*/
public with sharing class WFG_ProfileIdentificationMatrix 
{
    /**
     * This method will accept contact and retuen profileId for the anticipated user.
     * @return - string
     * @see    - N/A
     * @param  - Contact
     * @throws - N/A
     */
    public static string getProfileId(Contact objContact)
    {
        List<Contact> lstContact = new List<Contact>();
        lstContact.add(objContact);
        Map<string, string> mapProfileVsContactID = getProfileId(lstContact);
        if(mapProfileVsContactID != null 
            && mapProfileVsContactID.containskey(objContact.id)
            && mapProfileVsContactID.get(objContact.id) != null)
        {
            return mapProfileVsContactID.get(objContact.id);
        }
        return null;
    }
    
    
    /**
     * This method will accept list contact and retuen profileId for the anticipated user.
     * @return - string
     * @see    - N/A
     * @param  - Map<string, string>
     * @throws - N/A
     */
    public static Map<string, string> getProfileId(List<Contact> lstContact)
    {   
        system.debug('### CONTACT ID :: '+ lstContact);
        Map<string, string> mapProfileVsContactID = new Map<string, string>();
        Map<string, Contact> mapContact = new Map<string, Contact>();
        List<WFG_Profile_Identification_Matrix__mdt> lstMetaType = new List<WFG_Profile_Identification_Matrix__mdt>();
        //Map Name to ids of profiles
        map<string,id> mapProfileNameToIds = new map<string,id>();
        
        if(lstContact != null && !lstContact.isEmpty())
        {
            lstMetaType = [Select id, WFG_Agent_Type__c,WFG_Type__c,WFG_Launch_Channel__c,
                            WFG_Cycle_Type__c,WFG_Fiduciary_Flag__c,
                            WFG_Profile_Name__c, WFG_Source__c,WFG_Profile_ID__c
                            FROM WFG_Profile_Identification_Matrix__mdt];
                                           
            for(COntact objCon : lstContact)
            {
                mapProfileVsContactID.put(objCon.id, null);
                mapContact.put(objCon.Id, objCon);
            }
            //Put profile names and id to the map
            for(profile pf :[select name,id from profile where name like '%Home Office']){
                mapProfileNameToIds.put(pf.name,pf.id);
            }
            if(mapProfileVsContactID != null && !mapProfileVsContactID.keyset().IsEmpty())
            {
                for(Contact objCon : lstContact)
                {
                    if(objCon.WFG_Type__c != null) objCon.WFG_Type__c = objCon.WFG_Type__c.toUpperCase();
                    if(objCon.WFG_AgentPayType__c != null)objCon.WFG_AgentPayType__c = objCon.WFG_AgentPayType__c.toUpperCase();
                    if(objCon.WFG_CycleType__c != null) objCon.WFG_CycleType__c = objCon.WFG_CycleType__c.toUpperCase();
                    if(objCon.WFG_Channel__c != null) objCon.WFG_Channel__c = objCon.WFG_Channel__c.toUpperCase();
                    for(WFG_Profile_Identification_Matrix__mdt objMt : lstMetaType)
                    {
                        //Making evrything uppercase
                        
                        system.debug('### AGENT1 ' + objCon.WFG_AgentPayType__c);
                        system.debug('### AGENT2 ' + objMt.WFG_Agent_Type__c);
                        if(objCon.WFG_Type__c == 'Associate' &&
                            objMt.WFG_Type__c == 'Associate')
                        {
                            mapProfileVsContactID.put(objCon.id, objMt.WFG_Profile_ID__c);
                            break;
                        }
                        
                        //check for TAN condition
                        if(objCon.WFG_AgentPayType__c == 'TAN')
                        {
                            if(objMt.WFG_Agent_Type__c == objCon.WFG_AgentPayType__c)
                            {
                                if(objCon.WFG_Fiduciary_Advisor__c == true 
                                    && objMt.WFG_Fiduciary_Flag__c == objCon.WFG_Fiduciary_Advisor__c)
                                {
                                    mapProfileVsContactID.put(objCon.id, objMt.WFG_Profile_ID__c);
                                    break;
                                }
                                else if(objCon.WFG_Fiduciary_Advisor__c == false 
                                    && objMt.WFG_Fiduciary_Flag__c == objCon.WFG_Fiduciary_Advisor__c)
                                {
                                    set<string> strTypemdt = new set<string>();
                                    if(objMt.WFG_Type__c != null
                                        && objMt.WFG_Type__c.contains(';'))
                                    {
                                        for(string strType_mdt : objMt.WFG_Type__c.split(';'))
                                        {
                                            if(strType_mdt != null && strType_mdt != '') strTypemdt.add(strType_mdt);
                                        }
                                    }
                                    else if(objMt.WFG_Type__c != null) strTypemdt.add(objMt.WFG_Type__c.toUpperCase());
                                    
                                    set<string> strTypeCon = new set<string>();
                                    if(objCon.WFG_Type__c != null 
                                        && objCon.WFG_Type__c.contains(';'))
                                    {
                                        for(string strType_con : objCon.WFG_Type__c.split(';'))
                                        {
                                            if(strType_con != null && strType_con != '') strTypeCon.add(strType_con);
                                        }
                                    }else if(objCon.WFG_Type__c != null)  strTypeCon.add(objCon.WFG_Type__c.toUpperCase());
                                    
                                    if((!strTypeCon.isEMpty() && !strTypemdt.isEMPty()) && strTypeCon.containsAll(strTypemdt)
                                        && strTypemdt.containsAll(strTypeCon))
                                    {
                                        mapProfileVsContactID.put(objCon.id, objMt.WFG_Profile_ID__c);
                                        break;
                                    }                           
                                }
                            }
                        }
                        else 
                        {       
                            if(objMt.WFG_Agent_Type__c == objCon.WFG_AgentPayType__c)
                            {
                                //Agent type NOT TAN
                                if(objCon.WFG_Fiduciary_Advisor__c == true)
                                {
                                    if(objMt.WFG_Fiduciary_Flag__c == objCon.WFG_Fiduciary_Advisor__c && (objCon.WFG_Home_Office_Agent__c == false))
                                    {
                                        if(objCon.WFG_CycleType__c == objMt.WFG_Cycle_Type__c)
                                        {
                                            mapProfileVsContactID.put(objCon.id, objMt.WFG_Profile_ID__c);
                                            break;
                                        }
                                    }
                                    else
                                    {
                                        if((objCon.WFG_CycleType__c == 'US' || objCon.WFG_CycleType__c == 'PR' ) && (objCon.WFG_Home_Office_Agent__c == true))
                                        {
                                            mapProfileVsContactID.put(objCon.id, mapProfileNameToIds.get('FA Home Office'));
                                            break;
                                        }
                                    }
                                }
                                else
                                {
                                    //Fiduciary flag is set to FALSE
                                    //check for Lauch users W-026583
                                    if(objCon.WFG_Type__c == 'LAUNCH' && objMt.WFG_Type__c == 'LAUNCH' && objCon.WFG_AgentPayType__c== 'WFG'){
                                        
                                        if(objCon.WFG_CycleType__c == objMt.WFG_Cycle_Type__c){
                                            if(objCon.WFG_Channel__c == objMt.WFG_Launch_Channel__c){
                                                mapProfileVsContactID.put(objCon.id, objMt.WFG_Profile_ID__c);
                                                break;
                                            }
                                        }
                                    }
                                    if(objCon.WFG_CycleType__c == objMt.WFG_Cycle_Type__c && objCon.WFG_Home_Office_Agent__c == false && objCon.WFG_Type__c != 'LAUNCH')
                                    {
                                        set<string> strTypemdt = new set<string>();
                                        if(objMt.WFG_Type__c != null 
                                            && objMt.WFG_Type__c.contains(';'))
                                        {
                                            for(string strType_mdt : objMt.WFG_Type__c.split(';'))
                                            {
                                                if(strType_mdt != null && strType_mdt != '') strTypemdt.add(strType_mdt);
                                            }
                                        }
                                        else if(objMt.WFG_Type__c != null) strTypemdt.add(objMt.WFG_Type__c.toUpperCase());
                                        
                                        set<string> strTypeCon = new set<string>();
                                        if(objCon.WFG_Type__c != null
                                            && objCon.WFG_Type__c.contains(';'))
                                        {
                                            for(string strType_con : objCon.WFG_Type__c.split(';'))
                                            {
                                                if(strType_con != null && strType_con != '') strTypeCon.add(strType_con);
                                            }
                                        }
                                        else if(objCon.WFG_Type__c != null) strTypeCon.add(objCon.WFG_Type__c.toUpperCase());
                                        if((!strTypeCon.isEMpty() && !strTypemdt.isEMPty()) && strTypeCon.containsAll(strTypemdt)
                                            && strTypemdt.containsAll(strTypeCon))
                                        {
                                            system.debug('### 13_March : con' + objCon.WFG_Fiduciary_Advisor__c);
                                            system.debug('### 13_March : mdt' + objCon.WFG_Fiduciary_Advisor__c);
                                            mapProfileVsContactID.put(objCon.id, objMt.WFG_Profile_ID__c);
                                            break;
                                        }
                                            
                                    }
                                    // For US or PR Home office Agents
                                    else if((objCon.WFG_CycleType__c == 'US' || objCon.WFG_CycleType__c == 'PR') && (objCon.WFG_Home_Office_Agent__c == true)){
                                        if(objCon.WFG_Type__c != null){
                                            if((objCon.WFG_Type__c == 'REGISTERED_REP;IAR' || objCon.WFG_Type__c == 'REGISTERED_REP' || objCon.WFG_Type__c == 'IAR') &&  (objCon.WFG_CycleType__c == 'US' || objCon.WFG_CycleType__c == 'PR' )){
                                                mapProfileVsContactID.put(objCon.id, mapProfileNameToIds.get('RR Home Office'));
                                                break;
                                            }
                                            else
                                            if(objCon.WFG_Type__c == 'Agent'){
                                                mapProfileVsContactID.put(objCon.id, mapProfileNameToIds.get('LL US Home Office'));
                                                break;
                                            }
                                            
                                            
                                        }
                                    }
                                    
                                    // For Canada Home office Agents
                                    else if((objCon.WFG_CycleType__c == 'CA') && (objCon.WFG_Home_Office_Agent__c == true)){
                                        if(objCon.WFG_Type__c != null){
                                            if(objCon.WFG_Type__c == 'REGISTERED_REP;IAR' || objCon.WFG_Type__c == 'REGISTERED_REP' || objCon.WFG_Type__c == 'IAR'){
                                                mapProfileVsContactID.put(objCon.id, mapProfileNameToIds.get('MF Home Office'));
                                                break;
                                            }
                                            else
                                            if(objCon.WFG_Type__c == 'Agent'){
                                                mapProfileVsContactID.put(objCon.id, mapProfileNameToIds.get('LL CAN Home Office'));
                                                break;
                                            }
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        system.debug('#### 13 : '+mapProfileVsContactID);
        mapProfileVsContactID = WFG_NonREFprofileEvaluator.evaluateProfile(mapProfileVsContactID);
        return mapProfileVsContactID;
    }
}