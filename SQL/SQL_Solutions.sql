/* Welcome to the SQL mini project.

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.
I have downloaded these table locally and created mysql database and run following queries to get answers in Mysql workbench.

Attached exported schema as Exported_schema.sql

. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
SELECT name,membercost FROM springboard.facilities WHERE membercost = 0.0;


/* Q2: How many facilities do not charge a fee to members? */
SELECT count(name) from springboard.facilities WHERE membercost= 0.0;


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid,name,membercost,monthlymaintenance FROM springboard.facilities
WHERE (membercost> 0.0 AND membercost < 0.2*monthlymaintenance);

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT * FROM springboard.facilities WHERE FACID IN (1,5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name,
       monthlymaintenance,
       CASE WHEN monthlymaintenance > 100 THEN 'expensive'
            ELSE 'cheap' END AS is_expensive_or_cheap
  FROM springboard.facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */



SELECT surname, firstname FROM springboard.members WHERE memid = (SELECT MAX(memid) FROM springboard.members);



/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT fac.name ,CONCAT(mem.firstname," ", mem.surname) full_name FROM springboard.facilities fac,springboard.members mem,springboard.bookings bkng
WHERE bkng.facid = fac.facid AND bkng.memid = mem.memid ORDER BY fac.name;


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT concat(mem.firstname,' ',mem.surname) AS member,
       fac.name AS facility,
       (CASE WHEN mem.memid = 0 THEN fac.guestcost * bkng.slots
        ELSE fac.membercost * bkng.slots END) AS cost
FROM springboard.bookings AS bkng, 
springboard.facilities AS fac,springboard.members AS mem
WHERE bkng.facid = fac.facid AND bkng.memid = mem.memid AND starttime LIKE '2012-09-14%' 
AND
((mem.memid = 0 AND bkng.slots * fac.guestcost > 30) OR
  (mem.memid > 0 AND bkng.slots * fac.membercost > 30))
ORDER BY cost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT member, facility, cost from (
  SELECT
  concat(mem.firstname,' ',mem.surname) AS member,
  fac.name as facility,
  CASE WHEN mem.memid = 0 THEN bkng.slots * fac.guestcost
  ELSE bkng.slots * fac.membercost END AS cost
  FROM springboard.bookings AS bkng, 
springboard.facilities AS fac,springboard.members AS mem
WHERE bkng.facid = fac.facid AND bkng.memid = mem.memid AND starttime LIKE '2012-09-14%' 
) as bookings
WHERE cost > 30
ORDER BY cost DESC;
  

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT fac.name,SUM(bkng.slots*(CASE WHEN bkng.memid=0 THEN fac.guestcost ELSE fac.membercost END))AS revenue
FROM springboard.facilities fac,springboard.members mem,
springboard.bookings bkng WHERE bkng.facid = fac.facid AND bkng.memid = mem.memid
GROUP BY fac.name HAVING  SUM(bkng.slots*(CASE WHEN bkng.memid=0 THEN fac.guestcost ELSE fac.membercost END))<1000
ORDER BY revenue;

  


