-- Creating database
create database music_database;

-- Command that we are going to project in our query
use music_database;

-- To see the data in the album file
select * from invoice;

-- To make it safe for updates
set sql_safe_updates =0;

-- Q-1 Who is the senior most employee as per the job title
select * from employee 
order by levels desc limit 1;

-- Q-2 Which country have the most invoices
select billing_country, count(*) as max_invoice_counts from invoice
group by billing_country 
order by max_invoice_counts desc limit 1;

-- Q-3 What are top 3 values of total invoice
select * from invoice 
order by total desc limit 3;

-- Q-4 Which city has the highest sum invoices in total. Return the city name and sum of invoices in total
select billing_city, sum(total) as total_invoice from invoice
group by billing_city
order by total_invoice desc limit 1;

-- Q-5 Who is the best person who has spent the most money
select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as invoice_total from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id, customer.first_name, customer.last_name
order by invoice_total desc limit 1;

-- Q-6 Write a query to return email, first name, last name and genre of all the rock music listeners. Return the list ordered alphabetically
-- by email starting with a
select distinct email, first_name, last_name, genre.name from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
order by email;

-- Q-7 Lets invite the artist who have written the most rock music in our dataset. Write a query to return the artist name and total track
-- count of the top 10 rock bands
select artist.artist_id, artist.name, count(track.track_id) as number_of_songs from track
join album ON album.album_id = track.album_id
join artist ON artist.artist_id = album.artist_id
join genre ON genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id, artist.name
order by number_of_songs desc limit 10;

-- Q-8 Return all the track names that have a song length longer than the average song length. Return the name and milliseconds for each track
-- Order by the song length with the longest song listed first
select name, milliseconds from track
where milliseconds > (select avg(milliseconds) as avg_track_length from track)
order by milliseconds desc;

-- Q-9 Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

-- Update invoice_line total price column by multiplying unit_price and quantity
alter table invoice_line add column total_price int;
update invoice_line set total_price = unit_price * quantity;
select * from invoice_line;

with best_selling_artist as (
select artist.artist_id as artist_id, artist.name as artist_name,
sum(total_price) as total_price from invoice_line
join track on track.track_id = invoice_line.track_id
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
group by 1
order by 3 desc limit 1
)
select c.first_name, c.last_name, a.name, sum(il.total_price) as total_spent from invoice_line il
join invoice i on i.invoice_id = il.invoice_id
join track t on t.track_id = il.track_id
join album al on al.album_id = t.track_id
join artist a on a.artist_id = al.artist_id
join customer c on c.customer_id = i.customer_id
group by c.first_name, c.last_name, a.name
order by total_spent desc;

-- Q-10 We want to find out the most popular music genre for each country. We determine the most popular genre as the genre with the highest
-- amount of purchases. Write a query to return each country along with the top genre. For countries where the maximum number of purchases
-- is shared return all genres
WITH popular_genre AS (
  SELECT COUNT(invoice_line.quantity) AS purchases, customer.customer_id, genre.name, genre.genre_id, customer.country,
    ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS row_num
  FROM invoice_line
  JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
  JOIN customer ON customer.customer_id = invoice.customer_id
  JOIN track ON track.track_id = invoice_line.track_id
  JOIN genre ON genre.genre_id = track.genre_id
  GROUP BY customer.customer_id, genre.name, genre.genre_id, customer.country
  order by customer.customer_id asc, 1 desc
)
SELECT *
FROM popular_genre
WHERE row_num <= 1;









