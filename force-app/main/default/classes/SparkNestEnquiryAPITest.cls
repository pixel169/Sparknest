@isTest
public class SparkNestEnquiryAPITest {

    @isTest
    static void testNewCustomerEnquiry() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/sparknest/enquiry';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'customerName'   => 'Test Customer',
            'email'          => 'newcustomer@test.com',
            'phone'          => '+91-9999999999',
            'enquirySubject' => 'Interested in Band Pro',
            'enquiryType'    => 'Product_Enquiry',
            'customerBudget' => 5000,
            'source'         => 'Website'
        }));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        SparkNestEnquiryAPI.EnquiryResponse result = SparkNestEnquiryAPI.createEnquiry();
        Test.stopTest();

        System.assert(result.success, 'Should succeed for new customer: ' + result.message);
        System.assertNotEquals(null, result.contactId, 'Contact should be created');
        System.assertNotEquals(null, result.enquiryId, 'Enquiry should be created');
        System.assertEquals(201, result.statusCode);

        List<Contact> contacts = [SELECT Email FROM Contact WHERE Email = 'newcustomer@test.com'];
        System.assertEquals(1, contacts.size(), 'One contact should exist');

        List<Task> tasks = [SELECT Subject FROM Task WHERE WhatId = :result.enquiryId];
        System.assertEquals(1, tasks.size(), 'Follow-up task should exist');
    }

    @isTest
    static void testExistingCustomerEnquiry() {
        Contact c = TestDataFactory.createContact('Existing', 'Customer', 'existing@test.com');
        TestDataFactory.sysInsert(c);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/sparknest/enquiry';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'customerName'   => 'Existing Customer',
            'email'          => 'existing@test.com',
            'enquirySubject' => 'Care Plan Query',
            'enquiryType'    => 'Care_Plan_Enquiry',
            'customerBudget' => 10000
        }));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        SparkNestEnquiryAPI.EnquiryResponse result = SparkNestEnquiryAPI.createEnquiry();
        Test.stopTest();

        System.assert(result.success, 'Should succeed for existing customer: ' + result.message);
        System.assertEquals(c.Id, result.contactId, 'Should use existing contact');
        System.assert(result.message.contains('Existing'), 'Should say existing customer');
    }

    @isTest
    static void testMissingEmail() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/sparknest/enquiry';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'customerName' => 'No Email Customer'
        }));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        SparkNestEnquiryAPI.EnquiryResponse result = SparkNestEnquiryAPI.createEnquiry();
        Test.stopTest();

        System.assert(!result.success, 'Should fail without email');
        System.assertEquals(400, result.statusCode, 'Should return 400');
    }
}
