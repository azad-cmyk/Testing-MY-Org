trigger OrderTrigger on Order (before insert) {
    system.debug('order trigger');
 for (Order o : Trigger.new) {
        if (o.isClone()) {
            System.debug('is clone');
            o.total_Commision__c = null;
        }
    }
}