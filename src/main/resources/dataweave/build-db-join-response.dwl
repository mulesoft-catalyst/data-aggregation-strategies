%dw 1.0
%output application/json
---
payload map ((result,resultIndex) -> {
	orderId: result.id,
	orderName: result.description,
	orderDetails:{
		detail1:result.detail1,
		detail2:result.detail2
	} 
})