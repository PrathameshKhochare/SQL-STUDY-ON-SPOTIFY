CREATE table activity
(
user_id varchar(20),
event_name varchar(20),
event_date date,
country varchar(20)
);
----------------------------------
delete from activity;
----------------------------
insert into activity values
(1,'app-installed','2022-01-01','India'),
(1,'app-purchase','2022-01-02','India'),
(2,'app-installed','2022-01-01','USA'),
(3,'app-installed','2022-01-01','USA'),
(3,'app-purchase','2022-01-03','USA'),
(4,'app-installed','2022-01-03','India'),
(4,'app-purchase','2022-01-03','India'),
(5,'app-installed','2022-01-03','SL'),
(5,'app-purchase','2022-01-03','SL'),
(6,'app-installed','2022-01-04','Pakistan'),
(6,'app-purchase','2022-01-04','Pakistan');

----------------------
select * from activity

--Q1.: Find the total active users each day (difficulty level : easy)----
Ans-
select extract(day from event_date) as day_ ,count(distinct user_id) as total_users
from activity
group by extract(day from event_date)
order by day_

---other way ---------
select event_date,count(distinct user_id) as total_users
from activity
group by event_date
--------------------
--Q2 : Find the total active users each week (difficulty level : easy)---
Ans. -
select *, extract(week from event_date) as week_ from activity

select extract(week from event_date) as week_ ,count(distinct user_id) as total_users
from activity
group by week_


--------------
---Q3 :Find the datewise total number of users who made the purchase, the same day they installed the app
(difficulty level : medium)    ---
Ans-

with cte as
(
select user_id,event_date,
  case when count(distinct event_name) = 2  then user_id
   else null
   end as new_user
from activity
group by user_id,event_date
)
select event_date,count(new_user) as total
from cte
group by event_date
order by event_date
--------------
---Q4 : Percentage of paid users in India, USA and other countries where countries other than India and USA
--are tagged as Others.
(difficulty level : medium)
Ans-

with cte1 as
(
select count(distinct user_id) as total ,
	case when country = 'India' then country
	when country = 'USA' then country
	else 'other'
	end as country_name
from activity
where event_name = 'app-purchase'
group by country_name
),
cte2 as
(
select sum(total) as totals_ from cte1
)
select * , round((total/totals_)*100,2) as percentage_paid_users
from cte1,cte2;
----------------
Q5 :Among all the users who installed the app on any given day, how many did in app purchase on the very 
next day (give daywise result)
(difficulty level - hard)
Ans-
					
with prev_date as
(
select * ,
lag(event_name,1) over(partition by user_id order by event_date) as prev_event_name,
lag(event_date,1) over(partition by user_id order by event_date) as prev_event_date
from activity		
)
select event_date, count(distinct user_id) as final_user_id
from prev_date
where event_name ='app-purchase' and prev_event_name = 'app-installed' and ((extract (day from event_date)) - (extract (day from prev_event_date)))=1
group by event_date

--------------------other way------------
select a.event_date,count(b.user_id) as next_day_purchase 
from activity a left join activity b
on a.user_id=b.user_id
and a.event_date-b.event_date=1
group by a.event_date
order by 1

  