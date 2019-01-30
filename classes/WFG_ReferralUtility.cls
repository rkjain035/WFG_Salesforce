/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Samit
* @date 12-22-2016
* @description  Utility class for Referral Creation

Modification Log:
--------------------------------------------------------------------------------------------------------
Developer             Mod Number         Date                    Description
--------------------------------------------------------------------------------------------------------
Samit Bhoumick          M-001             12-22-2016              
*/
public Class WFG_ReferralUtility
{
    /**
     * This Utility method initiates the Referral action, a new Referral record is created if it is referred to a FA.
     * @return - Id of Newly created Referral record.
     * @param  - idCustProfile:  The Customer Profile record Id
     * @param  - boolFaPresent: TRUE if referred to FA, else FALSE
     * @param  - idReferredTo: The Id of the referred FA.
     * @throws - N/A
     * @author Samit
     * @date 12-22-2016
     */    
    public static WFG_ReferralResponseWrapper initiateReferral(Id idCustProfile, Boolean boolFaPresent, Id idReferredTo)
    {
        WFG_ReferralResponseWrapper objRes = new WFG_ReferralResponseWrapper();
        objRes.objGenericRes.boolIsError = FALSE;
        objRes.objGenericRes.strErrorMessage = '';
        try
        {
            if(idCustProfile != NULL)
            {
                system.debug('@@@ CUSTID: ' + idCustProfile);
                //Queries all the fields from the Customer Profile
                WFG_Customer_Profile__c objCustProfile = [SELECT Id, WFG_Contact__c, WFG_Contact__r.FirstName, WFG_Contact__r.LastName, 
                                                              WFG_Contact__r.Email, WFG_Contact__r.Phone, WFG_Contact__r.MailingCountry, WFG_Contact__r.MailingCity,
                                                              WFG_Contact__r.MailingState, WFG_Contact__r.MailingPostalCode, WFG_Contact__r.MailingStreet
                                                              FROM WFG_Customer_Profile__c WHERE Id=: idCustProfile];
                if(boolFaPresent)
                {
                    //Calls the createReferralRecord method to create a Referral Object from a Customer Profile
                    objRes.objRefferal = createReferralRecord(objCustProfile,idReferredTo,boolFaPresent);
                }
                //Else condition for Use case of referral to Advise Center
                else
                { 
                    String strProfileName = System.label.WFG_Referral_AdviceCenterProfile;
                    List<User> lstUser = [SELECT Id FROM User WHERE Profile.Name =: strProfileName AND IsActive = TRUE];
                    if(!lstUser.isEmpty())
                    {
                        objRes.objRefferal = createReferralRecord(objCustProfile,lstUser[0].Id,boolFaPresent);
                    }
                    else
                    {
                        objRes.objGenericRes.boolIsError = TRUE;
                        objRes.objGenericRes.strErrorMessage = System.Label.WFG_ReferralSelect_NoAdviceCenterError;                        
                    }
                }
                
            }
            else
            {
                objRes.objGenericRes.boolIsError = TRUE;
                objRes.objGenericRes.strErrorMessage = System.label.WFG_ReferralSelect_NoCustId_Error;
            }
        }
       //Handles the DML Operation
        catch(DMLException de)
        {      
            //For loop to get all the DML error messages and put them in proper format
            for(Integer i=0; i < de.getNumDml(); i++){
                objRes.objGenericRes.strErrorMessage = objRes.objGenericRes.strErrorMessage + de.getDmlMessage(i) + '\n';}
            //Populates the Error variables
            objRes.objGenericRes.boolIsError = TRUE; objRes.objGenericRes.strErrorMessage = objRes.objGenericRes.strErrorMessage.removeEnd('\n');
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_Referral__c', 'EXCEPTION', 'APEX', objRes.objGenericRes.strErrorMessage, objRes.objGenericRes.strErrorMessage, null, null, null, true);
        }
        //Handles all other exceptions
        catch(Exception e){
            //Populates the Error variables
            objRes.objGenericRes.boolIsError = TRUE; objRes.objGenericRes.strErrorMessage = e.getMessage(); 
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_Referral__c', 'EXCEPTION', 'APEX',e.getMessage(), e.getMessage(), null, null, null, true);
        } 
        //Returns the updated Wrapper Instance with Error variables and Id variables
        return objRes;
    }

    /**
     * This Utility method creatres a Refferal record from a Customer Profile record.
     * @return - Id of Newly created Referral record. 
     * @param  - objCustProfile:  The Customer Profile record instance
     * @throws - N/A
     * @author Samit
     * @date 12-22-2016
     */    
    private static WFG_Referral__c createReferralRecord(WFG_Customer_Profile__c objCustProfile, Id idReferredTo, Boolean boolFaPresent)
    {
        Map<id, User> mapUser = new map<Id, user>();
        List<User> lstUser = [Select id, name, WFG_Agent_Code__c
                    FROM User WHERE ID IN  (:UserInfo.getUserId(), :idReferredTo)];
        if(lstUser != null && !lstUser.isEmpty())
        {
            for(User objUser : lstUser)
            {
                mapUser.put(objUser.id, objUser);               
            }
        }
        //Creates a new Referral Record Instance
        WFG_Referral__c objReferral = new WFG_Referral__c();
        //objReferral.RecordTypeId = Schema.SObjectType.WFG_Referral__c.getRecordTypeInfosByName().get(System.Label.WFG_ReferralStatus_Referred).getRecordTypeId();
        objReferral.WFG_Customer_Profile__c = objCustProfile.Id;
        objReferral.WFG_Referred_By__c = UserInfo.getUserId();
        objReferral.WFG_Referred_To__c = idReferredTo;
        if(boolFaPresent)
            objReferral.WFG_Status__c = System.Label.WFG_ReferralStatus_Referred;
        else
            objReferral.WFG_Status__c = System.Label.WFG_ReferralStatus_AdviceCenter;
        //Calling the generic method for Mapping Contact values to Referral
        mapReferralFromContact(objCustProfile.WFG_Contact__r, objReferral);
        if(mapUser != null && !mapUser.keyset().isEMpty()
            && mapUser.containskey(UserInfo.getUserId())
            && mapUser.get(UserInfo.getUserId()) != null
            && mapUser.get(UserInfo.getUserId()).WFG_Agent_Code__c != null
            && mapUser.get(UserInfo.getUserId()).WFG_Agent_Code__c != '')
        {
            objReferral.WFG_Referred_From_Agent_Code__c = mapUser.get(UserInfo.getUserId()).WFG_Agent_Code__c;
        }
        else
        {
            objReferral.WFG_Referred_From_Agent_Code__c = '12345';
        }
        if(mapUser != null && !mapUser.keyset().isEMpty()
            && mapUser.containskey(idReferredTo)
            && mapUser.get(idReferredTo) != null
            && mapUser.get(idReferredTo).WFG_Agent_Code__c != null
            && mapUser.get(idReferredTo).WFG_Agent_Code__c != '')
        {
            objReferral.WFG_Referred_To_Agent_Code__c = mapUser.get(idReferredTo).WFG_Agent_Code__c;
        }
        else
        {
            objReferral.WFG_Referred_To_Agent_Code__c = '67890';
        }
        //Inserts the Referral record.
        INSERT objReferral;
        objReferral = [Select id, name, WFG_Customer_Profile__r.Name, WFG_Referred_To__c, WFG_Referred_To__r.Name 
                from WFG_Referral__c WHere Id = :objReferral.id];
        return objReferral;
    }

    /**
     * This Utility method Maps Referral fields with Contact fields
     * @param  - objContact:  The Contact Record Instance
     * @param  - objReferral:  The Referral Record Instance
     * @throws - N/A
     * @author Samit
     * @date 5-1-2017
     */    
    public static void mapReferralFromContact(Contact objContact, WFG_Referral__c objReferral)
    {
        objReferral.WFG_Contact_First_Name__c = objContact.FirstName;
        objReferral.WFG_Contact_Last_Name__c = objContact.LastName;
        objReferral.WFG_Email__c = objContact.Email;
        objReferral.WFG_Primary_Phone__c = objContact.Phone;
        //objReferral.WFG_Home_Country__c = objContact.MailingCountry;
        //objReferral.WFG_State__c = objContact.MailingState;
        
        objReferral.WFG_Home_Country__c = WFG_PicklistFieldDescribeUtility.getPicklistValueLabel('Contact','MailingCountryCode', objContact.MailingCountry);
        if(objReferral.WFG_Home_Country__c == 'Puerto Rico'){
            objReferral.WFG_State__c = 'Puerto Rico';
        }
        else{
            objReferral.WFG_State__c = WFG_PicklistFieldDescribeUtility.getPicklistValueLabel('Contact','MailingStateCode', objContact.MailingState);
        }
        objReferral.WFG_City__c = objContact.MailingCity;
        objReferral.WFG_Zipcode__c = objContact.MailingPostalCode;
        objReferral.WFG_Street_Address__c = objContact.MailingStreet;        
    }
     
    /**
     * 
     * @return - WFG_ReferralResponseWrapper (Response wrapper which can be comprehended by lighting component.)
     * @param  - idReferral:  The Referral record Id/ strActionName : The action Accept/reject
     * @throws - N/A
     * @author Samit
     * @date 12-22-2016
     */  
   public static WFG_ReferralResponseWrapper updateReferral(string idReferral, String strActionName)
   {
        WFG_ReferralResponseWrapper objRes = new WFG_ReferralResponseWrapper();
        objRes.objGenericRes.boolIsError = FALSE;
        objRes.objGenericRes.strErrorMessage = '';
       try
       {
           if(strActionName == 'Accept')
           {
               return acceptReferral(idReferral);
           }
           else
           {
               WFG_Referral__c objRef =  new WFG_Referral__c();
               //objRef.Id = idReferral;
               objRef = [SELECT Id, Name, WFG_Referred_To__c, 
                 WFG_Referred_By__c, WFG_Status__c,WFG_Customer_Profile__c
                 FROM WFG_Referral__c WHERE Id = : idReferral];
               if(strActionName == 'Reject')
                   objRef.WFG_Status__c = System.Label.WFG_ReferralStatus_Rejected;
               else if(strActionName == 'Cancel')
                   objRef.WFG_Status__c = System.Label.WFG_ReferralStatus_Cancelled ;
               else if(strActionName == 'Completed – Sold')
                   objRef.WFG_Status__c = System.Label.WFG_ReferralStatus_CompleteSold;
               else if(strActionName == 'Completed – Not Sold')
                   objRef.WFG_Status__c = System.Label.WFG_ReferralStatus_CompleteNotSold;
               UPDATE objRef;
               objRes.objRefferal = objRef;
               objRes.objGenericRes.boolIsError = false;
               objRes.objGenericRes.strSuccessMessage = System.Label.WFG_ReferralUpdate_SuccMsg + ' ' + objRef.WFG_Status__c;              
           }           
       }
       //Handles the DML Operation
        catch(DMLException de)
        {      
            //For loop to get all the DML error messages and put them in proper format
            for(Integer i=0; i < de.getNumDml(); i++){
                objRes.objGenericRes.strErrorMessage = objRes.objGenericRes.strErrorMessage + de.getDmlMessage(i) + '\n';}
            //Populates the Error variables
            objRes.objGenericRes.boolIsError = TRUE;
            objRes.objGenericRes.strErrorMessage = objRes.objGenericRes.strErrorMessage.removeEnd('\n');
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_Referral__c', 'EXCEPTION', 'APEX',objRes.objGenericRes.strErrorMessage, objRes.objGenericRes.strErrorMessage, null, null, null, true);
        }
        //Handles all other exceptions
        catch(Exception e){
            //Populates the Error variables
            objRes.objGenericRes.boolIsError = TRUE; objRes.objGenericRes.strErrorMessage = e.getMessage(); 
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_Referral__c', 'EXCEPTION', 'APEX',e.getMessage(), e.getMessage(), null, null, null, true);
        } 
       //Returns the updated Wrapper Instance with Error variables and Id variables
        return objRes;
   }
    /**
     * This Utility method initiates the Referral action, Accept
     * @return - WFG_ReferralResponseWrapper 
     * @param  - idReferral : Referral ID
     * @throws - N/A
     * @author Ninad
     * @date 12-22-2016
     */ 
    public static WFG_ReferralResponseWrapper acceptReferral(string idReferral)
    {
        WFG_ReferralResponseWrapper objRes = new WFG_ReferralResponseWrapper();
        list<WFG_Referral__c> lstReferral = new List<WFG_Referral__c>();
        
        if(idReferral != null)
        lstReferral = [Select Id, Name,  WFG_Contact_First_Name__c, WFG_Contact_Last_Name__c,
                                WFG_Email__c, WFG_Primary_Phone__c, WFG_Home_Country__c, WFG_State__c,
                                WFG_City__c, WFG_Zipcode__c, WFG_Street_Address__c, WFG_Referred_To__c
                                FROM WFG_Referral__c WHERE ID = :idReferral];
                    
        if(lstReferral != null && !lstReferral.isEmpty())    
        {                    
            objRes = createOrsearchContact(lstReferral[0]);
            if(objRes.objGenericRes.boolIsError)
            {
                return objRes;
            }
            else
            {
                string strSucc = objRes.objGenericRes.strSuccessMessage;
                WFG_ReferralResponseWrapper objRes1 = acceptReferralObj(lstReferral[0], objres.objContact);
                if(!objRes1.objGenericRes.boolIsError)
                objRes1.objGenericRes.strSuccessMessage = strSucc;
                return objRes1;
            }
        }
        return null;
    }
    /**
     * This Utility method initiates the Referral action, Accept
     * @return - WFG_ReferralResponseWrapper 
     * @param  - WFG_Referral__c: Referral Object
                 Contact: Contact Object
     * @throws - N/A
     * @author Ninad
     * @date 12-22-2016
     */ 
     @testVisible
    private static WFG_ReferralResponseWrapper createOrsearchContact(WFG_Referral__c objRef)
    {
        map <Id, List<Contact> > mapContactVsReferredTo = new map<Id, List<Contact> >();
        map <Id, Contact> mapContactTobeCreated = new map<Id, Contact>();
        try
        {
            if(objRef != null && objRef.id != null)
            {
                list<WFG_Referral__c> lstReferral = [Select Id, Name,  WFG_Contact_First_Name__c, WFG_Contact_Last_Name__c,
                                WFG_Email__c, WFG_Primary_Phone__c, WFG_Home_Country__c, WFG_State__c,
                                WFG_City__c, WFG_Zipcode__c, WFG_Street_Address__c, WFG_Referred_To__c
                                FROM WFG_Referral__c WHERE ID = :objRef.id];
    
                for(WFG_Referral__c objRef1 : lstReferral)
                {               
                    mapContactVsReferredTo.put(objRef1.WFG_Referred_To__c, null);
                }
                for(Contact objContact : [Select id, firstname, lastname, email, ownerId 
                        FROM Contact WHERE ownerId IN : mapContactVsReferredTo.keyset()])
                {
                    List<Contact> lstContacts;
                    if(mapContactVsReferredTo.containskey(objContact.ownerId) 
                        && mapContactVsReferredTo.get(objContact.ownerId) != null)
                    {
                        lstContacts = mapContactVsReferredTo.get(objContact.ownerId);       
                    }
                    else
                    {
                        lstContacts = new List<Contact>();
                    }
                    lstContacts.add(objContact);
                    mapContactVsReferredTo.put(objContact.ownerId, lstContacts);
                }
                for(WFG_Referral__c objRef1 : lstReferral)
                {
                    boolean boolIsContactExists = false;
                    if(mapContactVsReferredTo.containsKey(objref1.WFG_Referred_To__c)
                        && mapContactVsReferredTo.get(objref1.WFG_Referred_To__c) != null)
                    {
                        for(Contact objContact : mapContactVsReferredTo.get(objref1.WFG_Referred_To__c))
                        {
                            if(objRef1.WFG_Contact_First_Name__c == objContact.firstName 
                                && objRef1.WFG_Contact_Last_Name__c == objContact.lastName 
                                && objRef1.WFG_Email__c == objContact.email)
                            {
                                mapContactTobeCreated.put(objRef1.id, objContact);
                                boolIsContactExists = true;
                                break;
                            }                       
                        }                   
                    }
                    //If we have not found the contact that resembles with under considertaion.
                    if(!boolIsContactExists)
                    {
                        mapContactTobeCreated.put(objRef1.id, createContact(objRef1));
                    }
                }
                if(mapContactTobeCreated != null && !mapContactTobeCreated.keyset().isEMpty())
                {
                    List<Contact> lstContactsTobeInserted = new List<Contact>();
                    for(Contact objContact : mapContactTobeCreated.values())
                    {
                        if(objContact.id == null)
                        {
                            lstContactsTobeInserted.add(objContact);
                        }
                        else
                        {
                            WFG_ComponentResponseWrapper objGenericRes = new WFG_ComponentResponseWrapper();
                            objGenericRes.boolIsError = false;
                            objGenericRes.strSuccessMessage = System.Label.WFG_ContactDuplicationMsg + ' ' + objContact.firstName + ' ' + objContact.LastName;
                            WFG_ReferralResponseWrapper objres = new WFG_ReferralResponseWrapper();
                            objres.objGenericRes = objGenericRes;
                            objres.objContact = objContact;  
                            return objres; 
                        }                   
                    }
                    if(lstContactsTobeInserted != null && !lstContactsTobeInserted.isEMpty())
                    {
                        insert lstContactsTobeInserted;
                        WFG_ComponentResponseWrapper objGenericRes = new WFG_ComponentResponseWrapper();
                        objGenericRes.boolIsError = false;
                        objGenericRes.strSuccessMessage = System.Label.WFG_ContactCreationSuccMsg + ' ' + lstContactsTobeInserted[0].firstName + ' ' + lstContactsTobeInserted[0].LastName;
                        WFG_ReferralResponseWrapper objres = new WFG_ReferralResponseWrapper();
                        objres.objGenericRes = objGenericRes;
                        objres.objContact = lstContactsTobeInserted[0];
                        return objres;  
                    }                             
                }        
            }
        }
        catch(DmlException err)
        {
            
            WFG_ComponentResponseWrapper objGenericRes = new WFG_ComponentResponseWrapper();
            objGenericRes.boolIsError = true;
            
            WFG_ReferralResponseWrapper objres = new WFG_ReferralResponseWrapper();
            
            objres.objGenericRes = objGenericRes;
            objRes.objGenericRes.strErrorMessage = '';
            for(Integer i=0; i < err.getNumDml(); i++)
            {
                objRes.objGenericRes.strErrorMessage = objRes.objGenericRes.strErrorMessage + err.getDmlMessage(i) + '\n';
            }
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'Contact', 'EXCEPTION', 'APEX', objRes.objGenericRes.strErrorMessage, objRes.objGenericRes.strErrorMessage, null, null, null, true);
            return objres;
        }
        catch(Exception err)
        {
            String strErr = err.getMessage();
            WFG_ComponentResponseWrapper objGenericRes = new WFG_ComponentResponseWrapper();
            objGenericRes.boolIsError = true;
            objGenericRes.strErrorMessage = strErr;
            WFG_ReferralResponseWrapper objres = new WFG_ReferralResponseWrapper();
            objres.objGenericRes = objGenericRes;
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'Contact', 'EXCEPTION', 'APEX', strErr, strErr, null, null, null, true);
            return objres;
        }
        return null;
    }
    /**
     * This Utility method initiates the Referral action, Accept
     * @return - WFG_ReferralResponseWrapper 
     * @param  - WFG_Referral__c: Referral Object
                 Contact: Contact Object
     * @throws - N/A
     * @author Samit
     * @date 12-22-2016
     */ 
    private static WFG_ReferralResponseWrapper acceptReferralObj(WFG_Referral__c objRef, Contact objContact)
    {
        Map<Id, Contact> mapContactTobeCreated = new Map<Id, Contact>();
        WFG_ReferralResponseWrapper objRes = new WFG_ReferralResponseWrapper();
        try
        {
            if(objRef != null && objRef.id != null)
            {
                objRef = [Select Id, Name,  WFG_Contact_First_Name__c, WFG_Contact_Last_Name__c,
                                WFG_Email__c, WFG_Primary_Phone__c, WFG_Home_Country__c, WFG_State__c,
                                WFG_City__c, WFG_Zipcode__c, WFG_Street_Address__c, WFG_Referred_To__c,
                                WFG_Fiduciary_Contact__c
                                FROM WFG_Referral__c WHERE ID = :objRef.id];
                objRef.WFG_status__c = System.Label.WFG_ReferralStatus_Accepted;
                    
                objRef.WFG_Fiduciary_Contact__c = objContact.id;
                
                update objRef;
                
                //Creating customer profile
                List<WFG_Customer_Profile__c> lstCustPrfl = new List<WFG_Customer_Profile__c>();
                lstCustPrfl.add(createCustomerProfile(objRef.Id, objContact.id, 
                                                            objRef.WFG_Contact_First_Name__c+' '+objRef.WFG_Contact_Last_Name__c));  
                insert lstCustPrfl;
                WFG_ComponentResponseWrapper objGenericRes = new WFG_ComponentResponseWrapper();
                objGenericRes.boolIsError = false;
                objres = new WFG_ReferralResponseWrapper();
                objres.objGenericRes = objGenericRes;
                objres.strCustProfileId = lstCustPrfl[0].id;
                
                return objRes;
            }
        }
        catch(DmlException err)
        {
            
            WFG_ComponentResponseWrapper objGenericRes = new WFG_ComponentResponseWrapper();
            objGenericRes.boolIsError = true;
            objres = new WFG_ReferralResponseWrapper();
            objres.objGenericRes = objGenericRes;
            objRes.objGenericRes.strErrorMessage = '';
            for(Integer i=0; i < err.getNumDml(); i++)
            {
                objRes.objGenericRes.strErrorMessage = objRes.objGenericRes.strErrorMessage + err.getDmlMessage(i) + '\n';
            }
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_Referral__c', 'EXCEPTION', 'APEX', objRes.objGenericRes.strErrorMessage, objRes.objGenericRes.strErrorMessage, null, null, null, true);
            
            return objRes;
        } 
        catch(Exception err)
        {
            String strErr = err.getMessage();
            WFG_ComponentResponseWrapper objGenericRes = new WFG_ComponentResponseWrapper();
            objGenericRes.boolIsError = true;
            objGenericRes.strErrorMessage = strErr;
            objres = new WFG_ReferralResponseWrapper();
            objres.objGenericRes = objGenericRes;
            LogUtility.createLogs('EXCEPTION', 'ERROR', 'WFG_Referral__c', 'EXCEPTION', 'APEX', strErr, strErr, null, null, null, true);
            
            return objRes;
        }  
        return null;      
    }
    /**
     * 
     * @return - Contact
     * @param  - objReferral:  The Referral record 
     * @throws - N/A
     * @author Samit
     * @date 12-22-2016
     */
    public static Contact createContact(WFG_Referral__c objReferral)
    {
        //Creates a new Contact Instance
        Contact objContact = new Contact();
        //Maps the field from Refferal to Contact and set the Record type as Individual
        objContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        objContact.FirstName = objReferral.WFG_Contact_First_Name__c;
        objContact.LastName = objReferral.WFG_Contact_Last_Name__c;
        objContact.Email = objReferral.WFG_Email__c;
        objContact.Phone = objReferral.WFG_Primary_Phone__c;
        //objContact.MailingCountry = objReferral.WFG_Home_Country__c;
        //objContact.MailingState = objReferral.WFG_State__c;
        
        objContact.MailingCountry = WFG_PicklistFieldDescribeUtility.getPicklistValueCodes('Contact','MailingCountryCode',objReferral.WFG_Home_Country__c);
        
        
        if(objReferral.WFG_Home_Country__c == 'Puerto Rico'){
            objContact.MailingState = 'PRC';
        }
        else{
            objContact.MailingState = WFG_PicklistFieldDescribeUtility.getPicklistValueCodes('Contact','MailingStateCode',objReferral.WFG_State__c);
        }
        
        objContact.MailingCity = objReferral.WFG_City__c;
        objContact.MailingPostalCode = objReferral.WFG_Zipcode__c;
        objContact.MailingStreet = objReferral.WFG_Street_Address__c;
        //Dummy Values
        //objContact.WFG_AgentCode__c = '1234';
        //objContact.WFG_AgentLevel__c = 1;
        
        
        //Maintain a refernce in the Referral record Instance for future Mapping
        objReferral.WFG_Fiduciary_Contact__r = objContact;
        return objContact;
    }
    
    public static WFG_Customer_Profile__c createCustomerProfile(Id idReferral, Id idContact, String strContactName)
    {
        WFG_Customer_Profile__c objCP = new WFG_Customer_Profile__c();
        objCP.WFG_Referral__c = idReferral;
        objCP.WFG_Contact__c = idContact;
        objCP.WFG_Status__c = System.Label.WFG_CustomerProfileIncomplete;
        objCP.Name = strContactName + ' ' + System.Label.WFG_CustomerProfileShort;
        return objCP;
    }
    /**
     * This Utility method creatres a Refferal record from a Customer Profile record.
     * @return - Id of Newly created Referral record. 
     * @param  - objCustProfile:  The Customer Profile record instance
     * @throws - N/A
     * @author Samit
     * @date 12-22-2016
     */ 
    public static WFG_ReferralResponseWrapper checkCustomerProfiles(string strCustProfileId)
    {
        WFG_ReferralResponseWrapper objRes = new WFG_ReferralResponseWrapper();
        List<Id> lstCustId = new List<Id>{strCustProfileId};
        system.debug('##############' + strCustProfileId);
        map<id, WFG_ReferralResponseWrapper> mapRes = checkCustomerProfiles(lstCustId);
        if(mapRes != null && !mapRes.isEmpty()) 
        {
            if(mapRes.containskey(strCustProfileId) 
                && mapRes.get(strCustProfileId) != null)
            {
                objRes = mapRes.get(strCustProfileId);
            }
        }
        return objRes;
    }
    /**
     * This Utility method creatres a Refferal record from a Customer Profile record.
     * @return - Id of Newly created Referral record. 
     * @param  - objCustProfile:  The Customer Profile record instance
     * @throws - N/A
     * @author Samit
     * @date 12-22-2016
     */    
    public static map<id, WFG_ReferralResponseWrapper> checkCustomerProfiles(List<Id> lstCustProfileId)
    {
        List<WFG_Customer_Profile__c> lstCustProfile = new List<WFG_Customer_Profile__c>();
        map<id, WFG_ReferralResponseWrapper> mapResponse = new map<id, WFG_ReferralResponseWrapper>();
        set<String> setActiveReferralsStatus = WFG_Active_Referrals__c.getAll().keyset();
        if(lstCustProfileId != null && !lstCustProfileId.isEmpty())
        {
            lstCustProfile = [Select id, name, WFG_Status__C, WFG_advisors_to_contact_you__c,
                    WFG_Interested_in_discussing_options__c,WFG_OwnQualifiedAssets__c,
                    WFG_Consent_to_pass_contact_information__c,
                    WFG_Consent_for_FA_Contact__c,
                        (SELECT Id, name 
                        FROM Referrals__r 
                        WHERE WFG_Status__c 
                        IN :setActiveReferralsStatus)
                    FROM WFG_Customer_Profile__c
                    Where ID IN : lstCustProfileId];
            if(lstCustProfile != null && !lstCustProfile.isEmpty())
            {
                for(WFG_Customer_Profile__c objCustProfile : lstCustProfile)
                {
                    WFG_ReferralResponseWrapper objRes = new WFG_ReferralResponseWrapper();
                    if(objCustProfile.WFG_status__c != system.Label.WFG_CustomerProfile_Status)
                    {
                        objRes.objGenericRes.boolIsError = true;
                        objRes.objGenericRes.strErrorMessage = system.Label.WFG_CP_Incomplete_MSG;
                        mapResponse.put(objCustProfile.id, objRes);
                        continue;
                    }
                    if(objCustProfile.WFG_advisors_to_contact_you__c != 'Yes'
                        || objCustProfile.WFG_Interested_in_discussing_options__c != 'Yes'
                        || objCustProfile.WFG_OwnQualifiedAssets__c != 'Yes'
                        || objCustProfile.WFG_Consent_to_pass_contact_information__c != 'Yes'
                        || objCustProfile.WFG_Consent_for_FA_Contact__c != 'Yes')
                    {
                        objRes.objGenericRes.boolIsError = true;
                        objRes.objGenericRes.strErrorMessage = system.Label.WFG_CP_ImproperAnswer_MSG;
                        mapResponse.put(objCustProfile.id, objRes);
                        continue;
                    }
                    //Checks if there is already active referrals for a Customer Profile, and puts values in the Map according to it.
                    if(objCustProfile.Referrals__r != Null
                        && objCustProfile.Referrals__r.size()> 0)
                    {
                        string strError = System.Label.WFG_AlreadyActiveReferral.replace('[Referral_ID]',objCustProfile.Referrals__r[0].Name);
                        objRes.objGenericRes.boolIsError = true;
                        objRes.objGenericRes.strErrorMessage = strError;
                        mapResponse.put(objCustProfile.id, objRes);
                        continue;
                    }
                    
                }
            }
        }
        return mapResponse;
    }
}