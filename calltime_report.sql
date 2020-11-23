-- Calltime report example: SQL export to google sheets --

select *
FROM (select current_timestamp at time zone 'EST' as last_updated_et
        , type
        , vantype
        , datecanvassed
        , attempts
        , canvassed
        , left (case when attempts = 0 then 0 
              else
            (canvassed*100)::decimal / (attempts)::decimal 
            end,4)||'%' as rate
from (
  select vantype
, datecanvassed
, case when (username not ilike '%relay%' or username is null) then 'VPB' else 'Dialer' end as type
, count(distinct vanid) as attempts
, count(distinct case when resultid = 14 then vanid else null end) as canvassed
from (
            select vanid
            , datecanvassed
            , contacttypeid
            , committeeid
            , resultid
            , username
            , 'EA' as vantype
            from van.tsm_nextgen_contactscontacts_mym
            where contacttypeid = 1 and committeeid = 85292
                union
            select vanid
            , datecanvassed
            , contacttypeid
            , committeeid
            , resultid
            , username
            , 'MyV' as vantype
            from van.tsm_nextgen_contactscontacts_vf)
            where contacttypeid = 1 and committeeid = 85292
group by 1,2)
)
order by last_updated_et
