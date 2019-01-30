@isTest
public class WFG_TestsWrapper {
    static void createTestData(){
    User objuser;    
    WFG_AddressWrapper addressWrap = new WFG_AddressWrapper();    
    WFG_NestedReferralSel_Wrapper nestedRefSel = new WFG_NestedReferralSel_Wrapper(objuser, '');    
    WFG_AD03_AgentsResponseWrapper agentRespWrap = new WFG_AD03_AgentsResponseWrapper();  
    agentRespWrap.ReferredBy_AgentCode  = '';
    agentRespWrap.FA_AgentCode = '';
    agentRespWrap.FA_Name = '';
    agentRespWrap.FA_Address ='';
    agentRespWrap.FA_Phone =''; 
    agentRespWrap.FA_Email ='';
    agentRespWrap.timestamp ='';
    agentRespWrap.status ='';
    agentRespWrap.error ='';
    agentRespWrap.message ='';
    agentRespWrap.path ='';        
   }
static testMethod void  testWrapper(){
   createTestData();
}   
}