-- Total number of unique volunteers --
SELECT count(distinct vanid)
FROM ( 
    select a.vanid
        , A.eventroleid
        , eventrolename
        , B.eventstatusname
        , D.eventid
  		, D.createdbycommitteename
        , date(A.datetimeoffsetbegin) as datetimeoff 
    from van.tsm_nextgen_eventsignups A
    LEFT JOIN van.tsm_nextgen_eventsignupsstatuses B ON (A.eventsignupid = B.eventsignupid)
    LEFT JOIN van.tsm_nextgen_events D ON (A.eventid = D.eventid)
     )
where date (datetimeoff)>=date('2020-08-15')
and createdbycommitteename = 'NextGen America Distributed'
and eventrolename in ('Data Entry/ Admin/ Other', 'Volunteer') 
and eventstatusname = 'Completed'

-- Total number of unique volunteer shifts -- 
SELECT count(unique_shifts)
FROM (
    select distinct a.vanid
        , A.eventroleid
        , B.eventstatusname
        , D.eventid
        , A.eventshiftid
  		, D.createdbycommitteename
        , date(A.datetimeoffsetbegin) as datetimeoff 
        , A.vanid || D.eventid || A.eventroleid || A.eventshiftid as unique_shifts
    from van.tsm_nextgen_eventsignups A
    LEFT JOIN van.tsm_nextgen_eventsignupsstatuses B ON (A.eventsignupid = B.eventsignupid)
    LEFT JOIN van.tsm_nextgen_events D ON (A.eventid = D.eventid)
    where date (datetimeoff)>=date('2020-08-15')
        and createdbycommitteename = 'NextGen America Distributed'
        and eventstatusname = 'Completed'
   -- to distinguish between text/phone add 'and eventcalendarid = xyz' --
     )
     
 -- Total number unique conversations (texts) --
SELECT count(*)
FROM ( 
     SELECT *
           , row_number() over (partition by conversation_id order by ttimestamp asc) as msg_row
           , split_part(import_source,'/',1) as committee
     FROM thrutext.messages   
      )
WHERE msg_row = 1
and committee = 'nextgen' and ttimestamp >= date('2020-08-15')
