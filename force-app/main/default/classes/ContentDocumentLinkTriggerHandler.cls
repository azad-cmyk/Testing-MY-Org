public class ContentDocumentLinkTriggerHandler {
    
    public static void uploadfileOnGoogleDrive(List<ContentDocumentLink> newContentDocument){
        System.debug('trigger call uploadfileOnGoogleDrive method ');
        
        //find the document Id
        Set<Id> contentDocId=new Set<Id>();
        for(ContentDocumentLink cd:newContentDocument){
            if(cd.ContentDocumentId!=null){
                contentDocId.add(cd.ContentDocumentId);
            }
        }
        //find the document which upload
        list<ContentVersion> contentdoc=[SELECT Id, Title, FileExtension, VersionData
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocId
            AND IsLatest = true];
        
        //call the Async method
        for(ContentVersion content:contentdoc){
            uploadFile(content.Id);
        }
        
    }
    /*
     @future(callout=true)
    public static void uploadFile(Id ContentVersionId){
        system.debug('fuuture method call ');
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:GoogleDrive/upload/drive/v3/files?uploadType=multipart');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        
    }
 */
 	 @future(callout=true)
	public static void uploadFile(Id contentVersionId) {

    ContentVersion cv = [
        SELECT Title, FileExtension, VersionData
        FROM ContentVersion
        WHERE Id = :contentVersionId
        LIMIT 1
    ];

    String boundary = '-------314159265358979323846';
    String fileName = cv.Title + '.' + cv.FileExtension;

    // 🔹 Metadata Part
    String body =
        '--' + boundary + '\r\n' +
        'Content-Type: application/json; charset=UTF-8\r\n\r\n' +
        JSON.serialize(new Map<String, Object>{
            'name' => fileName
        }) + '\r\n';

    // 🔹 File Header
    body +=
        '--' + boundary + '\r\n' +
        'Content-Type: application/octet-stream\r\n' +
        'Content-Transfer-Encoding: base64\r\n\r\n';

    // 🔹 File Content (Base64)
    body += EncodingUtil.base64Encode(cv.VersionData) + '\r\n';

    // 🔹 End Boundary
    body += '--' + boundary + '--';

    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:GoogleDrive/upload/drive/v3/files?uploadType=multipart');
    req.setMethod('POST');
    req.setHeader(
        'Content-Type',
        'multipart/related; boundary=' + boundary
    );

    // 🔥 KEY LINE
    req.setBodyAsBlob(Blob.valueOf(body));

    Http http = new Http();
    HttpResponse res = http.send(req);

    System.debug('Status: ' + res.getStatus());
    System.debug('Response: ' + res.getBody());
}

}