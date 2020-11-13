SELECT createdbycommitteename
    , count(distinct case when eventrolename in ('Data Entry/ Admin/ Other', 'Volunteer') and eventstatusname in ('Scheduled', 'Walk-in', 'FB maybe', 'Sched web', 'Invited', 'Conf Twice','Confirmed', 'ConfThrice', 'FB going')
              then A.vanid||A.eventid||A.eventshiftid else null end) as total_open_shifts
  
FROM (
    select distinct A.vanid
      	, A.datetimeoffsetbegin
        , A.eventrolename
  		, A.eventroleid
        , B.eventstatusname
        , D.eventid
        , A.eventshiftid
  		, D.createdbycommitteename
  		, A.datetimeoffsetbegin
        , date(A.datetimeoffsetbegin) as datetimeoff
        , current_timestamp AT TIME ZONE 'PST' as time
        , A.datemodified as modtime  
        , row_number() over (partition by A.vanid || D.eventid || A.eventroleid || A.eventshiftid order by modtime desc, B.eventstatusname asc) as row
 
    from van.tsm_nextgen_eventsignups A
    LEFT JOIN van.tsm_nextgen_eventsignupsstatuses B ON (A.eventsignupid = B.eventsignupid)
    LEFT JOIN van.tsm_nextgen_contacts_mym C ON (A.vanid = C.vanid)
    LEFT JOIN van.tsm_nextgen_events D ON (A.eventid = D.eventid)
    where date (A.datetimeoffsetbegin)>=date('2020-08-23')
        and A.datesuppressed is null
        and D.datesuppressed is null
     ) a
Where row = 1
Group by createdbycommitteename;
