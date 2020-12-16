-- Count distinct Reach Users --
select count(distinct userid)
from reach.users

-- Count verified vs. unverified reach users --
select count(distinct case when email = 'nextgenamerica.org' then userid else null end) as count
FROM (
select *
      , split_part(emailaddress,'@',2) as email
from reach.users
  )
  
-- Count unique people that added users --
select count(distinct case when peoplereached is not null then userid else null end) as count
from reach.users

-- Count unique reach adds, broken by state -- 
select state, count(distinct reachid)
from reach.people
where state in ('AZ','FL','IA','ME','MI','NH','NC','NV','PA','VA','WI')
group by 1 
order by 1

-- Reach adds by relationship --
select relationshiptype, count(distinct reachid)
from reach.reach_report
group by 1

-- Count number of reach adds with phone --
select count(distinct case when phone is not null then reachid else null end) as phones
from reach.people
where state in ('AZ','FL','IA','ME','MI','NH','NC','NV','PA','VA','WI')

-- Count contact attempts to reach contacts --
select personstate
     , count(distinct case when actiontype = 'SMS' then reachid else null end) as SMS
     , count(distinct case when actiontype = 'Phone Call' then reachid else null end) as Phone
from reach.contact_actions
where personstate in ('AZ','FL','IA','ME','MI','NH','NC','NV','PA','VA','WI')
group by 1
order by 1

-- total unique vols contacted through app --
select personstate, count(distinct reachid)
from reach.contact_actions
where personstate in ('AZ','FL','IA','ME','MI','NH','NC','NV','PA','VA','WI')
and actiontype in ('SMS','Phone Call')
group by 1
order by 1

-- number reach adds that are matched to VF --
select vb_vf_source_state, count(distinct vb_voterbase_id)
FROM (
select p.state
      , case 
           when col_name = 'voterfilevanid'   
            then col_value
         else null end as vanid
from reach.people P
left join reach.people_xf XF using (reachid)
where state in ('AZ','FL','IA','ME','MI','NH','NC','NV','PA','VA','WI')
   ) px
left join ts.current_analytics vf on (px.vanid = vf.vb_smartvan_id and px.state = vf.vb_vf_source_state)
group by 1
order by 1

-- number of matched reach adds with vf or voterbase phone --
select count(distinct vb_voterbase_id)
FROM (
select p.state
      , case 
           when col_name = 'voterfilevanid'   
            then col_value
         else null end as vanid
from reach.people P
left join reach.people_xf XF using (reachid)
where state in ('AZ','FL','IA','ME','MI','NH','NC','NV','PA','VA','WI')
   ) px
left join ts.current_analytics vf on (px.vanid = vf.vb_smartvan_id and px.state = vf.vb_vf_source_state)
where  (
 (vb_vf_phone is not null)
 OR 
  (vb_voterbase_phone is not null)
      )
   
-- contact attempts to reach adds outside of reach app --
select contacttype
     , ct.vb_vf_source_state
     , count(distinct contactscontactid)
FROM (
select p.state
      , case 
          when col_name = 'voterfilevanid'   
          then col_value
        else null end as vanid
from reach.people P
left join reach.people_xf XF using (reachid)
where state in ('AZ','FL','IA','ME','MI','NH','NC','NV','PA','VA','WI')
   ) px
left join ts.current_analytics a on (a.vb_vf_source_state = px.state and px.vanid = a.vb_smartvan_id)
left join universes.callstexts2020 ct using (vb_voterbase_id)
group by 1, 2
order by 1, 2

-- unique people contacted outside reach app --
select ct.vb_vf_source_state, count(distinct ct.vb_voterbase_id)
FROM (
select p.state
      , case 
          when col_name = 'voterfilevanid'   
          then col_value
        else null end as vanid
from reach.people P
left join reach.people_xf XF using (reachid)
where state in ('AZ','FL','IA','ME','MI','NH','NC','NV','PA','VA','WI')
   ) px
left join ts.current_analytics a on (a.vb_vf_source_state = px.state and px.vanid = a.vb_smartvan_id)
left join universes.callstexts2020 ct using (vb_voterbase_id)
group by 1
order by 1

-- count unique PTVs among reach adds --
select ea.vb_vf_source_state, count(distinct ea.vanid)
from (
   select p.state
        , case 
          when col_name = 'voterfilevanid'   
          then col_value
        else null end as vanid
from reach.people P
left join reach.people_xf XF using (reachid)
     ) px
left join ts.current_analytics a on (a.vb_vf_source_state = px.state and a.vb_smartvan_id = px.vanid)
left join everyaction.ea_base_matched ea on (a.vb_voterbase_id = ea.voterbase_id)
left join van.tsm_nextgen_contactssurveyresponses_mym R ON (ea.vanid = r.vanid)
left join van.tsm_nextgen_surveyquestions Q using (surveyquestionid)
left join van.tsm_nextgen_surveyresponses SR ON (R.surveyresponseid = sr.surveyresponseid)
where surveyquestionname in ('Pledge 2020','Petition Signer 2019','Survey Card 2019')
group by 1 
order by 1

-- count unique Biden 1s and 2s among reach adds --
select ea.vb_vf_source_state, count(distinct ea.vanid)
from (
   select p.state
        , case 
          when col_name = 'voterfilevanid'   
          then col_value
        else null end as vanid
from reach.people P
left join reach.people_xf XF using (reachid)
     ) px
left join ts.current_analytics a on (a.vb_vf_source_state = px.state and a.vb_smartvan_id = px.vanid)
left join everyaction.ea_base_matched ea on (a.vb_voterbase_id = ea.voterbase_id)
left join van.tsm_nextgen_contactssurveyresponses_mym R ON (ea.vanid = r.vanid)
left join van.tsm_nextgen_surveyquestions Q using (surveyquestionid)
left join van.tsm_nextgen_surveyresponses SR ON (R.surveyresponseid = sr.surveyresponseid)
where surveyquestionname = '2020 Partisan ID' 
and (
(surveyresponsename like '1%') OR (surveyresponsename like '2%')
    )
group by 1 
order by 1

-- count unique reach adds in first gotv universe (2020-09-11) --
select a.vb_vf_source_state, count(distinct vb_voterbase_id)
from (
   select p.state
        , case 
          when col_name = 'voterfilevanid'   
          then col_value
        else null end as vanid
from reach.people P
left join reach.people_xf XF using (reachid)
     ) px
left join ts.current_analytics A on (a.vb_vf_source_state = px.state and a.vb_smartvan_id = px.vanid)
where a.vb_voterbase_id IN (
           select distinct(vb_voterbase_id)
           from universes.gotv_myv_20200911
                           )
 group by 1
 order by 1

-- count unique volunteers among reach adds --
select state, count(distinct vanid)
from (
  select ea.state, ea.vanid, eventsignupid, es.datetimeoffsetbegin
       from (
         select p.state
                , case 
                    when col_name = 'voterfilevanid'   
                    then col_value
                else null end as vanid
         from reach.people P
         left join reach.people_xf XF using (reachid)
            ) px
left join ts.current_analytics a on (a.vb_vf_source_state = px.state and a.vb_smartvan_id = px.vanid)
left join everyaction.ea_base_matched ea on (a.vb_voterbase_id = ea.voterbase_id)
left join van.tsm_nextgen_eventsignups es on (es.vanid = ea.vanid)
left join van.tsm_nextgen_eventsignupsstatuses st using(eventsignupid)
left join van.tsm_nextgen_events ev using(eventid)
  where date(es.datetimeoffsetbegin) between date('2019-01-01') and date('2020-11-03')
        and es.datesuppressed is null
        and ev.datesuppressed is null
        and eventstatusname = 'Completed'
        and committeename != 'NTI'
        and eventrolename in ('Data Entry/ Admin/ Other','Volunteer Leader','Volunteer')
     )
where state in ('AZ','FL','IA','ME','MI','NH','NC','NV','PA','VA','WI')
group by 1
order by 1

-- count AB/EV among reach adds --
select vb_vf_source_state
      , tsmart_voted
	  , count(distinct voterbase_id)
       from (
         select p.state
                , case 
                    when col_name = 'voterfilevanid'   
                    then col_value
                else null end as vanid
         from reach.people P
         left join reach.people_xf XF using (reachid)
            ) px 
left join ts.current_analytics a on (a.vb_vf_source_state = px.state and a.vb_smartvan_id = px.vanid)
left join ts.ev_g2020 ev on (a.vb_voterbase_id = ev.voterbase_id)
where vb_vf_source_state in ('AZ','FL','IA','ME','MI','NH','NC','NV','PA','VA','WI')
and tsmart_voted is not null
group by 1,2
order by 1,2
