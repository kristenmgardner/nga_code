drop table if exists kgardner.thrutext_bulk_upload;
create table kgardner.thrutext_bulk_upload AS (
SELECT *
FROM (
      SELECT vb_smartvan_id
       , vb_vf_source_state
       , contact_first_name
       , contact_last_name
       , contact_phone
       , cast(ttimestamp as date)
       , nvl(contact_result,'Texted') as contact_result
       , partisan_id
       , message_id
       , contact_id
     FROM (
              SELECT C.vb_smartvan_id
                 , C.vb_vf_source_state
                 , M.contact_first_name
                 , M.contact_last_name
                 , M.contact_phone
                 , M.message_id
                 , M.conversation_id
                 , M.ttimestamp
                 , S.updated_at
                 , S.survey_question
                 , S.contact_id
                 , S.response
                 , note
                 , S.contact_result
       			 , S.partisan_id
                 , split_part(M.import_source,'/',1) as committee
              FROM (
                    SELECT *
                      FROM ( SELECT *
                                , row_number() over (partition by conversation_id order by ttimestamp asc) as msg_row
                  FROM thrutext.messages
                  where message_direction = 'outgoing'
                           )
                            WHERE msg_row = 1
                     ) M
        LEFT JOIN (select vb_tsmart_first_name
                   , vb_tsmart_last_name
                   , coalesce(B.tsmart_wireless_phone, A.vb_voterbase_phone_wireless) as phone
                   , vb_smartvan_id
                   , vb_voterbase_id
                   , vb_vf_source_state
                   from ts.current_analytics A 
                   left join ts.current_cellbase B using(vb_voterbase_id)
                  ) C
                     ON upper(M.contact_first_name) = upper(C.vb_tsmart_first_name) and
       					upper(M.contact_last_name) = upper(C.vb_tsmart_last_name) and
       					M.contact_phone = '+1' || C.phone
        LEFT JOIN  (
          			SELECT *
                     FROM (
                       SELECT l.contact_last_name
                        , l.contact_first_name
                        , l.contact_phone
                        , l.updated_at
                        , l.survey_question
                        , l.contact_id
                        , l.response
                        , o.note
                        , row_number() over (partition by contact_id order by (case when response = 'Wrong Number' then '0' when note = 'DO NOT TEXT' then '1' when response = 'Moved' then '2' when response = 'Refused' then '3' when response = 'Deceased' then '4' when response = 'Texted' then '5' else '6' end) asc) as survey_row
                         , (case
                              when (regexp_replace(lower(survey_question), '[.,?!;:]') similar to 'wrong number|wrong number %'
                              and response ilike 'yes')
                              or response ilike 'wrong number'
                                 then 'Wrong Number'
                              when note ilike '%opted out%'
                                 then 'DO NOT TEXT'
                              when (regexp_replace(lower(survey_question), '[.,?!;:]') similar to 'moved|moved %'
                              and response in ('Yes', 'yes', 'Moved'))
                              or response ilike '%Moved/Wrong State%'
                                 then 'Moved'
                             when survey_question = 'Hostile'
                             and response similar to '%(Offensive Language|Contact Fatigue|Threatening)%'
                                 then 'Refused'
                             when response ilike '%Deceased%'
                                 then 'Deceased'
                             else 'Texted'
                        end) as contact_result
                     , (case
                            when contact_result = 'Wrong Number'
                                then null
                            when survey_question = 'Hostile'
                            and response ilike '%Political/Issue Opposition%'
                                then '5'
                           when regexp_replace(lower(survey_question), '[.,?!;:]') similar to '%trump supporter%'
                           and lower(response) similar to '%yes|republican/trump supporter%'
                                then '5'
                           when survey_question = 'Do you Pledge to Vote for Joe Biden?'
                           and response ilike '%Yes%'
                                then '1'
                            when survey_question = 'Do you Pledge to Vote for Joe Biden?'
                            and response ilike '%No%'
                                then '5'
                        end) as partisan_id
                       FROM thrutext.surveys l
               LEFT JOIN thrutext.opt_outs O using (contact_id)
               )
            where survey_row = 1
               ) S ON upper(S.contact_first_name) = upper(C.vb_tsmart_first_name) and
       					upper(S.contact_last_name) = upper(C.vb_tsmart_last_name) and
       					S.contact_phone = '+1' || C.phone
           WHERE vb_smartvan_id is not null
           AND committee = 'nextgen'
   ) B
   )
  )
