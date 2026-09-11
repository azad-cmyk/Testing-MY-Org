trigger AccountTrigger on Account (before insert) {
 system.debug('Account trigger');
 for (Account a : Trigger.new) {
        if (a.isClone()) {
            System.debug('is clone');
            a.contact_status__c = null;
        }
    }
}