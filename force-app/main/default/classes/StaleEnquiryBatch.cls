public class StaleEnquiryBatch implements Database.Batchable<SObject>, Schedulable {

    // -- Batchable --

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date thirtyDaysAgo = Date.today().addDays(-30);
        return Database.getQueryLocator([
            SELECT Id, Status__c, Closed_Date__c, LastModifiedDate
            FROM Enquiry__c
            WHERE Status__c = 'In Progress'
              AND LastModifiedDate < :thirtyDaysAgo
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Enquiry__c> scope) {
        for (Enquiry__c enq : scope) {
            enq.Status__c = 'Closed';
            // Closed_Date__c stamped by EnquiryTrigger beforeUpdate
        }
        Database.update(scope, true, AccessLevel.SYSTEM_MODE);
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('StaleEnquiryBatch complete.');
    }

    // -- Schedulable --

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new StaleEnquiryBatch(), 200);
    }
}
