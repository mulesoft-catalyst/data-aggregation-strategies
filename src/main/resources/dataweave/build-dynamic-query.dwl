%dw 1.0
%output application/java
%var includeDetails = inboundProperties."http.query.params".includeDetails as :boolean
---
'SELECT o.id, o.description' ++ (', od.detail1, od.detail2 ' when includeDetails otherwise ' ')
++ 'FROM Orders o ' ++ ('LEFT JOIN Order_Details od ON o.id = od.order_id ' when includeDetails otherwise ' ')