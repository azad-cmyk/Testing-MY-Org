public class OneDriveFeature {

    public static String createFolder(String folderName) {

        String token = getAccessToken();

        Http http = new Http();
        HttpRequest req = new HttpRequest();

        req.setEndpoint('https://graph.microsoft.com/v1.0/users/YOUR_USER_ID/drive/root/children');
        req.setMethod('POST');

        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Content-Type', 'application/json');

        String body = JSON.serialize(new Map<String, Object>{
            'name' => folderName,
            'folder' => new Map<String, Object>(),
            '@microsoft.graph.conflictBehavior' => 'rename'
        });

        req.setBody(body);

        HttpResponse res = http.send(req);

        System.debug(res.getBody());

        return res.getBody();
    }

    public static String getAccessToken() {

        Http http = new Http();
        HttpRequest req = new HttpRequest();

        req.setEndpoint('https://login.microsoftonline.com/common/oauth2/v2.0/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String body =
            'client_id=' + EncodingUtil.urlEncode('YOUR_CLIENT_ID', 'UTF-8') +
            '&scope=' + EncodingUtil.urlEncode('https://graph.microsoft.com/.default', 'UTF-8') +
            '&client_secret=' + EncodingUtil.urlEncode('YOUR_CLIENT_SECRET', 'UTF-8') +
            '&grant_type=client_credentials';

        req.setBody(body);

        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            throw new CalloutException('Token Error: ' + res.getBody());
        }

        Map<String, Object> result =
            (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

        return (String) result.get('access_token');
    }
}