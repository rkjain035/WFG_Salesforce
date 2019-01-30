public class RunningUserCtrl {
     @AuraEnabled
    public static User getCurrentUser() {
      User user = [SELECT Id, FirstName, LanguageLocaleKey, WFG_Agent_Code__c, LastName, WFG_Branding__c, Profile.Name,SmallPhotoUrl FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
      return user;
  }
    
    public static String getUserName() {
    return userinfo.getName();
  }
    /**
     * This method returns the string which is the country of logged on user
     * @throws - N/A
     * @author Girish
     * @date 07-13-2018
     */
    public static String getProfileCountry(){
        User currentUser = getCurrentUser();
        String userProfileCountry;
        if(currentUser.profile.Name.contains('US') && currentUser.profile.Name.contains('Launch')){
            userProfileCountry='US';
        }else if(currentUser.profile.Name.contains('CAN') && currentUser.profile.Name.contains('Launch')){
            userProfileCountry='CAN';
        }
        return userProfileCountry;
    }
}