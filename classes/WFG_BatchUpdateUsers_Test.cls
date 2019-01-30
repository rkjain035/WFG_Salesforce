/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Rashmi
* @date 9/19/2018
* @description - Test class for WFG_BatchUpdateUsers

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Rashmi               Mod-01             9/19/2018              UserStoryNo - W-027773
*/

@isTest
private class WFG_BatchUpdateUsers_Test {
    
    @testSetup static void setup() {
        list<user> userList = new list<User>();
        
        
        WFG_Test_Data_Utility.createTriggerActivationRecords();
        
        /*
        Id profileId = [select id from Profile where name = 'FA US'].id;
        Id profileId2 = [select id from Profile where name = 'FA TAN'].id;
         
        User u = WFG_Test_Data_Utility.createUserRecord('UsernameUserBatch@testname.com', true, 'ARC1233', null, profileId);
        insert u; 
        
        User u2 = WFG_Test_Data_Utility.createUserRecord('UsernameUserBatch2@testname.com', true, 'ARC1223', null, profileId2);
        insert u2; 
        
*/        
        Account a = WFG_Test_Data_Utility.createBusinessAccountRecord('Acc1', '1234P', 'USD'); // the branch where the two...
                                                        //...contact will be associated.
        insert a;
        
        Contact con1 = WFG_Test_Data_Utility.createContactTestRecord('firstName', 'lastName', a.id, 'RC1233', 12);
        insert con1; 
         
        Contact con2 = WFG_Test_Data_Utility.createContactTestRecord('firstName2', 'lastName2', a.id, 'RC1223', 12);
        insert con2;
        
        
        userList.add(WFG_Test_Data_Utility.createTestUser('FA TAN'));
        userList.add(WFG_Test_Data_Utility.createTestUser('FA US'));
        
        userList[0].WFG_Agent_Code__c =  'RC1233';
        userList[1].WFG_Agent_Code__c =  'RC1223';
        
        insert userList;
        
    }
    
    static testMethod void UpdateUsers(){
    
       
        Test.startTest();            
            DataBase.executeBatch(new WFG_BatchUpdateUsers(), 100);             
        Test.stopTest();  
    }
}