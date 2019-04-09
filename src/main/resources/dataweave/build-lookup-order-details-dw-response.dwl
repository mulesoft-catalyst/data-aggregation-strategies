%dw 1.0
%output application/json
---
flowVars.orders map ((order,orderIndex) -> {
	orderId:order.id,
	orderName: order.description,
	orderDetails: lookup("order-details-dw-lookup-flow",{orderDetails:flowVars.orderDetails, orderId:order.id})
})