public class WFG_launch_pre_licensing_education_Ctrl
{
    /**
    * This method returns pre-license education information.
    * @return - New Instance of WFG_Agent_PreLicense_Education.
    * @throws - N/A
    * @author DHunter
    * @date 04-05-2017
    */
  @AuraEnabled
  public static WFG_Agent_PreLicense_Education LoadPreLicenseEducation()
  {
      System.debug('Entered LoadPreLicenseEducation');
      WFG_Agent_PreLicense_Education objRes = new WFG_Agent_PreLicense_Education();
      objRes.setEducationLinks();
      System.debug('visibleKaplan: ' + objRes.visibleKaplan);
      System.debug('visibleADBanker: ' + objRes.visibleADBanker);
      System.debug('visibleExamFx: ' + objRes.visibleExamFX);
      System.debug('visibleOliver: ' + objRes.visibleOliver);
      System.debug('visibleiVari: ' + objRes.visibleiVari);
      return objRes;
  }
    
}