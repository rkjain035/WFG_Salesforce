public class AsyncUpdateUser implements Queueable {
   
    public list<user> lstUsersUpdated = new list<user>();
    public AsyncUpdateUser(list<user> userlist){
       lstUsersUpdated.addAll(userlist); 
       system.debug('User list in constructor = '+lstUsersUpdated );
    }

    public void execute(QueueableContext context) {
        system.debug('==in execute==='+lstUsersUpdated );
        map<id, list<WFG_Onboarding_Checklist__c>> mapUserIdtoOnboardingChecklist = new map<id, list<WFG_Onboarding_Checklist__c>>();
        list<Account> lstAcctoUpdate = new list<Account>();
        
        for(WFG_Onboarding_Checklist__c objOnboardingChecklist : [select id, Recruiting_Contact__c from WFG_Onboarding_Checklist__c ]){
        }
    }
}