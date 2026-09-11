trigger LeadTigger on Lead (after insert) {

    for(Lead l : Trigger.new){
         String leadName = (l.FirstName != null ? l.FirstName + ' ' : '') + l.LastName;
        LeadEventPublisher.publishLeadEvent(leadName, l.Email);
    }

}