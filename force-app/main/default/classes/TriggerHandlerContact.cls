public class TriggerHandlerContact {
   
    private static Boolean isRunning = false;
    
    public static void beforeInsert(List<Contact> newList) {
        if (isRunning) return; // Prevent recursion
        isRunning = true;

        Set<Id> accountIds = new Set<Id>();

        for (Contact con : newList) {
            if (con.AccountId != null) {
                accountIds.add(con.AccountId);

                // Ensure only one primary contact per account
                if (con.Primary_Contact__c) {
                    if(String.isBlank(con.Phone) ||String.isBlank(con.email)){
                        con.addError('primary contact must have Email and Phone');
                    }
                    else{
                        con.primary__c=true;
                    }
                }
            }
        }

        // No heavy processing here, just collecting info
          isRunning = false;
    }

    public static void beforeupdateHandler(Map<Id,Contact>newConMap,Map<Id,Contact> oldConMap){
            
        if (isRunning) return;
        isRunning = true;
        
        system.debug('beforeUpdate handler');
         Set<Id> accountIdSet=new Set<Id>();
        // Find accounts where Primary_Contact__c changed from TRUE → FALSE
        for(Contact con:oldConMap.values()){
            if(con.AccountId!=null 
              && con.Primary_Contact__c==true ){
                accountIdSet.add(con.AccountId);
            }
            
        }
        //fetch all contact except before Update
         List<Contact> conListExceptBeforeUpdate=[Select Id,Name,AccountId,Primary_Contact__c from Contact
                                where AccountId in :accountIdSet
                                And id not in:oldConMap.keySet()];
         System.debug('conListExceptBeforeUpdate'+conListExceptBeforeUpdate);
        //store Account->all Contact except Update
        Map<Id,List<Contact>> accToContactMap=new  Map<Id,List<Contact>>();
        for(Contact con:conListExceptBeforeUpdate){
            if(!accToContactMap.containskey(con.AccountId)){
                accToContactMap.put(con.AccountId,new List<Contact>());
            }
            accToContactMap.get(con.AccountId).add(con);
        }
         for(Contact con:newConMap.values()){
              // Ensure only one primary contact per account
                if (con.Primary_Contact__c) {
                    if(String.isBlank(con.Phone) ||String.isBlank(con.email)){
                        con.addError('primary contact must have Email and Phone');
                    }
                    else{
                        con.primary__c=true;
                    }
                }
            
             
            if(con.AccountId!=null  && con.Primary_Contact__c==false ){
                Contact oldContact=oldConMap.get(con.id);
               
                if(oldContact.Primary_Contact__c==true ){
                      //if the Update Contact was Primary and there are no other Contact->prevent
                      List<Contact> otherContact=accToContactMap.get(con.AccountId);
                if(otherContact==null || otherContact.size()==0){
                    con.addError('this Account have only one Primary Contact');
                }
                //If other Contacts exist but none are Primary-> random Assign Primary(after delete)
                }
               
               
            }
        }
         system.debug('after complete before update');
        isRunning=false;
    }
    
    public static void updateHandler(Map<Id,Contact>newConMap,Map<Id,Contact> oldConMap ){
        if (isRunning) return;
        isRunning = true;

        system.debug('update handler');
         system.debug('oldConMap.values()'+oldConMap.values());
         Set<Id> accountIdSet=new Set<Id>();
         Map<Id,Contact> upAccountMap=new Map<Id,Contact>();
        for(Contact con:newConMap.values()){
            Contact oldContact=oldConMap.get(con.id);
            if(con.AccountId!=null && oldContact!=null){ 
                //primary contact false->true
            if(oldContact.Primary_Contact__c==false && con.Primary_Contact__c==true){
                accountIdSet.add(con.AccountId);                           
            }
                //primary contact true->false
            else if(oldContact.Primary_Contact__c==true && con.Primary_Contact__c==false){
                    system.debug('primary contact true--->false');             
                	upAccountMap.put(con.id,con);	
                }    
                //primary Contact name or phone Changed
            else if(con.primary__c==True && (con.FirstName!=oldContact.FirstName ||con.LastName!=oldContact.LastName || con.Phone!=oldContact.Phone ||con.Email!=oldContact.Email)){
                system.debug('name is changed for primary contact'+con.FirstName);
                accountIdSet.add(oldContact.AccountId);
            }
            }
        }
         //fetch the conatct
        
          List<Contact> conListExceptUpdated=[Select Id,FirstName,LastName,  Email, Phone,AccountId,Primary_Contact__c from Contact
                                      where AccountId in :accountIdSet
                                             And id not in:newConMap.keyset()];
        
         //======
        List<Contact> lastPrimaryContacts=[select id from Contact where AccountId in:accountIdSet And Primary_Contact__c=true
                                           And id not in:newConMap.keyset() Limit 1];
        system.debug('==lastPrimaryContact=='+lastPrimaryContacts);
        //======
         system.debug('conListExceptUpdated'+conListExceptUpdated);
       
        for(Contact con:conListExceptUpdated){
            con.Primary_Contact__c=false;
        }
        if(!conListExceptUpdated.isEmpty()){
           update conListExceptUpdated;
        } 
        List<Contact> relatedContact=[Select Id,FirstName,LastName,  Email, Phone,AccountId,Primary_Contact__c from Contact
                                      where AccountId in :accountIdSet And Primary_Contact__c=true];
        system.debug('relatedContact'+relatedContact);
         system.debug('oldConMap.values()'+oldConMap.values());
        //store account to contact(Find the primary contact per account)
          Map<Id, Contact> primaryContactsMap = new Map<Id, Contact>();
       
       
             for(Contact c:relatedContact){
            if(!primaryContactsMap.containskey(c.AccountId)){
                primaryContactsMap.put(c.AccountId,c);
            }
        }
       
        
         system.debug('primaryContactsMap'+primaryContactsMap);
        //update the Account
        List<Account> accountsToUpdate=new List<Account>();
        for(Id accId : primaryContactsMap.keySet()){
            Contact  pmContact=primaryContactsMap.get(accId);
            if(pmContact.Primary_Contact__c){
              Account acc=new Account();
            acc.Id=accId;
            acc.Primary_Contact_Name__c=pmContact.FirstName+pmContact.LastName;
            acc.Primary_Contact_Email__c=pmContact.Email;
            acc.Primary_Contact_Phone__c=pmContact.Phone;
                if(!lastPrimaryContacts.isEmpty()){
                    acc.Last_Primary_Contact__c=lastPrimaryContacts[0].id;
                }else{
                    acc.Last_Primary_Contact__c= !conListExceptUpdated.isEmpty() ? conListExceptUpdated[0].Id : null;
                }
            accountsToUpdate.add(acc);
            }
           
        }
       system.debug('accountsToUpdate'+accountsToUpdate);
          
        if(!accountsToUpdate.isEmpty()){
           update accountsToUpdate;
        }
    }
    
    public static void afterDelete(Map<Id,Contact> oldConMap){
 	// Delete hone ke baad us deleted record pe trigger dobara chal hi nahi sakta.
        
        system.debug('After Delete handler');
        // 1. Collect Account Ids where deleted contact was primary
         Set<Id> accountIdSet=new Set<Id>();
        for(Contact con:oldConMap.values()){
            if(con.AccountId!=null && con.Primary_Contact__c==true ){
                accountIdSet.add(con.AccountId);
            }
            else{
                return;
            }
        }
         //======
        Account acc=[select id, name, Last_Primary_Contact__c from Account where id in:accountIdSet  limit 1];
            system.debug('contact deletd related to this Account'+acc);
        //======
         
        //used combined key and exluded in soql
         List<Id> excludedId=new List<Id>();
        excludedId.addAll(oldConMap.keySet());
        if (acc.Last_Primary_Contact__c != null) {
        excludedId.add(acc.Last_Primary_Contact__c); // Add the single ID if not null
          }
        // 2. Find accounts with no primary contact
        List<Contact> remainingContacts = [
            SELECT Id, Name, AccountId, Primary_Contact__c
            FROM Contact
            WHERE AccountId IN :accountIdSet
           And id not in:excludedId ];
       
        system.debug('remainingContacts'+remainingContacts);
        Map<Id, List<Contact>> accToContactsMap = new Map<Id, List<Contact>>();
        for (Contact c : remainingContacts) {
            if (!accToContactsMap.containsKey(c.AccountId)) {
                accToContactsMap.put(c.AccountId, new List<Contact>());
            }
            accToContactsMap.get(c.AccountId).add(c);
        }
        // 3. Assign new primary if none exists
        // ===
          List<Contact> contactsToUpdate = new List<Contact>();
        if(acc.Last_Primary_Contact__c!=null){
            Contact restoredPrimary = [
        SELECT Id, FirstName, LastName, Email, Phone, AccountId
        FROM Contact
        WHERE Id = :acc.Last_Primary_Contact__c
        LIMIT 1
    ];
    restoredPrimary.Primary_Contact__c = true;
    update restoredPrimary;
system.debug('restoredPrimary contact'+restoredPrimary);
    Account accUpdate = new Account(
        Id = restoredPrimary.AccountId,
        Primary_Contact_Name__c = restoredPrimary.FirstName + restoredPrimary.LastName,
        Primary_Contact_Email__c = restoredPrimary.Email,
        Primary_Contact_Phone__c = restoredPrimary.Phone,
        Last_Primary_Contact__c= !remainingContacts.isEmpty()  ? remainingContacts[0].Id : null

    );
    update accUpdate;
            
        }
        else{
             for (Contact con:oldConMap.values()) {
            List<Contact> contactList = accToContactsMap.get(con.AccountId);
            
            if (contactList!=null && !contactList.isEmpty()) {
                contactList[0].Primary_Contact__c = true;
                contactsToUpdate.add(contactList[0]);
            }
        }
             if(!contactsToUpdate.isEmpty()){
            update contactsToUpdate;
            isRunning = false;
            insertHandler(contactsToUpdate);
        }
     }
        system.debug('contactsToUpdate'+contactsToUpdate);
       
    }
    
    public static void beforeDelete(Map<Id,Contact> oldConMap){
        if (isRunning) return;
        isRunning = true;
        system.debug('beforeDelete handler');
         Set<Id> accountIdSet=new Set<Id>();
        for(Contact con:oldConMap.values()){
            if(con.AccountId!=null 
              && con.Primary_Contact__c==true ){
                accountIdSet.add(con.AccountId);
            }
        }
        //fetch all contact 
        List<Contact> existingContact=[select id, Name, AccountId from contact where AccountId in:accountIdSet];
         //fetch all contact except before deleted
         List<Contact> conListExceptBeforeDelete=[Select Id,Name,AccountId,Primary_Contact__c from Contact
                                where AccountId in :accountIdSet
                                And id not in:oldConMap.keySet()];
                              
        system.debug('existingContact'+existingContact);
        System.debug('conListExceptBeforeDelete'+conListExceptBeforeDelete);
        //store Account->all Contact except delete
        Map<Id,List<Contact>> accToContactMap=new  Map<Id,List<Contact>>();
        for(Contact con:conListExceptBeforeDelete){
            if(!accToContactMap.containskey(con.AccountId)){
                accToContactMap.put(con.AccountId,new List<Contact>());
            }
            accToContactMap.get(con.AccountId).add(con);
        }
        
         for(Contact con:oldConMap.values()){
            if(con.AccountId!=null  && con.Primary_Contact__c==true ){
                List<Contact> otherContact=accToContactMap.get(con.AccountId);
                 //if the deleted Contact was Primary and there are no other Contact->prevent
                if(otherContact==null || otherContact.size()==0){
                    con.addError('this Account have only one Primary Contact');
                }
                //If other Contacts exist but none are Primary-> random Assign Primary(after delete)
               
            }
        }
        
    }
    public static void insertHandler(List<Contact> newConList){
         // Ensure we don't run twice in same transaction
        if (isRunning) return;
        isRunning = true;
        System.debug('insertHandler Method');
         Set<Id> accountIdSet=new Set<Id>();
         Set<Id> contactIdSet=new Set<Id>();
        for(Contact con:newConList){
            if(con.AccountId!=null 
              && con.Primary_Contact__c==true ){
                accountIdSet.add(con.AccountId);
                  contactIdSet.add(con.id);
            }
        }
        //fetch the conatct
       // List<Account> accAccount=[select id, name,Primary_Contact_Name__c ,Primary_Contact_Phone__c , Primary_Contact_Email__c from Account];
        List<Contact> conList=[Select Id,FirstName,LastName,  Email, Phone,AccountId from Contact
                               where AccountId in :accountIdSet And id in:contactIdSet
                               And Email!=null And Phone!=null And Primary_Contact__c=true ];
        //fetch all contact except newly inserted
         List<Contact> conListExceptNewly=[Select Id,FirstName,LastName,  Email, Phone,AccountId from Contact
                                where AccountId in :accountIdSet And id not in:newConList
                               And Email!=null And Phone!=null 
                                ORDER BY CreatedDate DESC];
        for(Contact con:conListExceptNewly){
            con.Primary_Contact__c=false;
        }
        system.debug('conList'+conList);
        system.debug('conListExceptNewly'+conListExceptNewly);
        
        //store account to contact
          Map<Id, Contact> primaryContactsMap = new Map<Id, Contact>();
        for(Contact c:conList){
            if(!primaryContactsMap.containskey(c.AccountId)){
                primaryContactsMap.put(c.AccountId,c);
            }
        }
        
        //update the Account
        List<Account> accountsToUpdate=new List<Account>();
        for(Id accId:primaryContactsMap.keyset()){
            Contact  conData=primaryContactsMap.get(accId);
            Account acc=new Account();
            acc.Id=accId;
            acc.Primary_Contact_Name__c=conData.FirstName+conData.LastName;
            acc.Primary_Contact_Email__c=conData.Email;
            acc.Primary_Contact_Phone__c=conData.Phone;
            acc.Last_Primary_Contact__c= !conListExceptNewly.isEmpty() ? conListExceptNewly[0].Id : null;
            accountsToUpdate.add(acc);
        }
        if(!conListExceptNewly.isEmpty()){
           update conListExceptNewly;
        }
        if(!accountsToUpdate.isEmpty()){
           update accountsToUpdate;
        }
        system.debug('accountsToUpdate'+accountsToUpdate);
    }
    
   
}