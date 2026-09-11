public class OpportunityTriggerHandler {

    public static void insertHandler(List<Opportunity> newOppList){
         Set<Id> accountIdSet=new Set<Id>();
        for(Opportunity op:newOppList){
            if(op.AccountId!=null){
                accountIdSet.add(op.AccountId);
            }
        }
        
         //fetch toal Amount related to each account
        List<AggregateResult> existingOppAmount=[select sum(Amount) totalAmount, Accountid
                                       from Opportunity
                                      where Accountid in:accountIdSet
                                      group by AccountId];
        system.debug('existingOppAmount'+existingOppAmount);
        
        List<Account> updateAccount=new  List<Account>();
         for(AggregateResult rs:existingOppAmount){
            id accId=(Id) rs.get('Accountid');
            Decimal totalAmount=(Decimal) rs.get('totalAmount');
            
             Account acc=new Account();
             acc.id=accId;
             acc.Total_Opportunity_Amount__c=totalAmount;
            updateAccount.add(acc);
              //remove process data
            accountIdSet.remove(accId);
        }
       
         if(!updateAccount.isEmpty()){
            update updateAccount;
        }
    }
    
    public static void deleteHandler(List<Opportunity> newOppList){
        system.debug('delete');
          Set<Id> accountIdSet=new Set<Id>();
        for(Opportunity op:newOppList){
            if(op.AccountId!=null){
                accountIdSet.add(op.AccountId);
            }
        }
        
         //fetch all contact related to account
        List<AggregateResult> existingOppAmount=[select sum(Amount) totalAmount, Accountid
                                       from Opportunity
                                      where Accountid in:accountIdSet
                                      group by AccountId];
        system.debug('existingOppAmount'+existingOppAmount);
        
        List<Account> updateAccount=new  List<Account>();
         for(AggregateResult rs:existingOppAmount){
            id accId=(Id) rs.get('Accountid');
            Decimal totalAmount=(Decimal) rs.get('totalAmount');
            
             Account acc=new Account();
             acc.id=accId;
             acc.Total_Opportunity_Amount__c=totalAmount;
            updateAccount.add(acc);
              //remove process data
            accountIdSet.remove(accId);
        }
         //an Account has no opp Amount -> set 0.
       List<Account> NoOppAmountAccount=new  List<Account>();
        if(!accountIdSet.isEmpty()){
           for(Id accid:accountIdSet){
               Account ac=new Account();
                ac.id=accid;
               ac.Total_Opportunity_Amount__c=0;
            NoOppAmountAccount.add(ac);
          } 
        }
        
        system.debug('deleteAccount'+NoOppAmountAccount);
     if(!NoOppAmountAccount.isEmpty()){
            update NoOppAmountAccount;
        }
         if(!updateAccount.isEmpty()){
            update updateAccount;
        }
    }
    
    public static void updateHandler(Map<Id,Opportunity> newOpportunityMap, Map<Id,Opportunity> oldOpportunitymap){
         Set<Id> accountIdSet=new Set<Id>();
        for(Opportunity op:newOpportunityMap.values()){
            Opportunity oldOpportunity=oldOpportunitymap.get(op.id);
            if(op.AccountId!=oldOpportunity.AccountId){
                accountIdSet.add(op.AccountId);
                accountIdSet.add(oldOpportunity.AccountId);
            }
        } 
        
        //fetch all contact related to account
        List<AggregateResult> existingOppAmount=[select sum(Amount) totalAmount, Accountid
                                       from Opportunity
                                      where Accountid in:accountIdSet
                                      group by AccountId];
        system.debug('existingOppAmount'+existingOppAmount);
        
         List<Account> updateAccount=new  List<Account>();
         for(AggregateResult rs:existingOppAmount){
            id accId=(Id) rs.get('Accountid');
            Decimal totalAmount=(Decimal) rs.get('totalAmount');
            
             Account acc=new Account();
             acc.id=accId;
             acc.Total_Opportunity_Amount__c=totalAmount;
            updateAccount.add(acc);
        }
         if(!updateAccount.isEmpty()){
            update updateAccount;
        }
    }
}