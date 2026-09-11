public with sharing class TidycalEventCreated {
   

    public static void createEventIfLeadExists(String email,
    String firstName,
    String lastName) {

    if (String.isBlank(email)) {
        return;
    }

    Lead matchedLead;

    List<Lead> leadsByEmail = [
        SELECT Id, FirstName, LastName, Email,OwnerId
        FROM Lead
        WHERE Email = :email
        LIMIT 5
    ];

    if (!leadsByEmail.isEmpty()) {

        if (leadsByEmail.size() == 1) {
            matchedLead = leadsByEmail[0];
        }
        else {
            // 🔹 2. If multiple leads with same email → match name
            for (Lead l : leadsByEmail) {
                if (
                    l.FirstName == firstName &&
                    l.LastName == lastName
                ) {
                    matchedLead = l;
                    break;
                }
            }
        }
    }

    // 🔹 3. If Lead Found → Create Event
    if (matchedLead != null) {

         Datetime startDt = System.now();
            Integer duration = 30; // default 30 minutes
            Datetime endDt = startDt.addMinutes(duration);

            Event ev = new Event();
            ev.Subject = 'TidyCal Booking';
            ev.StartDateTime = startDt;
            ev.EndDateTime = endDt;
            ev.DurationInMinutes = duration;
            ev.WhoId = matchedLead.Id;
            ev.OwnerId = matchedLead.OwnerId;


        insert ev;

        System.debug('Event created for Lead: ' + matchedLead.Id);
    }
    else {
        System.debug('No matching Lead found.');
    }
}
}