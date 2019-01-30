public with sharing class MyTeamDemoSFConnectController {
      @AuraEnabled
  public static List<Agent__x> getMyTeam(){
    return [SELECT AgentId__c, AgentLevel__c,Name__c FROM Agent__x WHERE UplineCode__c = '1200W'];
  }

}