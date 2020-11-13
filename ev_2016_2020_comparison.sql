select -1*(days_until_e_day) as days_until_election
      , sum(voted_by_mail_2020) over (order by days_until_e_day desc rows between unbounded preceding and current row) as total_VBM_2020
      , sum(voted_by_mail_2016) over (order by days_until_e_day desc rows between unbounded preceding and current row) as total_VBM_2016
      , sum(early_voted_2020) over (order by days_until_e_day desc rows between unbounded preceding and current row) as total_EV_2020
      , sum(early_voted_2016) over (order by days_until_e_day desc rows between unbounded preceding and current row) as total_EV_2016     
from (
        select d.days_until_e_day, sum(voted_by_mail_2020) as voted_by_mail_2020, sum(voted_by_mail_2016) as voted_by_mail_2016, sum(early_voted_2020) as early_voted_2020, sum(early_voted_2016) as early_voted_2016
        from kgardner.e2016_dates D
        left join (
                select days_until_e_day, count(case when date_ballot_received is not null then 1 else null end) as voted_by_mail_2020
                from kgardner.ballots_received
           group by days_until_e_day
           order by days_until_e_day
                  ) a on d.days_until_e_day = a.days_until_e_day
        left join (
                select days_until_e_day, count(case when date_ballot_received is not null then 1 else null end) as voted_by_mail_2016
                from kgardner.ballots_received_2016
           group by days_until_e_day
           order by days_until_e_day
                  ) b on d.days_until_e_day = b.days_until_e_day
        left join (
                select days_until_e_day, count(case when date_early_voted is not null then 1 else null end) as early_voted_2020
                from kgardner.early_voted
           group by days_until_e_day
           order by days_until_e_day
                  ) c on d.days_until_e_day = c.days_until_e_day
        left join (
                select days_until_e_day, count(case when date_early_voted is not null then 1 else null end) as early_voted_2016
                from kgardner.early_voted_2016
           group by days_until_e_day
           order by days_until_e_day
                  ) e on d.days_until_e_day = e.days_until_e_day
        group by d.days_until_e_day
        order by d.days_until_e_day
    )
where days_until_election >= -60
and days_until_election <= (datediff(day, date('2020-11-03'), date(current_timestamp)))
order by days_until_election asc
