/*=========================================================
        RIDE-HAILING ANALYTICS SQL PROJECT
===========================================================

Database  : SQL Server
Tools     : SQL Server Management Studio (SSMS)
Dataset   : Ride-Hailing Dataset (50,000 Records)

Project Objective:
Analyze ride-hailing data using SQL to generate business
insights such as revenue analysis, customer trends,
payment methods, route performance, and ride statistics.

=========================================================*/
/*---------------------------------------------------------
1. DATABASE CREATION
-----------------------------------------------------------
Creating a new database to store the ride-hailing dataset.

*/

CREATE DATABASE Rides_Analytics;


/*---------------------------------------------------------
The USE command selects the database so that all
subsequent tables and queries are executed inside it.
---------------------------------------------------------*/

USE Rides_Analytics;

/*---------------------------------------------------------
2. TABLE CREATION
-----------------------------------------------------------

Creating the rides_data table with appropriate data types
to store ride details such as fare, distance, payment
method, service type, source, destination and timestamps.

*/
CREATE TABLE rides_data
(
    services VARCHAR(30),
    [date] DATE,
    [time] TIME,
    ride_status VARCHAR(20),
    source VARCHAR(100),
    destination VARCHAR(100),
    duration INT,
    ride_id VARCHAR(25) PRIMARY KEY,
    distance DECIMAL(6,2),
    ride_charge DECIMAL(10,2),
    misc_charge DECIMAL(10,2),
    total_fare DECIMAL(10,2),
    payment_method VARCHAR(30)
);

/*---------------------------------------------------------
3. DATA IMPORT
-----------------------------------------------------------
Import the CSV dataset into SQL Server using BULK INSERT.

This loads all ride records into the rides_data table for
analysis.

*/
BULK INSERT rides_data
FROM 'D:\SQL Project\SQL_Project_Level3_(Service_Sector)\rides_data.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);

/*---------------------------------------------------------
4. VERIFY DATA
-----------------------------------------------------------
Check whether the dataset has been imported successfully.

*/

Select * from rides_data;


/*=========================================================
ANALYSIS
=========================================================
Perform  exploratory analysis using aggregate
functions, filtering, sorting and grouping.

*/

/*---------------------------------------------------------
Find the total number of rides completed.
---------------------------------------------------------*/
SELECT COUNT(*) AS total_rides 
FROM rides_data ;

/*---------------------------------------------------------
Display the first 10 records to understand the
structure and contents of the dataset.
---------------------------------------------------------*/
SELECT TOP 10 *
FROM rides_data;
/*---------------------------------------------------------
Display all unique service types available.
---------------------------------------------------------*/
SELECT DISTINCT services
AS Services_offered
FROM rides_data;

/*---------------------------------------------------------
Check for missing values in the total_fare column
to assess data quality.
---------------------------------------------------------*/
SELECT *  FROM rides_data
WHERE total_fare IS NULL ; 

/*---------------------------------------------------------
Calculate the average distance travelled per ride.
---------------------------------------------------------*/
SELECT AVG(distance)
AS Average_Distance
from rides_data  ;

/*---------------------------------------------------------
Calculate the total revenue generated from all rides.
---------------------------------------------------------*/
SELECT SUM(total_fare)
AS Total_revenue
FROM rides_data;
/*---------------------------------------------------------
Count the number of rides for each payment method
to understand customer payment preferences.
---------------------------------------------------------*/
SELECT payment_method, 
COUNT(*) AS total_rides
FROM rides_data
GROUP BY payment_method
ORDER BY total_rides DESC;


/*---------------------------------------------------------
Calculate the total number of successfully
completed rides.
---------------------------------------------------------*/
SELECT COUNT(*) 
AS completed_rides
FROM rides_data
WHERE ride_status = 'completed';


/*---------------------------------------------------------
Identify the ride(s) with the maximum trip duration.
---------------------------------------------------------*/
SELECT *
FROM rides_data
WHERE duration = 
(SELECT MAX(duration) from rides_data);


/*---------------------------------------------------------
Identify the ride(s) with the highest total fare.
---------------------------------------------------------*/
SELECT * 
FROM rides_data
WHERE total_fare = 
(SELECT MAX (total_fare) FROM rides_data);


/*---------------------------------------------------------
Calculate the total number of rides completed
on each day.
---------------------------------------------------------*/
SELECT [date] ,
count(*) AS total_rides_per_day 
FROM rides_data
GROUP BY [date] ;


/*---------------------------------------------------------
Retrieve rides where the travelled distance
exceeds 30 kilometres.
---------------------------------------------------------*/
SELECT * 
FROM rides_data
WHERE distance > 30;


/*---------------------------------------------------------
Calculate total revenue generated by each
ride service type.
---------------------------------------------------------*/
SELECT services,
SUM(total_fare) AS total_revenue
FROM rides_data
GROUP BY services
ORDER BY total_revenue DESC;



/*---------------------------------------------------------
Calculate the average fare charged per kilometre
for each service type.
---------------------------------------------------------*/
SELECT services,
AVG(total_fare/distance) AS average_fare_km 
FROM rides_data
GROUP BY services;


/*---------------------------------------------------------
Identify the busiest hours of the day based on
ride volume.
---------------------------------------------------------*/
SELECT DATEPART(HOUR,[time]) AS hour_of_day,
COUNT(*) as total_rides
FROM rides_data
GROUP BY DATEPART(HOUR,[time])
order by total_rides DESC;


/*---------------------------------------------------------
Count the total number of rides between each
source and destination pair.
---------------------------------------------------------*/
SELECT source,destination,
COUNT(*) AS total_rides 
FROM rides_data
GROUP BY source,destination
ORDER BY total_rides DESC;



/*---------------------------------------------------------
Calculate total revenue by service type for
performance comparison.
---------------------------------------------------------*/
SELECT services,
SUM(total_fare) AS revenue
FROM rides_data
GROUP BY services
ORDER BY revenue DESC;

/*---------------------------------------------------------
Rank service types based on total revenue
using the DENSE_RANK() window function.
---------------------------------------------------------*/
SELECT services,
SUM(total_fare) AS revenue,
DENSE_RANK()
OVER(ORDER BY SUM(total_fare) DESC) AS revenue_rank
FROM rides_data 
GROUP BY services;



/*---------------------------------------------------------
Analyze payment method usage across different
ride service types.
---------------------------------------------------------*/
SELECT services,payment_method,
COUNT(*) AS total_rides
FROM rides_data
GROUP BY services,payment_method
ORDER BY total_rides DESC;


/*---------------------------------------------------------
Determine peak operating hours based on
ride frequency.
---------------------------------------------------------*/

SELECT 
DATEPART(HOUR,[time]) as Peak_Hour,
COUNT(*) AS total_rides
FROM rides_data
GROUP BY DATEPART(HOUR,[time])
ORDER BY total_rides DESC;



/*---------------------------------------------------------
Calculate the average ride duration for each
service category.
---------------------------------------------------------*/
SELECT services,
AVG(duration) AS Avg_duration
FROM  rides_data
GROUP BY services
ORDER BY Avg_duration DESC;


/*---------------------------------------------------------
Retrieve rides where miscellaneous charges are
higher than the overall average miscellaneous charge.
---------------------------------------------------------*/

SELECT * 
FROM rides_data
WHERE misc_charge >
(SELECT AVG(misc_charge) FROM rides_data)
ORDER BY misc_charge DESC;


/*---------------------------------------------------------
Create a SQL View containing only completed rides
for simplified reporting and analysis.
---------------------------------------------------------*/

CREATE VIEW completed_rides AS
SELECT * FROM rides_data
WHERE ride_status = 'completed';
SELECT * FROM completed_rides;



/*---------------------------------------------------------
Use a Common Table Expression (CTE) to calculate
route-wise revenue for better readability
and modular query design.
---------------------------------------------------------*/

WITH Route_profitability AS
(SELECT source,destination,
SUM(total_fare) AS total_revenue
FROM rides_data
GROUP BY source,destination)

SELECT * FROM Route_profitability ORDER BY total_revenue DESC;



/*---------------------------------------------------------
Rank routes based on total revenue generated
using DENSE_RANK().
---------------------------------------------------------*/

SELECT source,destination,
SUM(total_fare) AS total_revenue,
DENSE_RANK() 
OVER (ORDER BY SUM	(total_fare) DESC) 
AS revenue_rank
FROM rides_data
GROUP BY source,destination;




/*---------------------------------------------------------
Perform monthly revenue trend analysis using
YEAR() and MONTH() functions.
---------------------------------------------------------*/
SELECT YEAR(date) AS year_no,
MONTH(date) AS month_number,
SUM(total_fare) AS revenue
FROM rides_data
GROUP BY YEAR(date),MONTH(date)
ORDER BY year_no,month_number;




/*---------------------------------------------------------
Identify high-value routes by ranking them
according to total revenue generated.
---------------------------------------------------------*/
SELECT source,
destination,
SUM(total_fare)AS revenue,
DENSE_RANK()
OVER(ORDER BY SUM(total_fare) DESC )
AS revenue_rank
FROM rides_data
GROUP BY source,destination
ORDER BY revenue_rank;




/*---------------------------------------------------------
Create a View for route performance reporting.

Note:
SQL Server does not natively support Materialized
Views. A standard View is created to simplify
reporting queries.

---------------------------------------------------------*/
CREATE VIEW Performance_reporting AS
SELECT source,destination,SUM(total_fare) AS revenue
FROM rides_data
GROUP BY source,destination;
SELECT * FROM Performance_reporting;

