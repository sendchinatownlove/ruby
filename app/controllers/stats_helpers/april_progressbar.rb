$april_progress_bar_query = <<-SQL 

with i as (
	select distinct payment_intent_id, refunded
	from items i
)
,pws as (
	select line_items::json->0->>'seller_id' as seller_id,
		   (line_items::json->0->>'amount')::int as amount,
		   pi2.created_at 
	from payment_intents pi2
	join i
		on i.payment_intent_id = pi2.id 
	where line_items is not null
	and line_items like '%seller_id%'
	and i.refunded = false
	and pi2.created_at >= '2020-04-13' and pi2.created_at <= '2021-04-25'
)
select sum(amount)
from pws
where seller_id = 'send-chinatown-love'
SQL