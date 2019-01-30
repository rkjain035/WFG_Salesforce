public with sharing class WFG_MerrillOrderServerSideController {
  @AuraEnabled
  public static List<Merrill_Order__c> getOrders() {
    return [SELECT name, Order_Number__c, Order_Status__c, Order_Type__c, Order_Date_Time__c
    FROM Merrill_Order__c ORDER BY createdDate desc LIMIT 1000];
  }
}