public class ExcelProcessor {

    public static String uploadFiletoCreate(Id ContentDocumentId){
        system.debug('uploadFiletoCreate method call');
        List<ContentVersion> cv=[SELECT Id,Title, ContentDocumentId,VersionData,IsLatest,FileExtension 
                                 FROM ContentVersion where ContentDocumentId =:ContentDocumentId
                                 AND IsLatest = true
           						 LIMIT 1 ];
        
        if (cv[0].FileExtension != 'csv') {
   				 System.debug('Skipping non-CSV file: ' + cv[0].FileExtension);
   				 return 'Only CSV files allowed';
		}

        BLOB b1=cv[0].VersionData;
         String s1=b1.toString();
        List<String> data=s1.split('\n');
		System.debug('BLOB s1 '+s1);
        System.debug('data  '+data);
        System.debug('data length '+data.size());

        
       
       // String csvData = cv[0].VersionData.toString();
        //List<String> rows = csvData.split('\n');
		//System.debug('csvData'+csvData);
        //System.debug('rows'+rows);
        
        List<Account> accList = new List<Account>();

        for (Integer i = 1; i < data.size(); i++) {
            List<String> cols = data[i].split(',');
            System.debug('cols'+cols);
            
            accList.add(new Account(
            Name=cols[0],Phone=cols[1],Rating=cols[2])
                       );
            
        }
        insert accList;
            

        
        
	return 'success';
        
    }
}