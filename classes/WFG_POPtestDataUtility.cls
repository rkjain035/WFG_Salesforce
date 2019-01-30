@isTest
public class WFG_POPtestDataUtility {
	
	public static void CreateLeadRecords(Integer noOfLeads) {
        List<Lead> lstLead = new List<Lead>();
        
        for(Integer i = 1 ; i<=noOfLeads ; i++){
            Lead objLead = new Lead();
            objLead.FirstName = 'FirstName'+i;
            objLead.LastName = 'LastNameTest'+i;
            objLead.Company = 'TestCompany'+i;
            objLead.Country = 'PR';
            objLead.State = 'PRC';
            objLead.Email = 'test'+i+'@gmail.com';
            objLead.Phone = '9879879878';
            lstLead.add(objLead);
        }
        insert lstLead;
	}
}