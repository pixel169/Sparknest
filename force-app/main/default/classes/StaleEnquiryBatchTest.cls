@isTest
public class StaleEnquiryBatchTest {

    @isTest
    static void testBatchExecution() {
        List<Enquiry__c> enquiries = TestDataFactory.createEnquiries(5, 5000);
        for (Enquiry__c enq : enquiries) {
            enq.Status__c = 'In Progress';
        }
        TestDataFactory.sysInsert(enquiries);

        Test.startTest();
        Database.executeBatch(new StaleEnquiryBatch());
        Test.stopTest();

        List<Enquiry__c> results = [
            SELECT Status__c FROM Enquiry__c WHERE Id IN :enquiries
        ];
        for (Enquiry__c enq : results) {
            System.assertEquals('In Progress', enq.Status__c, 'Recent enquiries should not be closed');
        }
    }

    @isTest
    static void testSchedulable() {
        Test.startTest();
        String cronExp = '0 0 0 * * ?';
        System.schedule('Test Stale Enquiry Batch', cronExp, new StaleEnquiryBatch());
        Test.stopTest();

        List<CronTrigger> jobs = [
            SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Test Stale Enquiry Batch'
        ];
        System.assertEquals(1, jobs.size(), 'Scheduled job should exist');
    }
}
