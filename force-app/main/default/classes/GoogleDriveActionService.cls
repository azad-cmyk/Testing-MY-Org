public class GoogleDriveActionService {

    public static String createFolder(String folderName) {

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:GoogleDrive/drive/v3/files');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        // Request body to create folder
        Map<String, Object> body = new Map<String, Object>{
            'name' => folderName,
            'mimeType' => 'application/vnd.google-apps.folder'
        };

        req.setBody(JSON.serialize(body));

        Http http = new Http();
        HttpResponse res = http.send(req);

        System.debug('Status: ' + res.getStatusCode());
        System.debug('Body: ' + res.getBody());

        if (res.getStatusCode() == 200) {
            Map<String, Object> responseMap =
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) responseMap.get('id');
        }

        return null;
    }
}