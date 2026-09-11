trigger OrderLineTrigger on Order_Line__c (before insert, after insert) {

system.debug('order line c');
    if(Trigger.isafter && Trigger.isinsert){
        system.debug('after insert');
        OrderLineHandler.insertHandler(Trigger.new);
    }
}