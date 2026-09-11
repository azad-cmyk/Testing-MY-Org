public class CopilotAPI {
    public static void getClient() {
        String url = 'https://api.assembly.com/v1/clients';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('X-API-KEY', 'dce617ebda3143889e6a7dfad33ca309.c6d63b2869d8d9f0' );
        req.setHeader('Content-Type', 'application/json');
	  req.setHeader('accept', 'application/json');


        Http http = new Http();
        HttpResponse res = http.send(req);


        if (res.getStatusCode() == 200) {
            System.debug('Client Data: ' + res.getBody());
  }
        else{
            System.debug('Error: ' + res.getStatusCode()+'-'+ res.getBody());
        }
    }
    
    
   

    @future(callout=true)
    public static void createClient(Set<Id> contactIds) {
		System.debug('Trigger call CopilotAPI.createClient ');
        List<Contact> contacts = [
            SELECT Id, FirstName, LastName, Email, Phone, AccountId
            FROM Contact
            WHERE Id IN :contactIds
        ];
			System.debug('contacts'+contacts);
        for (Contact con : contacts) {
            createClientCallout(con);
        }
    }

    private static void createClientCallout(Contact con) {

        Map<String, Object> body = new Map<String, Object>();
        body.put('givenName', con.FirstName);
        body.put('familyName', con.LastName);
        body.put('email', con.Email);
        body.put('phone', con.Phone);
       
        HttpRequest req = new HttpRequest();
       // req.setEndpoint('https://api.assembly.com/v1/clients');
        req.setEndpoint('callout:Copilot_API/v1/clients');
        req.setMethod('POST');
        //req.setHeader('X-API-KEY', 'dce617ebda3143889e6a7dfad33ca309.c6d63b2869d8d9f0');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setBody(JSON.serialize(body));

        System.debug('Request Body => ' + JSON.serialize(body));

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            System.debug('Client created successfully for Contact ' + con.Id);
            System.debug(res.getBody());
        } else {
            System.debug('Error for Contact ' + con.Id);
            System.debug(res.getBody());
        }
    }


}