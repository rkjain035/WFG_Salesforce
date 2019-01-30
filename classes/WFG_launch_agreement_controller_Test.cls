@isTest
private class WFG_launch_agreement_controller_Test {
    @isTest static void myTest() {
        string agentcode = WFG_launch_agreement_controller.loggedInUserAgentCode();
        System.assertEquals('55KSD',agentcode);
        }
}