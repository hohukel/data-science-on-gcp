select *
from flights.streaming_delays
where airport='DEN'
order by timestamp desc
