public class RazorpayService {

    public static String createOrder(Decimal amount) {

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Razorpay/v1/orders');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        Map<String, Object> body = new Map<String, Object>{
            'amount'   => amount * 100, // Razorpay uses paise
            'currency' => 'INR',
            'receipt'  => 'SF-Test-' + System.currentTimeMillis()
        };

        req.setBody(JSON.serialize(body));

        Http http = new Http();
        HttpResponse res = http.send(req);

        System.debug('Status Code: ' + res.getStatusCode());
        System.debug('Response Body: ' + res.getBody());

        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            Map<String, Object> response =
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
			System.debug('response : ' + response);
            return (String) response.get('id'); // Razorpay Order ID
        }

        throw new CalloutException('Razorpay Error: ' + res.getBody());
    }
    
   

    public static String createPaymentLink(Decimal amount) {

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Razorpay/v1/payment_links');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        Map<String, Object> body = new Map<String, Object>{
            'amount' => amount * 100, // paise
            'currency' => 'INR',
            'description' => 'Salesforce Test Payment',
            'callback_url' => 'https://login.salesforce.com',
            'callback_method' => 'get'
        };

        req.setBody(JSON.serialize(body));

        Http http = new Http();
        HttpResponse res = http.send(req);

        System.debug('Status Code: ' + res.getStatusCode());
        System.debug('Payment Link Response: ' + res.getBody());

        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            Map<String, Object> response =
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            return (String) response.get('short_url'); // PAYMENT LINK
        }

        throw new CalloutException(res.getBody());
    }


}