public class WFG_CommunityHighlightPanel {
	
    @AuraEnabled
    public String strRecordName;
    @AuraEnabled
    public List<WFG_CommunityHeaderWrapper> lstHeaderData;
    
    public WFG_CommunityHighlightPanel(String strRecordName, List<WFG_CommunityHeaderWrapper> lstHeaderData){
        
        this.strRecordName = strRecordName;
        this.lstHeaderData = lstHeaderData;
    }
}