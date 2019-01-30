@isTest
public class WFG_ChatTranscript_Test {
	public static testMethod void testingMethod(){
    	LiveChatTranscript lct = new LiveChatTranscript();
        lct.StartTime = system.now();
        lct.EndTime = system.now()+10;
        WFG_ChatTranscript wct = new WFG_ChatTranscript(lct);
    }
}