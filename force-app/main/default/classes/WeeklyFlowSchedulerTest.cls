@isTest
public class WeeklyFlowSchedulerTest {

    @isTest
    static void testWeeklyFlowScheduler() {
        Test.startTest();
        String cronExp = '0 0 8 ? * MON';
        String jobId = System.schedule('Test Weekly Flow Scheduler', cronExp, new WeeklyFlowScheduler());
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('0 0 8 ? * MON', ct.CronExpression);
    }
}
