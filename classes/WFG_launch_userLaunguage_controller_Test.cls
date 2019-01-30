/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Hampesh
* @date 23-Oct-2018 
* @description  

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------

Hampesh G              M-001             23-Oct-2018            test class for WFG_launch_userLaunguage_controller class 
Hampesh G              M-002             30-Oct-2018            modified code to cover exception                    
*/
@isTest
public class WFG_launch_userLaunguage_controller_Test {
public static testMethod void testMethod1(){
  test.starttest();
  string languagekey='test';
  WFG_launch_userLaunguage_controller.loggedInUserLanguage();
  WFG_launch_userLaunguage_controller.setuserLanguage(languagekey);
  test.stoptest();
  } 
}