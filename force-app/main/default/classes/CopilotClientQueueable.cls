public class CopilotClientQueueable implements Queueable, Database.AllowsCallouts {

    private Set<Id> contactIds;

    public CopilotClientQueueable(Set<Id> contactIds) {
        this.contactIds = contactIds;
    }

    public void execute(QueueableContext qc) {

        List<Contact> contacts = [
            SELECT Id, FirstName, LastName, Email, Phone, AccountId
            FROM Contact
            WHERE Id IN :contactIds
        ];
		System.debug('contacts'+contacts);
        for (Contact con : contacts) {

            Map<String, Object> body = new Map<String, Object>{
                'givenName'  => con.FirstName,
                'familyName' => con.LastName,
                'email'      => con.Email,
                'phone'      => con.Phone
                //'companyId'  => String.valueOf(con.AccountId)
            };

            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://api.assembly.com/v1/clients');
            req.setMethod('POST');
       		 req.setHeader('X-API-KEY', 'dce617ebda3143889e6a7dfad33ca309.c6d63b2869d8d9f0' );
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            req.setBody(JSON.serialize(body));

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 201 || res.getStatusCode() == 200) {
                System.debug('Client created for Contact ' + con.Id);
                System.debug(res.getBody());
            } else {
                System.debug('Error for Contact ' + con.Id);
                System.debug(res.getBody());
            }
        }
    }
}