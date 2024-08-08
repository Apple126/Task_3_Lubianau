1. Вывести количество фильмов в каждой категории, отсортировать по убыванию.

SELECT name, count(category.category_id) as films_count
FROM category
JOIN film_category
	ON category.category_id = film_category.category_id
GROUP BY name
ORDER BY films_count DESC



2. Вывести 10 актеров, чьи фильмы большего всего арендовали, отсортировать по убыванию.

SELECT actor.actor_id, actor.first_name, actor.last_name, COUNT(rental.rental_id) AS total_rentals
FROM actor
JOIN film_actor
    ON actor.actor_id = film_actor.actor_id
JOIN film
    ON film_actor.film_id = film.film_id
LEFT JOIN inventory
    ON film.film_id = inventory.film_id
LEFT JOIN rental
    ON inventory.inventory_id = rental.inventory_id
GROUP BY actor.actor_id, actor.first_name, actor.last_name
ORDER BY total_rentals DESC
LIMIT 10

3. Вывести категорию фильмов, на которую потратили больше всего денег.

SELECT category.name as film_category, SUM(amount) as amount
FROM inventory
JOIN rental
	ON inventory.inventory_id = rental.inventory_id
JOIN payment
	ON rental.rental_id = payment.rental_id
JOIN film_category
	ON film_category.film_id = inventory.film_id
JOIN category
	ON film_category.category_id = category.category_id

GROUP BY film_category
ORDER BY amount DESC
LIMIT 1


4. Вывести названия фильмов, которых нет в inventory. Написать запрос без использования оператора IN.

SELECT distinct(title)
FROM film
LEFT JOIN inventory
	ON film.film_id = inventory.film_id
WHERE inventory.film_id IS NULL


5. Вывести топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”. Если у нескольких актеров одинаковое кол-во фильмов, вывести всех.

WITH com_actor AS (
	SELECT actor.actor_id, first_name, last_name, film_actor.film_id
	FROM actor
	JOIN film_actor ON actor.actor_id = film_actor.actor_id
), com_category AS (
	SELECT category.category_id, name as category_name, film_id
	FROM category
	JOIN film_category ON category.category_id = film_category.category_id
)

SELECT first_name, last_name, count(title)
FROM film
LEFT JOIN com_actor
	ON film.film_id = com_actor.film_id
LEFT JOIN com_category
	ON film.film_id = com_category.film_id
WHERE category_name = 'Children'
GROUP BY first_name, last_name
ORDER BY count DESC
LIMIT 3


6. Вывести города с количеством активных и неактивных клиентов (активный — customer.active = 1). Отсортировать по количеству неактивных клиентов по убыванию.

SELECT city, active, COUNT(customer_id) AS clients
FROM address
JOIN customer
	ON address.address_id = customer.address_id
JOIN city
	ON address.city_id = city.city_id
GROUP BY city, active
ORDER BY active, clients DESC


7. Вывести категорию фильмов, у которой самое большое кол-во часов суммарной аренды в городах (customer.address_id в этом city), и которые начинаются на букву “a”. То же самое сделать для городов в которых есть символ “-”. Написать все в одном запросе.

WITH info_table AS (
	SELECT *,
		EXTRACT(EPOCH FROM (rental.return_date - rental.rental_date)) / 3600 AS rental_hours
	FROM address
	JOIN city
		ON city.city_id = address.city_id
	JOIN customer
		ON customer.address_id = address.address_id
	JOIN rental
		ON customer.customer_id = rental.customer_id
	JOIN inventory
		ON inventory.inventory_id = rental.inventory_id
	JOIN film 
		ON inventory.film_id = film.film_id
	JOIN film_category 
		ON film_category.film_id = film.film_id
	JOIN category 
		ON category.category_id = film_category.category_id
),

city_with_a AS (
    SELECT name, SUM(rental_hours) AS total
    FROM info_table
    WHERE city LIKE 'A%'
    GROUP BY name
    ORDER BY total DESC
    LIMIT 1
),

city_with_dash AS (
    SELECT name, SUM(rental_hours) AS total
    FROM info_table
    WHERE city LIKE '%-%'
    GROUP BY name
    ORDER BY total DESC
    LIMIT 1
)

SELECT * 
FROM city_starts_with_a
UNION
SELECT * 
FROM city_contains_dash



