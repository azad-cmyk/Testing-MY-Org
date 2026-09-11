public class AccountCsvQueueable implements Queueable {

    private Set<Id> ContentDocumentId;
    
    public AccountCsvQueueable(Set<id> ContentDocumentId){
        this.ContentDocumentId=ContentDocumentId;
    }
    
    public void execute(QueueableContext qc){
        system.debug('execute method');
         List<ContentVersion> cv=[SELECT Id,Title, ContentDocumentId,VersionData,IsLatest,FileExtension 
                                 FROM ContentVersion where ContentDocumentId =:ContentDocumentId
                                 AND IsLatest = true
           						 LIMIT 1 ];
        if(cv[0].FileExtension!='csv'){
       		system.debug('not support'+cv[0].FileExtension);
        	return;
        }
        
        Blob b=cv[0].VersionData;
        String s1=b.toString();
        List<String> data=s1.split('\n');
        System.debug('data'+data);
        
       
        List <Account> accList=new List<Account>();
        
        for(Integer i=1;i<data.size();i++){
            List<String> col=data[i].split(',');
            System.debug('col'+col);
           // if(col.size()<3) continue;
            Account ac=new Account();
           if(!String.isBlank(col[0])){
        		ac.Id = col[0].trim();
    		}
            ac.Name=col[1];
            ac.Phone=col[2];
            ac.Rating=col[3];
            accList.add(ac);
        }
        if(!accList.isEmpty()){
            upsert accList;
        }
        
    }
}