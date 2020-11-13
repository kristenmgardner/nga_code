select case
          when turnout_score = 'score_0_to_30' then '0 to 30'
          when turnout_score = 'score_30_to_70' then '30 to 70'
          when turnout_score = 'score_70_to_100' then '70 to 100'
          when turnout_score in ('score_0_to_30','score_30_to_70','score_70_to_100') then 'turnout_total'
      end as "Turnout Scores"
     , count(case when partisanship_score = 'score_0_to_30' then 1 else null end) as "Support Score 0 to 30"
     , count(case when partisanship_score = 'score_30_to_70' then 1 else null end) as "Support Score 30 to 70"
     , count(case when partisanship_score = 'score_70_to_100' then 1 else null end) as "Support Score 70 to 100"
     , count(case when partisanship_score in ('score_0_to_30','score_30_to_70','score_70_to_100') then 1 else null end) as "Support Totals"
from kgardner.periscope_ev_dashboard
where voting_status = 'Y'
group by 1
order by 1
