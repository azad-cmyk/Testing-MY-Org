trigger PaymentTrigger on Payment__c (before insert,after insert) {
    if(Trigger.isinsert && Trigger.isafter){
        system.debug('payment is created');
        StripController.createPriceParam(Trigger.new);
    } 

}