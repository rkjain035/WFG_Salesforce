global class TestClassBatch implements Database.Batchable<sObject>,Database.Stateful{
    public List<LogWrapper> batchClassLogWrapperist = new List<LogWrapper>();
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        LogWrapper logOne = LogUtility.returnLogs('Warning','Error','Abc','Xyz1','Test1','Testing1','Test1', 'testSourceObject', 'Rest', 'Request');
        batchClassLogWrapperist.add(logOne);
        return Database.getQueryLocator('Select Id from User limit 1');
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        LogWrapper logOne = LogUtility.returnLogs('Warning','Error','Pqr','Xyz2','Test2','Testing2','Test2', 'testSourceObject', 'Rest', 'Request');
        batchClassLogWrapperist.add(logOne);
    }
    
    global void finish(Database.BatchableContext BC){
        LogWrapper logOne = LogUtility.returnLogs('Warning','Error','Lmn','Xyz3','Test3','Testing3','Test3', 'testSourceObject', 'Rest', 'Request');
        batchClassLogWrapperist.add(logOne);
        LogUtility.commitLogs(batchClassLogWrapperist);
    }
}