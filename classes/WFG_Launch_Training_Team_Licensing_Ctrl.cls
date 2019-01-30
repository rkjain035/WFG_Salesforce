global class WFG_Launch_Training_Team_Licensing_Ctrl {
    /**
     * This method returns the string which is the country of logged on user
     * @throws - N/A
     * @author Girish
     * @date 07-13-2018
     */
    @AuraEnabled
    global static String getCurrentUserCountry(){
       return RunningUserCtrl.getProfileCountry();
    
    }
}