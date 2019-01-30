@isTest
private class WFG_Contact_Handler_Test {

private static Account testAcc;
private static Contact testContact1;
private static Contact testContact2;

    @testSetup static void createTestData(){
        WFG_Test_Data_Utility.createTriggerActivationRecords(); // Added during Service Center changes before FSC Installation
        Time t = System.now().time();
        String str = String.valueOf(t); 
        testAcc = WFG_Test_Data_Utility.createBranchOfficeTestRecord('WFG11',str,'USD'); 
        if(testAcc !=null){
            insert testAcc;
        }
    }
    
    static testMethod void testIndividualContact(){
        
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        Contact testContactIndividual =  WFG_Test_Data_Utility.createIndividualRecord('Test','AgentContact'+randomInt,'9999999999','Married');
        insert testContactIndividual;
        
        Integer randomInt1 = Integer.valueOf(math.rint(math.random()*1000000));
        Contact testContactIndividual1 =  WFG_Test_Data_Utility.createIndividualRecord('Test1','IndividualContact'+randomInt1 ,'9999999999','Married');
        insert testContactIndividual1;
        
        testContactIndividual.FirstName = 'Test123';
        update testContactIndividual;
    }
    
    static testMethod void testAgentContact(){
        
        WFG_StateSynonyms__c testStateSynoynm = new WFG_StateSynonyms__c(Name = 'AL', State_Name__c = 'Alabama');
        insert testStateSynoynm;
        
        WFG_CountrySynonyms__c testCountrySynoynm = new WFG_CountrySynonyms__c(Name = 'UNITED STATES', Country_Name__c = 'United States');
        insert testCountrySynoynm;
        
        Account testBranchOffice = WFG_Test_Data_Utility.createBranchOfficeTestRecord('AccountName', '1234', 'USD');
        insert testBranchOffice;
        
        Integer randomInt = Integer.valueOf(math.rint(math.random()*100));
        Contact testContactAgent =  WFG_Test_Data_Utility.createContactTestRecord('Test','IndividualContact', testBranchOffice.Id, 'ZZZ'+randomInt, 5);
        testContactAgent.WFG_Fiduciary_Advisor__c = true;
        testContactAgent.WFG_Type__c = 'Agent';
        testContactAgent.WFG_AgentPayType__c ='WFG';
        testContactAgent.WFG_CycleType__c  ='US';
        testContactAgent.WFG_Country__c = 'UNITED STATES';
        testContactAgent.WFG_State_Province__c = 'AL';
        testContactAgent.mailingState = null;
        testContactAgent.MailingCountry = null;
        insert testContactAgent;
        
        testContactAgent.FirstName = 'Test123';
        testContactAgent.WFG_AgentCode__c = 'CCC'+randomInt;
        update testContactAgent;
        
        Integer randomInt1 = Integer.valueOf(math.rint(math.random()*100));
        Contact testContactAgent1 =  WFG_Test_Data_Utility.createContactTestRecord('Test','IndividualContact', testBranchOffice.Id, 'ZCZ'+randomInt1, 5);
        testContactAgent1.WFG_AgentPayType__c = 'WFG';
        testContactAgent1.WFG_Fiduciary_Advisor__c = false;
        insert testContactAgent1;
        
        testContactAgent.FirstName = 'Test123';
        testContactAgent.WFG_AgentCode__c = 'CCC'+randomInt;
        update testContactAgent;
        
        testContactAgent1.WFG_Fiduciary_Advisor__c =true;
        update testContactAgent1;
        
    }
    
    static testMethod void testDuplicateIndividualInsert(){
        
        try{
            Contact testContactIndividual =  WFG_Test_Data_Utility.createIndividualRecord('Test','IndividualContact','9999999999','Married');
            insert testContactIndividual;
        
            Contact testContactIndividual1 =  WFG_Test_Data_Utility.createIndividualRecord('Test','IndividualContact','9999999999','Married');
            insert testContactIndividual1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('This contact') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
    }
    
    static testMethod void testDuplicateIndividualUpdate(){
        
        try{
            Contact testContactIndividual =  WFG_Test_Data_Utility.createIndividualRecord('Test','IndividualContact','9999999999','Married');
            insert testContactIndividual;
        
            Contact testContactIndividual1 =  WFG_Test_Data_Utility.createIndividualRecord('Test','IndividualContact1','9999999999','Married');
            insert testContactIndividual1;
            
            testContactIndividual1.LastName = 'IndividualContact';
            update testContactIndividual1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('This contact') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
    }
    
    static testMethod void testDuplicateAgentInsert(){
        
        try{
            Account testBranchOffice = WFG_Test_Data_Utility.createBranchOfficeTestRecord('AccountName', '1234', 'USD');
            insert testBranchOffice;
            
            Contact testContactAgent =  WFG_Test_Data_Utility.createContactTestRecord('Test','IndividualContact', testBranchOffice.Id, 'ZZZ', 5);
            insert testContactAgent;
            
            Contact testContactAgent1 =  WFG_Test_Data_Utility.createContactTestRecord('Test','IndividualContact', testBranchOffice.Id, 'ZZZ', 5);
            insert testContactAgent1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Agent Code must be unique') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
    }
    
    static testMethod void testDuplicateAgentUpdate(){
        
        try{
            Account testBranchOffice = WFG_Test_Data_Utility.createBranchOfficeTestRecord('AccountName', '1234', 'USD');
            insert testBranchOffice;
            
            Contact testContactAgent =  WFG_Test_Data_Utility.createContactTestRecord('Test','IndividualContact', testBranchOffice.Id, 'ZZZ', 5);
            insert testContactAgent;
            
            Contact testContactAgent1 =  WFG_Test_Data_Utility.createContactTestRecord('Test','IndividualContact', testBranchOffice.Id, 'ZZZA', 5);
            insert testContactAgent1;
            
            testContactAgent1.WFG_AgentCode__c = 'ZZZ';
            update testContactAgent1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Agent Code must be unique') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
    }
}