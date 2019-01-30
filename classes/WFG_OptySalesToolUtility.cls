/**
*
Property of Transamerica andAegoncompanies.Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Samit
* @date 02-09-2017
* @description  Utility Class for Opportunity Sales Tool Component

*/
public with sharing class WFG_OptySalesToolUtility
{
    /**
     * Utility method which returns the list of sales Tool according to stage & Profile
     * @param  - strProfile: The Name of the Profile
     * @param  - strStage: The Name of the Opty Stage.
     * @throws - N/A
     * @author Samit
     * @date 02-09-2017
     */
    public static List<WFG_OptySalesToolWrapper> getSalesTool(String strProfile, String strStage, String strPacLifeStatus)
    {
        List<WFG_OptySalesToolWrapper> lstSalesTool = new List<WFG_OptySalesToolWrapper>();
       try {
      
        if(strProfile != NULL && strProfile != '' && strStage != NULL && strStage != '')
        {
            for(WFG_OptySalesToolLink__c objSalesToolConfig: WFG_OptySalesToolLink__c.getAll().values())
            {
                System.debug('Test class debug for loop');
                if(objSalesToolConfig.WFG_Active__c && objSalesToolConfig.WFG_Profile__c == strProfile && objSalesToolConfig.WFG_Stage__c == strStage)
                {
                    System.debug('Test class debug all conditions');
                    WFG_OptySalesToolWrapper objTool = new WFG_OptySalesToolWrapper(objSalesToolConfig);
                    System.debug(objTool.boolShowLink);
                    if(objTool.boolShowLink)
                    {
                        //check Pacific Life appointment to decide hide/show
                        System.debug('strSalesToolURL: ' + objTool.strSalesToolURL);
                        if(!objTool.strSalesToolURL.contains('PacificLife') || 
                           (!String.isEmpty(strPacLifeStatus) && strPacLifeStatus == 'Active'))
                        {
                        	lstSalesTool.add(objTool);
                        }
                    }
                }    
            }
            System.debug(lstSalesTool.size());
            lstSalesTool.sort();
        }
       }
     catch (Exception e) {
           System.debug(e.getMessage());
        }
        return lstSalesTool;      
    }
    
    public static WFG_OpportunityInfo GetOpportunity(String optyId) 
    {
        WFG_OpportunityInfo thisOpportunity = new WFG_OpportunityInfo();
        Try {
            Opportunity oppt = [select Amount, CloseDate, CreatedDate, Id, Name, Probability, RecordTypeId, StageName, 
                                WFG_Contact__c, WFG_Contact__r.Name, WFG_Contact__r.Id, Account.Name,
                                WFG_Customer_Profile_Status__c, WFG_CustomerProfile__r.Name, 
                                WFG_CustomerProfile__c, WFG_Lost_Reason__c, WFG_Product_Type__c, 
                                WFG_Referral__r.Name, WFG_Source__c, WFG_Total_Field_Commission__c, WFG_ModalName__c
                                from Opportunity where Id =: optyId];
            
            thisOpportunity.customerProfileName = oppt.WFG_CustomerProfile__r.Name;
            thisOpportunity.referralName = oppt.WFG_Referral__r.Name;
            thisOpportunity.contactName = oppt.WFG_Contact__r.Name;
            thisOpportunity.recordTypeName = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppt.RecordTypeId).getname();
            thisOpportunity.accountName = oppt.Account.Name;
            thisOpportunity.contactID = oppt.WFG_Contact__r.Id;
            
            //Get Opportunity client infor
            WFG_SSOClientInfo.getClientInfo(optyId, thisOpportunity);
            
            if(thisOpportunity.recordTypeName == 'InsuranceReadOnly'){
                thisOpportunity.recordTypeName = 'Insurance';
            }
            else if(thisOpportunity.recordTypeName == 'Investment/Savings Read Only'){
                thisOpportunity.recordTypeName = 'Investment/Saving';
            }
            return thisOpportunity;

        } catch (Exception e) {
            return null;
        }
    }
   
     /**
     * Utility method which SSO end point based on provider name
     * @param  - provider: The Name of the Provider
     * @throws - N/A
     * @author Linda Liu
     * @date 01-10-2019
     */
    public  static String GetProviderSSO(String oppId, String provider)
    {
        try
        {
            //Get end point from custom settings
            SSO_Endpoints__c endpoints = SSO_Endpoints__c.getValues(provider);
            String strEndpoints = '';
            Boolean updatePayload = false; 
            if(endpoints !=null)
            {
                strEndpoints =  endpoints.EndpointUrl__c;
                updatePayload = endpoints.UpdatePayload__c;
                //System.debug('EndpointUrl__c: ' + endpoints.EndpointUrl__c + ' UpdatePayload__c=' + endpoints.UpdatePayload__c);
            }
        	
            //Update User.ApplicationData for payload if needed, return error when update failed
            if(updatePayload)
            {  // System.debug('in updatePayload oppid=' + oppId + ' provider= ' + provider);
                String err = updatePayload(oppId, provider);
                if(err.length()>0)
                {
                    return err;
                }
            }
                        
            //System.debug('strEndpoints: ' + strEndpoints + ' up=' + updatePayload);
  
            return strEndpoints;
        }
        catch(Exception e)
        {
            return 'Error: ' + e.getMessage();
        }
    }
    
     /**
     * Private Utility method to update payload fields $User.ApplicationData
     * @param  - provider: The Name of the Provider
     * @throws - N/A
     * @author Linda Liu
     * @date 01-10-2019
     */
    public static String updatePayload(String opportunityId, String providerName)
    {        
        //System.debug('in updatePayload');
        try
        {
        	WFG_OpportunityInfo payload = GetOpportunity(opportunityId);
            if(payload==null)
                return '';
            System.debug('Occupation=' + payload.Occupation + ' salary=' + payload.AnnualIncome+ ' martst=' 
                         + payload.MaritalStatus+ ' code=' + payload.agentCode+ ' last=' + payload.LastName +
                        ' gender=' + payload.Gender+ ' birthdate=' + payload.Birthdate+ ' citizen=' + payload.Citizenship +
                        ' depend=' + payload.NumberofDependents + ' homephone=' + payload.HomePhone+ ' email=' + payload.Email +
                        ' employer=' + payload.CurrentEmployer + ' country=' + payload.MailingCountry + ' address=' + payload.MailingStreet); 
            
            String strPayload = getPayloadString(payload, providerName);
            System.debug(strPayload);
            string userId = UserInfo.getUserId();
            
			//save the payload to table per opportunity per provider            
            SSO_ApplicationData__c[] ssoDataList = [SELECT Id, Name, ApplicationData__c,OpportunityId__c,Provider__c, UserId__c
                                                    FROM SSO_ApplicationData__c WHERE OpportunityId__c = :opportunityId and Provider__c=:providerName];
            if(ssoDataList.size()>0) {
                ssoDataList[0].ApplicationData__c = strPayload;
            	ssoDataList[0].OpportunityId__c = opportunityId;
            	ssoDataList[0].Provider__c = providerName;
                ssoDataList[0].UserId__c = userId;
            }
            else
            {
            	SSO_ApplicationData__c ssodata = new SSO_ApplicationData__c();
                ssodata.ApplicationData__c = strPayload;
            	ssodata.OpportunityId__c = opportunityId;
            	ssodata.Provider__c = providerName;
                ssodata.UserId__c = userId;
            	ssoDataList.add(ssodata);
            }
            upsert ssoDataList;
            
            //User user = [select Id,ApplicationData__c
			//			from User where id=:userId];
            //user.ApplicationData__c = strPayload; 
           // update user;
            
            return '';
        }
        catch(Exception e)
        {
            return 'Error: ' + e.getMessage();
        }
    }
 
    private static String getPayloadString(WFG_OpportunityInfo opportunity, String providerName)
    {
        try
        {
            String strPayload = '';
            if(opportunity == null)
                return strPayload;
            
            //section for FireLight SSO update
            if(providerName.uncapitalize()=='firelight')
            {
            	//get guid
            //string guid = EncodingUtil.base64Encode(Crypto.generateAesKey(256)).right(40);
            	String hexKey = EncodingUtil.convertToHex(
        		Crypto.generateDigest('MD5', Blob.valueOf(DateTime.now().getTime().format()))
            	);
                String guid = hexKey.SubString(0,8)+ '-' + hexKey.SubString(8,12) + '-' + hexKey.SubString(12,16) + '-' + hexKey.SubString(16,20) + '-' + hexKey.substring(20);
        
            //get current datetime
           // Datetime now = Datetime.now();
            //Integer offset = UserInfo.getTimezone().getOffset(now);
            //Datetime local = now.addSeconds(offset/1000);
            	String agentCodeNumber = opportunity.agentCode;
            
            	strPayload += '<TXLife xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://ACORD.org/Standards/Life/2">';
                strPayload += '<TXLifeRequest><TransRefGUID>' + guid + '</TransRefGUID><TransType tc="103"></TransType><TransExeDate>' + Datetime.now().format('yyyy-MM-dd') + '</TransExeDate><TransExeTime>' + Datetime.now().time() + '</TransExeTime>';
        		strPayload +='<OLifE><SourceInfo><SourceInfoName>Transamerica Financial Advisors</SourceInfoName></SourceInfo>';
        		strPayload +='<Holding id="PrimaryHolding"><HoldingTypeCode tc="2">OLI_HOLDTYPE_POLICY</HoldingTypeCode><Policy><CarrierCode>TFA</CarrierCode></Policy></Holding>';
            
                strPayload += '<Party id="Agent_' + agentCodeNumber + '"><PartyTypeCode tc="1">OLI_PT_PERSON</PartyTypeCode><Producer><CarrierAppointment><CompanyProducerID>' + agentCodeNumber + '</CompanyProducerID><CarrierCode>TFA</CarrierCode></CarrierAppointment></Producer></Party>';
                strPayload += '<Party id="Contact_' + opportunity.opportunityId + '"><PartyTypeCode tc="1">OLI_PT_PERSON</PartyTypeCode>';
            	strPayload += '<Person><FirstName>' + opportunity.FirstName + '</FirstName><LastName>' + opportunity.LastName + '</LastName>' + getItemXml(opportunity.Gender, 'Gender') + getItemXml(opportunity.Birthdate, 'Birthdate') +  getItemXml(opportunity.MaritalStatus, 'MaritalStatus') + '<Citizenship>' + opportunity.Citizenship + '</Citizenship></Person>';
            	strPayload += '<Client><NumRelations>' + opportunity.NumberofDependents + '</NumRelations></Client>';
            	strPayload +='<Address><AddressTypeCode tc="1">OLI_ADTYPE_HOME</AddressTypeCode><Line1>' + opportunity.MailingStreet + '</Line1><City>' + opportunity.MailingCity + '</City><AddressState>' + opportunity.MailingState + '</AddressState><AddressStateTC>OLI_USA_' + opportunity.MailingState + '</AddressStateTC><Zip>' + opportunity.MailingZIP + '</Zip></Address>';
            	strPayload +='<Address><AddressTypeCode tc="2">OLI_ADTYPE_BUS</AddressTypeCode><Line1>' + opportunity.OtherStreet + '</Line1><City>' + opportunity.OtherCity + '</City><AddressState>' + opportunity.OtherState + '</AddressState><AddressStateTC>OLI_USA_' + opportunity.OtherState + '</AddressStateTC><Zip>' + opportunity.OtherZIP + '</Zip></Address>';
            	strPayload +='<Employment><Occupation>' + opportunity.Occupation + '</Occupation><EmployerName>' + opportunity.CurrentEmployer + '</EmployerName>' + getItemXml(opportunity.AnnualIncome, 'AnnualIncome') + '</Employment></Party>';
            	strPayload += '<Relation OriginatingObjectID="PrimaryHolding" RelatedObjectID="Agent_' + agentCodeNumber + '"><OriginatingObjectType tc="4">OLI_HOLDING</OriginatingObjectType><RelatedObjectType tc="6">OLI_PARTY</RelatedObjectType><RelationRoleCode tc="37">OLI_REL_PRIMAGENT</RelationRoleCode></Relation>';
            	strPayload += '<Relation OriginatingObjectID="PrimaryHolding" RelatedObjectID="Contact_' + opportunity.opportunityId + '"><OriginatingObjectType tc="4">OLI_HOLDING</OriginatingObjectType><RelatedObjectType tc="6">OLI_PARTY</RelatedObjectType><RelationRoleCode tc="8">OLI_REL_OWNER</RelationRoleCode></Relation>';
            	strPayload += '</OLifE></TXLifeRequest></TXLife>';
            
                strPayload = strPayload.replace('null','').replace('NULL','');
            }    
                System.debug('The Output is' + strPayload); 
            return strPayload;
        }
        catch(Exception e){
            return 'Error - ' + e.getStackTraceString();
        }
    }
    private static String getItemXml(String itemValue, String itemName)
    {
        //remove note xml when value is null or empty
        if(itemValue == null || itemValue.trim().length()==0)
        {
            return '';
        }
            
        itemValue = itemValue.uncapitalize();
        
        if(itemName=='Gender')
        {
            switch on itemValue
            {
                when 'male'{
                    return '<Gender tc="1">Male</Gender>';
                }
                when 'female'{
                    return '<Gender tc="2">Female</Gender>';
                }
                when 'other'{
                    return '<Gender tc="3">Other</Gender>';
                }
            }
        }
                
        if(itemName=='MaritalStatus')
        {
            switch on itemValue
            {
                when 'married'{
                    return '<MarStat tc="1">Married</MarStat>';
                }
                when 'single'{
                    return '<MarStat tc="2">Single</MarStat>';
                }
                when 'other'{
                    return '<MarStat tc="3">Other</MarStat>';
                }
            }
        }
        
        if(itemName=='Birthdate')
        {
            return '<BirthDate>' + itemValue + '</BirthDate>';          
        }
        
        if(itemName=='AnnualIncome')
        {
            return '<AnnualSalary>' + itemValue + '</AnnualSalary>';          
        }
        
        return '';
    }
        
    private static String getMarStatId(String marStat)
    {
        if(marStat == null || marStat.trim().length()==0)
            return '3';
        
        if(marStat.uncapitalize()=='married')
            return '1';
        if(marStat.uncapitalize()=='single')
            return '2';
        
        return '3';
    }
    private static String getPayloadXml(WFG_OpportunityInfo opportunity, String providerName)
    {
        try
        {
            XmlStreamWriter w =new XmlStreamWriter();
            w.writeStartDocument(null, '1.0');
                    
            if(providerName.uncapitalize()=='firelight')
            {
                w.writeStartElement(null,'ApplicationData', null);
                    w.writeStartElement(null, 'oppid', null);
                    w.writeCharacters(opportunity.opportunityId);
                    w.writeEndElement();
                w.writeEndElement();
            }
            
            w.writeEndDocument();
            String xmlOutput = w.getXmlString();
    		w.close();
        	System.debug('The Output is' + xmlOutput); 
            return xmlOutput;
        }
        catch(Exception e){
            return 'Error - ' + e.getStackTraceString();
        }
    }
    
}