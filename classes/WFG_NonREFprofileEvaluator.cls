public without sharing class WFG_NonREFprofileEvaluator 
{
    public static Map<string, string> evaluateProfile(map <string, string> mapStringVsProfile)
    {
    	//map<string, WFG_ReferralSwitch__c> mapReferralSwitch = WFG_ReferralSwitch__c.getAll(); 
    	map<string, WFG_ReferralSwitch__c> mapReferralSwitch = new Map<string, WFG_ReferralSwitch__c>();
        for(String strProfileId : WFG_ReferralSwitch__c.getAll().keyset())
        {
            mapReferralSwitch.put(strProfileId.substring(0,15),WFG_ReferralSwitch__c.getAll().get(strProfileId));
		}
    	if(mapStringVsProfile != null && !mapStringVsProfile.keyset().isEmpty())
    	{
            for(String strConId : mapStringVsProfile.keyset())
    		{
    		    if(mapStringVsProfile.get(strConId) != null)
                {
        			if(mapReferralSwitch.containskey(mapStringVsProfile.get(strConID).substring(0,15))
        				&& mapReferralSwitch.get(mapStringVsProfile.get(strConID).substring(0,15)) != null)
        			{
        				if(mapReferralSwitch.get(mapStringVsProfile.get(strConID).substring(0,15)).WFG_Referral_Switch__c == true)
        				{
        					mapStringVsProfile.put(strConId, mapReferralSwitch.get(mapStringVsProfile.get(strConID).substring(0,15)).WFG_NR_Profile_ID__c);
        				}
        			}
                }
    		}
    	}
    	return mapStringVsProfile;
    }
}