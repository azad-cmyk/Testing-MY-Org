public class StripeService {

    public static String createPaymentIntent(Decimal amount) {

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Stripe/v1/payment_intents');
       // req.setEndpoint('https://api.stripe.com/v1/payment_intents');
        req.setMethod('POST');
       // req.setHeader(
  		//'Authorization','Bearer sk_test_51Sm9IxRoEuV8U4EScSaaENHTilu9VTG8jXgWFfFrmIgWeHWrtZtvDl8eGWZJkplZQI4WzVrfd9utH7Bm43cjTMvA00lbOxJgD5');

        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String body =
            'amount=' + String.valueOf(amount * 100) +
            '&currency=usd';

        req.setBody(body);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            return res.getBody();
        } else {
            throw new CalloutException(res.getBody());
        }
    }
}