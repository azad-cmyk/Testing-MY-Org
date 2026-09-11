/*trigger OpportunityTrigger on Opportunity (before insert,after insert, before update, after update,before delete,after delete) {

    if(Trigger.isafter && Trigger.isinsert){
       OpportunityTriggerHandler.insertHandler(Trigger.new);
        system.debug('sdhhfbbg');
    }
    
    if(Trigger.isafter && Trigger.isdelete){
        OpportunityTriggerHandler.deleteHandler(Trigger.old);
        system.debug('sdhhfbbg');
    }
    if(Trigger.isafter && Trigger.isupdate){
          system.debug('sdhhfbbg');
        OpportunityTriggerHandler.updateHandler(Trigger.newMap,Trigger.oldMap);
        
    }
}
*/
trigger OpportunityTrigger on Opportunity (after insert, before update, after update,before delete,after delete){
       if(Trigger.isafter && Trigger.isinsert){
       OpportunityHandlerAssesment.insertHandler(Trigger.new);
       
    } 
    if(Trigger.isAfter && Trigger.isDelete){
        system.debug('after delete');
        OpportunityHandlerAssesment.insertHandler(Trigger.old);
    }
    if(Trigger.isAfter && Trigger.isUpdate ){
        system.debug('after update');
        OpportunityHandlerAssesment.updateHandler(Trigger.newmap,Trigger.oldMap);
    }
}