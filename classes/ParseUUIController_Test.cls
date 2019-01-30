@istest
private class ParseUUIController_Test {

    static testmethod void testUUIPopMatchingAgentCode()
    {
        
        Contact testContact = new Contact();
        testContact.LastName = 'Test';
        testContact.WFG_AgentCode__c = '001BBC';
        testContact.WFG_AgentLevel__c = 1;
        insert testContact;
        
        WFG_AgentCode__c agentCode = new WFG_AgentCode__c();
        agentCode.WFG_AgentCode__c = '001BBC';
        agentCode.WFG_Contact__c = testContact.Id;
        insert agentCode;
        
        //UUI Layout
        //Agent (A) | Agent ID | Authenticated | Last Menu Text | Collected Digits | IVR Call Start | IVR Call End
        //    0           1           2                3                  4               5  6 7               8910
        
		string theUUI = 'A|'+agentCode.WFG_AgentCode__c+'|Y|test|test|test|test';
        //string theUUI = 'A|001BBC|Y|test|test|test|test';
        
        PageReference testPage = Page.ParseUUI;

        test.setCurrentPage(testPage);
        ApexPages.currentPage().getParameters().put('UUI',theUUI);
        ParseUUIController controller = new ParseUUIController();
		controller.UUIData = theUUI;
        controller.ParseUUIController();
        controller.Redirect();
        
    }
    
        static testmethod void testUUIPopNoMatchingAgentCode()
    {
        
        Contact testContact = new Contact();
        testContact.LastName = 'Test';
        testContact.WFG_AgentCode__c = '001BBC';
        testContact.WFG_AgentLevel__c = 1;
        insert testContact;
        
        WFG_AgentCode__c agentCode = new WFG_AgentCode__c();
        agentCode.WFG_AgentCode__c = '001BBC';
        agentCode.WFG_Contact__c = testContact.Id;
        insert agentCode;
        
        //UUI Layout
        //Agent (A) | Agent ID | Authenticated | Last Menu Text | Collected Digits | IVR Call Start | IVR Call End
        //    0           1           2                3                  4               5  6 7               8910
        
		//string theUUI = 'A|'+agentCode.WFG_AgentCode__c+'|Y|test|test|test|test';
        string theUUI = 'A|0021CZ|Y|test|test|test|test';
        
        PageReference testPage = Page.ParseUUI;

        test.setCurrentPage(testPage);
        ApexPages.currentPage().getParameters().put('UUI',theUUI);
        ParseUUIController controller = new ParseUUIController();
		controller.UUIData = theUUI;
        controller.ParseUUIController();
        controller.Redirect();
        
    }
        
        static testmethod void testUUIPopNoAgent()
    {
        
        Contact testContact = new Contact();
        testContact.LastName = 'Test';
        testContact.WFG_AgentCode__c = '001BBC';
        testContact.WFG_AgentLevel__c = 1;
        insert testContact;
        
        WFG_AgentCode__c agentCode = new WFG_AgentCode__c();
        agentCode.WFG_AgentCode__c = '001BBC';
        agentCode.WFG_Contact__c = testContact.Id;
        insert agentCode;
        
        //UUI Layout
        //Agent (A) | Agent ID | Authenticated | Last Menu Text | Collected Digits | IVR Call Start | IVR Call End
        //    0           1           2                3                  4               5  6 7               8910
        
		//string theUUI = 'A|'+agentCode.WFG_AgentCode__c+'|Y|test|test|test|test';
        string theUUI = 'B|0021CZ|Y|test|test|test|test';
        
        PageReference testPage = Page.ParseUUI;

        test.setCurrentPage(testPage);
        ApexPages.currentPage().getParameters().put('UUI',theUUI);
        ParseUUIController controller = new ParseUUIController();
		controller.UUIData = theUUI;
        controller.ParseUUIController();
        controller.Redirect();
        
    }
     static testmethod void testUUIPopNoUUI()
    {
        
        Contact testContact = new Contact();
        testContact.LastName = 'Test';
        testContact.WFG_AgentCode__c = '001BBC';
        testContact.WFG_AgentLevel__c = 1;
        insert testContact;
        
        WFG_AgentCode__c agentCode = new WFG_AgentCode__c();
        agentCode.WFG_AgentCode__c = '001BBC';
        agentCode.WFG_Contact__c = testContact.Id;
        insert agentCode;
        
        //UUI Layout
        //Agent (A) | Agent ID | Authenticated | Last Menu Text | Collected Digits | IVR Call Start | IVR Call End
        //    0           1           2                3                  4               5  6 7               8910
        
		//string theUUI = 'A|'+agentCode.WFG_AgentCode__c+'|Y|test|test|test|test';
        string theUUI = '';
        
        PageReference testPage = Page.ParseUUI;

        test.setCurrentPage(testPage);
        ApexPages.currentPage().getParameters().put('UUI',theUUI);
        ParseUUIController controller = new ParseUUIController();
		controller.UUIData = theUUI;
        controller.ParseUUIController();
        controller.Redirect();
        
    }
    static testmethod void testUUIPopHasUUINoAgent()
    {
        
        Contact testContact = new Contact();
        testContact.LastName = 'Test';
        testContact.WFG_AgentCode__c = '001BBC';
        testContact.WFG_AgentLevel__c = 1;
        insert testContact;
        
        WFG_AgentCode__c agentCode = new WFG_AgentCode__c();
        agentCode.WFG_AgentCode__c = '001BBC';
        agentCode.WFG_Contact__c = testContact.Id;
        insert agentCode;
        
        //UUI Layout
        //Agent (A) | Agent ID | Authenticated | Last Menu Text | Collected Digits | IVR Call Start | IVR Call End
        //    0           1           2                3                  4               5  6 7               8910
        
		//string theUUI = 'A|'+agentCode.WFG_AgentCode__c+'|Y|test|test|test|test';
        string theUUI = 'A||Y|test|test|test|test';
        
        PageReference testPage = Page.ParseUUI;

        test.setCurrentPage(testPage);
        ApexPages.currentPage().getParameters().put('UUI',theUUI);
        ParseUUIController controller = new ParseUUIController();
		controller.UUIData = theUUI;
        controller.ParseUUIController();
        controller.Redirect();
        
        
    }
}