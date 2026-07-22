public without sharing class GetEnquiriesByEmail {

    public class Input {
        @InvocableVariable(required=true description='Customer email address to look up enquiries')
        public String email;
    }

    public class Output {
        @InvocableVariable(description='Summary of all enquiries found for this email')
        public String enquirySummary;

        @InvocableVariable(description='Number of enquiries found')
        public Integer enquiryCount;

        @InvocableVariable(description='Whether any enquiries were found')
        public Boolean found;
    }

    @InvocableMethod(label='Get Enquiries by Email'
                     description='Retrieves all Enquiry records matching the given email and returns a formatted summary')
    public static List<Output> getEnquiries(List<Input> inputs) {
        List<Output> results = new List<Output>();

        for (Input inp : inputs) {
            Output out = new Output();
            out.found = false;
            out.enquiryCount = 0;
            out.enquirySummary = 'No enquiries found for this email.';

            if (String.isNotBlank(inp.email)) {
                List<Enquiry__c> enquiries = [
                    SELECT Name, Status__c, Customer_Name__c, CreatedDate, Customer_Budget__c
                    FROM Enquiry__c
                    WHERE Email_ID__c = :inp.email
                    ORDER BY CreatedDate DESC
                    LIMIT 10
                ];

                if (!enquiries.isEmpty()) {
                    out.found = true;
                    out.enquiryCount = enquiries.size();

                    List<String> lines = new List<String>();
                    for (Enquiry__c enq : enquiries) {
                        lines.add(
                            enq.Name +
                            ' | Status: ' + enq.Status__c +
                            ' | Created: ' + enq.CreatedDate.format('dd-MMM-yyyy') +
                            ' | Budget: ' + (enq.Customer_Budget__c != null ? String.valueOf(enq.Customer_Budget__c) : 'N/A')
                        );
                    }
                    out.enquirySummary = String.join(lines, '\n');
                }
            }

            results.add(out);
        }

        return results;
    }
}
