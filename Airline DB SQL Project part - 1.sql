--1.Represent the “book_date” column in “yyyy-MMM-dd”. User Bookings table 

select 
book_ref,
to_char(book_date,'yyyy-MON-dd') book_date ,
total_amount
from bookings.bookings	

--2.Create a table having ticket_no, boarding_no, seat_number, passenger_id, passenger_name.

select 
t.ticket_no, bp.boarding_no, bp.seat_no,
t.passenger_id, t.passenger_name
from bookings.tickets t 
full outer join bookings.boarding_passes bp 
on t.ticket_no = bp.ticket_no

--3. Which seat number is least allocated among all the seats?

select 
seat_no , count(*)
from bookings.boarding_passes
group by  1
order by 2
limit 1

--4. In the database, identify the month wise highest paying passenger name and passenger id

select 
	to_char(B.book_date,'Mon-dd') month_name,
	t.passenger_id , 
	t.passenger_name,
	sum (b.total_amount) amount 
from bookings.bookings B 
FULL OUTER JOIN bookings.tickets T
on b.book_ref = t.book_ref
  group by 1 ,2, 3 
  ORDER BY 4 DESC
  

--5. In the database, identify the month wise least paying passenger name and passenger id?

select 
	to_char(B.book_date,'Mon-dd') month_name,
	t.passenger_id , 
	t.passenger_name,
	sum (b.total_amount) amount 
from bookings.bookings B
JOIN bookings.tickets T
on b.book_ref = t.book_ref
  group by 1 ,2, 3
  ORDER BY 4 asc

--6. Identify the travel details of non no stop journeys  or return journeys (having more than 1 flight).

select
	t.passenger_id , t.passenger_name,
	t.ticket_no, 
	count(tf.flight_id) flight_count 
from bookings.tickets t
full outer join bookings.ticket_flights tf 
on t.ticket_no = tf.ticket_no
group by 1,2,3
having  count( tf.flight_id) > 1
order by 4 desc 

--7. How many tickets are there without boarding passes?

select 
count(t.ticket_no)
from bookings.tickets t 
left join bookings.boarding_passes b 
on t.ticket_no = b.ticket_no
group by  boarding_no
having boarding_no is null 

--8. Identify details of the longest flight (using flights table) ?

Select
 flight_no,
 ( select 
max(scheduled_arrival-scheduled_departure) as timeings
from bookings.flights ) 
from bookings.flights 
group by 1 

--9. Categorize flights using following logic (using flights table)  :
--		a.Early morning flights: 2 AM to 6AM
--	  	b.Morning flights: 6 AM to 11 AM
--		c.Noon flights: 11 AM to 4 PM
--		d.Evening flights: 4 PM to 7 PM
--		e.Night flights: 7 PM to 11 PM 
--		f.Late Night flights: 11 PM to 2 AM

select 
flight_id ,flight_no , scheduled_departure,scheduled_arrival,
case when to_char(scheduled_departure, 'HH24:MI') BETWEEN '02:00' AND '06:00' THEN 'EARLY_MORNING_FLIGHT'
     when to_char(scheduled_departure, 'HH24:MI') BETWEEN '06:00' AND '11:00' THEN 'MORNING_FLIGHT'
     when to_char(scheduled_departure, 'HH24:MI') BETWEEN '11:00' AND '16:00' THEN 'NOON_FLIGHT'
     when to_char(scheduled_departure, 'HH24:MI') BETWEEN '16:00' AND '19:00' THEN 'EVENING_FLIGHT'
     when to_char(scheduled_departure, 'HH24:MI') BETWEEN '19:00' AND '23:00' THEN 'NIGHT_FLIGHT'
     ELSE 'LATE_NIGHT_FLIGHT' END AS TIMEINGS
FROM  BOOKINGS.FLIGHTS

 
--10.	Identify details of all the morning flights (morning means between 6AM to 11 AM, using flights table) ?

select 
flight_id ,flight_no , scheduled_departure,scheduled_arrival,
case when to_char(scheduled_departure, 'HH24:MI') BETWEEN '02:00' AND '06:00' THEN 'EARLY_MORNING_FLIGHT'
     when to_char(scheduled_departure, 'HH24:MI') BETWEEN '06:00' AND '11:00' THEN 'MORNING_FLIGHT'
     when to_char(scheduled_departure, 'HH24:MI') BETWEEN '11:00' AND '16:00' THEN 'NOON_FLIGHT'
     when to_char(scheduled_departure, 'HH24:MI') BETWEEN '16:00' AND '19:00' THEN 'EVENING_FLIGHT'
     when to_char(scheduled_departure, 'HH24:MI') BETWEEN '19:00' AND '23:00' THEN 'NIGHT_FLIGHT'
     ELSE 'LATE_NIGHT_FLIGHT' END AS TIMEINGS
FROM bookings.FLIGHTS
where to_char(scheduled_departure, 'HH24:MI') BETWEEN '06:00' AND '11:00'


--11. Identify the earliest morning flight available from every airport.

select flight_id , flight_no , scheduled_departure , scheduled_arrival, departure_airport,
case when to_char(scheduled_departure, 'HH24:MI') BETWEEN '02:00' AND '06:00' THEN 'EARLY_MORNING_FLIGHT'
     when to_char(scheduled_departure, 'HH24:MI') BETWEEN '06:00' AND '11:00' THEN 'MORNING_FLIGHT'
     when to_char(scheduled_departure, 'HH24:MI') BETWEEN '11:00' AND '16:00' THEN 'NOON_FLIGHT'
     when to_char(scheduled_departure, 'HH24:MI') BETWEEN '16:00' AND '19:00' THEN 'EVENING_FLIGHT'
     when to_char(scheduled_departure, 'HH24:MI') BETWEEN '19:00' AND '23:00' THEN 'NIGHT_FLIGHT'
     ELSE 'LATE_NIGHT_FLIGHT' END AS TIMEINGS
FROM (select * , 
 rank()over(partition by departure_airport order by scheduled_departure) 
 from bookings.flights) as t
 where to_char(scheduled_departure, 'HH24:MI') BETWEEN '06:00' AND '11:00' and rank = 1 
 
