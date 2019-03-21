USE sakila;
-- 1a. Display the first and last names of all actors from the table actor.
SELECT 
    first_name, last_name
FROM
    actor;
-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column Actor Name.
SELECT 
    UPPER(CONCAT(first_name, ' ', last_name)) AS 'Actor Name'
FROM
    actor;
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    first_name LIKE 'Joe%';
--  2b. Find all actors whose last name contain the letters GEN:
SELECT 
    last_name
FROM
    actor
WHERE
    last_name LIKE '%gen%';
 -- 2c. Find all actors whose last names contain the letters LI. 
SELECT 
    last_name, first_name
FROM
    actor
WHERE
    last_name LIKE '%li%'
ORDER BY last_name , first_name;
 -- 2d. Using IN, display the country_id and country columns of the following countries: 
SELECT 
    country_id, country
FROM
    country
WHERE
    country IN ('Afghanistan' , 'Bangladesh', 'China');
 -- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description,
 -- so create a column in the table actor named description and use the data type BLOB 
 alter table actor add column Description BLOB;
SELECT 
    *
FROM
    actor;
 -- 3b. Delete the description column.
 alter table actor drop column Description;
SELECT 
    *
FROM
    actor;
 -- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT 
    last_name, COUNT(*) AS 'Number of Actors'
FROM
    actor
GROUP BY last_name;
-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) AS 'Number of Actors' 
FROM actor GROUP BY last_name HAVING count(*) >=2;
-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS.
-- Write a query to fix the record
UPDATE actor 
SET first_name = 'HARPO'
WHERE First_name = "Groucho" AND last_name = "Williams";
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
SELECT first_name, last_name 
FROM actor 
WHERE first_name 
IN ("HARPO");
UPDATE actor 
SET first_name = "Groucho"
WHERE First_name = "Harpo" AND last_name = "Williams";
-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
DESCRIBE sakila.address;
-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:
SELECT first_name, last_name, address
FROM staff as s 
JOIN address as a
ON s.address_id = a.address_id;
-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.
select * from payment;
SELECT first_name, last_name, SUM(amount)
FROM staff AS s
INNER JOIN payment AS p
ON s.staff_id = p.staff_id
GROUP BY p.staff_id;
-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join.
select * from film;
SELECT f.title AS 'Film Title', COUNT(fa.actor_id) AS `Number of Actors`
FROM film_actor AS fa
INNER JOIN film AS f 
ON fa.film_id= f.film_id
GROUP BY f.title;
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select * from inventory;
SELECT title, (
SELECT COUNT(*) FROM inventory
WHERE film.film_id = inventory.film_id
) AS 'Number of Copies'
FROM film
WHERE title = "Hunchback Impossible";
-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer.
-- List the customers alphabetically by last name:
SELECT last_name, first_name, SUM(amount)
FROM payment AS p
INNER JOIN customer AS c
ON p.customer_id = c.customer_id
GROUP BY p.customer_id
ORDER BY last_name ASC;
-- 7a. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title FROM film
WHERE language_id in
	(SELECT language_id 
	FROM language
	WHERE name = "English" )
AND (title LIKE "K%") OR (title LIKE "Q%");
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip
SELECT last_name, first_name FROM actor
WHERE actor_id in
	(SELECT actor_id 
	FROM film_actor
	WHERE film_id IN
		(SELECT film_id
         FROM film
         WHERE title = "Alone Trip"));
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
SELECT cus.first_name, cus.last_name, cus.email 
FROM customer AS cus
JOIN address AS adr
ON (cus.address_id = adr.address_id)
JOIN city AS cty
ON (cty.city_id = adr.city_id)
JOIN country
ON (country.country_id = cty.country_id)
WHERE country.country= 'Canada';
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT title, category
FROM film_list
WHERE category = 'Family';
-- Display the most frequently rented movies in descending order.
SELECT fi.title, COUNT(rental_id) AS 'Number of Rentals'
FROM rental AS re
JOIN inventory AS inv
ON (re.inventory_id = inv.inventory_id)
JOIN film as fi
ON (inv.film_id = fi.film_id)
GROUP BY fi.title
ORDER BY `Number of Rentals` DESC;
-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store, total_sales FROM sales_by_store;
-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT st.store_id, ct.city, country.country 
FROM store AS st
JOIN address AS ad 
ON (st.address_id = ad.address_id)
JOIN city AS cty
ON (ct.city_id = ad.city_id)
JOIN country
ON (country.country_id = ct.country_id);
-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT ctg.name AS 'Top 5 Genres', SUM(pmt.amount) AS Gross_Revenue
FROM category AS ctg
JOIN film_category AS fc 
ON (ctg.category_id=fc.category_id)
JOIN inventory AS inv 
ON (fc.film_id=inv.film_id)
JOIN rental AS rtl
ON (inv.inventory_id=rtl.inventory_id)
JOIN payment AS pmt
ON (rtl.rental_id=pmt.rental_id)
GROUP BY ctg.name
ORDER BY Gross_Revenue DESC LIMIT 5;
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top5_Genre AS
SELECT ctg.name AS 'Top 5 Genres', SUM(pmt.amount) AS Gross_Revenue
FROM category AS ctg
JOIN film_category AS fc 
ON (ctg.category_id=fc.category_id)
JOIN inventory AS inv 
ON (fc.film_id=inv.film_id)
JOIN rental AS rtl
ON (inv.inventory_id=rtl.inventory_id)
JOIN payment AS pmt
ON (rtl.rental_id=pmt.rental_id)
GROUP BY ctg.name
ORDER BY Gross_Revenue DESC LIMIT 5;
-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top5_genre;
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top5_genre;

