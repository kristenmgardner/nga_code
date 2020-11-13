select -1*(days_until_e_day)
      , sum(voted_by_mail) over (order by date asc rows between unbounded preceding and current row) as total_votes_by_mail
      , sum(early_voted) over (order by date asc rows between unbounded preceding and current row) as total_early_votes
from (
        select d.date, d.days_until_e_day, sum(voted_by_mail) as voted_by_mail, sum(early_voted) as early_voted
        from kgardner.days_to_election d
        left join (
                select date, count(case when date_ballot_received is not null then 1 else null end) as voted_by_mail
                from kgardner.ballots_received
           group by date
           order by date
                  ) b on d.date = b.date
        left join (
                select date, count(case when date_early_voted is not null then 1 else null end) as early_voted
                from kgardner.early_voted
           group by date
           order by date
                  ) c on d.date = c.date
        where d.date >= date('2020-08-31') and d.date <= current_timestamp
        group by d.date, d.days_until_e_day
        order by d.date, d.days_until_e_day
    )
order by days_until_e_day desc
