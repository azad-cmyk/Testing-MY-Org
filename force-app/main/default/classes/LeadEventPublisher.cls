public class LeadEventPublisher {

    public static void publishLeadEvent(String name, String email){

        LeadNotification__e eventMsg = new LeadNotification__e(
            Lead_name__c = name, 	
            Email__c = email
        );

        Database.SaveResult sr = EventBus.publish(eventMsg);
    }
}