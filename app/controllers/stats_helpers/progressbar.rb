$progress_bar_query = <<-SQL 

with original_values as (
    select distinct on (gift_card_detail_id) gca.value,
        (case when single_use = false then 'gift_cards' else 'gam' end) as label
    from gift_card_amounts gca
    join gift_card_details gcd 
    on gcd.id = gca.gift_card_detail_id 
    join items i
    on i.id = gcd.item_id 
    where i.refunded = false
    and i.created_at >= '2021-04-12' and i.created_at <= '2021-04-25'
    order by gift_card_detail_id, gca.created_at asc
),
gc_gam as (
    select sum(value), label
    from original_values 
    group by label
),
donations as (
    select sum(amount), 'donations' as label
    from donation_details dd 
    join items i
    on i.id = dd.item_id 
    where i.refunded = false
    and i.created_at >= '2021-04-12' and i.created_at <= '2021-04-25'
    and seller_id is not null
)
select *
from gc_gam
union select * from donations
SQL