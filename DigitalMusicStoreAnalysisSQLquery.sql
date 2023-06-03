/*1. What are the different genres of music available in the store? */

select name 
from [MusicStoreAnalysis].[dbo].[genre];


/*2.How many albums does the store have in its collection? */

select count(*) as TotalAlbum  
from [MusicStoreAnalysis].[dbo].[album];

/*3.Which artists are featured in the music store? */

select name from [MusicStoreAnalysis].[dbo].[artist];

/*4.What are the top-selling tracks in terms of quantity? */

select name,sum(quantity) as TotalQuantity 
from [MusicStoreAnalysis].[dbo].[track$]
join [MusicStoreAnalysis].[dbo].[invoice_line$] 
on invoice_line$.track_id=track$.track_id
group by name 
order by TotalQuantity desc;

/*5.What are total revenue genarated by the store? */

select sum(unit_price * quantity) as TotalRevenue from [MusicStoreAnalysis].[dbo].[invoice_line$];

/*6.how many customers have made purchases? */
 select COUNT(Distinct(Customer_id)) as TotalCustomers
 from [MusicStoreAnalysis].[dbo].[customer];


/*7. what is the average number of tracks per album? */

select Avg(TrackCount) as AvgTrackCount
from
(select album_id,Count(*) as TrackCount 
from [MusicStoreAnalysis].[dbo].[track$] 
group by album_id) as p;

/*8.Which Country has the highest number of customers? */

select Top 1 billing_country,count(distinct(customer_id)) as CustomerCount 
from [MusicStoreAnalysis].[dbo].[invoice]
group by billing_country
order by CustomerCount desc;

/*9.What is the average price of a track in the store? */
select Avg(unit_price) as AverageTrackPrice
from [MusicStoreAnalysis].[dbo].[track$] ;


/*10.How many tracks are there in each genre ? */

select genre.name,Count(*) as TrackCount
from [MusicStoreAnalysis].[dbo].[track$] join [MusicStoreAnalysis].[dbo].[genre]
on track$.genre_id = genre.genre_id
group by genre.name;









/*1. Who is the senior most employee based on job title?*/

select * from [MusicStoreAnalysis].[dbo].[employee]
where levels = ( select max(levels) from [MusicStoreAnalysis].[dbo].[employee]);

select top 1 * from [MusicStoreAnalysis].[dbo].[employee]
order by levels desc;

/*2.which countries have the most invoices?*/

select billing_country,count(*) as invoiceCount
from [MusicStoreAnalysis].[dbo].[invoice]
group by billing_country
order by invoiceCount desc;


/*3.what are top 3 values of total invoice?*/

select top 3 billing_country,count(*) as invoiceCount  from [MusicStoreAnalysis].[dbo].[invoice]
group by billing_country
order by invoiceCount desc;


/*4.Which city has the best customers? We would like to throw a promotional music festival in the city we have made the most money? Write a query that returns one city that has the highest sum of invoice totals.
Returns both city name & sum of all invoice total?*/

SELECT top 1 billing_city,billing_country,SUM(total) AS InvoiceTotal
FROM [MusicStoreAnalysis].[dbo].[invoice]
GROUP BY billing_city,billing_country
ORDER BY InvoiceTotal DESC;



/*5.Who is the best customer? The customer who has spent most money will be declared best customer,Write a query to find the person who spent money?*/

SELECT top 1 customer.customer_id, SUM(total) AS total_spending
FROM [MusicStoreAnalysis].[dbo].[customer]
JOIN [MusicStoreAnalysis].[dbo].[invoice] ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC;

/*6.write a query to return the email,first_name,last name ,Genre of all rock music listeners. 
Return your list ordered alphanatically by email starting with A.*/

SELECT DISTINCT(email) AS Email,first_name AS FirstName, last_name AS LastName, genre.name AS Name
FROM [MusicStoreAnalysis].[dbo].[customer]
JOIN [MusicStoreAnalysis].[dbo].[invoice] ON invoice.customer_id = customer.customer_id
JOIN [MusicStoreAnalysis].[dbo].[invoice_line$] ON invoice_line$.invoice_id = invoice.invoice_id
JOIN [MusicStoreAnalysis].[dbo].[track$] ON track$.track_id = invoice_line$.track_id
JOIN [MusicStoreAnalysis].[dbo].[genre] ON genre.genre_id = track$.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;


/*7.Let invite the artists who have written the most rock music in our dataset.Write a query that returns the artist name,total track count of the top 10 rock bands.*/

SELECT top 10 artist.artist_id, COUNT(artist.artist_id) AS number_of_songs
FROM [MusicStoreAnalysis].[dbo].[track$]
JOIN [MusicStoreAnalysis].[dbo].[album] ON album.album_id = track$.album_id
JOIN [MusicStoreAnalysis].[dbo].[artist] ON artist.artist_id = album.artist_id
JOIN [MusicStoreAnalysis].[dbo].[genre] ON genre.genre_id = track$.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC;


/*8.Return all the track names that have a song lenght longer than the average song lenght.Return the name and milliseconds for each track.
Order by the song lenght with the longest songs listed first*/

SELECT name,milliseconds
FROM [MusicStoreAnalysis].[dbo].[track$]
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM [MusicStoreAnalysis].[dbo].[track$] )
ORDER BY milliseconds DESC;


/*9.Find how much amount spent by each customer on artists? Write a query to return customer name,artist name, total spent.*/

WITH CustomerSpending AS (
	SELECT artist.artist_id AS artist_id, artist.name,customer.first_name
	FROM [MusicStoreAnalysis].[dbo].[invoice_line$]
	JOIN [MusicStoreAnalysis].[dbo].[track$] ON track$.track_id = invoice_line$.track_id
	JOIN [MusicStoreAnalysis].[dbo].[album] ON album.album_id = track$.album_id
	JOIN [MusicStoreAnalysis].[dbo].[artist] ON artist.artist_id = album.artist_id
	GROUP BY 1
)


/*10.We want to find out the most popular music genre for each country.We determine the most popular genre vs the genre with the highest amount of purchases.
Write a query that returns each country along with the top genre.For Countries where the maximum number of purchases is shared return all genres  */
WITH popular_genre AS 
(
    SELECT COUNT(invoice_line$.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line$.quantity) DESC) AS RowNo 
    FROM [MusicStoreAnalysis].[dbo].[invoice_line$] 
	JOIN [MusicStoreAnalysis].[dbo].[invoice] ON invoice.invoice_id = invoice_line$.invoice_id
	JOIN [MusicStoreAnalysis].[dbo].[customer] ON customer.customer_id = invoice.customer_id
	JOIN [MusicStoreAnalysis].[dbo].[track$] ON track$.track_id = invoice_line$.track_id
	JOIN [MusicStoreAnalysis].[dbo].[genre] ON genre.genre_id = track$.genre_id
	GROUP BY 
)
SELECT * FROM popular_genre WHERE RowNo <= 1





/* 11.Write a query that determines the customer that has spent the most on music for each country.
Write a query that returns the country along with the top customer and how much they spent.
For countries where the top amount spent is shared,provide all customers who spent this amount.  */


WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM [MusicStoreAnalysis].[dbo].[invoice]
		JOIN [MusicStoreAnalysis].[dbo].[customer] ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1