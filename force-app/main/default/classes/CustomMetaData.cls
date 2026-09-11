public class CustomMetaData {

    public Static Void customDatamethod(){
        List<Customer_Discount__mdt> discounts =
                                            [SELECT Customer_Type__c, Discount_Percent__c
                                             FROM Customer_Discount__mdt];

       for(Customer_Discount__mdt d : discounts){
       System.debug(d.Customer_Type__c + ' ---> ' + d.Discount_Percent__c);
      }
    }
}