trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after insert) {
	
    if(Trigger.isinsert && Trigger.isafter){
        system.debug('ContentDocumentLink is trigger');
       // ContentDocumentLinkTriggerHandler.uploadfileOnGoogleDrive(Trigger.new);
       Set<Id> contentDocIds = new Set<Id>();

    for (ContentDocumentLink cdl : Trigger.new) {
		System.debug('cd'+ cdl.LinkedEntityId.getSObjectType());

        if (cdl.LinkedEntityId != null &&
            cdl.LinkedEntityId.getSObjectType() == Account.SObjectType) {
				System.debug('cd'+ cdl.LinkedEntityId.getSObjectType());
            contentDocIds.add(cdl.ContentDocumentId);
        }
    }
        
        if(!contentDocIds.isEmpty()){
            List<id> l=new List<Id>(contentDocIds);
        //ExcelProcessor.uploadFiletoCreate(l[0]);
        System.debug('queueable call');
          System.enqueueJob(new AccountCSVQueueable(contentDocIds));

      }
    }
    
    
    
}