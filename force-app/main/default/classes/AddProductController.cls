public with sharing class AddProductController {

    @AuraEnabled(cacheable=true)
    public static Pricebook2 getPricebook(Id recordId, String objectSchema) {
        if (recordId == null || String.isBlank(objectSchema)) {
            throw new AuraHandledException('Invalid parameters');
        }
        Pricebook2 pb2;
        // 🔹 Opportunity
        if (objectSchema == 'Opportunity') {
            Opportunity op = [  SELECT Pricebook2Id
                FROM Opportunity WHERE Id = :recordId
                LIMIT 1
            ];
            system.debug('opportunity'+op);
            if(op.Pricebook2Id!=null){
                 pb2=[SELECT Id, Name, IsActive
                      FROM Pricebook2 WHERE Id = :op.Pricebook2Id
                      LIMIT 1];
            }
          
        }
        system.debug('Pricebook2'+pb2);
          return pb2;
    }

    /**
     * Get all Price Book Entries related to that Pricebook
     * @param pricebookId - Id of the Price Book
     * @return List of PricebookEntry
     */
    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> fetchAllPricebookEntry(Id pricebookId){
        if (pricebookId == null) {
            throw new AuraHandledException('Invalid parameters');
        }
        List<PricebookEntry> pbe= [SELECT Id, Pricebook2Id, Product2Id, Product2.Name, Product2.Description, Product2.ProductCode, Product2.Family, UnitPrice 
                FROM PricebookEntry
                WHERE Pricebook2Id = :pricebookId
                AND IsActive = true
                ORDER BY Product2.Name ASC];

         return pbe;
    }

    /**
     * Get all Price Book
     * @return List of Pricebook2
     */
    @AuraEnabled(cacheable=true)
    public static List<Pricebook2> fetchAllPriceBook(){
        List<Pricebook2> pb2= [SELECT Id, Name, IsActive
                                FROM Pricebook2
                                WHERE IsActive = true
                                ORDER BY Name ASC];

           return pb2;                     
    }
    

     /**
     * Get Discount Type Picklist Values
     * @param objectApiName - API name of the object
     * @param fieldApiName - API name of the field
     * @return List<String>
     */
    @AuraEnabled
    public static List<Map<String, String>> getDiscountTypePicklistValues(String objectApiName, String fieldApiName){
        List<Map<String, String>> picklistValues = new List<Map<String, String>>();

        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectApiName);
        if (objType == null)
            return picklistValues;
        Schema.DescribeFieldResult fieldDesc = objType.getDescribe().fields.getMap().get(fieldApiName).getDescribe();
        if (fieldDesc == null)
            return picklistValues;
        for (Schema.PicklistEntry ple : fieldDesc.getPicklistValues()){
            if (ple.isActive()){
                picklistValues.add(new Map<String, String>{ 'label' => ple.getLabel(), 'value' => ple.getValue() });
            }
        }
        return picklistValues;
    }


   
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountList() {
        return [SELECT Id, Name, Industry, NumberOfEmployees FROM Account WITH USER_MODE LIMIT 10];
    
}
}