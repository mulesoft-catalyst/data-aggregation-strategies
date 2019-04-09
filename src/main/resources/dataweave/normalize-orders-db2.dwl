%dw 1.0
%output application/java
---
payload map ((order,orderIndex) -> {
	orderId: order.id,
	orderName: order.name
})