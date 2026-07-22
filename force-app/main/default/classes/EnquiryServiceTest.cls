@isTest
public class EnquiryServiceTest {

    @isTest
    static void testDefaultStatus() {
        Enquiry__c enq = TestDataFactory.createEnquiry('Test Default', null, 5000);

        Test.startTest();
        TestDataFactory.sysInsert(enq);
        Test.stopTest();

        Enquiry__c result = [SELECT Status__c FROM Enquiry__c WHERE Id = :enq.Id];
        System.assertEquals('New', result.Status__c, 'Status should default to New when blank');
    }

    @isTest
    static void testBudgetValidation() {
        Enquiry__c enq = TestDataFactory.createEnquiry('Test Budget', 'New', 500);

        Test.startTest();
        try {
            TestDataFactory.sysInsert(enq);
            System.assert(false, 'Should have thrown an error for budget < 1000');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('1000') || e.getMessage().contains('1,000'),
                'Error should mention minimum budget');
        }
        Test.stopTest();
    }

    @isTest
    static void testBudgetValidPass() {
        Enquiry__c enq = TestDataFactory.createEnquiry('Test Budget Pass', 'New', 5000);

        Test.startTest();
        TestDataFactory.sysInsert(enq);
        Test.stopTest();

        Enquiry__c result = [SELECT Id FROM Enquiry__c WHERE Id = :enq.Id];
        System.assertNotEquals(null, result.Id, 'Enquiry should be created with valid budget');
    }

    @isTest
    static void testNullBudgetAllowed() {
        Enquiry__c enq = TestDataFactory.createEnquiry('Test Null Budget', 'New', null);

        Test.startTest();
        TestDataFactory.sysInsert(enq);
        Test.stopTest();

        Enquiry__c result = [SELECT Id FROM Enquiry__c WHERE Id = :enq.Id];
        System.assertNotEquals(null, result.Id, 'Enquiry should be created with null budget');
    }

    @isTest
    static void testFollowUpTaskCreated() {
        Enquiry__c enq = TestDataFactory.createEnquiry('Test Follow Up', 'New', 5000);

        Test.startTest();
        TestDataFactory.sysInsert(enq);
        Test.stopTest();

        List<Task> tasks = [
            SELECT Subject, WhatId, ActivityDate, Status
            FROM Task WHERE WhatId = :enq.Id
        ];
        System.assertEquals(1, tasks.size(), 'One follow-up task should be created');
        System.assert(tasks[0].Subject.contains('Follow up:'), 'Task subject should have Follow up');
        System.assertEquals(Date.today().addDays(3), tasks[0].ActivityDate, 'Due in 3 days');
    }

    @isTest
    static void testClosedDateStamped() {
        Enquiry__c enq = TestDataFactory.createEnquiry('Test Closed', 'New', 5000);
        TestDataFactory.sysInsert(enq);

        Test.startTest();
        enq.Status__c = 'Closed';
        TestDataFactory.sysUpdate(enq);
        Test.stopTest();

        Enquiry__c result = [SELECT Closed_Date__c, Status__c FROM Enquiry__c WHERE Id = :enq.Id];
        System.assertEquals('Closed', result.Status__c);
        System.assertEquals(Date.today(), result.Closed_Date__c, 'Closed Date should be today');
    }

    @isTest
    static void testClosedDateNotStampedForOtherStatus() {
        Enquiry__c enq = TestDataFactory.createEnquiry('Test No Stamp', 'New', 5000);
        TestDataFactory.sysInsert(enq);

        Test.startTest();
        enq.Status__c = 'In Progress';
        TestDataFactory.sysUpdate(enq);
        Test.stopTest();

        Enquiry__c result = [SELECT Closed_Date__c FROM Enquiry__c WHERE Id = :enq.Id];
        System.assertEquals(null, result.Closed_Date__c, 'Closed Date should be null');
    }

    @isTest
    static void testBulkInsert() {
        List<Enquiry__c> enquiries = TestDataFactory.createEnquiries(200, 5000);

        Test.startTest();
        TestDataFactory.sysInsert(enquiries);
        Test.stopTest();

        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId IN :enquiries];
        System.assertEquals(200, tasks.size(), '200 follow-up tasks for bulk insert');
    }
}
