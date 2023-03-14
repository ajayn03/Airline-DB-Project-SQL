--1. How many flights from ‘DME’ airport don’t have actual departure?

select departure_airport, COUNT(*)
from bookings.flights 
where departure_airport = 'DME' and actual_departure is null
group by 1

--2. Identify flight ids having range between 3000 to 6000

select 
distinct(f.flight_no), a.aircraft_code, a.range
from bookings.aircrafts a 
join bookings.flights f 
on a.aircraft_code=f.aircraft_code
where a.range between '3000' and '6000'

--3. Write a query to get the count of flights flying between URS and KUF?

select 
count (*)
from flights
where departure_airport = 'URS' and arrival_airport = 'KUF'

--4. Write a query to get the count of flights flying from either from NOZ or KRR?

select 
count (*)
from flights
where departure_airport in ('NOZ','KRR')  

--5. Find out the name of the airport having least number of scheduled departure flights
--Expected output: airport_name

select airport_name 
from (select a.airport_name, count(*)from flights f 
join airports a
on a.airport_code=f.departure_airport
group by 1 
order by 2 asc) as x
limit 1

--6. Find out the name of the airport having maximum number of departure flight

 select airport_name 
from (select a.airport_name, count(*)from flights f 
join airports a
on a.airport_code=f.departure_airport
group by 1 
order by 2 desc) as x
limit 1

--7. Write a query to get the count of flights flying from KZN, DME, NBC,NJC,GDX,SGC,VKO,ROV

select 
departure_airport,
count (*)
from BOOKINGS.flights
where departure_airport IN ('KZN', 'DME', 'NBC','NJC','GDX','SGC','VKO','ROV')
GROUP BY 1

--8. Write a query to extract flight details having range between 3000 and 6000 and flying from DME

select 
F.FLIGHT_NO, A.AIRCRAFT_CODE , A.RANGE, F.DEPARTURE_AIRPORT
FROM BOOKINGS.FLIGHTS F 
JOIN BOOKINGS.AIRCRAFTS A 
ON F.AIRCRAFT_CODE=A.AIRCRAFT_CODE
WHERE DEPARTURE_AIRPORT = 'DME' AND RANGE BETWEEN '3000' AND '6000'

--9. Find the list of flight ids which are using aircrafts from “Airbus” company and got cancelled or delayed

select 
f.flight_id,a.model   
from bookings.flights f 
join bookings.aircrafts a 
on f.aircraft_code = a.aircraft_code
where f.status in ('Cancelled','Delayed') and a.model like ('%Airbus%')

--10. Find the list of flight ids which are using aircrafts from “Boeing” company and got cancelled or delayed

select 
f.flight_id,a.model   
from bookings.flights f 
join bookings.aircrafts a 
on f.aircraft_code = a.aircraft_code
where f.status in ('Cancelled','Delayed') and a.model like ('%Boeing%')


--11. Which airport(name) has most cancelled flights (arriving)?

WITH cancelled_details as
(SELECT airport_name::json->> 'en' as airport_name, 
count(*) as cancelled_flight 
FROM bookings.flights f 
JOIN bookings.airports_data a 
ON f.arrival_airport=a.airport_code 
WHERE status='Cancelled' GROUP BY 1) 
SELECT airport_name FROM cancelled_details 
WHERE cancelled_flight=(SELECT MAX(cancelled_flight) FROM cancelled_details)

--12. Identify flight ids which are using “Airbus aircrafts”

select
f.flight_id, a.model
from flights f 
join aircrafts a 
on f.aircraft_code=a.aircraft_code
where model like ('%Air%')

--13. Identify date-wise last flight id flying from every airport?

Select
flight_id, flight_no, 
scheduled_departure, scheduled_arrival,departure_airport 
from (select *,
Rank()over(partition by departure_airport order by scheduled_departure desc ) 
from bookings.flights ) as time 
where rank = 1

--14. Identify list of customers who will get the refund due to cancellation of the flights? And how much amount they will get?

SELECT
passenger_name,SUM(total_amount) as total_refund
FROM bookings.flights f
LEFT JOIN
bookings.boarding_passes bp ON bp.flight_id=f.flight_id
LEFT JOIN
bookings.tickets ti ON ti.ticket_no=bp.ticket_no
LEFT JOIN
bookings.bookings b ON b.book_ref=ti.book_ref
WHERE status='Cancelled'
GROUP BY passenger_name,total_amount,f.flight_id

--15. Identify date wise first cancelled flight id flying for every airport?

select 
flight_id, flight_no, scheduled_departure, 
scheduled_arrival,departure_airport 
from (select *, 
Rank()over(partition by departure_airport order by scheduled_departure ) 
from bookings.flights 
where status='Cancelled') as time 
where rank = 1

--16. Identify list of Airbus flight ids which got cancelled.

select
flight_id
from (select flight_id from bookings.aircrafts_data a 
join bookings.flights f 
on a.aircraft_code = f. aircraft_code
where f.status='Cancelled' and model::json->> 'en' like  '%Air%') as flight_id

--17. Identify list of flight ids having highest range.

Select
flight_no, max(range) as highest_range
from bookings.aircrafts_data ad
join bookings.flights f
on f.aircraft_code = ad.aircraft_code
where range = (select max(range) from bookings.aircrafts_data)
group by flight_no


