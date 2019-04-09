%dw 1.0
%output application/json
%var details = flatten flowVars.orderDetails
---
flowVars.orders map ((order,orderIndex) -> {
	orderId:order.id,
	orderName: order.description,
	orderDetails:  details filter ($.order_id == order.id)
})