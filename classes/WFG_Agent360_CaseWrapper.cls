public class WFG_Agent360_CaseWrapper {

    @AuraEnabled
    public List<String> lstFieldNames;
    
    @AuraEnabled
    public List<Case> lstCases;
       
    @AuraEnabled
    public Boolean hasCases;
    
    @AuraEnabled
    public integer intCount;
    
    @AuraEnabled
    public integer intOpenCasesCount;
    
    @AuraEnabled
    public integer intInProgressCasesCount;
    
    @AuraEnabled
    public integer intNewCasesCount;
    
    @AuraEnabled
    public integer intDuplicateCasesCount;
    
    @AuraEnabled
    public integer intResearchCasesCount;
    
    @AuraEnabled
    public integer intEscalatedCasesCount;
    
    @AuraEnabled
    public integer intClosedCasesCount;
    
    public WFG_Agent360_CaseWrapper(){
        hasCases = false;
    }
}