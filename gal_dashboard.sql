drop table if exists galvanize.eval_dash;
create table galvanize.eval_dash AS (

Select mym.vanid
     , a.vb_voterbase_id as voterbase_id
     , mym.state as ea_state
     , a.vb_vf_reg_state as vf_state
     , a.vb_vf_reg_city as city
     , a.vb_reg_latitude 
     , a.vb_reg_longitude
     , (case
     		  when a.vb_voterbase_age between 18 and 34 then '18_to_34'
              when a.vb_voterbase_age between 35 and 54 then '35_to_54'
              when a.vb_voterbase_age between 55 and 74 then '55_to_74'
              when a.vb_voterbase_age >= 75 then 'Above_75'
        end) as age 
     , (case
        	when a.vb_vf_party = 'Republican' then 'Republican'
        	when a.vb_vf_party = 'Democrat' then 'Democrat'
          else 'Other' 
        end) as party
     , a.vb_vf_cd as congressional_district
     , a.vb_voterbase_marital_status as marital_status
     , a.vb_presence_of_children_in_household 
     , (case 
            when a.vb_household_income_amount <= 29999.99 then 'below_30k'
            when a.vb_household_income_amount between 30000.00 and 74999.00 then '30_to_75k'
            when a.vb_household_income_amount between 75000.00 and 99999.99 then '75_to_100k'
            when a.vb_household_income_amount >= 100000.00 then 'above_100k'
                end) as income_range
     , (case 
        	  when a.ts_tsmart_partisan_score <= 29.99 then 'score_0_to_30'
            when a.ts_tsmart_partisan_score between 30.00 and 69.99 then 'score_30_to_70'
            when a.ts_tsmart_partisan_score >= 70.00 then 'score_70_to_100'
                 end) as partisanship_score
     , (case 
        	  when a.ts_tsmart_offyear_general_turnout_score <= 29.99 then 'score_0_to_30'
            when a.ts_tsmart_offyear_general_turnout_score between 30.00 and 69.99 then 'score_30_to_70'
            when a.ts_tsmart_offyear_general_turnout_score >= 70.00 then 'score_70_to_100'
           	     end) as turnout_score
     , (case 
          	when a.predictwise_compassion_score <= 29.99 then 'score_0_to_30'
            when a.predictwise_compassion_score between 30.00 and 69.99 then 'score_30_to_70'
            when a.predictwise_compassion_score >= 70.00 then 'score_70_to_100'
           	     end) as compassion_score
     , (case 
        	  when a.ts_reg_urbanicity = 'R1' then 'rural'
            when a.ts_reg_urbanicity = 'R2' then 'somewhat_rural'
            when a.ts_reg_urbanicity = 'S3' then 'rural_to_suburban'
            when a.ts_reg_urbanicity = 'S4' then 'suburban'
            when a.ts_reg_urbanicity = 'U5' then 'suburban_to_urban'
            when a.ts_reg_urbanicity = 'U6' then 'urban'
           	     end) as urbanicity_score
	  , a.vb_voterbase_registration_status 
	  , activistcodename
	  , a.tmc_landline_phone
	  , a.tmc_cell_phone
	  , a.vb_voterbase_phone_type
	  , a.meta_has_cell
	  , a.vb_voterbase_phone
	  , mym.email
FROM tmc_van.gal_contact_summary_mym mym
LEFT JOIN ts.ntl_current A on (mym.vb_voterbase_id = a.vb_voterbase_id)
left join tmc_van.gal_activist_codes_summary_mym ac on (mym.vanid = ac.vanid)
where mym.committeeid = '78444'


  );
grant usage on schema galvanize to periscope_galvanize;
grant select on galvanize.eval_dash to periscope_galvanize;
