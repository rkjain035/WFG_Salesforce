public class ParseUUIController {
    
    Public String CallFunc {get;set;}
    public string DNIS {get;set;}
    Public String UCID {get;set;}
    public string Queue {get;set;}
    Public string ANI {get;set;}
    public string UUIData {get;set;}
    public string AgentID {get;set;}
    public string ContactName {get;set;}
    Public List<String> UUIList {get;set;}
    public list<WFG_AgentCode__c> WFGAgentList {get;set;}
    public list<Contact> ContactList = new List<Contact>();
    public string contactID {get;set;}
    public string nonconsole{Get;set;}
    public void ParseUUIController()
    {
        system.debug('PARSEUUI Initialized');
        //UUI Layout
        //Agent (A) | Agent ID | Authenticated | Last Menu Text | Collected Digits | IVR Call Start | IVR Call End
        //    0           1           2                3                  4               5  6 7               8910
        
        Redirect();
    }
    
    public void Redirect()
    {   
        //nonconsole = '/0038A000004J4ik';
        nonconsole = '/home/home.jsp';
        //nonconsole = '/apex/WFG_ComplaintsPanelPage';
        
        //contactid = casesearchid;
        //contactname = casesearchname; 
        UUIList = new List<String>(); 
        UCID = ApexPages.currentPage().getParameters().get('UCID');        
        ANI = ApexPages.currentPage().getParameters().get('ANI');        
        Queue = ApexPages.currentPage().getParameters().get('Queue');        
        DNIS = ApexPages.currentPage().getParameters().get('DNIS');        
        UUIData = ApexPages.currentPage().getParameters().get('UUI');    
        
        system.debug('UUIDATA: '+UUIData);
        
        if(String.isNotBlank(UUIData)) 
        {
            string tempstring = UUIData.replace('|',':');
            UUIList = tempstring.split(':',-2);
            
            system.debug('UUILIST: '+UUIList);
            //Agent found
            if(UUIList[0]=='A')
            {
                AgentID = UUIList[1];
                if(AgentID != null && AgentID!='')
                {
                    WFGAgentList = new list<WFG_AgentCode__c>([select id, WFG_AgentCode__c, WFG_Contact__c from WFG_AgentCode__c where WFG_AgentCode__c =:AgentID]);
                    system.debug('WFG Agent List: '+WFGAgentList);
                    if(WFGAgentList.size()>0){
                        ContactList = new list<Contact>([select id, name from Contact where id =: WFGAgentList[0].WFG_Contact__c]);
                        system.debug('Contact List: '+Contactlist);
                        if(WFGAgentList.size() == 1)
                        {
                            contactID = WFGAgentList[0].WFG_Contact__c;
                            contactname = ContactList[0].Name;
                            callfunc = '<script> openTheContact(); </script>';
                        }
                    }
                    else
                    {
                        callfunc = '<script> openTheContact(); </script>';
                    }
                }
                else
                {
                    callfunc = '<script> openTheContact(); </script>';
                }
                
            }
            else{
                callfunc = '<script> openTheContact(); </script>';
            }
        }
        else
        {
            //No data, redirect to search
            callfunc = '<script>openTheContact();</script>';
        }
    }
}