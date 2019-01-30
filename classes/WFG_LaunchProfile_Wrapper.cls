public class WFG_LaunchProfile_Wrapper {
    
    @AuraEnabled public String AgentCode { get; set; }
    @AuraEnabled public String StartDate { get; set; }
    @AuraEnabled public String EndDate { get; set; }
    
    // Trivial constructor, for server-side Apex -> client-side JavaScript
    public WFG_LaunchProfile_Wrapper(String agentCode, String startDate, String endDate) {
        this.AgentCode = agentCode;
        this.StartDate = startDate;
        this.EndDate = endDate;
    }
    
    // Default, no-arg constructor, for client-side -> server-side
    public WFG_LaunchProfile_Wrapper() {}
    

}