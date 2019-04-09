%dw 1.0
%output application/java
---
payload.orderDetails filter ($.order_id==payload.orderId)
