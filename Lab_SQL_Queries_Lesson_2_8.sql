-- Lab | SQL Queries - Lesson 2.8

-- 1. Write a query to display for each store its store ID, city, and country.
-- info is available in tables: store, address, city, country
SELECT s.store_id, city, country
FROM sakila.store s
INNER JOIN sakila.address a ON s.address_id = a.address_id
INNER JOIN sakila.city ci ON a.city_id = ci.city_id
INNER JOIN sakila.country co ON ci.country_id = co.country_id;

-- 2. Write a query to display how much business, in dollars, each store brought in.
-- info is available in tables: payment, store, staff 
SELECT sto.store_id, CONCAT('$',FORMAT(sum(amount),2,'en_US')) as amount
FROM sakila.payment p
INNER JOIN sakila.staff sta ON p.staff_id = sta.staff_id
INNER JOIN sakila.store sto ON sta.store_id = sto.store_id
GROUP BY sto.store_id;

-- 3. Which film categories are longest?
-- assumption what is meant: longest at an average per movie
-- info is available in tables: film, film_category, category
SELECT fc.category_id AS id, c.name AS Cat_name, ROUND(AVG(f.length),0) AS Duration
FROM sakila.film f
INNER JOIN sakila.film_category fc ON fc.film_id = f.film_id
INNER JOIN sakila.category c ON c.category_id = fc.category_id
GROUP BY fc.category_id
ORDER BY AVG(f.length) DESC
LIMIT 1;

-- 4. Display the most frequently rented movies in descending order.
-- info is available in tables: rental, inventory, film
SELECT i.film_id, title, COUNT(i.film_id) tot_rented
FROM sakila.rental r
INNER JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
INNER JOIN sakila.film f ON i.film_id = f.film_id
GROUP BY i.film_id
ORDER BY tot_rented DESC;

-- 5. List the top five genres in gross revenue in descending order.
-- Assumption: genres = categories, revenue = total amount paid
-- info is available in tables: payment, rental, inventory, film, film_category, category
SELECT fc.category_id, c.name, CONCAT('$',FORMAT(sum(amount),2,'en_US')) AS amount
FROM sakila.payment p
INNER JOIN sakila.rental r ON p.rental_id = r.rental_id
INNER JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
INNER JOIN sakila.film f ON i.film_id = f.film_id 
INNER JOIN sakila.film_category fc ON f.film_id = fc.film_id
INNER JOIN sakila.category c ON fc.category_id = c.category_id
GROUP BY fc.category_id
ORDER BY SUM(amount) DESC
;

-- 6. Is "Academy Dinosaur" available for rent from Store 1?
-- Interpretation: a rental transaction without return date (NULL) means:
-- item has not yet been returned by customer
-- info is available in tables: film, inventory, rental
SELECT f.title, i.inventory_id, r.rental_date, r.return_date
FROM sakila.film f
INNER JOIN sakila.inventory i ON f.film_id = i.film_id
INNER JOIN sakila.rental r ON i.inventory_id = r.inventory_id
WHERE f.title LIKE "Academy Dinosaur" AND store_id = 1    -- AND r.return_date is null
;
-- Answer: all return dates of this inventory item have a valid value 
-- so at this moment (but also in 2005) inventory items 1-4 are available

-- 7. Get all pairs of actors that worked together.
-- info is available in tables: film_actor (actor_id<> and film_id=)
SELECT fa1.film_id, fa1.actor_id AS pers1, fa2.actor_id AS pers2
FROM sakila.film_actor fa1
JOIN sakila.film_actor fa2 
ON (fa1.film_id = fa2.film_id)
AND (fa1.actor_id <> fa2.actor_id)
ORDER BY fa1.film_id;

-- 8. Get all pairs of customers that have rented the same film more than 3 times.
-- info is available in tables: rental, inventory | selfjoin film_id<> customer_id=

-- self join on a subquery
-- first create a working subquery creating the columns I need from rental and inventory
SELECT film_id, customer_id FROM sakila.rental r1 JOIN sakila.inventory i1 ON r1.inventory_id = i1.inventory_id;
-- use this as subquery again against rental
WITH subquery AS(
    SELECT film_id, customer_id FROM sakila.rental r1 JOIN sakila.inventory i1 ON r1.inventory_id = i1.inventory_id
) 
SELECT q1.film_id, q1.customer_id AS cust1, q2.customer_id AS cust2
FROM subquery q1
JOIN subquery q2
ON (q1.film_id = q2.film_id)
AND (q1.customer_id <> q2.customer_id)
;
-- up to here it is still correct: 

-- 9. For each film, list actor that has acted in more films.
-- info is available in tables: actor, film_actor, film
-- First a query for checking: there is no actor that played
-- in less than 14 films, so to fullfill the assigment
-- full table film_actor, sorted on film_id will do
SELECT fa.actor_id, count(f.film_id)
FROM sakila.film f
INNER JOIN sakila.film_actor fa ON f.film_id = fa.film_id
INNER JOIN sakila.actor a ON fa.actor_id = a.actor_id
GROUP BY fa.actor_id
ORDER BY count(f.film_id);
-- per film, actors that has acted in more films:
SELECT fa.film_id, title, first_name AS first_name_actor, last_name AS last_name_actor
FROM sakila.film f
INNER JOIN sakila.film_actor fa ON f.film_id = fa.film_id
INNER JOIN sakila.actor a ON fa.actor_id = a.actor_id
ORDER BY film_id;








