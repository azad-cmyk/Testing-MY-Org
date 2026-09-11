public class OpportunityHandlerAssesment {

    public static void updateHandler(Map<Id,Opportunity>newOppMap, Map<Id,Opportunity> oldOppMap){
        Set<Id> accountIdSet=new Set<Id>();
        for(Opportunity op:newOppMap.values()){
            Opportunity oldOpp=oldOppMap.get(op.Id);
            //case1-> AccountId Changed
            if(op.AccountId!=oldOpp.AccountId){
                if(op.AccountId!=null){
                     accountIdSet.add(op.AccountId);
                }
                if(oldOpp.AccountId!=null){
                    accountIdSet.add(oldOpp.AccountId);
                }
            }
            //same Account
            else{
                //case2->Amount, type or stage changed
                if(op.Amount!=oldOpp.Amount){
                     if(op.AccountId!=null){
                     accountIdSet.add(op.AccountId);
                }
               
                }
                //case3->Type changed
                    if(op.Type!=oldOpp.Type){
                        if(op.AccountId!=null){
                            accountIdSet.add(op.AccountId);
                        }
                    }
                //case4 stage changed
                if(op.StageName!=oldOpp.StageName){
                    if(op.AccountId!=null){
                        accountIdSet.add(op.AccountId);
                    }
                }
            }
        }
         system.debug('accountidset=='+accountIdSet);       
         if(!accountIdSet.isEmpty()){
                recalAvg(accountIdSet);
            }
    }
 
    public static void insertHandler(List<Opportunity> newOppList){
        try{
            Set<Id> accountIdSet=new Set<Id>();
        for(Opportunity op:newOppList){
            if(op.AccountId!=null){
                accountIdSet.add(op.AccountId);
            }
        }
        
        //all closed opportunity
    List<Opportunity> oppList = [
        SELECT Id, AccountId, Amount, Type
        FROM Opportunity
        WHERE AccountId IN :accountIdSet
        AND StageName = 'Closed Lost'
        ];
        
            // for new Customer
        Map<Id, List<Opportunity>> newCustomerAccountOppMap=new  Map<Id, List<Opportunity>>();
         Map<Id, Decimal> totalAmountMBMap = new Map<Id, Decimal>(); //amount store
        
            //for Existing Customer
         Map<Id, List<Opportunity>> ExistingCustomerAccountOppMap=new  Map<Id, List<Opportunity>>();
			 Map<Id, Decimal> totalAmountExistingMap= new Map<Id, Decimal>();
            
        for(Opportunity op:opplist){
            if(op.type== 'New Customer'){
                if(!newCustomerAccountOppMap.containskey(op.accountid)){
                    newCustomerAccountOppMap.put(op.AccountId,new List<Opportunity>());
                }
                newCustomerAccountOppMap.get(op.Accountid).add(op);
                 totalAmountMBMap.put(op.AccountId, 
                (totalAmountMBMap.containsKey(op.AccountId) ? totalAmountMBMap.get(op.AccountId) : 0) 
                + (op.Amount != null ? op.Amount : 0));
            }
            else if(op.type!=null && op.Type!='New Customer'){
                if(!ExistingCustomerAccountOppMap.containsKey(op.AccountId)){
                    ExistingCustomerAccountOppMap.put(op.AccountId,new List<Opportunity>());
                }
                ExistingCustomerAccountOppMap.get(op.AccountId).add(op);
                totalAmountExistingMap.put(op.AccountId,
                        (totalAmountExistingMap.containskey(op.AccountId)?totalAmountExistingMap.get(op.AccountId):0)
                                          +(op.Amount!=null?op.Amount:0));
            }
            
        }
        system.debug('ExistingCustomerAccountOppMap'+ExistingCustomerAccountOppMap);
            system.debug('newCustomerAccountOppMap'+newCustomerAccountOppMap);
          List<Account> accountsToUpdate = new List<Account>();
        for(Id accId:accountIdSet){
            List<Opportunity> ops=newCustomerAccountOppMap.get(accId);
            system.debug('newCustomerAccountOppMap is empty then it return null'); 
            Decimal AvgSmb=0;
            
            List<Opportunity> opsExisting=ExistingCustomerAccountOppMap.get(accId);
            Decimal AvgEnterprise=0;
            if(ops!=null && ops.size()>0) {
            AvgSmb = totalAmountMBMap.get(accId) / ops.size();         
          }
            if(opsExisting!=null && opsExisting.size()>0){
                AvgEnterprise=totalAmountExistingMap.get(accId)/opsExisting.size();
            }
            accountsToUpdate.add( new Account(Id=accId, Avg_Lost_SMB_Opps__c =AvgSmb,Avg_Lost_Enterprise_Opps__c =AvgEnterprise));
        }
         if(!accountsToUpdate.isEmpty()) {
        update accountsToUpdate;
    }
        }
        catch(Exception e){
            System.debug('e is here ->'+e);
            System.debug('e Line is '+e.getLineNumber());
            System.debug('E is message -?'+e.getMessage());
        }
        
          
        
    }
    
    public static void delteHandler(List<Opportunity> oldOpplist){
          Set<Id> accountIdSet=new Set<Id>();
        for(Opportunity op:oldOpplist){
            if(op.AccountId!=null){
                accountIdSet.add(op.AccountId);
            }
        }
        system.debug('accountIdSet'+accountIdSet);
         //all remaining closed opportunity
    List<Opportunity> oppList = [
        SELECT Id, AccountId, Amount, Type  FROM Opportunity WHERE AccountId IN :accountIdSet
        AND StageName = 'Closed Lost'];
        system.debug('oppList'+oppList);
    }
    
    
     //===HELPER mETHOD======//
    public static void recalAvg(Set<Id> accountIdSet){
        //all closed opportunity
   		 List<Opportunity> oppList = [ SELECT Id, AccountId, Amount, Type from opportunity
                                      WHERE AccountId IN :accountIdSet AND StageName = 'Closed Lost'];
       //Map for Amountsum and count
        Map<Id, Decimal> totalAmountNewCustomerMBMap = new Map<Id, Decimal>(); //amount store
         Map<Id, Integer> countMBMap = new Map<Id, Integer>(); 
        
         Map<Id, Decimal> totalAmountEnterpriseap = new Map<Id, Decimal>(); //amount store
         Map<Id, Integer> countEnterpriseMap = new Map<Id, Integer>(); 
        
        for(Opportunity op:oppList){
            if(op.type== 'New Customer'){
                if(!totalAmountNewCustomerMBMap.containskey(op.AccountId)){
                    totalAmountNewCustomerMBMap.put(op.AccountId,op.Amount!=null?op.Amount:0);
                }
                else{
                    totalAmountNewCustomerMBMap.put(op.AccountId,totalAmountNewCustomerMBMap.get(op.AccountId)+op.Amount!=null?op.Amount:0);
                }
                countMBMap.put(op.AccountId,countMBMap.containskey(op.AccountId)?countMBMap.get(op.AccountId)+1:1);
            }
            else if(op.type!=null && op.Type!='New Customer'){
                totalAmountEnterpriseap.put(op.AccountId,
           					 (totalAmountEnterpriseap.containskey(op.AccountId)?totalAmountEnterpriseap.get(op.AccountId):0)
                                            +(op.Amount!=null?op.Amount:0));
                countEnterpriseMap.put(op.AccountId,countEnterpriseMap.containskey(op.AccountId)?countEnterpriseMap.get(op.AccountId)+1:1);
            }
        }
        
        //prepare for Account to update
         List<Account> accountsToUpdate = new List<Account>();
        for(Id accId:accountIdSet){
            Decimal totalAmount=totalAmountNewCustomerMBMap.get(accId);
            Decimal Avg=0;
            if(totalAmount>0 && countMBMap.get(accId)>0 ){
                Avg=totalAmount/countMBMap.get(accId);
            }
            Decimal totalEnterprise=totalAmountEnterpriseap.get(accId);
            Decimal AvgEnterprise=0;
            if(totalEnterprise>0 && countEnterpriseMap.get(accId)>0 ){
                AvgEnterprise=totalEnterprise/countEnterpriseMap.get(accId);
            }
            
            accountsToUpdate.add( new Account(Id=accId, Avg_Lost_SMB_Opps__c =Avg,Avg_Lost_Enterprise_Opps__c =AvgEnterprise));
        }
        if(!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
    }
    
   public static  Map<Id, List<Opportunity>>  opportunityconvetedMap(List<Opportunity> oppList) {
        Map<Id, List<Opportunity>> accopportunityMap=new  Map<Id, List<Opportunity>>();
        for(Opportunity op: oppList){
            if(!accopportunityMap.containskey(op.AccountId)){
                accopportunityMap.put(op.AccountId, new list<Opportunity>());
            }
           accopportunityMap.get(op.AccountId).add(op);
        }
        return accopportunityMap;
    }
}