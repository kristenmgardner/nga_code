-- Distribution of Partisan IDs across support score buckets --
SELECT CASE 
         WHEN ts_tsmart_partisan_score BETWEEN 90.00 and 100.00 THEN 'score_90_to_100'
         WHEN ts_tsmart_partisan_score BETWEEN 80.00 and 89.99 THEN 'score_80_to_90'
         WHEN ts_tsmart_partisan_score BETWEEN 70.00 and 79.99 THEN 'score_70_to_80'
         WHEN ts_tsmart_partisan_score BETWEEN 60.00 and 69.99 THEN 'score_60_to_70'
         WHEN ts_tsmart_partisan_score BETWEEN 50.00 and 59.99 THEN 'score_50_to_60'
         WHEN ts_tsmart_partisan_score BETWEEN 40.00 and 49.99 THEN 'score_40_to_50'
         WHEN ts_tsmart_partisan_score BETWEEN 30.00 and 39.99 THEN 'score_30_to_40'
         WHEN ts_tsmart_partisan_score BETWEEN 20.00 and 29.99 THEN 'score_20_to_30'
         WHEN ts_tsmart_partisan_score BETWEEN 10.00 and 19.99 THEN 'score_10_to_20'
         WHEN ts_tsmart_partisan_score BETWEEN 0.00 and 9.99 THEN 'score_0_to_10'
      END as score_buckets
     , count (CASE WHEN surveyresponseid = '1519015' then 1 else null end) as score_1
     , count (CASE WHEN surveyresponseid = '1519016' then 1 else null end) as score_2
     , count (CASE WHEN surveyresponseid = '1519017' then 1 else null end) as score_3
     , count (CASE WHEN surveyresponseid = '1519018' then 1 else null end) as score_4
     , count (CASE WHEN surveyresponseid = '1519019' then 1 else null end) as score_5
FROM (
SELECT A.surveyresponseid
     , B.vb_voterbase_id
     , A.datecanvassed
     , B.ts_tsmart_partisan_score
     , row_number () over (partition by vb_voterbase_id order by datecanvassed desc) as row
FROM van.tsm_nextgen_contactssurveyresponses_vf A
LEFT JOIN ts.current_analytics B ON (A.vanid = B.vb_smartvan_id AND A.statecode = B.vb_vf_source_state)
WHERE surveyresponseid in ('1519015','1519016','1519017','1519018','1519019')
and datecanvassed >= date('2020-10-21')
  ) a
WHERE row = 1
and score_buckets is not null
group by 1
order by 1

-- Contact Type Among Low Partisan Score buckets --
SELECT count (case when contacttypeid in ('1','112','4') then 1 else null end) as phone
     , count (case when contacttypeid in ('9','80','86') then 1 else null end) as email 
     , count (case when contacttypeid = 139 then 1 else null end) as reach
     , count (case when contacttypeid in ('2','16','130') then 1 else null end) as walk
     , count (case when contacttypeid in ('82','3','7') then 1 else null end) as direct_mail
     , count (case when contacttypeid = 37 then 1 else null end) as sms
     , count (case when contacttypeid NOT in ('1','112','4','9','80','86','139','2','16','130','82','3','7','37') then 1 else null end) as other
FROM (
SELECT A.surveyresponseid
     , b.vb_voterbase_id
     , A.datecanvassed
     , B.ts_tsmart_partisan_score
     , B.vb_vf_source_state
     , A.contacttypeid
     , row_number () over (partition by vb_voterbase_id order by datecanvassed desc) as row
FROM van.tsm_nextgen_contactssurveyresponses_vf A
LEFT JOIN ts.current_analytics B ON (A.vanid = B.vb_smartvan_id AND A.statecode = B.vb_vf_source_state)
WHERE surveyresponseid in ('1519015','1519016','1519017','1519018','1519019')
AND vb_vf_source_state  in ('AZ','FL','IA','ME','MI','NH','NC','NV','PA','VA','WI')
AND ts_tsmart_partisan_score <= 60.00
  and datecanvassed >= date('2020-10-21')
  ) a
WHERE row = 1

-- Input type among low partisan score buckets --
SELECT count (case when inputtypeid = 10 then 1 else null end) as VPB
     , count (case when inputtypeid = 29 then 1 else null end) as open_vpb
     , count (case when inputtypeid = 4 then 1 else null end) as bulk
     , count (case when inputtypeid = 11 then 1 else null end) as API
     , count (case when inputtypeid NOT in ('10','29','4','11') then 1 else null end) as other
FROM (
SELECT A.surveyresponseid
     , b.vb_voterbase_id
     , A.datecanvassed
     , B.ts_tsmart_partisan_score
     , B.vb_vf_source_state
     , A.inputtypeid
     , row_number () over (partition by vb_voterbase_id order by datecanvassed desc) as row
FROM van.tsm_nextgen_contactssurveyresponses_vf A
LEFT JOIN ts.current_analytics B ON (A.vanid = B.vb_smartvan_id AND A.statecode = B.vb_vf_source_state)
WHERE surveyresponseid in ('1519015','1519016','1519017','1519018','1519019')
AND vb_vf_source_state  in ('AZ','FL','IA','ME','MI','NH','NC','NV','PA','VA','WI')
AND ts_tsmart_partisan_score <= 60.00
  and datecanvassed >= date('2020-10-21')
  ) a
WHERE row = 1

--State by state breakdown of low partisanship scores --
SELECT CASE 
         WHEN ts_tsmart_partisan_score BETWEEN 50.00 and 60.00 THEN 'score_50_to_60'
         WHEN ts_tsmart_partisan_score BETWEEN 40.00 and 49.99 THEN 'score_40_to_50'
         WHEN ts_tsmart_partisan_score BETWEEN 30.00 and 39.99 THEN 'score_30_to_40'
         WHEN ts_tsmart_partisan_score BETWEEN 20.00 and 29.99 THEN 'score_20_to_30'
         WHEN ts_tsmart_partisan_score BETWEEN 10.00 and 19.99 THEN 'score_10_to_20'
         WHEN ts_tsmart_partisan_score BETWEEN 0.00 and 9.99 THEN 'score_0_to_10'
      END as score_buckets
     , count (case when vb_vf_source_state = 'AZ' then 1 else null end) as AZ
     , count (case when vb_vf_source_state = 'FL' then 1 else null end) as FL
     , count (case when vb_vf_source_state = 'IA' then 1 else null end) as IA
     , count (case when vb_vf_source_state = 'ME' then 1 else null end) as ME
     , count (case when vb_vf_source_state = 'MI' then 1 else null end) as MI
         , count (case when vb_vf_source_state = 'NH' then 1 else null end) as NH
         , count (case when vb_vf_source_state = 'NC' then 1 else null end) as NC
           , count (case when vb_vf_source_state = 'NV' then 1 else null end) as NV
            , count (case when vb_vf_source_state = 'VA' then 1 else null end) as VA
             , count (case when vb_vf_source_state = 'PA' then 1 else null end) as PA
              , count (case when vb_vf_source_state = 'WI' then 1 else null end) as WI
FROM (
SELECT A.surveyresponseid
     , B.vb_voterbase_id
     , A.datecanvassed
     , B.ts_tsmart_partisan_score
     , B.vb_vf_source_state
     , row_number () over (partition by vb_voterbase_id order by datecanvassed desc) as row
FROM van.tsm_nextgen_contactssurveyresponses_vf A
LEFT JOIN ts.current_analytics B ON (A.vanid = B.vb_smartvan_id AND A.statecode = B.vb_vf_source_state)
WHERE surveyresponseid in ('1519015','1519016','1519017','1519018','1519019')
  and datecanvassed >= date('2020-10-21')
  ) a
WHERE row = 1
and score_buckets is not null
group by 1
order by 1
