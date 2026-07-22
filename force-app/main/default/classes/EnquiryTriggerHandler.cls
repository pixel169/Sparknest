public without sharing class EnquiryTriggerHandler implements ITriggerHandler {

    public void beforeInsert(List<SObject> newRecords) {
        EnquiryService.setDefaults((List<Enquiry__c>) newRecords);
    }

    public void beforeUpdate(List<SObject> newRecords, Map<Id, SObject> oldMap) {
        EnquiryService.archiveOldEnquiries((List<Enquiry__c>) newRecords);
        EnquiryService.stampClosedDate((List<Enquiry__c>) newRecords,(Map<Id, Enquiry__c>) oldMap);
    }

    public void afterInsert(List<SObject> newRecords) {
        EnquiryService.createFollowUpTasks((List<Enquiry__c>) newRecords);
    }

    public void afterUpdate(List<SObject> newRecords, Map<Id, SObject> oldMap) {
    }
}
