%dw 1.0
%output application/json
---
payload map ((order,orderIndex) -> {
	orderId:order.id,
	orderName: order.description,
	orderDetails: lookup("order-details-db-lookup-flow",{orderId:order.id})
})