public class ContactHandlerAssesment {
    
    public static void afterUpdate(Map<Id,Contact> newContactMap, Map<Id,Contact> oldContactmap){
        system.debug('afterUpdate');
          Set<Id> accountIdSet=new Set<Id>();
       
        for(Contact con:newContactMap.values()){
             Contact oldContact=oldContactmap.get(con.id);
             //AccountId changed
            if(con.AccountId!=oldContact.AccountId){
                if(con.AccountId!=null){
                     accountIdSet.add(con.AccountId);
                }
                if(oldContact.AccountId!=null){
                    accountIdSet.add(oldContact.AccountId);
                }
             }
                
              //change dead field
            if (con.Dead__c!=oldContact.Dead__c){
               if(con.AccountId!=null){
                     accountIdSet.add(con.AccountId);
                }
                if(oldContact.AccountId!=null){
                    accountIdSet.add(oldContact.AccountId);
                }
            }
               
            system.debug('accountIdSet=='+accountIdSet);
           
           
        }
         if(!accountIdSet.isempty()){
                 recalculate(accountIdSet);
            }
    }
    
    public static void afterInsert(List<Contact> newConList){
         Set<Id> accountIdSet=new Set<Id>();
        for(Contact con:newConList){
            if(con.AccountId!=null){
                accountIdSet.add(con.AccountId);
            }
        }
        //fetch all related contact
        List<Contact> deadontact=[select accountId, Dead__c
                                       from contact
                                      where Accountid in:accountIdSet and Dead__c=true
                                      ];
        //fetch all  contact
        List<Contact> AllContact=[select Accountid,Dead__c
                                       from contact
                                      where Accountid in:accountIdSet  
                                     ];
        system.debug('deadontact'+deadontact);
        system.debug('AllContact'+AllContact);
        
        Map<Id, list<Contact>> deadontactmap=contactconvetedMap(deadontact);
        system.debug('deadontactmap'+deadontactmap);
        Map<Id, List<Contact>> accContactMap=new  Map<Id, List<Contact>>();
        for(Contact con: AllContact){
            if(!accContactMap.containskey(con.AccountId)){
                accContactMap.put(con.AccountId, new list<Contact>());
            }
           accContactMap.get(con.AccountId).add(con);
        }
        
     List<Account> accountsToUpdate = new List<Account>();
    for(Id accId : accContactMap.keySet()) {
        List<Contact> cons = accContactMap.get(accId);
        List<Contact> dcons=deadontactmap.get(accId);
        Integer total = cons.size();
        Integer deadCounts=dcons.size();
        Integer deadCount = 0;
        
        for(Contact c : cons) {
            if(c.Dead__c == true) {
                deadCount++;
            }
        }
        
        if(total > 0) {
            Decimal ratio = (Decimal)deadCount / total;
            if(ratio >= 0.7) {
                accountsToUpdate.add(new Account(
                    Id = accId,
                    need_intel__c  = true  
                ));
            } 
            else{
                 accountsToUpdate.add(new Account(Id=accId,  need_intel__c  =false ));
            }
            
            }
        }
        system.debug('==accountsToUpdate'+accountsToUpdate);
        if(!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
    }
    
    
    
    //===HELPER mETHOD======//
    public static void recalculate(Set<Id> accountIdSet){
        //fetch all related contact
        List<Contact> allCotact=[select accountId, Dead__c
                                       from contact
                                      where Accountid in:accountIdSet ];
        //map for counting
        Map<Id, Decimal> totalCountMap=new  Map<Id, Decimal> ();
         Map<Id, Integer> deadCount=new  Map<Id, integer>();
        
        for(Contact con:allCotact){
            if(!totalCountMap.containskey(con.AccountId)){
                totalCountMap.put(con.AccountId,1);
            }else{
               totalCountMap.put(con.AccountId,totalCountMap.get(con.AccountId)+1);
            }
            //count deadContact
            if(con.Dead__c==true){
               deadCount.put(con.AccountId,deadCount.containskey(con.AccountId)?deadCount.get(con.AccountId)+1:1); 
            }
            
        }
        //prepare for account update
      // List<Account> accountsToUpdate = new List<Account>();
       List<Account> accountsToUpdate = [select id, need_intel__c from account where id in:accountIdSet];
        for(account accId : accountsToUpdate) {
            Decimal total=totalCountMap.get(accId.id);
            integer deadtotal=deadCount.containskey(accId.id)?deadCount.get(accId.id):0;
            
            if(total>0){
                decimal percentage=deadtotal/total;
                if(percentage>=0.7){
                    accId.need_intel__c = true;
                    //accountsToUpdate.add(new Account(Id=accId,  need_intel__c  =true ));
                }
                else{
                    accId.need_intel__c = false;
                    //accountsToUpdate.add(new Account(Id=accId,  need_intel__c  =false ));
                }
            }
            //that account has 0 contact
            
            /*
            else{
                 accountsToUpdate.add(new Account(Id=accId,  need_intel__c  =false ));
            }
            */
        }
        
         system.debug('==accountsToUpdate'+accountsToUpdate);
        if(!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
    } 
   public static  Map<Id, List<Contact>>  contactconvetedMap(List<Contact> conList) {
        Map<Id, List<Contact>> accContactMap=new  Map<Id, List<Contact>>();
        for(Contact con: conList){
            if(!accContactMap.containskey(con.AccountId)){
                accContactMap.put(con.AccountId, new list<Contact>());
            }
           accContactMap.get(con.AccountId).add(con);
        }
        return accContactMap;
    }
    
}