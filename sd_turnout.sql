select state, SD, votes as "# Votes", to_char(((votes*1.0)/ (registered*1.0))*100, '999D9%') as "% Turnout"
FROM (
select state, SD, votes, registered
FROM (
select state
     , senate_district as SD
     , count(case when voting_status is not null then 1 else null end) as votes
     , count(case when registration_status is not null then 1 else null end) as registered
FROM kgardner.periscope_ev_dashboard 
   )
