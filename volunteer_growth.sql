-- total number super vols 2016 --
select count(case when count >= 10 then 1 else null end)
FROM (
  select vanid, count(distinct eventsignupid) as count
  from van.tsm_nextgen_eventsignups es
  left join van.tsm_nextgen_eventsignupsstatuses st using(eventsignupid)
  left join van.tsm_nextgen_events ev using(eventid)
  where date(es.datetimeoffsetbegin) between date('2015-01-01') and date('2016-11-08')
        and es.datesuppressed is null
        and ev.datesuppressed is null
        and eventstatusname = 'Completed'
        and committeename != 'NTI'
        and eventrolename NOT ilike '%attendee%'
  group by vanid
  )
  
-- count number super vols 2018 -- 
  select count(case when count >= 10 then 1 else null end)
FROM (
  select vanid, count(distinct eventsignupid) as count
  from van.tsm_nextgen_eventsignups es
  left join van.tsm_nextgen_eventsignupsstatuses st using(eventsignupid)
  left join van.tsm_nextgen_events ev using(eventid)
  where date(es.datetimeoffsetbegin) between date('2017-01-01') and date('2018-11-06')
        and es.datesuppressed is null
        and ev.datesuppressed is null
        and eventstatusname = 'Completed'
        and committeename != 'NTI'
        and eventrolename in ('Data Entry/ Admin/ Other','Volunteer Leader','Volunteer')
  group by vanid
  )
  
-- count number super vols 2020 -- 
select count(case when count >= 10 then 1 else null end)
FROM (
  select vanid, count(distinct eventsignupid) as count
  from van.tsm_nextgen_eventsignups es
  left join van.tsm_nextgen_eventsignupsstatuses st using(eventsignupid)
  left join van.tsm_nextgen_events ev using(eventid)
  where date(es.datetimeoffsetbegin) between date('2019-01-01') and date('2020-11-03')
        and es.datesuppressed is null
        and ev.datesuppressed is null
        and eventstatusname = 'Completed'
        and committeename != 'NTI'
        and eventrolename in ('Data Entry/ Admin/ Other','Volunteer Leader','Volunteer')
  group by vanid
  )
  
-- number of 2016/2018 vols that returned in 2020 --
with data AS (
  
SELECT distinct vanid
FROM ( 
    select a.vanid
        , B.eventstatusname
        , date(A.datetimeoffsetbegin) as datetimeoff 
    from van.tsm_nextgen_eventsignups A
    LEFT JOIN van.tsm_nextgen_eventsignupsstatuses B ON (A.eventsignupid = B.eventsignupid)
     left join van.tsm_nextgen_events ev using(eventid)
   where (date(datetimeoff) between date('2015-01-01') and date('2016-11-08'))
        and eventstatusname = 'Completed'
        and a.datesuppressed is null
        and ev.datesuppressed is null
        and committeename != 'NTI'
        and eventrolename NOT ilike '%attendee%'    
      )
  
UNION
  
SELECT distinct vanid
FROM ( 
    select a.vanid
        , B.eventstatusname
        , date(A.datetimeoffsetbegin) as datetimeoff 
    from van.tsm_nextgen_eventsignups A
    LEFT JOIN van.tsm_nextgen_eventsignupsstatuses B ON (A.eventsignupid = B.eventsignupid)
     left join van.tsm_nextgen_events ev using(eventid)
	where (date(datetimeoff) between date('2017-01-01') and date('2018-11-06'))
        and eventstatusname = 'Completed'
        and a.datesuppressed is null
        and ev.datesuppressed is null
        and committeename != 'NTI'
        and eventrolename in ('Data Entry/ Admin/ Other','Volunteer Leader','Volunteer')
     )
 )
  
select count(case when match is not null then vanid else null end) as matches
  FROM (
SELECT distinct vanid, match
FROM (
    select a.vanid
        , B.eventstatusname
        , c.vanid as match
        , a.datesuppressed 
        , ev.datesuppressed 
        , date(A.datetimeoffsetbegin) as datetimeoff 
    from van.tsm_nextgen_eventsignups A
    LEFT JOIN van.tsm_nextgen_eventsignupsstatuses B ON (A.eventsignupid = B.eventsignupid)
    LEFT JOIN van.tsm_nextgen_events ev using(eventid)
    LEFT JOIN data c on (a.vanid = c.vanid)
	where date (datetimeoff) between date('2019-01-01') and date('2020-11-03')
	  and eventstatusname = 'Completed'
      and a.datesuppressed is null
      and ev.datesuppressed is null
      and committeename != 'NTI'
      and eventrolename in ('Data Entry/ Admin/ Other','Volunteer Leader','Volunteer')
    )
    )

-- number of 2016 vols that returned in 2018 --
with data_2016 AS (  
SELECT distinct vanid
FROM ( 
    select a.vanid
        , B.eventstatusname
        , date(A.datetimeoffsetbegin) as datetimeoff 
    from van.tsm_nextgen_eventsignups A
    LEFT JOIN van.tsm_nextgen_eventsignupsstatuses B ON (A.eventsignupid = B.eventsignupid)
     left join van.tsm_nextgen_events ev using(eventid)
   where (date(datetimeoff) between date('2015-01-01') and date('2016-11-08'))
        and eventstatusname = 'Completed'
        and a.datesuppressed is null
        and ev.datesuppressed is null
        and committeename != 'NTI'
        and eventrolename NOT ilike '%attendee%'    
      )
 )
  
select count(case when match is not null then vanid else null end) as matches
  FROM (
SELECT distinct vanid, match
FROM (
    select a.vanid
        , B.eventstatusname
        , c.vanid as match
        , a.datesuppressed 
        , ev.datesuppressed 
        , date(A.datetimeoffsetbegin) as datetimeoff 
    from van.tsm_nextgen_eventsignups A
    LEFT JOIN van.tsm_nextgen_eventsignupsstatuses B ON (A.eventsignupid = B.eventsignupid)
    LEFT JOIN van.tsm_nextgen_events ev using(eventid)
    LEFT JOIN data_2016 c on (a.vanid = c.vanid)
	where (date(datetimeoff) between date('2017-01-01') and date('2018-11-06'))
	  and eventstatusname = 'Completed'
      and a.datesuppressed is null
      and ev.datesuppressed is null
      and committeename != 'NTI'
      and eventrolename in ('Data Entry/ Admin/ Other','Volunteer Leader','Volunteer')
    )
    )
    
-- total unique vols 2016 --
SELECT count(distinct vanid)
FROM (
    select a.vanid
        , B.eventstatusname
        , a.eventrolename
        , date(A.datetimeoffsetbegin) as datetimeoff 
    from van.tsm_nextgen_eventsignups A
    LEFT JOIN van.tsm_nextgen_eventsignupsstatuses B ON (A.eventsignupid = B.eventsignupid)
  left join van.tsm_nextgen_events ev using(eventid)
    where date (datetimeoff) between date('2015-01-01') and date('2016-11-08')
    and eventstatusname = 'Completed'
   and a.datesuppressed is null
        and ev.datesuppressed is null
        and committeename != 'NTI'
       and eventrolename NOT ilike '%attendee%'
  )
  
-- total unique vols 2018 --
SELECT count(distinct vanid)
FROM (
    select distinct(a.vanid)
        , B.eventstatusname
        , a.eventrolename
        , date(A.datetimeoffsetbegin) as datetimeoff 
    from van.tsm_nextgen_eventsignups A
    LEFT JOIN van.tsm_nextgen_eventsignupsstatuses B ON (A.eventsignupid = B.eventsignupid)
  left join van.tsm_nextgen_events ev using(eventid)
    where date (datetimeoff) between date('2017-01-01') and date('2018-11-06')
    and eventstatusname = 'Completed'
   and a.datesuppressed is null
        and ev.datesuppressed is null
        and committeename != 'NTI'
        and eventrolename in ('Data Entry/ Admin/ Other','Volunteer Leader','Volunteer')
  )
  
-- total unique vols 2020 --
SELECT count(distinct vanid)
FROM (
    select a.vanid
        , B.eventstatusname
        , a.eventrolename
        , date(A.datetimeoffsetbegin) as datetimeoff 
    from van.tsm_nextgen_eventsignups A
    LEFT JOIN van.tsm_nextgen_eventsignupsstatuses B ON (A.eventsignupid = B.eventsignupid)
  left join van.tsm_nextgen_events ev using(eventid)
    where date (datetimeoff) between date('2019-01-01') and date('2020-11-03')
    and eventstatusname = 'Completed'
    and eventrolename in ('Data Entry/ Admin/ Other', 'Volunteer','Volunteer Leader')
   and a.datesuppressed is null
        and ev.datesuppressed is null
        and committeename != 'NTI'
  )

--total number shifts 2016 --
select count(distinct vanid||eventid||eventshiftid)
  from (
    select vanid
      , eventrolename
      , eventstatusname
      , eventid
      , eventshiftid
      , datetimeoff 
      , row_number() over (partition by vanid || eventid || eventroleid || eventshiftid order by modtime desc, eventstatusname asc) as row
    from (
      select distinct es.vanid
        , es.datetimeoffsetbegin
        , es.eventrolename
        , es.eventroleid
        , st.eventstatusname
        , es.eventid
        , es.eventshiftid
        , st.datecreated
        , date(es.datetimeoffsetbegin) as datetimeoff
        , current_timestamp AT TIME ZONE 'PST' as time
        , st.datemodified as modtime
      from van.tsm_nextgen_eventsignups es
      left join van.tsm_nextgen_eventsignupsstatuses st using(eventsignupid)
      left join van.tsm_nextgen_events ev using(eventid)
      where date(es.datetimeoffsetbegin) between date('2015-01-01') and date('2016-11-08')
        and es.datesuppressed is null
        and ev.datesuppressed is null
        and committeename != 'NTI'
    ) a 
  ) b
  where row = 1
and eventrolename NOT ilike '%attendee%' and eventstatusname='Completed'

-- total number shifts 2018 --
select count(distinct vanid||eventid||eventshiftid)
  from (
    select vanid
      , eventrolename
      , eventstatusname
      , eventid
      , eventshiftid
      , datetimeoff 
      , row_number() over (partition by vanid || eventid || eventroleid || eventshiftid order by modtime desc, eventstatusname asc) as row
    from (
      select distinct es.vanid
        , es.datetimeoffsetbegin
        , es.eventrolename
        , es.eventroleid
        , st.eventstatusname
        , es.eventid
        , es.eventshiftid
        , st.datecreated
        , date(es.datetimeoffsetbegin) as datetimeoff
        , current_timestamp AT TIME ZONE 'PST' as time
        , st.datemodified as modtime
      from van.tsm_nextgen_eventsignups es
      left join van.tsm_nextgen_eventsignupsstatuses st using(eventsignupid)
      left join van.tsm_nextgen_events ev using(eventid)
      where date(es.datetimeoffsetbegin) between date('2017-01-01') and date('2018-11-06')
        and es.datesuppressed is null
        and ev.datesuppressed is null
        and committeename != 'NTI'
    ) a 
  ) b
  where row = 1
and eventrolename in ('Data Entry/ Admin/ Other','Volunteer Leader','Volunteer') and eventstatusname='Completed'

-- total number shifts 2020 --
select count(distinct vanid||eventid||eventshiftid)
  from (
    select vanid
      , eventrolename
      , eventstatusname
      , eventid
      , eventshiftid
      , datetimeoff 
      , row_number() over (partition by vanid || eventid || eventroleid || eventshiftid order by modtime desc, eventstatusname asc) as row
    from (
      select distinct es.vanid
        , es.datetimeoffsetbegin
        , es.eventrolename
        , es.eventroleid
        , st.eventstatusname
        , es.eventid
        , es.eventshiftid
        , st.datecreated
        , date(es.datetimeoffsetbegin) as datetimeoff
        , current_timestamp AT TIME ZONE 'PST' as time
        , st.datemodified as modtime
      from van.tsm_nextgen_eventsignups es
      left join van.tsm_nextgen_eventsignupsstatuses st using(eventsignupid)
      left join van.tsm_nextgen_events ev using(eventid)
      where date(es.datetimeoffsetbegin) between date('2019-01-01') and date('2020-11-03')
        and es.datesuppressed is null
        and ev.datesuppressed is null
        and committeename != 'NTI'
    ) a 
  ) b
  where row = 1
and eventrolename in ('Data Entry/ Admin/ Other', 'Volunteer') and eventstatusname='Completed'
