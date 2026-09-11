public with sharing class QuickActionController {
   
    @AuraEnabled
    public static String runApex(Id recordId){

        Account acc = [SELECT Id, Name FROM Account WHERE Id = :recordId LIMIT 1];

        acc.Name = acc.Name + ' Updated';
        // update acc;

        return 'Success';
    }
}