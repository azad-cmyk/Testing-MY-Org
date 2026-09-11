trigger OrderitemTrigger on OrderItem ( after insert, after update) {

    // Step 1: Collect impacted Order Ids
    Set<Id> orderIds = new Set<Id>();
    
    if(Trigger.isInsert || Trigger.isUpdate){
        for(OrderItem oi : Trigger.new){
            if(oi.OrderId != null){
                orderIds.add(oi.OrderId);
            }
        }
    }
    // Step 2: Query all OrderItems for these Orders along with Product Commission Rate
    List<OrderItem> orderItems = [
        SELECT Id, OrderId, Quantity, UnitPrice,TotalPrice 
        FROM OrderItem
        WHERE OrderId IN :orderIds ];
    
    // Step 3: Aggregate Commission per Order
    Map<Id, Decimal> orderCommissionMap = new Map<Id, Decimal>();
    
    for(OrderItem oi : orderItems){
     
        Decimal invoiceAmount = oi.TotalPrice  ;
        Decimal commission=(invoiceAmount *0.62 * 0.0275)+(invoiceAmount * 0.38* 0.01);
		system.debug('commission'+commission);
        // Sum per order
        if(!orderCommissionMap.containsKey(oi.OrderId)){
            orderCommissionMap.put(oi.OrderId, 0);
           
        }
        orderCommissionMap.put(oi.OrderId, orderCommissionMap.get(oi.OrderId) + commission);

        // Optional: add detail text
       
    }
     // Step 4: Update Orders
    List<Order> ordersToUpdate = new List<Order>();
    for(Id ordId : orderIds){
        ordersToUpdate.add(new Order(
            Id = ordId,
            total_Commision__c  = orderCommissionMap.containsKey(ordId) ? orderCommissionMap.get(ordId) : 0 ));
    }

    if(!ordersToUpdate.isEmpty()){
        update ordersToUpdate;
    }
}