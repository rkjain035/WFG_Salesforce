global class DummyBatch implements Database.Batchable<sObject>,Database.Stateful  {
    
    private Set<Id> setContactIdsParam = new Set<Id>();
    private map<Id,Id> parentToChildMap = new Map<Id,Id>();
    public DummyBatch(Set<Id> conIdParam) {
        setContactIdsParam.addAll(conIdParam); 
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        for(Contact c : [select id,reportsToId from Contact where id in :setContactIdsParam])
        {
            parentToChildMap.put(c.ReportsToId, c.Id);
        }
        
        String query = 'select userOrGroupId, ContactId from ContactShare where ContactId in : parentToChildMap.keySet()';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<ContactShare> scope)
    {
        LIST<ContactShare> conShareList = new LIST<ContactShare>();
        for(ContactShare cs : scope)
        {
            ContactShare conShare = new ContactShare();
            conShare.ContactId = parentToChildMap.get(cs.ContactId);
            conShare.UserOrGroupId = cs.UserOrGroupId;
            conShare.RowCause = 'Manual';
            conShare.ContactAccessLevel = 'Read';
            conShareList.add(conShare);
        }
        insert conShareList;
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
        
    }
}