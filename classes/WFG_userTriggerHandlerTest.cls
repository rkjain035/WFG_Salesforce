/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Samit
* @date 03-30-2017
* @description  test class for WFG_userTriggerHandler

*/
@isTest
public class WFG_userTriggerHandlerTest {
    

  public static testmethod void WFG_userTriggerHandlerTestMethod()
    {
        
        Profile p = [select name, id from profile where name= 'FA US']; 
        system.assert(p.id != null);
        String testUserName = String.valueOf(System.now().getTime()) + '@transamerica.com';
        User usr = new User( alias = 'TsClsUsr', email='testUser@transamerica.com',
                                emailencodingkey='UTF-8', lastname='TestUser1', country ='US', languagelocalekey='en_US',
                                localesidkey='en_US', profileid = p.Id,
                                timezonesidkey='America/Denver', username=testUserName, isActive=true);
        //system.assert(usr.id!=null);
        insert usr;
        
        usr.Country= 'CA';
        update usr;
        
        User objUser = WFG_Test_Data_Utility.createTestUser('FA US');
        User objUser1 = WFG_Test_Data_Utility.createTestUser('FA Home Office');
        INSERT objUser;
        Id userId = objUser.Id;
        insert objUser1;
        objUser.lastname = 'FAN';
        update objUser;
        list<ID> userIds = new list<ID>();
        userIds.add(userId);
        
        
        Test.startTest();
        System.runAs(objUser)
        {          
            WFG_Test_Data_Utility.createTriggerActivationRecords();
            list<string> lstUser = new list<string>();
            for(Id usrId: userIds){
                
                lstUser.add(usrId);
            }
            WFG_userTriggerHandler.RequestForVariables rfv = new WFG_userTriggerHandler.RequestForVariables();
            rfv.strUserId = lstUser[0];
            rfv.strInsertorDelete = 'Delete';
            list<WFG_userTriggerHandler.RequestForVariables> lstRfv = new list<WFG_userTriggerHandler.RequestForVariables>();
            lstRfv.add(rfv);
            WFG_userTriggerHandler.AddorRemovePermissionSetandLicense(lstRfv);
            INSERT new WFG_DisableUserEdit__c(setupOwnerId = UserInfo.getUserId(), WFG_Disable_Edit__c = TRUE);
            Boolean boolIsError = FALSE;
            try
            {
                objUser.FirstName = 'Test Change';
                UPDATE objUser;
            } 
            catch(exception e)
            {
                boolIsError = TRUE;
            } 
            System.assert(boolIsError);        
        }
        Test.stopTest();
        
        User objUser2 = WFG_Test_Data_Utility.createTestUser('RR US');
        objUser2.isActive = False;
        insert objUser2;
        WFG_userTriggerHandler.createCaseTeamMember = TRUE;
        objUser2.LastName ='Test RR';
        objUser2.isActive = True;
        update objUser2;
        
    }
}