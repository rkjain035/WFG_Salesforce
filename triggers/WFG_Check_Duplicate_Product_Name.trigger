trigger WFG_Check_Duplicate_Product_Name on FinServ__FinancialAccount__c (before insert,before update) {
  
   if(WFG_TriggerActivation__c.getInstance('WFG_Financial_Account') != null && 
       WFG_TriggerActivation__c.getInstance('WFG_Financial_Account').WFG_isActive__c != null && 
       WFG_TriggerActivation__c.getInstance('WFG_Financial_Account').WFG_isActive__c == true){
         WFG_Financial_Account_Handler.checkduplicatebeforeInsert();
       }
  
   }