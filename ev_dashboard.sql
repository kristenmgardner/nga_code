drop table kgardner.periscope_ev_dashboard CASCADE;
create table kgardner.periscope_ev_dashboard AS (

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
grant usage on schema kgardner to periscope_nextgen;
grant select on kgardner.periscope_ev_dashboard to periscope_nextgen;
