/*
 * @description Unit test for PendingCaseSyncPlugin
 */
@isTest
private class PendingCaseSyncPluginTest {
    @isTest
    static void test_SyncFieldMappings() {
        PendingCaseSyncPlugin plugin = new PendingCaseSyncPlugin();

        List<PendingCaseSyncPlugin.SyncFieldMapping> fmList = new List<PendingCaseSyncPlugin.SyncFieldMapping> {
            new PendingCaseSyncPlugin.SyncFieldMapping('contact', '', 'name', '', 'new_name__c', '', 'add'),
            new PendingCaseSyncPlugin.SyncFieldMapping('contact', '', 'namerem', '', '', '', 'remove'),
            new PendingCaseSyncPlugin.SyncFieldMapping('contact', '', 'name', 'account', 'new_name__c', '', 'add'),
            new PendingCaseSyncPlugin.SyncFieldMapping('contact', 'account', 'new_name__c', 'factfinder', 'new_name__c', '', 'add'),
            new PendingCaseSyncPlugin.SyncFieldMapping('account', '', 'name', '', 'new_name__c', '', 'replace'),
            new PendingCaseSyncPlugin.SyncFieldMapping('agentone__insurancecase__c', '', 'agentone__product_type_name__c', '', 'agentone__product_type_name__c', 'productTypeConversion', 'transform')
        };
        

        List<AgentOne.EntityEntry> peList = new List<AgentOne.EntityEntry>();
        AgentOne.PendingCaseEntry pe = new AgentOne.PendingCaseEntry();
        peList.add(pe);
        pe.primaryInsured.setFieldValue('name', 'Justin');
        pe.primaryInsured.setFieldValue('namerem', 'Justin-to-remove');

        AgentOne.EntityEntry pt = new AgentOne.EntityEntry();
        pe.parties.add(pt);

        AgentOne.EntityEntry ae = new AgentOne.EntityEntry();
        ae.setFieldValue('name', 'iPipeline');
        pt.addRelatedEntry('account', ae);

        AgentOne.EntityEntry ce = new AgentOne.EntityEntry();
        ce.setFieldValue('name', 'Michelle');
        pt.addRelatedEntry('contact', ce);


        plugin.executeBeforeSync(fmList, null, peList, 'PendingCaseEntry');

        // System.debug(JSON.serialize(peList));

        System.assertEquals('Justin', pe.primaryInsured.getFieldValue('name'));
        System.assertEquals('Justin', pe.primaryInsured.getFieldValue('new_name__c'));
        System.assertEquals(null, pe.primaryInsured.getFieldValue('namerem'));
        System.assertEquals('Justin', pe.primaryInsured.getRelatedEntry('account').getFieldValue('new_name__c'));
        System.assertEquals('Justin', pe.primaryInsured.getRelatedEntry('factfinder').getFieldValue('new_name__c'));
        
        // System.assertEquals(null, pe.primaryInsured.getFieldValue('namerem'));
        System.assertEquals(null, pe.parties[0].getRelatedEntry('account').getFieldValue('name'));
        System.assertEquals('iPipeline', pe.parties[0].getRelatedEntry('account').getFieldValue('new_name__c'));

    }

    @isTest
    static void test_GetCarrierAppointmentInfo() {
        GetCarrierAppointmentInfo getInfo = new GetCarrierAppointmentInfo();
        Map<String, Object> ctx = new Map<String, Object>();
        User agent = new User(
            AgentOne__Agent_Number__c = 'agtnm'
        );
        AgentOne__Agent_Appointment__c appt = new AgentOne__Agent_Appointment__c(
            AgentOne__Appointment_Code__c = 'apptCode'
        );
        appt.putSObject('AgentOne__Appointed_Agent__r', agent);
        AgentOne__Agent_Appointment__c[] agentApptCodes = new List<AgentOne__Agent_Appointment__c> {
            appt
        };
        ctx.put('appointmentcodes', agentApptCodes);
       

        AgentOne__Insurance_Carrier_Code__c[] carrierCodes = new List<AgentOne__Insurance_Carrier_Code__c> {
            new AgentOne__Insurance_Carrier_Code__c(
                AgentOne__Type__c = 'iGO',
                AgentOne__Code__c = 'cCode'
            )
        };
        ctx.put('carriercodes', carrierCodes);

        
        
        String result = getInfo.transform('', 'agtnm', '', null, ctx);

        System.debug(result);

    }
}