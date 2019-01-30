// Pendingcase Sync plugin for FSC
global with sharing class PendingCaseSyncPlugin implements AgentOne.IEntitySyncPlugin {

    public class SyncFieldMapping {

        public String objectType;
 
        public String sourceRefObject;

        public String sourceField;

        public String targetRefObject;

        public String targetField;
 
        public String transformAction;

        public String mappingType;
  
        public Boolean enabled;

        public SyncFieldMapping(String objectType, String sourceRefObject, String sourceField, String targetRefObject, String targetField, String transformAction, String mappingType) {
            this.objectType = objectType;
            this.sourceRefObject = sourceRefObject;
            this.sourceField = sourceField;
            this.targetRefObject = targetRefObject;
            this.targetField = targetField;
            this.transformAction = transformAction;
            this.mappingType = mappingType;

            this.enabled = true;
        }
    }

	// entry point of the PendingCase SyncPlugin method
    global void entity_beforeSync(List<AgentOne__Sync_Record__c> syncRecords, List<AgentOne.EntityEntry> syncEntities, String entityName) {
        System.debug('PendingCaseSyncPlugin.entity_beforeSync(syncRecords, syncEntities, entityName)');
 		try {
       		StaticResource fieldMappingRes = [Select Id, Body From StaticResource Where Name = 'PendingCaseSyncMapper'];
        	List<SyncFieldMapping> fmList = (List<SyncFieldMapping>)JSON.deserialize(fieldMappingRes.Body.toString(), List<SyncFieldMapping>.class);

        	executeBeforeSync(fmList, syncRecords, syncEntities, entityName);
      	} catch (Exception ex) {
          	// if an exception occured then log it to the AgentOne Team
          	AgentOne.OrganizationService.log('AgentOneRD-External', ex.getMessage());
      	}
    
    }

    public void executeBeforeSync(List<SyncFieldMapping> allFmList, List<AgentOne__Sync_Record__c> syncRecords, List<AgentOne.EntityEntry> syncEntities, String entityName) {
        Map<String, List<SyncFieldMapping>> objectFieldMappings = new Map<String, List<SyncFieldMapping>>();
        for (SyncFieldMapping fm : allFmList) {
            if (fm.enabled) {
                List<SyncFieldMapping> fmList = objectFieldMappings.get(fm.objectType);
                if (fmList == null) {
                    fmList = new List<SyncFieldMapping>();
                    objectFieldMappings.put(fm.objectType, fmList);
                }
                fmList.add(fm);
            }
        }
        
        List<AgentOne.EntityEntry> contactEnList = new List<AgentOne.EntityEntry>();
        List<AgentOne.EntityEntry> accountEnList = new List<AgentOne.EntityEntry>();

        for (AgentOne.EntityEntry en : syncEntities) {
            AgentOne.PendingCaseEntry pe = (AgentOne.PendingCaseEntry)en;
            
            // Transform insurance cases
            List<SyncFieldMapping> caseMappings = objectFieldMappings.get('agentone__insurancecase__c');
            if (!caseMappings.isEmpty()) {
                for (SyncFieldMapping fm : caseMappings) {
                    transformEntityField(fm, pe);
                }
            }

            // Add primary insured
            contactEnList.add(pe.primaryInsured);

            // Add contact entity for additional insured(s)
            for (AgentOne.EntityEntry ee : pe.insureds) {
                if (ee.getFieldValue(AgentOne__Insured__c.AgentOne__Is_Primary__c) == 'false' && ee.getRelatedEntry('contact') != null) {
                    contactEnList.add(ee.getRelatedEntry('contact'));
                }
            }

            // Add contact/account entity from party
            for (AgentOne.EntityEntry ee : pe.parties) {
                if (ee.getRelatedEntry('contact') != null) {
                    contactEnList.add(ee.getRelatedEntry('contact'));
                    
                }
                if (ee.getRelatedEntry('account') != null) {
                    accountEnList.add(ee.getRelatedEntry('account'));
                }        
            }
        }

        // Transform contact objects
        List<SyncFieldMapping> contactFldMappings = objectFieldMappings.get('contact');
        if (contactFldMappings != null && contactFldMappings.size() > 0) {
            for (AgentOne.EntityEntry ee : contactEnList) {
                for (SyncFieldMapping fm : contactFldMappings) {
                    transformEntityField(fm, ee);
                }
            }
        }

        // Transform account objects
        List<SyncFieldMapping> accountFldMappings = objectFieldMappings.get('account');
        if (accountFldMappings != null && accountFldMappings.size() > 0) {
            for (AgentOne.EntityEntry ee : accountEnList) {
                for (SyncFieldMapping fm : accountFldMappings) {
                    transformEntityField(fm, ee);
                }
            }
        }
    }

	//transform contact entity based on field mappers
    private void transformEntityField(SyncFieldMapping fm, AgentOne.EntityEntry ee) {
        String srcVal = null;
        AgentOne.EntityEntry se = ee;
        if (String.isNotEmpty(fm.sourceRefObject)) {
            se = ee.getRelatedEntry(fm.sourceRefObject);
        } 

        if (se != null && se.containsField(fm.sourceField) && String.isNotEmpty(fm.targetField)) {
            srcVal = se.getFieldValue(fm.sourceField);

            // Transform value
            String targetVal = srcVal;
            
            if (String.isNotBlank(fm.mappingType)) {
                targetVal = transformEntity(fm.transformAction, se, targetVal);
            }

            AgentOne.EntityEntry te = ee;
            if (String.isNotEmpty(fm.targetRefObject)) {
                te = ee.getRelatedEntry(fm.targetRefObject);
                if (te == null) {
                    te = new AgentOne.EntityEntry();
                    ee.addRelatedEntry(fm.targetRefObject, te);
                }
            }
            
            
            te.setFieldValue(fm.targetField, targetVal);
        }

        if (se != null && (fm.mappingType == 'replace' || fm.mappingType == 'remove')) {
            se.removeFieldEntry(fm.sourceField);
        }
    }
    
    
     // map the field value from one text to another
     private string transformEntity(String transformAction, AgentOne.EntityEntry ee, String sourceValue) {
         String returnValue = sourceValue;

         if (transformAction == 'USAtoUS') {
             if (sourceValue == 'United States of America') {
                 
                 // Need to add patch to convert puerto rico's country to use PR instead of US 
                 // otherwise it will not work -- notice that in the previous transforms we actually replace otherstate with mailingstate so that is 
                 // why it must be checked
                 if (ee.getFieldValue('mailingstate') == 'Puerto Rico' || ee.getFieldValue('otherstate') == 'Puerto Rico') {
                     returnValue = 'Puerto Rico';
                 } else {                 
                     returnValue = 'United States';
                 }
             }
         }
   		 
         if(transformAction == 'productTypeConversion') {
      		if(sourceValue == 'Term') {
	     		returnValue = 'Term Life';
	  	 	}
   		 }
         
         return returnValue;
     }
}