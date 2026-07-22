@isTest
public class TestDataFactory {

    public static Enquiry__c createEnquiry(String name, String status, Decimal budget) {
        Enquiry__c enq = new Enquiry__c();
        enq.Name = name;
        enq.Status__c = status;
        enq.Customer_Budget__c = budget;
        enq.Customer_Name__c = 'Test Customer';
        enq.Email_ID__c = 'test@example.com';

        Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Enquiry__c.getRecordTypeInfosByDeveloperName();
        if (rtMap.containsKey('Product_Enquiry')) {
            enq.RecordTypeId = rtMap.get('Product_Enquiry').getRecordTypeId();
        }
        return enq;
    }

    public static List<Enquiry__c> createEnquiries(Integer count, Decimal budget) {
        List<Enquiry__c> enquiries = new List<Enquiry__c>();
        for (Integer i = 0; i < count; i++) {
            enquiries.add(createEnquiry('Test Enquiry ' + i, 'New', budget));
        }
        return enquiries;
    }

    public static Contact createContact(String firstName, String lastName, String email) {
        Contact c = new Contact();
        c.FirstName = firstName;
        c.LastName = lastName;
        c.Email = email;
        return c;
    }

    // system-mode DML helpers -- bypasses FLS enforcement
    public static void sysInsert(SObject record) {
        Database.insert(record, true, AccessLevel.SYSTEM_MODE);
    }

    public static void sysInsert(List<SObject> records) {
        Database.insert(records, true, AccessLevel.SYSTEM_MODE);
    }

    public static void sysUpdate(SObject record) {
        Database.update(record, true, AccessLevel.SYSTEM_MODE);
    }

    public static void sysUpdate(List<SObject> records) {
        Database.update(records, true, AccessLevel.SYSTEM_MODE);
    }
}
