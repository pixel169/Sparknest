public without sharing class EnquiryService {

    // default Status to 'New' if blank
    public static void setDefaults(List<Enquiry__c> newEnquiries) {
        for (Enquiry__c enq : newEnquiries) {
            if (String.isBlank(enq.Status__c)) {
                enq.Status__c = 'New';
            }
        }
    }


    // stamp Closed Date when Status changes to Closed
    public static void stampClosedDate(List<Enquiry__c> newEnquiries, Map<Id, Enquiry__c> oldMap) {
        for (Enquiry__c enq : newEnquiries) {
            Enquiry__c oldEnq = oldMap.get(enq.Id);
            if (enq.Status__c == 'Closed' && oldEnq.Status__c != 'Closed') {
                enq.Closed_Date__c = Date.today();
            }
        }
    }

    // create follow-up task for each new enquiry
    public static void createFollowUpTasks(List<Enquiry__c> newEnquiries) {
        List<Task> tasksToInsert = new List<Task>();

        for (Enquiry__c enq : newEnquiries) {
            Task followUp = new Task();
            followUp.Subject = 'Follow up: ' + enq.Name;
            followUp.WhatId = enq.Id;
            followUp.OwnerId = enq.OwnerId;
            followUp.Status = 'Not Started';
            followUp.Priority = 'Normal';
            followUp.ActivityDate = Date.today().addDays(3);
            tasksToInsert.add(followUp);
        }

        if (!tasksToInsert.isEmpty()) {
            Database.insert(tasksToInsert, true, AccessLevel.SYSTEM_MODE);
        }
    }

    public static void archiveOldEnquiries(List<Enquiry__c> enquiries){
        for (Enquiry__c enq : enquiries){
            if (enq.Status__c=='Closed'){
                enq.Phone__c='9090909900';

            }
        }
    }
}
