select d.date, sum(voted_by_mail) as voted_by_mail, sum(early_voted) as early_voted
from kgardner.days_to_election d
left join (
        select date, count(date_ballot_received) as voted_by_mail
        from kgardner.ballots_received
        group by date
        order by date
          ) b on d.date = b.date
left join (
        select date, count(date_early_voted) as early_voted
        from kgardner.early_voted
        group by date
        order by date
          ) c on d.date = c.date
where d.date >= date('2020-09-01') and d.date <= current_timestamp
group by d.date
order by d.date
