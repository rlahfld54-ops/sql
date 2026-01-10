select oi.product_id,sum(oi.price * oi.quantity) as total_sales
from order_items oi
join orders o
on o.order_id = oi.order_id
where order_date >='2025-12-01'
order_date < '2026-01-01'
group by oi.product_id
order by 
limit 3;