public class  ContactDummy {
	public Contact Contact { get; private set; }
     
     public ContactDummy() {
        Contact = [SELECT Id, Name, WFG_FederationId__c FROM Contact

                   WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
    }


}