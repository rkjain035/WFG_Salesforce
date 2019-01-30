// Sample code for PS team to prefill the carrier code and agent appointment code
global with sharing class GetCarrierAppointmentInfo implements AgentOne.IFieldValueTransformer2 {
    global String transform(String fieldName, String fieldValue, String args, AgentOne.EntityEntry entity, Map<String, Object> ctx) {
        System.debug('GetCarrierAppointmentInfo: ' + JSON.serialize(ctx));

        AgentOne__Insurance_Carrier_Code__c[] carrierCodes = (AgentOne__Insurance_Carrier_Code__c[])ctx.get('carriercodes');
        AgentOne__Agent_Appointment__c[] agentApptCodes = (AgentOne__Agent_Appointment__c[])ctx.get('appointmentcodes');

        String codeLine = '';
        String agentNumber = fieldValue;
        for (AgentOne__Agent_Appointment__c apptCode : agentApptCodes) {
            if (agentNumber == apptCode.AgentOne__Appointed_Agent__r.AgentOne__Agent_Number__c) {
                String agentCode =  apptCode.AgentOne__Appointment_Code__c;
                String carrierId = apptCode.AgentOne__Insurance_Product_Carrier__c;
                String carrierCodeLine = '';
                for (AgentOne__Insurance_Carrier_Code__c cc : carrierCodes) {
                    if (cc.AgentOne__Carrier__c == carrierId && cc.AgentOne__Type__c == 'iGO') {
                        if (carrierCodeLine == '') carrierCodeLine = cc.AgentOne__Code__c;
                        else carrierCodeLine = carrierCodeLine + ',' + cc.AgentOne__Code__c;
                    }
                }
                if (codeLine == '') codeLine = carrierCodeLine + '|' + agentCode;
                else codeLine = codeLine + ';' + carrierCodeLine + '|' + agentCode;
            }
        }

        System.debug(fieldName + ' : ' + codeLine);
        return codeLine;
    }
}