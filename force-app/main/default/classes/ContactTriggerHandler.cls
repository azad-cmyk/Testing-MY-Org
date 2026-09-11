public class ContactTriggerHandler {

    public static void insertHandler(List<Contact> newConList){
        Set<Id> accountIdSet=new Set<Id>();
        for(Contact con:newConList){
            if(con.AccountId!=null){
                accountIdSet.add(con.AccountId);
            }
        }
        
        //fetch all contact related to account
        List<AggregateResult> existingContact=[select count(id) totalcontact, Accountid
                                       from contact
                                      where Accountid in:accountIdSet
                                      group by AccountId];
        system.debug('existingContact'+existingContact);
        
       
        Map<Id, Decimal> updateAccountMap=new  Map<Id, Decimal>();
        for(AggregateResult rs:existingContact){
            id accId=(Id) rs.get('Accountid');
            Decimal totalContact=(Decimal) rs.get('totalcontact');
            
            updateAccountMap.put(accId, totalContact);
        }
         system.debug('existingContact'+updateAccountMap);
        
         List<Account> updateAccount=new  List<Account>(); 
        for(Id accid:updateAccountMap.keyset()){
            
            Decimal totalContactNumber=updateAccountMap.get(accid);
            if(totalContactNumber==1 || totalContactNumber==2){
                Account acc=new Account();
                acc.id=accid;
                acc.contact_status__c='Low Contacts';
                updateAccount.add(acc);
            }
            if(totalContactNumber>2){
                Account acc=new Account();
                acc.id=accid;
                acc.contact_status__c='Active';
                updateAccount.add(acc);
            }
        }
        
        if(!updateAccount.isEmpty()){
            update updateAccount;
        }
    }
    
    
    public static void deleteHandler(List<Contact> newConList){
          Set<Id> accountIdSet=new Set<Id>();
        for(Contact con:newConList){
            if(con.AccountId!=null){
                accountIdSet.add(con.AccountId);
            }
        }
        
        //fetch all contact related to each account
        List<AggregateResult> existingContact=[select count(id) totalcontact, Accountid
                                       from contact
                                      where Accountid in:accountIdSet
                                      group by AccountId];
        system.debug('existingContact'+existingContact);
        
         Map<Id, Decimal> updateAccountMap=new  Map<Id, Decimal>();
        for(AggregateResult rs:existingContact){
            id accId=(Id) rs.get('Accountid');
            Decimal totalContact=(Decimal) rs.get('totalcontact');
            
            updateAccountMap.put(accId, totalContact);
            //remove process data
            accountIdSet.remove(accId);
        }
         system.debug('existingContact'+updateAccountMap);
        
         List<Account> updateAccount=new  List<Account>(); 
        for(Id accid:updateAccountMap.keyset()){
            
            Decimal totalContactNumber=updateAccountMap.get(accid);
            if(totalContactNumber==1 || totalContactNumber==2){
                Account acc=new Account();
                acc.id=accid;
                acc.contact_status__c='Low Contacts';
                updateAccount.add(acc);
            }
            if(totalContactNumber>2){
                Account acc=new Account();
                acc.id=accid;
                acc.contact_status__c='Active';
                updateAccount.add(acc);
            }
        }
        
        if(!updateAccount.isEmpty()){
            update updateAccount;
        }
       //an Account has no Contacts, the Account should get deleted.
       List<Account> deleteAccount=new  List<Account>();
        if(!accountIdSet.isEmpty()){
           for(Id accid:accountIdSet){
               Account ac=new Account();
               ac.id=accid;
            deleteAccount.add(ac);
          } 
        }
        
        system.debug('deleteAccount'+deleteAccount);
     if(!deleteAccount.isEmpty()){
            delete deleteAccount;
        }
    }
    
    public static void updateHandler(Map<Id,Contact> newContactMap, Map<Id,Contact> oldContactmap){
        
       Set<Id> accountIdSet=new Set<Id>();
        for(Contact con:newContactMap.values()){
            Contact oldContact=oldContactmap.get(con.id);
            if(con.AccountId!=oldContact.AccountId){
                accountIdSet.add(con.AccountId);
                accountIdSet.add(oldContact.AccountId);
            }
        } 
         //fetch all contact related to account
        List<AggregateResult> existingContact=[select count(id) totalcontact, Accountid
                                       from contact
                                      where Accountid in:accountIdSet
                                      group by AccountId];
        
         Map<Id, Decimal> updateAccountMap=new  Map<Id, Decimal>();
        for(AggregateResult rs:existingContact){
            id accId=(Id) rs.get('Accountid');
            Decimal totalContact=(Decimal) rs.get('totalcontact');
            
            updateAccountMap.put(accId, totalContact);
            //remove process data
            accountIdSet.remove(accId);
        }
         system.debug('existingContact'+updateAccountMap);
        system.debug('accountIdSet'+accountIdSet);
         List<Account> updateAccount=new  List<Account>(); 
        for(Id accid:updateAccountMap.keyset()){
            
            Decimal totalContactNumber=updateAccountMap.get(accid);
            if(totalContactNumber==1 || totalContactNumber==2){
                Account acc=new Account();
                acc.id=accid;
                acc.contact_status__c='Low Contacts';
                updateAccount.add(acc);
            }
            if(totalContactNumber>2){
                Account acc=new Account();
                acc.id=accid;
                acc.contact_status__c='Active';
                updateAccount.add(acc);
            }
        }
        
        if(!updateAccount.isEmpty()){
            update updateAccount;
        }
         //an Account has no Contacts, the Account should get deleted.
       List<Account> deleteAccount=new  List<Account>();
        if(!accountIdSet.isEmpty()){
           for(Id accid:accountIdSet){
               Account ac=new Account();
               ac.id=accid;
            deleteAccount.add(ac);
          } 
        }
        
        system.debug('deleteAccount'+deleteAccount);
     if(!deleteAccount.isEmpty()){
            delete deleteAccount;
        }
    }
}