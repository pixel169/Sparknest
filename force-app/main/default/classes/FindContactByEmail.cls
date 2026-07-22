public without sharing class FindContactByEmail {

    public class Input {
        @InvocableVariable(required=true description='Customer email address')
        public String email;
    }

    public class Output {
        @InvocableVariable(description='Contact Id')
        public String contactId;

        @InvocableVariable(description='Contact full name')
        public String contactName;

        @InvocableVariable(description='Whether a contact was found')
        public Boolean found;
    }

    @InvocableMethod(label='Find Contact by Email'
                     description='Searches for a Contact record matching the given email address')
    public static List<Output> findContact(List<Input> inputs) {
        List<Output> results = new List<Output>();

        for (Input inp : inputs) {
            Output out = new Output();
            out.found = false;

            if (String.isNotBlank(inp.email)) {
                List<Contact> contacts = [
                    SELECT Id, FirstName, LastName, Email
                    FROM Contact
                    WHERE Email = :inp.email
                    LIMIT 1
                ];

                if (!contacts.isEmpty()) {
                    Contact c = contacts[0];
                    out.contactId = c.Id;
                    out.contactName = (c.FirstName != null ? c.FirstName + ' ' : '') + c.LastName;
                    out.found = true;
                }
            }

            results.add(out);
        }

        return results;
    }
}
