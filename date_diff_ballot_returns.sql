select  count(case when day_difference <= -32 then 1 else null end) as more_than_32_days
    , count(case when day_difference between -31 and -22 then 1 else null end) as _22_to_31_days
 	   , count(case when day_difference between -21 and -15 then 1 else null end) as _15_to_21_days
     , count(case when day_difference between -14 and -8 then 1 else null end) as _8_to_14_days
     , count(case when day_difference between -7 and 0 then 1 else null end) as _0_to_7_days
     
FROM (
  select *
      , DATEDIFF(day, date(date_ballot_received), date(date_ballot_mailed)) as day_difference
  from kgardner.periscope_ev_dashboard
  where date_ballot_received is not null
  and date_ballot_mailed is not null
    )
