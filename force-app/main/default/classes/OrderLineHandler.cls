public class OrderLineHandler {

    public static void insertHandler(List<Order_Line__c> newOrderLineList){
         Set<Id> OrderIdSet=new Set<Id>();
        for(Order_Line__c od:newOrderLineList){
            if(od.OrderId__c !=null){
                OrderIdSet.add(od.OrderId__c);
            }
        }
        
        //fetch all contact related to account
        List<AggregateResult> existingOrderLine=[select count(id) totalOrderLine, OrderId__c
                                       from Order_Line__c
                                      where OrderId__c in:OrderIdSet
                                      group by OrderId__c];
        system.debug('existingOrderLine'+existingOrderLine);
        
         
        Map<Id, Decimal>OrderQuantityMap=new  Map<Id, Decimal>();
        //for Amount
        Map<Id, Decimal> updateOrderAmountMap=new  Map<Id, Decimal>();
        for(AggregateResult rs:existingOrderLine){
            id oId=(Id) rs.get('OrderId__c');
            Decimal totalOrderLine=(Decimal) rs.get('totalOrderLine');
            OrderQuantityMap.put(oId,totalOrderLine);
        }
        for(AggregateResult rs:[select OrderId__c,Sum(Amount__c) totalAmount from Order_Line__c
                                where OrderId__c in:OrderIdSet and line_Status__c='Confirmed' 
                                group by OrderId__c]){
          id oId=(Id) rs.get('OrderId__c');
          Decimal totalAmount=(Decimal) rs.get('totalAmount'); 
          updateOrderAmountMap.put(oId,totalAmount);
         }
         
        system.debug('updateOrderAmountMap'+updateOrderAmountMap);
        system.debug('OrderQuantityMap'+OrderQuantityMap);
        // for update Order
        List<Order> updateOrder=new  List<Order>();
        for(Id oId:OrderIdSet){
            Decimal totalOrderline=OrderQuantityMap.get(oId);
            Decimal totalAmount=updateOrderAmountMap.get(oId);
             Order ol= new Order(Id=oId,Total_Quantity__c =totalOrderline,Total_Amount__c =totalAmount);
            updateOrder.add(ol);
        }
         if(!updateOrder.isempty()){
        update updateOrder;
    }
    }
   
}