/**
    *
    Property of Transamerica andAegoncompanies.Do not distribute without permission.
    * Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
    * @author Ninad
    * @date 12-22-2016
    * @description  test class for Referral trigger
    
    Modification Log:
    --------------------------------------------------------------------------------------------------------
    Developer             Mod Number         Date                    Description
    --------------------------------------------------------------------------------------------------------
    Ninad Patil          M-001             12-22-2016              trigger handler
    */
    @isTest
    private class WFG_Referral_Test 
    {
        public static List<Contact> lstContacts = new List<Contact>();
        public static List<WFG_Customer_Profile__c> lstCustrofile = new List<WFG_Customer_Profile__c>();
        public static List<WFG_Referral__c> lstReferral = new List<WFG_Referral__c>();
        
        private static void populateList()
        {
          lstContacts = [Select id, name , email,firstName,lastName,MailingState,MailingCity,
            MailingPostalCode,MailingStreet from Contact];
              lstCustrofile = [Select id, name ,WFG_Contact__r.FirstName,WFG_Contact__r.LastName,
               WFG_Contact__r.Email, WFG_Contact__r.Phone,WFG_Contact__r.MailingCountry,
               WFG_Contact__r.MailingCity from WFG_Customer_Profile__C ];
              lstReferral = [Select id, name,WFG_Email__c,WFG_Contact_First_Name__c,
              WFG_Contact_Last_Name__c,WFG_Home_Country__c,WFG_State__c,
              WFG_City__c,WFG_Street_Address__c from WFG_Referral__C];
        }
        /**
        @author Ninad Patil
        @date 22-Dec-2016
        @description data Creation method
        @return - void
        @param  - NA
        @throws - N/A
        @author Ninad
        */
        
        @testSetup
        static void craeteDataForReferral()
        {
            WFG_Test_Data_Utility.createTriggerActivationRecords();
            User objRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
            objRRUser.userName = 'ninad_dev@test.com.dev';
            insert objRRUser;
          system.runAs(objRRUser)
          {
            
              for(Integer intVar=0; intVar < 200; intVar++)
              {
                  //WFG_Test_Data_Utility.createIndividualRecord('LL', 'Contact', '7878787878', 'Single');
                  lstContacts.add(WFG_Test_Data_Utility.createIndividualRecord('firstName_' + intVar, 
                  'lastName_' + intVar, '9867775643', 'Single'));
                  lstContacts[intVar].email = 'asdfa_' + intVar + '@asdf.com'; 
              }
              insert lstContacts;
              for(Integer intVar=0; intVar < lstContacts.size(); intVar++)
              {
                  lstCustrofile.add(WFG_Test_Data_Utility.createCustomerProfile(lstContacts[intVar].id));
              }
              insert lstCustrofile;
          }
        }
        /**
        @author Ninad Patil
        @date 22-Dec-2016
        @description test methods for referral creation
        @return - void
        @param  - NA
        @throws - N/A
        @author Ninad
        */
        static testMethod void testReferralCreation() 
        {       
            User objRRUser = [Select id, name from User WHere profile.Name = 'RR US' AND userName = 'ninad_dev@test.com.dev'];
            User objFAUser = WFG_Test_Data_Utility.createTestUser(System.Label.WFG_FA_Label);
            insert objFAUser;
            populateList();
            Test.startTest();
            system.runAs(objRRUser)
            {
                //craeteDataForReferral();
                list <Id> lstId = new List<Id>();
                for(Contact objContact : lstContacts)
                {
                    lstId.add(objContact.id);
                }
                lstContacts = [Select id, name, firstName, lastName,
                        MailingCountry, MailingState,MailingCity, MailingPostalCode,
                        MailingStreet from Contact WHERE Id IN : lstId];  
                for(Integer intVar=0; intVar<lstCustrofile.size(); intVar ++)
                {
                    lstReferral.add(WFG_Test_Data_Utility.createReferral(lstCustrofile[intVar], objFAUser.id));
                }
                lstReferral = WFG_SystemModeHelper.createReferralRecord(lstReferral);
                
                List<WFG_Referral__Share> lstShare = [Select id,  ParentId,
                                UserOrGroupId, AccessLevel from WFG_Referral__Share
                                Where ParentId = :lstReferral[1].id];
                system.assertEquals(lstShare.size(), 2);
                            
                lstReferral[1].WFG_status__c = system.Label.WFG_ReferralStatus_Referred;
                update lstReferral[1];
                
                lstShare = [Select id,  ParentId,
                                UserOrGroupId, AccessLevel from WFG_Referral__Share
                                Where ParentId = :lstReferral[1].id];
                system.assertEquals(lstShare.size(), 2);            
                
                //simulate Error condition
                WFG_Referral__c objRef = WFG_Test_Data_Utility.createReferral(lstCustrofile[0], objFAUser.id);
                try
                {
                    //insert objRef;
                    List <WFG_referral__c> lstRef1 = new List<WFG_referral__c>{objRef};
                    lstRef1 = WFG_SystemModeHelper.createReferralRecord(lstRef1);
                }
                catch(Exception e)
                {
                    system.assert(e.getMessage().length()>0);
                }
                
                //Creating referral
                try
                {
                    lstReferral[1].WFG_status__c = system.Label.WFG_ReferralStatus_Cancelled;
                    update lstReferral[1];
                    
                    lstReferral[1].WFG_status__c = system.Label.WFG_ReferralStatus_Referred;
                    lstReferral[1].WFG_Referred_By__c = UserInfo.getUserId();
                    lstReferral[1].WFG_Referred_To__c = UserInfo.getUserId();
                    update lstReferral[1];
                }
                catch(exception e)
                {
                    system.assert(e.getMessage().length()>0);
                }
            }
            
            system.runAs(objFAUser)
            {
                lstReferral[0].WFG_status__c = system.Label.WFG_ReferralStatus_Accepted;
                update lstReferral[0];
                
                lstReferral = [Select id, name , WFG_EMail__c from WFG_Referral__c WHERE ID = :lstReferral[0].id];          
            }
            Test.stopTest();
        }
        
        /**
        @author Ninad Patil
        @date 22-Dec-2016
        @description test methods for referral creation
        @return - void
        @param  - NA
        @throws - N/A
        @author Ninad
        */
        static testMethod void testReferralclosing() 
        {       
            //User objRRUser = WFG_Test_Data_Utility.createTestUser(System.Label.WFG_RR_Label);
            User objRRUser = [Select id, name from User WHere profile.name = 'RR US' AND UserName =  'ninad_dev@test.com.dev'];
            User objFAUser = WFG_Test_Data_Utility.createTestUser(System.Label.WFG_FA_Label);
            insert objFAUser;
            populateList();
            string strAccountId = '';
            Test.startTest();
            system.runAs(objRRUser)
            {
                //craeteDataForReferral();
                list <Id> lstId = new List<Id>();
                for(Contact objContact : lstContacts)
                {
                    lstId.add(objContact.id);
                }
                lstContacts = [Select id, name, firstName, lastName,
                        MailingCountry, MailingState,MailingCity, MailingPostalCode,
                        MailingStreet from Contact WHERE Id IN : lstId];  
                for(Integer intVar=0; intVar<lstCustrofile.size(); intVar ++)
                {
                    lstReferral.add(WFG_Test_Data_Utility.createReferral(lstCustrofile[intVar], objFAUser.id));
                    lstReferral[intVar].WFG_Email__c = 'asdfa_' + intVar + '@asdf.com';
                    lstReferral[intVar].WFG_Contact_First_Name__c = lstContacts[intVar].firstName;
                    lstReferral[intVar].WFG_Contact_Last_Name__c = lstContacts[intVar].lastName;
                    lstReferral[intVar].WFG_Home_Country__c = WFG_PicklistFieldDescribeUtility.getPicklistValueLabel('Contact','MailingCountryCode', lstContacts[intVar].MailingCountry); 
                    lstReferral[intVar].WFG_State__c = lstContacts[intVar].MailingState;
                    lstReferral[intVar].WFG_City__c = lstContacts[intVar].MailingCity;
                    lstReferral[intVar].WFG_Zipcode__c = lstContacts[intVar].MailingPostalCode;
                    lstReferral[intVar].WFG_Street_Address__c = lstContacts[intVar].MailingStreet;
                }
                lstReferral = WFG_SystemModeHelper.createReferralRecord(lstReferral);
                
            }
            
            system.runAs(objFAUser)
            {
                lstReferral[0].WFG_status__c = system.Label.WFG_ReferralStatus_Accepted;
                update lstReferral[0];
                
                list<WFG_Referral__c> lstReferral1 = [Select id, name , WFG_EMail__c from WFG_Referral__c WHERE ID = :lstReferral[0].id];
                            
                lstReferral[0].WFG_status__c = system.Label.WFG_ReferralStatus_CompleteSold; 
                try
                {
                    update lstReferral[0];
                }
                catch(Exception e)
                {
                    system.assert(e.getmessage().contains(System.Label.WFG_OpportunityForReferralCompletionErrMsg));
                }
                lstReferral[0].WFG_status__c = System.Label.WFG_ReferralStatus_CompleteNotSold;
                update lstReferral[0];
                system.assertEquals(System.Label.WFG_ReferralStatus_CompleteNotSold, [Select WFG_status__c
                    FROM WFG_referral__c WHERE Id = :lstReferral[0].id ].WFG_status__c);

                
                WFG_ReferralResponseWrapper objREs = WFG_ReferralUtility.createOrsearchContact(lstReferral[1]);
                system.assertNotEquals(objREs.objGenericRes.boolIsError, null);
                system.assertNotEquals(objREs.objContact, null);
                //Create Financial Account under Referral.
                Contact objCon = [Select id, name, accountid,FinServ__IndividualId__c from Contact WHERE Id = :objREs.objContact.id];
                //Account objACc = WFG_Test_Data_Utility.createIndividualRecord('Dummy ACcount');
                //insert objAcc;
                
                //FinServ__FinancialAccount__c objFA = WFG_Test_Data_Utility.createIndividualInvestmentAccountRecord(objAcc.id); 
                //objFA.RecordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Investment Account').getRecordTypeId(); 
                //insert objFA;
                
                lstReferral[0].WFG_status__c = System.Label.WFG_ReferralStatus_CompleteNotSold;
                try
                {
                    update lstReferral[0];
                }
                catch(Exception e)
                {
                    //system.assertEquals(e.getMEssage(),'incomplete');
                }
            }
            Test.stopTest();
        } 
        /**
        @author Ninad Patil
        @date 22-Dec-2016
        @description test methods for referral creation
        @return - void
        @param  - NA
        @throws - N/A
        @author Ninad
        */
        static testMethod void testReferralCompleteNOTSold() 
        {       
            //User objRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
            User objRRUser = [Select id, name from User WHere profile.name = 'RR US' AND UserName =  'ninad_dev@test.com.dev'];
            User objFAUser = WFG_Test_Data_Utility.createTestUser('FA US');
            insert objFAUser;
            populateList();
            string strAccountId = '';
            Test.startTest();
            system.runAs(objRRUser)
            {
                //craeteDataForReferral();
                list <Id> lstId = new List<Id>();
                for(Contact objContact : lstContacts)
                {
                    lstId.add(objContact.id);
                }
                lstContacts = [Select id, name, firstName, lastName,
                        MailingCountry, MailingState,MailingCity, MailingPostalCode,
                        MailingStreet from Contact WHERE Id IN : lstId];  
                for(Integer intVar=0; intVar<lstCustrofile.size(); intVar ++)
                {
                    lstReferral.add(WFG_Test_Data_Utility.createReferral(lstCustrofile[intVar], objFAUser.id));
                    lstReferral[intVar].WFG_Email__c = 'asdfa_' + intVar + '@asdf.com';
                    lstReferral[intVar].WFG_Contact_First_Name__c = lstContacts[intVar].firstName;
                    lstReferral[intVar].WFG_Contact_Last_Name__c = lstContacts[intVar].lastName;
                    lstReferral[intVar].WFG_Home_Country__c = WFG_PicklistFieldDescribeUtility.getPicklistValueLabel('Contact','MailingCountryCode', lstContacts[intVar].MailingCountry); 
                    lstReferral[intVar].WFG_State__c = lstContacts[intVar].MailingState;
                    lstReferral[intVar].WFG_City__c = lstContacts[intVar].MailingCity;
                    lstReferral[intVar].WFG_Zipcode__c = lstContacts[intVar].MailingPostalCode;
                    lstReferral[intVar].WFG_Street_Address__c = lstContacts[intVar].MailingStreet;
                }
                lstReferral = WFG_SystemModeHelper.createReferralRecord(lstReferral);
                
            }
            
            system.runAs(objFAUser)
            {
                lstReferral[0].WFG_status__c = system.Label.WFG_ReferralStatus_Accepted;
                update lstReferral[0];
                
                list<WFG_Referral__c> lstReferral1 = [Select id, name , WFG_EMail__c from WFG_Referral__c WHERE ID = :lstReferral[0].id];
                            
                lstReferral[0].WFG_status__c = system.Label.WFG_ReferralStatus_CompleteNotSold; 
                update lstReferral[0];
                
            }
            Test.stopTest();
        } 
        /**
        @author Ninad Patil
        @date 22-Dec-2016
        @description test methods for referral creation
        @return - void
        @param  - NA
        @throws - N/A
        @author Ninad
        */
        static testMethod void testReferralCompleteNOTSoldNegFin() 
        {       
            //User objRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
            User objRRUser = [Select id, name from User WHere profile.name = 'RR US' AND UserName =  'ninad_dev@test.com.dev'];
            User objFAUser = WFG_Test_Data_Utility.createTestUser('FA US');
            insert objFAUser;
            populateList();
            string strAccountId = '';
            Test.startTest();
            system.runAs(objRRUser)
            {
                //craeteDataForReferral();
                list <Id> lstId = new List<Id>();
                for(Contact objContact : lstContacts)
                {
                    lstId.add(objContact.id);
                }
                lstContacts = [Select id, name, firstName, lastName,
                        MailingCountry, MailingState,MailingCity, MailingPostalCode,
                        MailingStreet from Contact WHERE Id IN : lstId];  
                for(Integer intVar=0; intVar<lstCustrofile.size(); intVar ++)
                {
                    lstReferral.add(WFG_Test_Data_Utility.createReferral(lstCustrofile[intVar], objFAUser.id));
                    lstReferral[intVar].WFG_Email__c = 'asdfa_' + intVar + '@asdf.com';
                    lstReferral[intVar].WFG_Contact_First_Name__c = lstContacts[intVar].firstName;
                    lstReferral[intVar].WFG_Contact_Last_Name__c = lstContacts[intVar].lastName;
                    lstReferral[intVar].WFG_Home_Country__c = WFG_PicklistFieldDescribeUtility.getPicklistValueLabel('Contact','MailingCountryCode', lstContacts[intVar].MailingCountry); 
                    lstReferral[intVar].WFG_State__c = lstContacts[intVar].MailingState;
                    lstReferral[intVar].WFG_City__c = lstContacts[intVar].MailingCity;
                    lstReferral[intVar].WFG_Zipcode__c = lstContacts[intVar].MailingPostalCode;
                    lstReferral[intVar].WFG_Street_Address__c = lstContacts[intVar].MailingStreet;
                    
                }
                lstReferral = WFG_SystemModeHelper.createReferralRecord(lstReferral);       
            }
            
            system.runAs(objFAUser)
            {
                lstReferral[0] = [Select id, name , WFG_status__C , WFG_Home_Country__c from WFG_Referral__c WHere id =:lstReferral[0].id];
                WFG_ReferralResponseWrapper objres = WFG_ReferralUtility.acceptReferral(lstReferral[0].Id);
                lstReferral[0] = [Select id, name , WFG_status__C , WFG_Home_Country__c from WFG_Referral__c WHere id =:lstReferral[0].id];
                
                list<WFG_Referral__c> lstReferral1 = [Select id, name , WFG_EMail__c from WFG_Referral__c WHERE ID = :lstReferral[0].id];
                
                /*Account objACc = WFG_Test_Data_Utility.createIndividualRecord('Dummy ACcount');
                insert objAcc;
                
                FinServ__FinancialAccount__c objFA = WFG_Test_Data_Utility.createIndividualInvestmentAccountRecord(objAcc.id); 
                objFA.RecordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Investment Account').getRecordTypeId(); 
                objFA.WFG_Referral__C =  lstReferral[0].id;
                insert objFA;
                
                try
                {
                    lstReferral[0].WFG_status__c = 'Completed - Not Sold';
                    update lstReferral[0];
                }
                catch(Exception e)
                {
                    system.assert(e.getMessage().contains(system.Label.WFG_PolicyForReferralInCompleteErrMsg));
                    //system.assertNotEquals(e.getMessage(),e.getMessage());
                }*/
                //Create Opportunity
                WFG_Customer_Profile__c objCP = [SELECT Id, WFG_Contact__c, WFG_Contact__r.AccountId FROM WFG_Customer_Profile__c LIMIT 1];
                Opportunity objOpty = new Opportunity();
                objOpty.Name = 'Test 1';
                objOpty.StageName = system.Label.WFG_OpportunityStage_NeedAssessment;
                objOpty.WFG_CustomerProfile__c = objCP.Id;
                objOpty.WFG_Contact__c = objCP.WFG_Contact__c;
                objOpty.CloseDate = Date.Today();
                objOpty.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_OpportunityQualifiedRetirement).getRecordTypeId();
                objOpty.WFG_Source__c = System.Label.WFG_OpportunitySourceReferral;
                objOpty.WFG_referral__c = lstReferral[0].id;
                INSERT objOpty;
                
                system.assertEquals(objOpty.WFG_referral__C, lstReferral[0].id);
                
                try
                {
                    lstReferral[0].WFG_status__c = system.Label.WFG_ReferralStatus_CompleteNotSold; 
                    update lstReferral[0];
                }
                catch(Exception e)
                {
                    system.assert(e.getMessage().contains(System.Label.WFG_OpportunityForReferralInCompletionErrMsg));
                }
            }
            Test.stopTest();
        }    
        
        /**
        @author Ninad Patil
        @date 22-Dec-2016
        @description test methods for referral creation
        @return - void
        @param  - NA
        @throws - N/A
        @author Ninad
        */
        static testMethod void testReferralCompleteSoldNegOpty() 
        {       
            //User objRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
            User objRRUser = [Select id, name from User WHere profile.name = 'RR US' AND UserName =  'ninad_dev@test.com.dev'];
            User objFAUser = WFG_Test_Data_Utility.createTestUser('FA US');
            insert objFAUser;
            populateList();
            string strAccountId = '';
            Test.startTest();
            system.runAs(objRRUser)
            {
                //craeteDataForReferral();
                list <Id> lstId = new List<Id>();
                for(Contact objContact : lstContacts)
                {
                    lstId.add(objContact.id);
                }
                lstContacts = [Select id, name, firstName, lastName,
                        MailingCountry, MailingState,MailingCity, MailingPostalCode,
                        MailingStreet from Contact WHERE Id IN : lstId];  
                for(Integer intVar=0; intVar<lstCustrofile.size(); intVar ++)
                {
                    lstReferral.add(WFG_Test_Data_Utility.createReferral(lstCustrofile[intVar], objFAUser.id));
                    lstReferral[intVar].WFG_Email__c = 'asdfa_' + intVar + '@asdf.com';
                    lstReferral[intVar].WFG_Contact_First_Name__c = lstContacts[intVar].firstName;
                    lstReferral[intVar].WFG_Contact_Last_Name__c = lstContacts[intVar].lastName;
                    lstReferral[intVar].WFG_Home_Country__c = WFG_PicklistFieldDescribeUtility.getPicklistValueLabel('Contact','MailingCountryCode', lstContacts[intVar].MailingCountry); 
                    lstReferral[intVar].WFG_State__c = lstContacts[intVar].MailingState;
                    lstReferral[intVar].WFG_City__c = lstContacts[intVar].MailingCity;
                    lstReferral[intVar].WFG_Zipcode__c = lstContacts[intVar].MailingPostalCode;
                    lstReferral[intVar].WFG_Street_Address__c = lstContacts[intVar].MailingStreet;
                }
                lstReferral = WFG_SystemModeHelper.createReferralRecord(lstReferral);
                
            }
            
            system.runAs(objFAUser)
            {
                //lstReferral[0].WFG_status__c = 'Accepted';
                //update lstReferral[0];
                WFG_ReferralUtility.acceptReferral(lstReferral[0].Id);
                
                list<WFG_Referral__c> lstReferral1 = [Select id, name , WFG_EMail__c from WFG_Referral__c WHERE ID = :lstReferral[0].id];
                
                //Account objACc = WFG_Test_Data_Utility.createIndividualRecord('Dummy ACcount');
                //insert objAcc;
                
                //Create Opportunity
                WFG_Customer_Profile__c objCP = [SELECT Id, WFG_Contact__c, WFG_Contact__r.AccountId FROM WFG_Customer_Profile__c LIMIT 1];
                Opportunity objOpty = new Opportunity();
                objOpty.Name = 'Test 1';
                objOpty.StageName = system.Label.WFG_OpportunityStage_NeedAssessment;
                objOpty.WFG_CustomerProfile__c = objCP.Id;
                objOpty.WFG_Contact__c = objCP.WFG_Contact__c;
                objOpty.CloseDate = Date.Today();
                objOpty.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_OpportunityQualifiedRetirement).getRecordTypeId();
                objOpty.WFG_Source__c = System.Label.WFG_OpportunitySourceReferral;
                objOpty.WFG_referral__c = lstReferral[0].id;
                INSERT objOpty;
                
                try
                {
                    lstReferral[0].WFG_status__c = system.Label.WFG_ReferralStatus_CompleteSold; 
                    update lstReferral[0];
                }
                catch(Exception e)
                {
                    system.assert(e.getMessage().contains(system.Label.WFG_OpportunityForReferralCompletionErrMsg));
                }
            }
            Test.stopTest();
        } 
        /**
        @author Ninad Patil
        @date 22-Dec-2016
        @description test methods for referral creation
        @return - void
        @param  - NA
        @throws - N/A
        @author Ninad
        */
        static testMethod void testReferralCompleteSoldOpty() 
        {       
            //User objRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
            User objRRUser = [Select id, name from User WHere profile.name = 'RR US' AND UserName =  'ninad_dev@test.com.dev'];
            User objFAUser = WFG_Test_Data_Utility.createTestUser('FA US');
            insert objFAUser;
            string strAccountId = '';
            populateList();
            Test.startTest();
            system.runAs(objRRUser)
            {
                //craeteDataForReferral();
                list <Id> lstId = new List<Id>();
                for(Contact objContact : lstContacts)
                {
                    lstId.add(objContact.id);
                }
                lstContacts = [Select id, name, firstName, lastName,
                        MailingCountry, MailingState,MailingCity, MailingPostalCode,
                        MailingStreet from Contact WHERE Id IN : lstId];  
                for(Integer intVar=0; intVar<lstCustrofile.size(); intVar ++)
                {
                    lstReferral.add(WFG_Test_Data_Utility.createReferral(lstCustrofile[intVar], objFAUser.id));
                    lstReferral[intVar].WFG_Email__c = 'asdfa_' + intVar + '@asdf.com';
                    lstReferral[intVar].WFG_Contact_First_Name__c = lstContacts[intVar].firstName;
                    lstReferral[intVar].WFG_Contact_Last_Name__c = lstContacts[intVar].lastName;
                    lstReferral[intVar].WFG_Home_Country__c = WFG_PicklistFieldDescribeUtility.getPicklistValueLabel('Contact','MailingCountryCode', lstContacts[intVar].MailingCountry); 
                    lstReferral[intVar].WFG_State__c = lstContacts[intVar].MailingState;
                    lstReferral[intVar].WFG_City__c = lstContacts[intVar].MailingCity;
                    lstReferral[intVar].WFG_Zipcode__c = lstContacts[intVar].MailingPostalCode;
                    lstReferral[intVar].WFG_Street_Address__c = lstContacts[intVar].MailingStreet;
                }
                lstReferral = WFG_SystemModeHelper.createReferralRecord(lstReferral);
                
            }
            
            system.runAs(objFAUser)
            {
                //lstReferral[0].WFG_status__c = 'Accepted';
                //update lstReferral[0];
                WFG_ReferralUtility.acceptReferral(lstReferral[0].Id);
                
                list<WFG_Referral__c> lstReferral1 = [Select id, name , WFG_EMail__c from WFG_Referral__c WHERE ID = :lstReferral[0].id];
                
                //Account objACc = WFG_Test_Data_Utility.createIndividualRecord('Dummy ACcount');
                //insert objAcc;
                
                //Create Opportunity
                WFG_Customer_Profile__c objCP = [SELECT Id, WFG_Contact__c, WFG_Contact__r.AccountId FROM WFG_Customer_Profile__c LIMIT 1];
                Opportunity objOpty = new Opportunity();
                objOpty.Name = 'Test 1';
                objOpty.StageName = system.Label.WFG_OpportunityStage_NeedAssessment;
                objOpty.WFG_CustomerProfile__c = objCP.Id;
                objOpty.WFG_Contact__c = objCP.WFG_Contact__c;
                objOpty.CloseDate = Date.Today();
                objOpty.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.WFG_OpportunityQualifiedRetirement).getRecordTypeId();
                objOpty.WFG_Source__c = System.Label.WFG_OpportunitySourceReferral;
                objOpty.WFG_referral__c = lstReferral[0].id;
                INSERT objOpty;
                objOpty.stageName = system.label.WFG_OpportunityStage_CloseWon;
                update objOpty;
                
                /*FinServ__FinancialAccount__c objFA = WFG_Test_Data_Utility.createIndividualInvestmentAccountRecord(objAcc.id); 
                objFA.RecordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Investment Account').getRecordTypeId(); 
                objFA.WFG_Referral__C =  lstReferral[0].id;
                insert objFA;*/
                
                try
                {
                    
                    lstReferral[0].WFG_status__c = system.Label.WFG_ReferralStatus_CompleteSold; 
                    update lstReferral[0];
                }
                catch(Exception e)
                {
                    system.assert(e.getMessage().contains(system.Label.WFG_OpportunityForReferralCompletionErrMsg));
                    //system.assertNOTEquals(e.getMessage(),e.getMessage());
                }
            }
            Test.stopTest();
        }
        /**
        @author Ninad Patil
        @date 22-Dec-2016
        @description test methods for referral creation
        @return - void
        @param  - NA
        @throws - N/A
        @author Ninad
        */
        static testMethod void testMultipleReferral() 
        {       
            //User objRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
            User objRRUser = [Select id, name from User WHere profile.name = 'RR US' AND UserName =  'ninad_dev@test.com.dev'];
            User objFAUser = WFG_Test_Data_Utility.createTestUser('FA US');
            insert objFAUser;
            string strAccountId = '';
            Test.startTest();
            populateList();
            system.runAs(objRRUser)
            {
                //craeteDataForReferral();
                list <Id> lstId = new List<Id>();
                for(Contact objContact : lstContacts)
                {
                    lstId.add(objContact.id);
                }
                lstContacts = [Select id, name, firstName, lastName,
                        MailingCountry, MailingState,MailingCity, MailingPostalCode,
                        MailingStreet from Contact WHERE Id IN : lstId];  
                for(Integer intVar=0; intVar<lstCustrofile.size(); intVar ++)
                {
                    lstReferral.add(WFG_Test_Data_Utility.createReferral(lstCustrofile[intVar], objFAUser.id));
                    lstReferral[intVar].WFG_Email__c = 'asdfa_' + intVar + '@asdf.com';
                    lstReferral[intVar].WFG_Contact_First_Name__c = lstContacts[intVar].firstName;
                    lstReferral[intVar].WFG_Contact_Last_Name__c = lstContacts[intVar].lastName;
                    lstReferral[intVar].WFG_Home_Country__c = WFG_PicklistFieldDescribeUtility.getPicklistValueLabel('Contact','MailingCountryCode', lstContacts[intVar].MailingCountry); 
                    lstReferral[intVar].WFG_State__c = lstContacts[intVar].MailingState;
                    lstReferral[intVar].WFG_City__c = lstContacts[intVar].MailingCity;
                    lstReferral[intVar].WFG_Zipcode__c = lstContacts[intVar].MailingPostalCode;
                    lstReferral[intVar].WFG_Street_Address__c = lstContacts[intVar].MailingStreet;
                }
                lstReferral = WFG_SystemModeHelper.createReferralRecord(lstReferral);
                try
                {
                    WFG_SystemModeHelper.createReferralRecord(new List<WFG_Referral__c>{WFG_Test_Data_Utility.createReferral(lstCustrofile[0], objFAUser.id)});
                }
                catch(Exception e)
                {
                    system.assert(e.getMessage().length()>0);
                }
            }
            Test.stopTest();
        }
        
         /**
        @author Bharat Madaan
        @date 23-May-2017
        @description test methods for referral creation
        @return - void
        @param  - NA
        @throws - N/A
        @author bmadaan
        */
        /*static testMethod void testpopulateActiveReferral() 
        {   
          map < id, WFG_REferral__C > mapNewref;
            map < Id, WFG_Referral__c > mapOldRef;
            //User objRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
            User objRRUser = [Select id, name from User WHere profile.name = 'RR US' AND UserName =  'ninad_dev@test.com.dev'];
            User objFAUser = WFG_Test_Data_Utility.createTestUser('FA US');
            insert objFAUser;
            string strAccountId = '';
            populateList();
            Test.startTest();
            system.runAs(objRRUser)
            {
                //craeteDataForReferral();
                list <Id> lstId = new List<Id>();
                for(Contact objContact : lstContacts)
                {
                    lstId.add(objContact.id);
                }
                lstContacts = [Select id, name, firstName, lastName,
                        MailingCountry, MailingState,MailingCity, MailingPostalCode,
                        MailingStreet from Contact WHERE Id IN : lstId];
                 for(Integer intVar=0; intVar<lstCustrofile.size(); intVar ++)
                {
                    lstReferral.add(WFG_Test_Data_Utility.createReferral(lstCustrofile[intVar], objFAUser.id));
                    
                    lstReferral[intVar].WFG_Email__c = 'asdfa_' + intVar + '@asdf.com';
                    lstReferral[intVar].WFG_Contact_First_Name__c = lstContacts[intVar].firstName;
                    lstReferral[intVar].WFG_Contact_Last_Name__c = lstContacts[intVar].lastName;
                    lstReferral[intVar].WFG_Home_Country__c = WFG_PicklistFieldDescribeUtility.getPicklistValueLabel('Contact','MailingCountryCode', lstContacts[intVar].MailingCountry); 
                    lstReferral[intVar].WFG_State__c = lstContacts[intVar].MailingState;
                    lstReferral[intVar].WFG_City__c = lstContacts[intVar].MailingCity;
                    lstReferral[intVar].WFG_Zipcode__c = lstContacts[intVar].MailingPostalCode;
                    lstReferral[intVar].WFG_Street_Address__c = lstContacts[intVar].MailingStreet;
                }
                insert lstReferral;
                lstReferral[0].WFG_Status__c = 'Referred';
                update lstReferral;
            } 
        }*/
    }