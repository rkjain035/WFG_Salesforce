public class WFG_Launch_Vertical_navigation_Ctrl {
    @AuraEnabled
    public static String getCurrentUserCountry(){
       return RunningUserCtrl.getProfileCountry();
    }
    
    @AuraEnabled
    public static WFG_Agent_PreLicense_Education LoadPreLicenseEducation()
    {
        return WFG_launch_pre_licensing_education_Ctrl.LoadPreLicenseEducation();
    }
}