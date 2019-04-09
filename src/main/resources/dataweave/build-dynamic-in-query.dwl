%dw 1.0
%output application/java
---
'SELECT * FROM Order_Details od WHERE od.order_id IN (' ++ (flowVars.orders['id'] joinBy ',') ++ ')'
