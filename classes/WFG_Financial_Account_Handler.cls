/*
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2018] Transamerica Corporation, its affiliates and their licensors.
* @author Hampesh
* @date 4-Jul-2018
* @description - Trigger Handler for the Trigger Financial Account

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Hampesh               MOD-01             4-Jul-2018             Checks for duplicate product name
                                                              
*/

public with sharing class WFG_Financial_Account_Handler {
    /**
    @author Hampesh
    @date 4-Jul-2018
    @description Executed on Trigger Context - Before Insert and Before Update. Collects the list of Service center contacts being Inserted & checks for Duplicate Product Name 
    */
    public static void checkduplicatebeforeInsert() {
        try {
            List < FinServ__FinancialAccount__c > lstfinAcc = Trigger.new;
            List < string > lstprodName = new List < string > ();
            for (FinServ__FinancialAccount__c acc: lstfinAcc) {
                if (acc.WFG_Product_Name__c != null && !String.isBlank(acc.WFG_Product_Name__c))
                    lstprodName.add(acc.WFG_Product_Name__c);
            }

            List < FinServ__FinancialAccount__c > lstExistingProd = new List < FinServ__FinancialAccount__c > ();
            if (lstprodName.size() > 0 && !lstprodName.isEmpty()) {
                lstExistingProd = [Select name, id, WFG_Product_Name__c from FinServ__FinancialAccount__c where WFG_Product_Name__c in: lstprodName AND ownerId =: userinfo.getuserid()];
            }

            if (lstExistingProd.size() > 0 && !lstExistingProd.isEmpty()) {
                Map < string, List < FinServ__FinancialAccount__c >> mapProdVsFinAcc = new Map < string, List < FinServ__FinancialAccount__c >> ();
                for (FinServ__FinancialAccount__c newacc: lstfinAcc) {
                    List < FinServ__FinancialAccount__c > lstAcc = new List < FinServ__FinancialAccount__c > ();
                    for (FinServ__FinancialAccount__c existingacc: lstExistingProd) {
                        if (newacc.WFG_Product_Name__c == existingacc.WFG_Product_Name__c) {
                            lstAcc.add(existingacc);
                        }
                    }
                    integer currIndex = lstAcc.indexof(newacc);
                    if (currIndex >= 0) {
                        lstAcc.remove(currIndex);
                    }
                    mapProdVsFinAcc.put(newacc.WFG_Product_Name__c, lstAcc);
                }
                if (lstfinAcc.size() > 0) {
                    for (FinServ__FinancialAccount__c acc: lstfinAcc) {
                        if (trigger.isinsert) {
                            if (mapProdVsFinAcc.get(acc.WFG_Product_Name__c).size() > 0) {
                                acc.adderror('Product Name requires a unique name. This is a known issue that we are working quickly to resolve. For now, please make sure that the product name is unique.(Suggestion: Product Name + Client Name)');
                            }
                        }

                        if (trigger.isupdate) {
                            FinServ__FinancialAccount__c obj = (FinServ__FinancialAccount__c) trigger.oldmap.get(acc.id);

                            if ((obj.WFG_Product_Name__c != acc.WFG_Product_Name__c) && (mapProdVsFinAcc.get(acc.WFG_Product_Name__c).size() > 0)) {
                                acc.adderror('Product Name requires a unique name. This is a known issue that we are working quickly to resolve. For now, please make sure that the product name is unique.(Suggestion: Product Name + Client Name)');
                            }
                        }

                    }
                }
            }
        } catch (Exception e) {
            system.debug('WFG_Financial_Account_Handler--' + e);
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_Financial_Account_Handler', 'EXCEPTION', 'APEX', e.getMessage(), e.getMessage(), null, null, null, true);
        }
    }
}