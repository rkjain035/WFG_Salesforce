public without sharing class WFG_AgentAppointments {
	public static String getUserPacLifeStatus() {
        String strAppointmentStatus = '';
        try
        {
            String strAgentCode = RunningUserCtrl.getCurrentUser().WFG_Agent_Code__c;
            System.debug('strAgentCode: ' + strAgentCode);
            WFG_AgentStatus__c objAgentStatus = [SELECT WFG_Status__c FROM WFG_AgentStatus__c WHERE WFG_Contact__r.WFG_AgentCode__c = :strAgentCode And Name = 'PacLife' LIMIT 1];
            System.debug('objAgentStatus: ' + objAgentStatus);
            if(objAgentStatus != null)
            {
                strAppointmentStatus = objAgentStatus.WFG_Status__c;
            }
        }
        catch(Exception e)
        {
            System.debug('Get Agent Appointment Status error: ' + e.getMessage());
        }
        
        System.debug('Appointment: ' + strAppointmentStatus);
        return strAppointmentStatus;
  }
}