# frozen_string_literal: true

$donation_query = <<~SQL
  
  -- All donations and giftcards purchased 
  -- User level transactions
  with giftcards as (
      select 
          d.id 
          ,d.gift_card_id
          ,d.receipt_id
          ,d.expiration at time zone 'utc' at time zone 'America/New_York'
          ,d.created_at at time zone 'utc' at time zone 'America/New_York'
          ,d.updated_at at time zone 'utc' at time zone 'America/New_York'
          ,d.item_id
          ,d.seller_gift_card_id 
          ,d.single_use
          ,a.value as giftcard_amount
          ,a.gift_card_detail_id 
      from gift_card_details as d
      join gift_card_amounts as a 
      on d.id = a.gift_card_detail_id
      
      ), 
      all_donations as (
      select 
      c.email
      ,i.purchaser_id
      ,s.seller_id as merchant
      ,i.payment_intent_id
      ,g.single_use as gam
      ,(case when i.item_type = 1 then 'giftcard' else 'donation' end) as purchase_type
      ,coalesce (d.item_id, g.item_id) as transaction_id
      ,coalesce(d.amount/100, g.giftcard_amount/100) as dollar_amount
      ,date(i.created_at at time zone 'utc' at time zone 'America/New_York') as created
      ,date(i.updated_at at time zone 'utc' at time zone 'America/New_York') as last_update
      ,i.created_at at time zone 'utc' at time zone 'America/New_York' as created_timepstamp
      ,i.refunded
      from items as i 
      left join donation_details as d
      on i.id = d.item_id
      left join giftcards as g      
      on i.id = g.item_id
      left join sellers as s 
      on i.seller_id = s.id
      left join contacts as c   
      on i.purchaser_id = c.id
      left join payment_intents as p
      on i.payment_intent_id = p.id 
      where refunded = 'false'
      order by created_timepstamp desc
      ), 
      pool as (
      select 
          payment_intent_id
          ,refunded
          ,date(p.created_at at time zone 'utc' at time zone 'America/New_York') as created
          ,count(*) as num
      from donation_details as d
      join items as i
      on d.item_id = i.id
      join payment_intents as p
      on i.payment_intent_id = p.id 
      group by 1,2,3
      )
  
  -- -- RUN TO GET BI-WEEKLY PAYOUT $
      SELECT  
      -- merchant
      min(created) as start_date
      ,max(created) as end_date 
      ,sum(case when purchase_type = 'donation' then dollar_amount else 0 end) as donation
      ,sum(case when purchase_type = 'giftcard' AND gam is FALSE then dollar_amount else 0 end) as giftcard
      ,sum(case when purchase_type = 'giftcard' AND gam is TRUE then dollar_amount else 0 end) as GAM
      /*if purchase type is giftcard, and gam is TRUE then giftcard dollar amount? = GAM */ 
      ,sum(dollar_amount) as total
  
      from all_donations
      /*** Input Dates Here ***/ 
      -- where created >= '2020-03-16' and created < '2021-03-23'
      -- group by 
      -- merchant
      /*order by 1 */
  values
SQL
