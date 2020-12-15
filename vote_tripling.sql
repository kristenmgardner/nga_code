-- number registered triplers in 11 states --
select count(distinct vb_voterbase_id)
from kgardner.vote_triplers_2020 vt
left join ts.current_analytics a using (vb_voterbase_id)
where vb_voterbase_registration_status = 'Registered' and  vb_vf_source_state in ('AZ','IA','FL','MI','ME','NC','NV','NH','PA','VA','WI')

-- number triplers that voted EV/AB -- 
select tsmart_voted, count(*)
from kgardner.vote_triplers_2020 vt
left join ts.current_analytics a using (vb_voterbase_id)
left join ts.ev_g2020 ev on (ev.voterbase_id = a.vb_voterbase_id)
where vb_voterbase_registration_status = 'Registered' and tsmart_voted is not null and vb_vf_source_state in ('AZ','IA','FL','MI','ME','NC','NV','NH','PA','VA','WI')
group by 1

-- number triplers with phone --
select count(distinct vb_voterbase_id)
from kgardner.vote_triplers_2020 vt
left join ts.current_analytics a using (vb_voterbase_id)
where vb_voterbase_phone is not null 
and vb_voterbase_registration_status = 'Registered'
and vb_vf_source_state in ('AZ','IA','FL','MI','ME','NC','NV','NH','PA','VA','WI')

-- number unique triplers contacted by ph/text --
select count(distinct vb_voterbase_id)
from kgardner.vote_triplers_2020 vt
left join ts.current_analytics a using (vb_voterbase_id)
left join van.tsm_nextgen_contactscontacts_vf cc on (cc.vanid = a.vb_smartvan_id and cc.statecode = a.vb_vf_source_state)
where contacttypeid in (1,37) 
and vb_voterbase_registration_status = 'Registered'
and vb_vf_source_state in ('AZ','IA','FL','MI','ME','NC','NV','NH','PA','VA','WI')

-- number phone and sms attempts among triplers --
select count(distinct case when contacttypeid = 1 then vb_voterbase_id else null end) as phone_attempts
     , count(distinct case when contacttypeid = 37 then vb_voterbase_id else null end) as sms_attempts
from kgardner.vote_triplers_2020 vt
left join ts.current_analytics a using (vb_voterbase_id)
left join van.tsm_nextgen_contactscontacts_vf cc on (cc.vanid = a.vb_smartvan_id and cc.statecode = a.vb_vf_source_state)
where vb_vf_source_state in ('AZ','IA','FL','MI','ME','NC','NV','NH','PA','VA','WI')
and vb_voterbase_registration_status = 'Registered'

-- turnout among triplers contacted by ph/sms --
select count(distinct vb_voterbase_id)
from kgardner.vote_triplers_2020 vt
left join ts.current_analytics a using (vb_voterbase_id)
left join ts.ev_g2020 ev on (a.vb_voterbase_id = ev.voterbase_id)
left join van.tsm_nextgen_contactscontacts_vf cc on (cc.vanid = a.vb_smartvan_id and cc.statecode = a.vb_vf_source_state)
where contacttypeid in (1,37) and vb_vf_source_state in ('AZ','IA','FL','MI','ME','NC','NV','NH','PA','VA','WI') 
and vb_voterbase_registration_status = 'Registered'
and tsmart_voted is not null

-- turnout among triplers NOT contacted --
select count(distinct vb_voterbase_id)
from kgardner.vote_triplers_2020 vt
left join ts.current_analytics a using (vb_voterbase_id)
left join ts.ev_g2020 ev on (a.vb_voterbase_id = ev.voterbase_id)
where tsmart_voted is not null
and vb_vf_source_state in ('AZ','IA','FL','MI','ME','NC','NV','NH','PA','VA','WI') 
and vb_voterbase_registration_status = 'Registered'
and vb_voterbase_id NOT in (
    select distinct vb_voterbase_id
    from kgardner.vote_triplers_2020 vt
    left join ts.current_analytics a using (vb_voterbase_id)
    left join ts.ev_g2020 ev on (a.vb_voterbase_id = ev.voterbase_id)
    left join van.tsm_nextgen_contactscontacts_vf cc on (cc.vanid = a.vb_smartvan_id and cc.statecode = a.vb_vf_source_state)
    where contacttypeid in (1,37) and vb_vf_source_state in ('AZ','IA','FL','MI','ME','NC','NV','NH','PA','VA','WI') and vb_voterbase_registration_status = 'Registered'
  						)

-- number of people that share household ID with triplers (excluding the tripler) --
select count(distinct vb_voterbase_id)
FROM (
select vb_voterbase_id
from ts.current_analytics a
left join ts.ev_g2020 ev on (ev.voterbase_id = a.vb_voterbase_id)
where vb_voterbase_registration_status = 'Registered'  
  and vb_vf_source_state in ('AZ','IA','FL','MI','ME','NC','NV','NH','PA','VA','WI')
  and vb_voterbase_household_id in (
        select a.vb_voterbase_household_id
  		from kgardner.vote_triplers_2020 vt
        left join ts.current_analytics a using (vb_voterbase_id)
        where vb_voterbase_registration_status = 'Registered' and vb_vf_source_state in ('AZ','IA','FL','MI','ME','NC','NV','NH','PA','VA','WI')
                             )
  and vb_voterbase_id NOT in (
        select a.vb_voterbase_id
  		from kgardner.vote_triplers_2020 vt
        left join ts.current_analytics a using (vb_voterbase_id)
        where vb_voterbase_registration_status = 'Registered' and vb_vf_source_state in ('AZ','IA','FL','MI','ME','NC','NV','NH','PA','VA','WI')
     						)
     )

-- turnout among household triplers (excluding the tripler) --
select tsmart_voted, count(*)
FROM (
select distinct(vb_voterbase_id), tsmart_voted
from ts.current_analytics a
left join ts.ev_g2020 ev on (ev.voterbase_id = a.vb_voterbase_id)
where vb_voterbase_registration_status = 'Registered'  
  and vb_vf_source_state in ('AZ','IA','FL','MI','ME','NC','NV','NH','PA','VA','WI')
  and vb_voterbase_household_id in (
        select a.vb_voterbase_household_id
  		from kgardner.vote_triplers_2020 vt
        left join ts.current_analytics a using (vb_voterbase_id)
        where vb_voterbase_registration_status = 'Registered' and vb_vf_source_state in ('AZ','IA','FL','MI','ME','NC','NV','NH','PA','VA','WI')
                             )
  and vb_voterbase_id NOT in (
        select a.vb_voterbase_id
  		from kgardner.vote_triplers_2020 vt
        left join ts.current_analytics a using (vb_voterbase_id)
        where vb_voterbase_registration_status = 'Registered' and vb_vf_source_state in ('AZ','IA','FL','MI','ME','NC','NV','NH','PA','VA','WI')
     						)
     )
 group by 1

-- overall turnout queries --
select count(distinct vb_voterbase_id)
FROM ts.current_analytics a 
left join ts.ev_g2020 ev on (a.vb_voterbase_id = ev.voterbase_id)
where vb_voterbase_registration_status = 'Registered' and vb_vf_source_state in ('AZ','IA','FL','MI','ME','NC','NV','NH','PA','VA','WI')

and

select tsmart_voted, count(*)
FROM ts.current_analytics a 
left join ts.ev_g2020 ev on (a.vb_voterbase_id = ev.voterbase_id)
where vb_voterbase_registration_status = 'Registered' and vb_vf_source_state in ('AZ','IA','FL','MI','ME','NC','NV','NH','PA','VA','WI')
group by 1
