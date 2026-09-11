/*
    if(Trigger.isafter && Trigger.isinsert){
        ContactTriggerHandler.insertHandler(Trigger.new);
        system.debug('sdhhfbbg');
    }
    
     if(Trigger.isafter && Trigger.isdelete){
          system.debug('sdhhfbbg');
        ContactTriggerHandler.deleteHandler(Trigger.old);
        
    }
    if(Trigger.isafter && Trigger.isupdate){
          system.debug('sdhhfbbg');
        ContactTriggerHandler.updateHandler(Trigger.newMap,Trigger.oldMap);
        
    }
*/
    /* Primary Contact Updates on Account
If a Contact is marked as Primary_Contact__c = TRUE and has a non-null Email and Phone, update the parent Account’s:
Primary_Contact_Name__c with the Contact’s FirstName + LastName
Primary_Contact_Phone__c with the Contact’s Phone
Primary_Contact_Email__c with the Contact’s Email

    
     if(Trigger.isbefore ){
         
         if(Trigger.isInsert || Trigger.isUpdate){
              system.debug('before update');
            // ContactPrimary.beforeupdateHandler(Trigger.newMap,Trigger.oldMap);
       		 ContactPrimary.beforeInsertUpdate(Trigger.new,Trigger.oldMap);
         }
		
         
         if(Trigger.isDelete){
             system.debug('before delete');
        ContactPrimary.beforeDelete(Trigger.oldMap); 
         }
       
    }
  
    if(Trigger.isafter && Trigger.isinsert){
        system.debug('asdf');
        ContactPrimary.insertHandler(Trigger.new);
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        system.debug('update');
        ContactPrimary.updateHandler(Trigger.newMap,Trigger.oldMap);
    }
    
     if(Trigger.isAfter && Trigger.isDelete){
        system.debug('after delete');
        ContactPrimary.afterDelete(Trigger.oldMap);
    }

 


}*/
    
/*
trigger ContactTrigger on Contact (
    before insert, before update, before delete,
    after insert, after update, after delete
) {
    if(Trigger.isbefore ){
        
        
         if(Trigger.isInsert ){
              system.debug('before update');
            
       		 TriggerHandlerContact.beforeInsert(Trigger.new);
         }
         if(Trigger.isUpdate){
           TriggerHandlerContact.beforeupdateHandler(Trigger.newMap,Trigger.oldMap);
         }
        
         if(Trigger.isDelete){
             system.debug('before delete');
        TriggerHandlerContact.beforeDelete(Trigger.oldMap); 
         }
       
    }
  
    if(Trigger.isafter && Trigger.isinsert){
        system.debug('asdf');
        TriggerHandlerContact.insertHandler(Trigger.new);
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        system.debug('update');
        TriggerHandlerContact.updateHandler(Trigger.newMap,Trigger.oldMap);
    }
    
     if(Trigger.isAfter && Trigger.isDelete){
        system.debug('after delete');
        TriggerHandlerContact.afterDelete(Trigger.oldMap);
    }

}
*/


/*
trigger ContactTrigger on Contact (before insert, after insert, before update, after update,before delete,after delete) {
   if(Trigger.IsAfter ){
       
         if(Trigger.isInsert ){
              system.debug('before insert');
       		 ContactHandlerAssesment.afterInsert(Trigger.new);
         }
         if(Trigger.isUpdate){
           ContactHandlerAssesment.afterUpdate(Trigger.newMap,Trigger.oldMap);
         }
   }     
}
*/
trigger ContactTrigger on Contact (after insert) {

    Set<Id> contactIds = new Set<Id>();

    for (Contact c : Trigger.new) {
        contactIds.add(c.Id);
    }

    if (!contactIds.isEmpty()) {
        system.debug('CopilotClientQueueable call');
        //System.enqueueJob(new CopilotClientQueueable(contactIds));
        CopilotAPI.createClient(contactIds);
    }
}