@RestResource(urlMapping='/stripeWebhook')
global without sharing class StripeWebhookHanler {

    @HttpPost
    global static void handleWebhook() {

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String requestBody = req.requestBody.toString();

        System.debug('Webhook Body => ' + requestBody);
        System.debug('res-->'+res);
        try{ 

            System.debug('Webhook Body JSON.deserializeUntyped => ' +JSON.deserializeUntyped(requestBody));
            Map<String,Object> webhookData=( Map<String,Object>) JSON.deserializeUntyped(requestBody);

            System.debug('webhookData-->'+webhookData);

            Map<String, Object> data = (Map<String, Object>)webhookData.get('data');
            System.debug('data => ' + data);

            Map<String,Object> objectMap =(Map<String,Object>)data.get('object');

            String paymentIntentId = (String)objectMap.get('id');

            System.debug('Payment Intent Id = ' + paymentIntentId);
            String eventType = (String) webhookData.get('type');
            System.debug('eventType => ' + eventType); 

            if (eventType == 'checkout.session.completed' ) {
                Map<String, Object> dataObject = (Map<String, Object>) webhookData.get('data');
                Map<String, Object> session = (Map<String, Object>) dataObject.get('object');
                Map<String, Object> stripeDataMap = new Map<String, Object>();
                
                System.debug(session);
                
                stripeDataMap.put('stripePaymentId', session.get('payment_intent') != null ? (String) session.get('payment_intent') : null);
                stripeDataMap.put('stripeLinkId', session.get('payment_link') != null ? (String) session.get('payment_link') : null);
                stripeDataMap.put('customerEmail',session.get('customer_details') != null && ((Map<String, Object>) session.get('customer_details')).get('email') != null ? (String) ((Map<String, Object>) session.get('customer_details')).get('email') : null);
                stripeDataMap.put('customerName',session.get('customer_details') != null && ((Map<String, Object>) session.get('customer_details')).get('name') != null ? (String) ((Map<String, Object>) session.get('customer_details')).get('name') : null);
                stripeDataMap.put('amountPaid', session.get('amount_total') != null ? ((Decimal) session.get('amount_total')) / 100: null);
                stripeDataMap.put('paymentStatus', session.get('payment_status') != null ? (String) session.get('payment_status') : null);
                
                System.debug('stripeDataMap-->'+stripeDataMap);
                // updatePaymentFromResponse(stripeDataMap);
                String paymentLink=(String) session.get('payment_link');
                String paymentStatus= (String) session.get('payment_status');
                System.debug(' paymentLink--> '+paymentLink);
                
                List<Payment__c>  pay =[select id,name,Payment_Status__c from Payment__c where Stripe_Payment_Id__c = :paymentLink limit 1];
                if(!pay.isEmpty()){
                    System.debug('No Payment__c record found for paymentLink: ' + paymentLink);
                    pay[0].Payment_Status__c = paymentStatus;
                    update pay[0];
                }
                res.statusCode = 200;
            }
            else if(eventType =='customer.subscription.created'){
                Map<String, Object> dataObject = (Map<String, Object>) webhookData.get('data');
                Map<String, Object> subscriptionItem = (Map<String, Object>) dataObject.get('object');

                String subscriptionId = (String) subscriptionItem.get('id');
                Stripe_Subscription__c sub = new Stripe_Subscription__c();
                sub.Name = subscriptionId;
                // sub.Stripe_Subscription_Item__c = JSON.serialize(subscriptionItem);

                Map<String,Object> items =(Map<String,Object>)subscriptionItem.get('items');
                List<Object> itemdata = (List<Object>)items.get('data');

                sub.Stripe_Subscription_Item__c =JSON.serialize(itemdata);

                insert sub;
            }
        }catch (Exception ex) {
            System.debug('Exception: ' + ex.getMessage());
            res.statusCode = 500;
        }
    }
}