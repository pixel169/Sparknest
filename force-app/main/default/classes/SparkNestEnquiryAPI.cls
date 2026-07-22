@RestResource(urlMapping='/sparknest/enquiry')
global without sharing class SparkNestEnquiryAPI {

    global class EnquiryRequest {
        global String customerName;
        global String email;
        global String phone;
        global String enquirySubject;
        global String enquiryType;     // Care_Plan_Enquiry or Product_Enquiry
        global Decimal customerBudget;
        global String source;          // Website, App, Walk-in Store
    }

    global class EnquiryResponse {
        global Boolean success;
        global String contactId;
        global String enquiryId;
        global String message;
        global Integer statusCode;
    }

    @HttpPost
    global static EnquiryResponse createEnquiry() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        EnquiryResponse response = new EnquiryResponse();

        try {
            EnquiryRequest payload = (EnquiryRequest) JSON.deserialize(
                req.requestBody.toString(),
                EnquiryRequest.class
            );

            // validate email
            if (String.isBlank(payload.email)) {
                res.statusCode = 400;
                response.success = false;
                response.statusCode = 400;
                response.message = 'Email is required';
                return response;
            }

            // find or create contact
            List<Contact> existing = [
                SELECT Id, FirstName, LastName, Email
                FROM Contact
                WHERE Email = :payload.email
                LIMIT 1
            ];

            Contact contact;
            if (!existing.isEmpty()) {
                contact = existing[0];
                response.message = 'Existing customer found. Enquiry created.';
            } else {
                contact = new Contact();
                contact.LastName = String.isNotBlank(payload.customerName)
                    ? payload.customerName : 'Unknown';
                contact.Email = payload.email;
                contact.Phone = payload.phone;
                Database.insert(contact, true, AccessLevel.SYSTEM_MODE);
                response.message = 'New customer created. Enquiry created.';
            }

            // pick record type
            String rtDev = (String.isNotBlank(payload.enquiryType)
                && payload.enquiryType == 'Care_Plan_Enquiry')
                ? 'Care_Plan_Enquiry' : 'Product_Enquiry';

            Id recordTypeId = Schema.SObjectType.Enquiry__c
                .getRecordTypeInfosByDeveloperName()
                .get(rtDev)
                .getRecordTypeId();

            // create enquiry
            Enquiry__c enquiry = new Enquiry__c();
            enquiry.Name = String.isNotBlank(payload.enquirySubject)
                ? payload.enquirySubject : 'Website Enquiry';
            enquiry.Customer_Name__c = payload.customerName;
            enquiry.Email_ID__c = payload.email;
            enquiry.Phone__c = payload.phone;
            enquiry.Customer_Budget__c = payload.customerBudget;
            enquiry.RecordTypeId = recordTypeId;
            enquiry.Status__c = 'New';

            if (String.isNotBlank(payload.source)) {
                enquiry.Heard_About_SparkNest__c = payload.source;
            }

            Database.insert(enquiry, true, AccessLevel.SYSTEM_MODE);
            // trigger will auto-create follow-up task

            response.success = true;
            response.contactId = contact.Id;
            response.enquiryId = enquiry.Id;
            response.statusCode = 201;
            res.statusCode = 201;
            return response;

        } catch (Exception e) {
            res.statusCode = 500;
            response.success = false;
            response.statusCode = 500;
            response.message = 'Server Error: ' + e.getMessage();
            return response;
        }
    }
}
