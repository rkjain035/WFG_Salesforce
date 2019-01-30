/*
Property of Transamerica and Aegon companies. Do not distribute without permission.
* Copyright (c) [2016] Transamerica Corporation, its affiliates and their licensors.
* @author Ramanarayanan
* @date 06-24-2016
* @description US-2372: Wrapper class to hold Live Chat Transcript

Modification Log:
__________________________________________________________________________________________________________
Developer          ModNumber           Date                    Description
__________________________________________________________________________________________________________
Ramanarayanan P    M-001               06-24-2016              US-2372: Wrapper to hold Live chat transcript 
                                                               and format start and end date time 
*/
public class WFG_ChatTranscript 
    { 
        @AuraEnabled
        public String strStartTime = '';
        @AuraEnabled
        public String strEndTime = '';
        @AuraEnabled
        public LiveChatTranscript lchatTranscript = new LiveChatTranscript();
       public WFG_ChatTranscript(LiveChatTranscript lchatTranscript)
       {
           this.lchatTranscript = lchatTranscript;
           DateTime dtStartime = lchatTranscript.StartTime;
           DateTime dtEndtime = lchatTranscript.EndTime;
           strStartTime = dtStartime.format();
           strEndTime = dtEndtime.format();
       }
    }