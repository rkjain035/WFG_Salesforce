@isTest
public class RunningUserCtrl_Test {

     
    @isTest public static User getCurrentUser() {
               // Let's create a new test user
    Profile testProfile = [SELECT Id 
                           FROM profile
                           WHERE Name = 'System Administrator' 
                           LIMIT 1];

    User testUser = new User(FirstName = 'test user 1',
                             LastName = 'test user 1', 

                             Username = 'test.user.1@transamerica.com', 
                             Email = 'test.1@transamerica.com', 
                             Alias = 'testu1', 
                             TimeZoneSidKey = 'GMT', 
                             LocaleSidKey = 'en_GB', 
                             EmailEncodingKey = 'ISO-8859-1', 
                             ProfileId = testProfile.Id, 
                             LanguageLocaleKey = 'en_US');
        
        Test.startTest();
        
            System.runas(testUser)
            {
            User user = [SELECT Id, FirstName, LastName, WFG_Branding__c, ProfileId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    
            }
        Test.stopTest();
        RunningUserCtrl.getCurrentUser();
		return testUser;

    }
    
    @isTest public static String getUserName() {
        RunningUserCtrl.getUserName();
        return userinfo.getName();
    }
    
    @isTest public static String getUserProfileCountry(){
        
          Profile testUSLaunchProfile = [SELECT Id 
                           FROM profile
                           WHERE Name = 'Launch Blue US' 
                           LIMIT 1];
        
         Profile testCANLaunchProfile = [SELECT Id 
                           FROM profile
                           WHERE Name = 'Launch Blue CAN' 
                           LIMIT 1];
   
        Contact testContact = new Contact(FirstName = 'Test Launch',
                                 LastName = 'US User',
                                 email ='test.launch@transamerica.com',
                                 WFG_AgentPayType__c = 'WFG',
                                 WFG_Fiduciary_Advisor__c = false,
                                 WFG_CycleType__c = 'US',
                                 WFG_Type__c = 'Launch',
                                 WFG_AgentId__c = '12345',
                                 WFG_AgentCode__c ='12345',
                                 WFG_AgentLevel__c = 20);
        insert testContact;
       
         User testUser = new User(FirstName = 'test launch',
                             LastName = 'US User', 
                             Username = 'test.user.1@transamerica.com', 
                             Email = 'test.launch@transamerica.com', 
                             Alias = 'testu1', 
                             TimeZoneSidKey = 'GMT', 
                             LocaleSidKey = 'en_GB', 
                             EmailEncodingKey = 'ISO-8859-1', 
                             ProfileId = testUSLaunchProfile.Id, 
                             LanguageLocaleKey = 'en_US',
                             ContactId = testContact.Id );
        insert testUser;
        Test.startTest();
            System.runas(testUser)
            {
            User user = [SELECT Id, FirstName, LastName, Profile.name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            }
        String usUser = RunningUserCtrl.getProfileCountry();
        Test.stopTest();
        return RunningUserCtrl.getProfileCountry();
    }
    

}