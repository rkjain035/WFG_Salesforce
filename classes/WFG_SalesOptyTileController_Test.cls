@isTest
public class WFG_SalesOptyTileController_Test {
  
    @isTest
    static void testMethod0()
    {
        WFG_Test_Data_Utility.createTriggerActivationRecords();
        User canadianAgent = [select id from User where profile.Name = 'LL US' and isActive = true and country = 'US' limit 1];
        System.runAs(canadianAgent)
        {
            Contact objContact = WFG_Test_Data_Utility.createIndividualRecord('Test11', 'Contact11', '1234567290', 'Single');
            INSERT objContact;
            
            Opportunity objOpty = new Opportunity();
            objOpty.Name = 'Test Rec 1';
            objOpty.StageName = 'Needs Assessment';
            objOpty.WFG_Contact__c = objContact.id ;
            objOpty.CloseDate = Date.Today() + 20;
            objOpty.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Insurance').getRecordTypeId();
          insert objOpty;
            
           WFG_SalesOptyTileController wfg_Sales = WFG_SalesOptyTileController.fetchRecordTypes();  
        } 
    }
    @isTest
    static void testMethod1()
    {
       
        
        WFG_Test_Data_Utility.createTriggerActivationRecords();
         User objRRUser = WFG_Test_Data_Utility.createTestUser('RR US');
        INSERT objRRUser;
        System.runAs(objRRUser)
        {
            Contact objContact = WFG_Test_Data_Utility.createIndividualRecord('Test', 'Contact', '1234567890', 'Single');
            INSERT objContact;
            
            Opportunity objOpty = new Opportunity();
            objOpty.Name = 'Test Rec 1';
            objOpty.StageName = 'Needs Assessment';
            objOpty.WFG_Contact__c = objContact.id ;
            objOpty.CloseDate = Date.Today() + 20;
            objOpty.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Insurance').getRecordTypeId();
          insert objOpty;
            
           WFG_SalesOptyTileController wfg_Sales = WFG_SalesOptyTileController.fetchRecordTypes();  
        } 
        
        
    }
    @isTest
    static void testMethod2()
    {
        WFG_Test_Data_Utility.createTriggerActivationRecords();
        User usAgent = [select id from User where profile.Name = 'LL US' and isActive = true and country = 'US' limit 1];
        System.runAs(usAgent)
        {
            Contact objContact = WFG_Test_Data_Utility.createIndividualRecord('Test11', 'Contact11', '1234567290', 'Single');
            INSERT objContact;
            
            Opportunity objOpty = new Opportunity();
            objOpty.Name = 'Test Rec 1';
            objOpty.StageName = 'Needs Assessment';
            objOpty.WFG_Contact__c = objContact.id ;
            objOpty.CloseDate = Date.Today() + 20;
            objOpty.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Recruiting').getRecordTypeId();
            insert objOpty;
            
            Opportunity objOpty1 = new Opportunity();
            objOpty1.Name = 'Test Rec 1';
            objOpty1.StageName = 'WFG Registration';
            objOpty1.WFG_Contact__c = objContact.id ;
            objOpty1.CloseDate = Date.Today() + 20;
            objOpty1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Onboarding').getRecordTypeId();
            insert objOpty1;
            
            
            Test.starttest();
              WFG_SalesOptyTileController wfg_Sales = WFG_SalesOptyTileController.fetchOppRecords('Recruiting'); 
              WFG_SalesOptyTileController wfg_Sales1 = WFG_SalesOptyTileController.fetchOppRecords('Onboarding'); 
              string recruitRecType=WFG_SalesOptyTileController.getSalesOptyListViewID('recruitment');
              string salesRecType=WFG_SalesOptyTileController.getSalesOptyListViewID('sales');
              string onboardingRecType=WFG_SalesOptyTileController.getSalesOptyListViewID('onboarding');
              system.assert(wfg_Sales !=null);
              system.assert(wfg_Sales1 !=null);
              system.assert(!string.isEmpty(recruitRecType));
              system.assert(!string.isEmpty(salesRecType));
              system.assert(!string.isEmpty(onboardingRecType));
            Test.stopTest();
        } 
      
    }
    
}