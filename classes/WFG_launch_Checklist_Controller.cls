/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Rashmi 
* @date 06/26/2018   
* @description  Controller class for Lightning component in the Checklist of WFG Launch

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Rashmi                Mod-01          06/26/2018                  W-026711 : Quering and displaying the checklist 
                                                                  when Launch user logs in into the Dashboard. 
*/

public without sharing class WFG_launch_Checklist_Controller {
    
    /**
     * This method returns the list of wrapper containing the checklist data
     * @return - list
     * @see    - @Auraenabled
     * @param  - N/A
     * @throws - N/A
     */
    @Auraenabled
    public static list<checkListWrapper> getCheckList(string strAgentCode){
        
        try{
            user objUser = new User();
            Contact objContact = new Contact();
            if(strAgentCode == null){
            
                User objLoggedinUser = [select id, WFG_Agent_Code__c from user where id =: userinfo.getuserId() limit 1];
                objContact = [select id, WFG_AgentCode__c, WFG_AgentPayType__c, WFG_CycleType__c, WFG_Type__c, WFG_Fiduciary_Advisor__c from Contact where WFG_AgentCode__c =: objLoggedinUser.WFG_Agent_Code__c]; 
            } else if(strAgentCode == 'No Downlines')
            {
                return null;
            }
            else{
                
                objContact = [select id, WFG_AgentCode__c, WFG_AgentPayType__c, WFG_CycleType__c, WFG_Type__c, WFG_Fiduciary_Advisor__c from Contact where WFG_AgentCode__c =: strAgentCode]; 
                
            }
            
            map<string, string> mapAPItoCustomLableVal = new map<string, string>();
            map<string, string> mapAPItoLabel = new map<string, string>();
            WFG_Onboarding_Checklist__c objOnboardingChecklist;
            
            //if the logged in user's profile is US, show the checklist related to US user
            if((objContact.WFG_CycleType__c.contains('US') || objContact.WFG_CycleType__c.contains('PR'))){// && objContact.WFG_Type__c.contains('Launch')){
            
                //fetches the fileds added in the US_Fields_for_Checklist field set.
                list<Schema.FieldSetMember> lstUSFieldSet= Schema.SObjectType.WFG_Onboarding_Checklist__c.fieldSets.getMap().get('US_Fields_for_Checklist').getFields();
                //fetches the value stored in the label WFG_Launch_USChecklist
                string strUSLabel = label.WFG_Launch_USChecklist;
                list<string> listUSCheckList = strUSLabel.split(';');
                
                for(Schema.FieldSetMember objUSCheck : lstUSFieldSet){
                    
                    mapAPItoLabel.put(objUSCheck.getFieldPath(), objUSCheck.getLabel());
                }
                for(integer i=0;i<listUSCheckList.size() ; i++){
                
                    mapAPItoCustomLableVal.put(lstUSFieldSet[i].getFieldPath(), listUSCheckList[i]);
                }
            }
            
            //if the logged in user's profile is CAN, show the checklist related to Canada user
            if(objContact.WFG_CycleType__c.contains('CA')){// && objContact.WFG_Type__c.contains('Launch')){
                
                //fetches the fileds added in the Canada_fields_for_Checklist field set.
                list<Schema.FieldSetMember> lstCANFieldSet= Schema.SObjectType.WFG_Onboarding_Checklist__c.fieldSets.getMap().get('Canada_fields_for_Checklist').getFields();
                //fetches the value stored in the label WFG_Launch_CANChecklist
                string strCANLabel = label.WFG_Launch_CANChecklist;
                list<string> listCheckList = strCANLabel.split(';');
                
                for(Schema.FieldSetMember objCANCheck : lstCANFieldSet){
                    
                    mapAPItoLabel.put(objCANCheck.getFieldPath(), objCANCheck.getLabel());
                }  
                for(integer i=0;i<listCheckList.size() ; i++){
                
                    mapAPItoCustomLableVal.put(lstCANFieldSet[i].getFieldPath(), listCheckList[i]);
                }
            }
            
            //fetches the onboarding checklist related to logged in user.
            list<WFG_Onboarding_Checklist__c> lstOnboardingChecklist = [select id, CreatedDate, Recruiting_Contact__c, Agency_Agreement_Approved__c, Agency_Agreement_Submitted__c, Contracting_App_Received__c, Contracting_Approved_By_Council__c, Contracting_Sent_To_Council__c, Launch_Accessed__c, Pre_Licensing_Complete__c, Pre_Licensing_Started__c, WFG_Registration_Approved__c, WFG_Registration_Submitted__c 
                                                                        from WFG_Onboarding_Checklist__c where Contact__c =: objContact.id Limit 1];
            
            //wrapper list containing the field label(licensing step) and boolean (represents if step is completed or not)
            list<checkListWrapper> listCheckListWrapper= new list<checkListWrapper>();
            if(!lstOnboardingChecklist.isEmpty()){
                
                for(string strTemp: mapAPItoLabel.keyset()){
                    
                    listCheckListWrapper.add(new checkListWrapper(mapAPItoCustomLableVal.get(strTemp).replace('_',' '), boolean.valueof(lstOnboardingChecklist[0].get(strTemp))));
                }
            }
            
            return listCheckListWrapper;
            
        }catch(Exception e)
        {
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_launch_Checklist_Controller', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
            return null;
        }
    }
    
    /**
     * Wrapper class to contain licensing step and if it is completed or not
     * @return - N/A
     * @see    - N/A
     * @param  - N/A
     * @throws - N/A
     */
    public class checkListWrapper{
       @AuraEnabled
       public string checkListValue { get; set;}
       @AuraEnabled
       public boolean isChecklistCompleted  { get; set;}
       public checkListWrapper(string checkListValue, boolean isChecklistCompleted){
           this.checkListValue = checkListValue;
           this.isChecklistCompleted = isChecklistCompleted;
       }
    }
    
}