use sakila;

/* 1a. Display the first and last names of all actors from the table `actor`.*/
select *
from actor;

/* 1b. Display the first and last name of each actor in a single column in upper case letters.
Name the column `Actor Name`.*/
select Concat(first_name, ' ',last_name)
as Actor_Name
from actor;

/* 2a. You need to find the ID number, first name, and last name of an actor,
of whom you know only the first name, "Joe."
What is one query would you use to obtain this information?*/
select actor_id, first_name, last_name
from actor
where first_name = "Joe";

/* 2b. Find all actors whose last name contain the letters `GEN`:*/
select *
from actor
where last_name rLIKE "(GEN)(\d+)?";

/* 2c. Find all actors whose last names contain the letters `LI`.
This time, order the rows by last name and first name, in that order:*/
select *
from actor
where last_name rLIKE "(LI)(\d+)?"
order by last_name asc, first_name asc;

/* 2d. Using `IN`, display the `country_id` and `country` columns of the following countries:
Afghanistan, Bangladesh, and China:*/
select country_id, country
from country
where country in ("Afghanistan","Bangladesh","China");

/* 3a. You want to keep a description of each actor.
You don't think you will be performing queries on a description,
so create a column in the table `actor` named `description` and use the data type `BLOB`
(Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).*/
ALTER TABLE actor
ADD COLUMN description BLOB;
select *
from actor;

/* 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.*/
ALTER TABLE actor
DROP COLUMN description;

/* 4a. List the last names of actors, as well as how many actors have that last name.*/
SELECT last_name, COUNT(last_name)
from actor
GROUP BY last_name;

/* 4b. List last names of actors and the number of actors who have that last name,
but only for names that are shared by at least two actors*/
SELECT last_name, COUNT(last_name) as x
from actor
GROUP BY last_name HAVING x >=2;

/* 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`.
Write a query to fix the record.*/
UPDATE actor
SET first_name = 'Harpo'
WHERE first_name = 'Groucho' AND last_name = 'williams';

/* 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`.
It turns out that `GROUCHO` was the correct name after all! In a single query,
if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.*/
UPDATE actor
SET first_name = 'Groucho'
WHERE first_name = 'Harpo';

/* 5a. You cannot locate the schema of the `address` table.
Which query would you use to re-create it?*/
SHOW CREATE TABLE address;

/* 6a. Use `JOIN` to display the first and last names,
as well as the address, of each staff member. Use the tables `staff` and `address`:*/
SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address ON
address.address_id=staff.address_id;

/* 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005.
Use tables `staff` and `payment`.*/
SELECT staff.first_name, staff.last_name, staff.staff_id, SUM(payment.amount)
FROM staff
INNER JOIN payment ON
payment.staff_id=staff.staff_id
GROUP BY staff_id;

/* 6c. List each film and the number of actors who are listed for that film.
Use tables `film_actor` and `film`. Use inner join.*/
SELECT film.title, film.film_id, COUNT(film_actor.actor_id)
FROM film
INNER JOIN film_actor ON
film.film_id = film_actor.film_id
GROUP BY film_id;

/* 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?*/
SELECT film.title, COUNT(inventory.film_id)
FROM film
INNER JOIN inventory ON
film.film_id = inventory.film_id
WHERE film.title = 'Hunchback Impossible';

/* 6e. Using the tables `payment` and `customer` and the `JOIN` command,
list the total paid by each customer.
List the customers alphabetically by last name:*/
SELECT customer.last_name, customer.first_name, customer.customer_id, SUM(payment.amount)
FROM customer
INNER JOIN payment ON
customer.customer_id = payment.customer_id
GROUP BY customer_id;

/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity.
Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.*/
SELECT title
FROM film
WHERE language_id IN (
	SELECT language_id
	FROM language
    WHERE name = 'English')
AND (title LIKE 'K%') OR (title LIKE 'Q%');

/* 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.*/
SELECT *
FROM actor
WHERE actor_id IN (
	SELECT actor_id
    FROM film_actor
    WHERE film_id IN (
		SELECT film_id
        FROM film
        WHERE title = 'Alone Trip'
        )
	);
    
/* 7c. You want to run an email marketing campaign in Canada,
for which you will need the names and email addresses of all Canadian customers.
Use joins to retrieve this information.*/
SELECT first_name,last_name,email
FROM customer
WHERE address_id IN (
		SELECT address.address_id
		FROM address
		JOIN city ON
		address.city_id = city.city_id
		WHERE country_id IN(
			SELECT country_id
			FROM country
			WHERE country = 'Canada'
			)
	);
    
/* 7d. Sales have been lagging among young families,
and you wish to target all family movies for a promotion.
Identify all movies categorized as family films.*/
SELECT *
FROM film
WHERE rating in ("G","PG","PG-13");

/* 7e. Display the most frequently rented movies in descending order.*/
SELECT film.film_id, film.title, COUNT(rental.inventory_id)
FROM inventory
INNER JOIN rental
ON inventory.inventory_id = rental.inventory_id
INNER JOIN film
ON inventory.film_id = film.film_id
GROUP BY rental.inventory_id
ORDER BY COUNT(rental.inventory_id) desc;

/* 7f. Write a query to display how much business, in dollars, each store brought in.*/
SELECT store.store_id, SUM(amount)
FROM store
INNER JOIN staff
ON store.store_id = staff.store_id
INNER JOIN payment
ON payment.staff_id = staff.staff_id
GROUP BY store.store_id
ORDER BY SUM(amount);

/* 7g. Write a query to display for each store its store ID, city, and country.*/
SELECT store.store_id, city, country
FROM store
INNER JOIN customer
ON customer.store_id = store.store_id
INNER JOIN address
ON address.address_id = customer.address_id
INNER JOIN city
ON city.city_id = address.city_id
INNER JOIN country
ON country.country_id = city.country_id;

/* 7h. List the top five genres in gross revenue in descending order.*/
SELECT name, SUM(payment.amount)
FROM category
INNER JOIN film_category
INNER JOIN inventory
ON film_category.film_id = inventory.film_id
INNER JOIN rental
ON rental.inventory_id = inventory.inventory_id
INNER JOIN payment
GROUP BY name
ORDER BY SUM(payment.amount) desc
LIMIT 5;

/* 8a. In your new role as an executive,
you would like to have an easy way of viewing the Top five genres by gross revenue.
Use the solution from the problem above to create a view. If you haven't solved 7h,
you can substitute another query to create a view.*/

CREATE VIEW top_five_grossing_genres AS

SELECT name, SUM(p.amount)
FROM category c
INNER JOIN film_category fc
INNER JOIN inventory i
ON i.film_id = fc.film_id
INNER JOIN rental r
ON r.inventory_id = i.inventory_id
INNER JOIN payment p
GROUP BY name
LIMIT 5;