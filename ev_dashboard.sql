-- 2020 EV Dashboard Base Table --
drop table if exists ts.ev_g2020_dashboard_table CASCADE;
create table ts.ev_g2020_dashboard_table AS (
  Select a.vb_voterbase_id as voterbase_id
     , a.vb_smartvan_id as smartvan_id
     , a.vb_vf_source_state as state
     , (case 
     		  when a.vb_voterbase_age <= 35 then 'Under_35'
          when a.vb_voterbase_age >= 36 then 'Above_35'
        end) as age
     , (case
        	when a.vb_vf_party = 'Republican' then 'Republican'
        	when a.vb_vf_party = 'Democrat' then 'Democrat'
          else 'Other' 
        end) as party
     , a.vb_voterbase_gender as gender
     , a.vb_vf_race as race
     , a.vb_vf_cd as congressional_district
     , a.vb_vf_sd as senate_district
     , a.vb_vf_hd as house_district
     , a.vb_vf_county_name as county 
     , a.vb_vf_precinct_name as precinct
     , (case 
        	when a.ts_tsmart_partisan_score <= 29.99 then 'score_0_to_30'
            when a.ts_tsmart_partisan_score between 30.00 and 69.99 then 'score_30_to_70'
            when a.ts_tsmart_partisan_score >= 70.00 then 'score_70_to_100'
                 end) as partisanship_score
     , (case 
        	when a.ts_tsmart_presidential_general_turnout_score <= 29.99 then 'score_0_to_30'
            when a.ts_tsmart_presidential_general_turnout_score between 30.00 and 69.99 then 'score_30_to_70'
            when a.ts_tsmart_presidential_general_turnout_score >= 70.00 then 'score_70_to_100'
           	     end) as turnout_score
     , (case when vb_voterbase_registration_status = 'Registered' then 'Y' else null end) as registration_status
     , ev.ballot_mailed_date as date_ballot_mailed
     , ev.ballot_received_date as date_ballot_received
     , ev.early_voted_date as date_early_voted 
     , ev.election_date 
     , (case when tsmart_voted is not null then 'Y' else null end) as voting_status
     , ev.ev_data_update_date as updated_at
FROM ts.current_analytics A
LEFT JOIN ts.ev_g2020 EV ON (A.vb_voterbase_id = EV.voterbase_id)
WHERE vb_voterbase_registration_status = 'Registered'
and vb_vf_source_state in ('AZ','FL','IA','ME','MI','NH','NC','NV','PA','VA','WI')
  );
grant usage on schema ts to periscope_nextgen;
grant select on ts.ev_g2020_dashboard_table to periscope_nextgen;


-- 2020 Absentee Ballot Table --
drop table if exists ts.ev_g2020_dashboard_received;
create table ts.ev_g2020_dashboard_received as (
  select voterbase_id
   , date
   , days_until_e_day
   , state
   , gender
   , race
   , age
   , party
   , (case when date_ballot_received is not null then 'Y' else null end) as date_ballot_received
FROM (
        select *
        from ts.ev_g2020_dashboard_dates A
        left join (
            select voterbase_id
                , state
                , gender
  						  , race
                , age
                , party
                , (case when date_ballot_received < '20200831' then '20200831'
                   else date_ballot_received end) 
                   as date_ballot_received
            FROM ts.ev_g2020_dashboard_table
            where date_ballot_received is not null
                 )
        B ON (A.date = date(b.date_ballot_received))
      )
order by date
  );
grant usage on schema ts to periscope_nextgen;
grant select on ts.ev_g2020_dashboard_received to periscope_nextgen;


-- 2020 Early Vote Table --
drop table if exists ts.ev_g2020_dashboard_early;
create table ts.ev_g2020_dashboard_early AS (
  select voterbase_id
   , date
   , days_until_e_day
   , state
   , gender
   , race
   , age
   , party
   , (case when date_early_voted is not null then 'Y' else null end) as date_early_voted
FROM (
        select *
        from ts.ev_g2020_dashboard_dates A
        left join (
            select voterbase_id
                , state
                , age
                , gender
   							, race
                , party
                , (case when date_early_voted < '20200831' then '20200831'
                   else date_early_voted end) 
                   as date_early_voted
            FROM ts.ev_g2020_dashboard_table
            where date_early_voted is not null
                 )
        B ON (A.date = date(b.date_early_voted))
      )
order by date
 );
grant usage on schema ts to periscope_nextgen;
grant select on ts.ev_g2020_dashboard_early to periscope_nextgen;


-- 2020 Ballots Mailed Table --
drop table if exists ts.ev_g2020_dashboard_mailed;
create table ts.ev_g2020_dashboard_mailed as (
select voterbase_id
   , date
   , days_until_e_day
   , state
   , age
   , gender
   , race
   , party
   , (case when date_ballot_mailed is not null then 'Y' else null end) as date_ballot_mailed
FROM (
        select *
        from ts.ev_g2020_dashboard_dates A
        left join (
            select voterbase_id
                , state
                , age
          			, gender
  						  , race
                , party
                , (case when date_ballot_mailed < '20200831' then '20200831'
                   else date_ballot_mailed end) 
                   as date_ballot_mailed
            FROM ts.ev_g2020_dashboard_table
            where date_ballot_mailed is not null
                 )
        B ON (A.date = date(b.date_ballot_mailed))     
      )
order by date
  );
grant usage on schema ts to periscope_nextgen;
grant select on ts.ev_g2020_dashboard_mailed to periscope_nextgen;
  
  
-- 2020 Contact History Among EV/AV --
drop table if exists ts.ev_g2020_dashboard_contacts;
create table ts.ev_g2020_dashboard_contacts AS (
select voterbase_id, smartvan_id, state, age, gender, race, party, date_ballot_received, date_early_voted, datecanvassed, contacttypeid
from ts.ev_g2020_dashboard_table D
left join van.tsm_nextgen_contactscontacts_vf C on (c.vanid = D.smartvan_id and c.statecode = D.state)
where c.datecanvassed >= date('2020-06-01')
and voting_status is not null
 and date(nvl(date_ballot_received,date_early_voted)) > c.datecanvassed
  );
grant usage on schema ts to periscope_nextgen;
grant select on ts.ev_g2020_dashboard_contacts to periscope_nextgen;
  

-- 2020 Pledges to Vote Among EV/AV --
drop table if exists ts.ev_g2020_dashboard_ptvs;
create table ts.ev_g2020_dashboard_ptvs AS (
select *
FROM (
select distinct(m.vanid)
     , d.state
     , d.age
     , d.party
     , d.gender
     , d.race
     , surveyquestionname
     , surveyresponsename
     , voting_status
     , date_ballot_mailed
from ts.ev_g2020_dashboard_table D
left join everyaction.ea_base_matched M on (d.smartvan_id = m.vb_smartvan_id AND d.state = m.vb_vf_source_state)
left join van.tsm_nextgen_contactssurveyresponses_mym R ON (m.vanid = r.vanid)
left join van.tsm_nextgen_surveyquestions Q using (surveyquestionid)
left join van.tsm_nextgen_surveyresponses SR ON (R.surveyresponseid = sr.surveyresponseid)
where (
      surveyquestionname in ('Pledge 2020','Petition Signer 2019','Survey Card 2019')
      or 
      (surveyquestionname = '2020 Partisan ID' and surveyresponsename like '1%')
    )
  )
  );
grant usage on schema ts to periscope_nextgen;
grant select on ts.ev_g2020_dashboard_ptvs to periscope_nextgen;
 
   
 -- 2016 EV Dashboard Base Table --
 drop table if exists ts.ev_g2016_dashboard_table;
create table ts.ev_g2016_dashboard_table AS (
  Select a.vb_voterbase_id as id
     , a.vb_vf_source_state as state
     , (case 
     		when a.vb_voterbase_age <= 35 then 'Under_35'
        when a.vb_voterbase_age >= 36 then 'Above_35'
              end) as age
     , (case
        	when a.vb_vf_party = 'Republican' then 'Republican'
        	when a.vb_vf_party = 'Democrat' then 'Democrat'
          else 'Other' 
          end) as party
     , a.vb_voterbase_gender as gender
     , a.vb_vf_race as race
     , a.vb_vf_cd as congressional_district
     , a.vb_vf_sd as senate_district
     , a.vb_vf_hd as house_district
     , a.vb_vf_county_name as county 
     , a.vb_vf_precinct_name as precinct
     , (case 
        	when a.ts_tsmart_partisan_score <= 29.99 then 'score_0_to_30'
            when a.ts_tsmart_partisan_score between 30.00 and 69.99 then 'score_30_to_70'
            when a.ts_tsmart_partisan_score >= 70.00 then 'score_70_to_100'
                 end) as partisanship_score
     , (case 
        	when a.ts_tsmart_presidential_general_turnout_score <= 29.99 then 'score_0_to_30'
            when a.ts_tsmart_presidential_general_turnout_score between 30.00 and 69.99 then 'score_30_to_70'
            when a.ts_tsmart_presidential_general_turnout_score >= 70.00 then 'score_70_to_100'
           	     end) as turnout_score
     , ev.ballot_received_date as date_ballot_received
     , ev.early_vote_date as date_early_voted 
     , (case when tsmart_voted is not null then 'Y' else null end) as voting_status
     , ev.ev_data_update_date as updated_at
FROM ts.ev_g2016 EV
LEFT JOIN ts.analytics_snapshot_2016_nov A ON (A.vb_voterbase_id = EV.vb_voterbase_id)
WHERE vb_voterbase_registration_status = 'Registered'
AND vb_vf_source_state in ('AZ','FL','IA','ME','MI','NH','NC','NV','PA','VA','WI')
  );
grant usage on schema ts to periscope_nextgen;
grant select on ts.ev_g2016_dashboard_table to periscope_nextgen;
  
  
-- 2016 Early Vote Table --
drop table if exists ts.ev_g2016_dashboard_early;
create table ts.ev_g2016_dashboard_early AS (
  select id
   , date
   , days_until_e_day
   , state
   , gender
   , race
   , age
   , party
   , (case when date_early_voted is not null then 'Y' else null end) as date_early_voted
FROM (
        select *
        from ts.ev_g2016_dashboard_dates A
        left join (
            select id
                , state
                , gender
                , race
                , age
                , party
                , date_early_voted
            FROM ts.ev_g2016_dashboard_table
            where date_early_voted is not null
                 )
        B ON cast(a.date as date) = cast(b.date_early_voted as date)
      )
order by date
 );
grant usage on schema ts to periscope_nextgen;
grant select on ts.ev_g2016_dashboard_early to periscope_nextgen;
  
  
-- 2016 Absentee Ballot Table --
drop table if exists ts.ev_g2016_dashboard_received;
create table ts.ev_g2016_dashboard_received as (
  select id
   , date
   , days_until_e_day
   , state
   , race
   , gender
   , age
   , party
   , (case when date_ballot_received is not null then 'Y' else null end) as date_ballot_received
FROM (
        select *
        from ts.ev_g2016_dashboard_dates A
        left join (
            select id
                , state
                , age
                , race
                , gender
                , party
                , date_ballot_received
            FROM ts.ev_g2016_dashboard_table
            where date_ballot_received is not null
                 )
        B ON cast(a.date as date) = cast(b.date_ballot_received as date)
      )
order by date
  );
grant usage on schema ts to periscope_nextgen;
grant select on ts.ev_g2016_dashboard_received to periscope_nextgen;
