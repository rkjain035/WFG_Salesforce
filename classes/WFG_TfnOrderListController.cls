public class WFG_TfnOrderListController {
@AuraEnabled
public static List<TFN_Order__c> getOrders(Id recordId) {
   return [Select Id, Name, Order_Status__c, Order_Type__c From TFN_Order__c Where CreatedById = :recordId];
}

}