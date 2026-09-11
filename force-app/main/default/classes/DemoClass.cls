public class DemoClass {
    
    public static void demo(Integer x, String z) {
        System.debug('Number: ' + x);
        System.debug('Text: ' + z);
    }
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(Integer limitSize, Integer offset){
        
        return [
            SELECT Id, Name, Rating, Industry
            FROM Account
            ORDER BY CreatedDate DESC
            LIMIT :limitSize
            OFFSET :offset
        ];
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getFields(String recordId,Integer limitSize,Integer offset ) {
        
        Map<String, Object> result = new Map<String, Object>();
        
        String objectApiName = ((Id)recordId).getSObjectType().getDescribe().getName();
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectApiName);

        Map<Object, Object> mapName = new Map<Object, Object>();

        List<Map<String, Object>> allFields = new  List<Map<String, Object>>();
        Map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
        
        for(Schema.SobjectField field : fieldMap.values()) {
            Schema.DescribeFieldResult f = field.getDescribe();
            // System.debug('f--'+f);
            Map<String, Object> fieldData = new Map<String, Object>();

            fieldData.put('label', f.getLabel());
            fieldData.put('apiName', f.getName());
            fieldData.put('type', String.valueOf(f.getType()));
             System.debug('fieldData--'+fieldData);

             allFields.add(fieldData);
        }
        // pagination
        Integer startIndex = offset;
        Integer endIndex = Math.min(offset + limitSize, allFields.size());
        List<Map<String, Object>> paginatedFields =new List<Map<String, Object>>();
        for(Integer i=0;i<endIndex;i++){
            paginatedFields.add(allFields[i]);
        }
        result.put('fields',paginatedFields);
        result.put('hasMore',endIndex < allFields.size());
        return result;
        
    }
}