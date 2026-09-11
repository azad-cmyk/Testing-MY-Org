trigger ProjectTaskTrigger on Project_Task__c (before insert,after insert, after update, after delete) {

    if(Trigger.isAfter && Trigger.isInsert){
        system.debug('after insert');
        ProjectTaskHandler.insertHandler(Trigger.new);
    }
    if(Trigger.isAfter && Trigger.isDelete){
        system.debug('after delete');
        ProjectTaskHandler.deleteHandler(Trigger.old);
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        system.debug('after update');
        ProjectTaskHandler.updatehandler(Trigger.newMap,Trigger.oldmap);
    }
}