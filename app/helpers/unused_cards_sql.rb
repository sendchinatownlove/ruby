$unused_vouchers_sql_query = <<-SQL 

with ugd as (
	select gift_card_detail_id, count(*)
	from gift_card_amounts gca 
	group by gift_card_detail_id
	having count(*) <= 1
	order by gift_card_detail_id 
),
la as (
	select distinct on (gift_card_detail_id) gift_card_detail_id, value
	from gift_card_amounts gca2
	order by gift_card_detail_id, created_at desc
)
select c."name", c.email, ugd.gift_card_detail_id, 
la.value, initcap(replace(s.seller_id, '-', ' ')) as seller_name, 
CONCAT('https://merchant.sendchinatownlove.com/voucher/', gcd.gift_card_id) as redeem_url 
from gift_card_details gcd 
join ugd
on ugd.gift_card_detail_id = gcd.id 
join la
on la.gift_card_detail_id = gcd.id
join items i
on gcd.item_id = i.id 
join contacts c 
on i.purchaser_id = c.id
join sellers s 
on i.seller_id = s.id
order by email, seller_name

SQL