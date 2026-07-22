// invokes the Weekly_Enquiry_Summary flow on a schedule
public class WeeklyFlowScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        Flow.Interview flow = Flow.Interview.createInterview(
            'Weekly_Enquiry_Summary', new Map<String, Object>()
        );
        flow.start();
    }
}
