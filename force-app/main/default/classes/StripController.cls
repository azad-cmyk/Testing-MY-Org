public class StripController {
    
     @future(callout=true)
    public static void createPrice(Integer amount, String customerCurrency, String productName,Id paymentId) {

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Stripe/v1/prices');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		//amount convert in smallest unit
		 Integer amountInCents =Integer.valueOf(Math.round(amount * 100));
        String body =
            'unit_amount=' + amountInCents +
            '&currency=' + customerCurrency +
            '&product_data[name]=' + EncodingUtil.urlEncode(productName, 'UTF-8');

        req.setBody(body);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> result =
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            //return (String) result.get('id'); // price_xxx
            system.debug('price id'+result.get('id'));
            createPaymentLink((String)result.get('id'),1,paymentId);
        } else {
            throw new CalloutException('Price creation failed: ' + res.getBody());
        }
    }

    public static void createPaymentLink(String priceId, Integer quantity,Id paymentId) {

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Stripe/v1/payment_links');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String body =
            'line_items[0][price]=' + EncodingUtil.urlEncode(priceId, 'UTF-8') +
            '&line_items[0][quantity]=' + quantity;

        req.setBody(body);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> responseMap =
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            System.debug('responseMap-->'+responseMap);
             String sessionId = (String) responseMap.get('id'); // VERY IMPORTANT
             System.debug('sessionId--'+sessionId);
           // return (String) responseMap.get('url');
           system.debug('Payment link'+(String) responseMap.get('url'));
            Payment__c p=new Payment__c();
            p.Id=paymentId;
            p.Payment_Link__c=(String) responseMap.get('url');
            p.Stripe_Payment_Id__c=sessionId;
            update p;
            
            
        } else {
            throw new CalloutException('Stripe Error: ' + res.getBody());
        }
    }


    public class priceRequestWrapper{
        public integer unitAmount;
        public String customerCurrency;
        public String productName;
    }
    public static void createPriceParam(List<Payment__c> newPaymentList){
        system.debug('createPriceParam call');
        
        for(Payment__c pay:newPaymentList){
            if(pay.amount__c!=null && pay.Customer_Currency__c!=null && pay.Product_name__c!=null){
                priceRequestWrapper preq=new priceRequestWrapper();
                preq.unitAmount=Integer.valueOf(pay.amount__c);
                preq.customerCurrency=pay.Customer_Currency__c;
                preq.productName=pay.Product_name__c;
                
                
        		createPrice(preq.unitAmount, preq.customerCurrency, preq.productName,pay.Id);
            }
        }
    }
    
}