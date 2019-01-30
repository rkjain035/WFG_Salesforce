trigger InsuranceCaseToOpportunityTrigger on AgentOne__InsuranceCase__c (after update) {
	System.debug('*****InsuranceCaseToOpportunityTrigger*****');
    
    if (UserInfo.isCurrentUserLicensed('AgentOne')) {
        System.debug('UserInfo.isCurrentUserLicensed(\'AgentOne\') returned True');
        
        /*WFGAGTONE-116 : Orphaned Case*/
        //Get a list of insurance case records whose Opportunity__c field is null before update
        List<AgentOne__InsuranceCase__c> insCases1 = new List<AgentOne__InsuranceCase__c>();
        for (AgentOne__InsuranceCase__c i1 : Trigger.old) {
            if (i1.Opportunity__c == null) { insCases1.add(i1); }
        }
        
        if (!insCases1.isEmpty()) {
            System.debug('Beyond insCases1.isEmpty(); count is: ' + insCases1.size());
            //Get a list of insurance case records whose Opportunity__c field is not null after update
            List<AgentOne__InsuranceCase__c> insCases2 = new List<AgentOne__InsuranceCase__c>();
            for (AgentOne__InsuranceCase__c i2 : Trigger.new) {
                if (i2.Opportunity__c != null) { insCases2.add(i2); }
            }
            
            if(!insCases2.isEmpty()) {
                System.debug('Beyond insCases2.isEmpty(); count is: ' + insCases2.size());
                //Get a list of insurance case records that were orphaned but are now associated with an opportunity record
                List<AgentOne__InsuranceCase__c> insCases3 = new List<AgentOne__InsuranceCase__c>();
                for (AgentOne__InsuranceCase__c i3 : insCases2) {
                    for (AgentOne__InsuranceCase__c i4 : insCases1) {
                        if (i3.Id == i4.Id) { 
                            insCases3.add(i3);
                            break; 
                        }
                    }
                }
                
                if(!insCases3.isEmpty()) {
                    System.debug('Beyond insCases3.isEmpty(); count is: ' + insCases3.size());
                    //Update the opportunity records that have been associated with orphaned insurance case records
                    Integer numberOfChanges = 0;
                    
                    //These are used for the call to UpdateContactFieldInsuranceCase
                    Set<Id> orphanedInsCaseIds = new Set<Id>();
                    Set<Id> opporunityIds = new Set<Id>();
                    
                    Set<Id> oppIds = new Set<Id>();
                    List<Opportunity> opps1 = [SELECT Id, Name, WFG_Contact__c, Insurance_Case__c, StageName, WFG_Product_Type__c FROM Opportunity WHERE Insurance_Case__c = null]; 
                    for (Opportunity o1 : opps1) {
                        for(AgentOne__InsuranceCase__c i5 : insCases3) {
                            if(o1.Id == i5.Opportunity__c) {
                                //Create a set of specific opportunity.Ids to avoid Validation Rules Exception
                                oppIds.add(o1.Id);
                                
                                //Create Sets of Insurance Case and Opportunity Id so that
                                //the @future method can update the insurance case record Contact to 
                                //the opportunity contact if they are not already the same.
                                if(o1.WFG_Contact__c !=  i5.AgentOne__Contact__c) {
                                    orphanedInsCaseIds.add(i5.Id);
                                    opporunityIds.add(o1.Id);
                                }                                       
                                numberOfChanges++;
                                break;
                            }
                        }
                        
                        if(numberOfChanges >= insCases3.size()) { break; }
                    }
                   
                    List<Opportunity> opps2 = [SELECT Id, Name, WFG_Contact__c, Insurance_Case__c, StageName, WFG_Product_Type__c FROM Opportunity WHERE Id in :oppIds];
                    for(Opportunity o2 : opps2) {
                        for(AgentOne__InsuranceCase__c i6 : insCases3) {
                            if(o2.Id == i6.Opportunity__c) {
                                if ((i6.AgentOne__Phase__c == 'Underwriting' || i6.AgentOne__Phase__c == 'Delivery') && (o2.StageName != 'Sale Accepted' && o2.StageName != 'Sale Not Accepted' && o2.StageName != 'Opportunity Won' && o2.StageName != 'Opportunity Lost')) {
                                    o2.StageName = 'Pending Sale';
                                }
                                o2.WFG_Product_Type__c = i6.AgentOne__Product_Type_Name__c;
                                o2.Insurance_Case__c = i6.Id;
                            }
                        }
                    }
                    if (orphanedInsCaseIds.size() > 0) { UpdateContactFieldInsuranceCase.updateContactField(orphanedInsCaseIds, opporunityIds); }
                    if (numberOfChanges > 0) { update opps2; }          
                }
            }
        }
    
    
    
            
        
        /*WFGAGTONE-106 : Update Opportunity Record*/
        //Step 1: Create a list of updated insurance case records.
        List<AgentOne__InsuranceCase__c> insCases = new List<AgentOne__InsuranceCase__c>();
        List<Id> insCaseIds = new List<Id>();
        for (AgentOne__InsuranceCase__c insuranceCase : Trigger.new) {
            insCases.add(insuranceCase);
            insCaseIds.add(insuranceCase.Id);
        }
        
        if(!insCases.isEmpty()) {
            //Step 2: Get the Opportunity records associated with the Insurance Case records
            List<Opportunity> opps = [SELECT Id, Name, WFG_Product_Type__c, Insurance_Case__c, StageName FROM Opportunity WHERE Insurance_Case__c in :insCaseIds];
            
            if(!opps.isEmpty()) {
                //Step 3: Assign the specified values to the opportunity record and update
                Integer numOfChanges = 0;
                for(Opportunity opp : opps) {
                    if (opp.Id != null && opp.StageName != 'Sale Accepted' && opp.StageName != 'Sale Not Accepted' && opp.StageName != 'Opportunity Won' && opp.StageName != 'Opportunity Lost') {
                        AgentOne__InsuranceCase__c insCase = null;
                        for (AgentOne__InsuranceCase__c i : insCases) {
                            if (i.Opportunity__c == opp.Id){
                                insCase = i;
                                break;
                            }
                        }
    
                        if(insCase != null){
                            if (insCase.AgentOne__Phase__c == 'Underwriting') {opp.StageName = 'Pending Sale';}
                            opp.WFG_Product_Type__c = insCase.AgentOne__Product_Type_Name__c;
                            numOfChanges++;
                        }
                    }
                }
                if(numOfChanges > 0) { update opps; }     
            }
        }
    }
    else {
        System.debug('UserInfo.isCurrentUserLicensed(\'AgentOne\') returned False');
    }
        
}