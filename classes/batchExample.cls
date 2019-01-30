global class batchExample implements Database.Batchable<sObject>,Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext BC) {
         
        String query = 'SELECT Id,lastname,mailingcountry,mailingstate FROM Contact';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Contact> conlist) {
        integer c1 =1;
        list<contact> clist = new list<contact>();
        for(Contact con : conlist)
        {   
            c1++;
            Contact c = new contact();
            c.firstname = 'sda'+c1;
            c.lastname = con.lastname+'22'+C1;
            c.mailingCountry = 'US';
            c.mailingState = 'FL';
            c.email = 'test@tes.com';
            c.phone = '1234567890';
            c.recordtypeid = '012440000002PZ9';
            clist.add(c);
        }
        try 
        {
           insert clist;
         
        } catch(Exception e) {
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {
        
  }
}