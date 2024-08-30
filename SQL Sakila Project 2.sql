use sakila;

-- **** Basic Queries ****************************************************************************************
-- 1
select
	title,
    release_year
from film
where release_year = 2006;


-- 2
select
	first_name,
    last_name,
    rental.rental_date
from customer
join rental on customer.customer_id = rental.customer_id
where rental_date >= date_sub('2005-08-23 23:00:00', interval 1 month);


-- **** Joins ***********************************************************************************************
-- 3
select
	customer.first_name,
    customer.last_name
from customer
join rental on customer.customer_id = rental.customer_id
join inventory on rental.inventory_id = inventory.inventory_id
where inventory.store_id = 1
and customer.customer_id in (
	select
		rental.customer_id
	from rental
    join inventory on rental.inventory_id = inventory.inventory_id
    where inventory.store_id = 2
);


-- 4
select
	film.title
from film
where film.film_id not in (
select
	inventory.film_id
from inventory
);


-- 5
select
	title,
    rental_rate
from film
join film_category on film.film_id = film_category.film_id
join category on film_category.category_id = category.category_id
where category.name = "Action" or category.name = "Comedy";


-- **** Aggregate Functions **********************************************************************************
-- 6
select
	category.name,
    avg(timestampdiff(day, rental.rental_date, ifnull(rental.return_date ,now()))) as average_rental_duration
from film
join 
    film_category on film.film_id = film_category.film_id
join 
    category on film_category.category_id = category.category_id
left join 
    inventory on film.film_id = inventory.film_id
left join 
    rental on inventory.inventory_id = rental.inventory_id
group by 
    category.name;


-- 7
select
	store.store_id,
    sum(payment.amount) as total_revenue
from rental
join inventory on rental.inventory_id = inventory.inventory_id
join store on inventory.store_id = store.store_id
join payment on rental.rental_id = payment.rental_id
group by store.store_id;


-- 8
select
	customer.first_name,
    customer.last_name,
    count(rental.rental_id) as total_film_rentals
from customer
join rental on customer.customer_id = rental.customer_id
group by customer.customer_id, customer.first_name, customer.last_name;


-- **** Views ************************************************************************************************
-- 9
create view top_5_most_renting_customer as
select
	customer.first_name,
    customer.last_name,
    count(rental.rental_id) as total_film_rentals
from customer
join rental on customer.customer_id = rental.customer_id
group by customer.customer_id, customer.first_name, customer.last_name
order by total_film_rentals desc limit 5;


-- 10
create view most_rented_film as
select
	film.film_id as id,
    film.title,
    film.description,
    film.release_year,
    film.length,
    count(rental.rental_id) as total_rentals
from film
join inventory on film.film_id = inventory.film_id
join rental on inventory.inventory_id = rental.inventory_id
group by film.film_id, film.title
order by total_rentals asc limit 1;


-- 11
create view horror_watching_customers as
select 
    customer.first_name,
    customer.last_name
from 
    customer
join 
    rental on customer.customer_id = rental.customer_id
join 
    inventory on rental.inventory_id = inventory.inventory_id
join 
    film on inventory.film_id = film.film_id
join 
    film_category on film.film_id = film_category.film_id
join 
    category on film_category.category_id = category.category_id
where 
    category.name = 'Horror'
group by 
    customer.customer_id, customer.first_name, customer.last_name
having 
    count(distinct film.film_id) = (
        select 
            count(distinct film.film_id)
        from 
            film
        join 
            film_category on film.film_id = film_category.film_id
        join 
            category on film_category.category_id = category.category_id
        where 
            category.name = 'Horror'
    );
    
    
-- 12
select
	film.title,
	category.name as category_name,
	film.rental_rate,
	count(rental.rental_id) as total_rentals
from film
join film_category on film.film_id = film_category.film_id
join category on film_category.category_id = category.category_id
join inventory on film.film_id = inventory.film_id
join rental on inventory.inventory_id = rental.inventory_id
group by film.film_id, category.name, film.rental_rate;
    

-- **** String Functions *************************************************************************************************
-- 13
select
	first_name,
    last_name
from customer
where first_name like 'A%' and last_name like '%s';


-- 14
select
	left(title, 10) as short_title
from film;


-- **** Date and Time Functions ******************************************************************************************
-- 15
select
	rental_id,
    rental_date as booking_date,
    return_date
from rental
where month(rental_date) = 6 and year(rental_date) = 2005;


-- 16
select
	film_id,
	year(now()) - release_year
from film;


-- 17
select
	customer.customer_id,
    customer.first_name,
    customer.last_name,
    timestampdiff(day, rental.rental_date, rental.return_date) as rental_days
from customer
join rental on customer.customer_id = rental.customer_id;


-- **** Case Statements *************************************************************************************
-- 18
select
	film_id,
    title,
    length,
    case
		when length <= 80 then 'Short'
        when length > 120 then 'Long'
		else 'Medium'
	end as length_classified
    from film;
    
    
-- 19
-- To check the overall amount of spendings of customers
select
	customer.customer_id,
	sum(payment.amount) as total_amount
from customer
join payment on customer.customer_id = payment.customer_id
group by customer.customer_id;
    
-- The real code
select
	customer.customer_id,
	customer.first_name,
	customer.last_name,
	sum(payment.amount) as total_amount_spent,
	case
		when sum(payment.amount) < 90 then 'Low'
		when sum(payment.amount) > 110 then 'High'
		else 'Medium'
	end as amount_classified
from customer
join payment on customer.customer_id = payment.customer_id
group by customer.customer_id;
    
    
-- **** Set Operations ***************************************************************************************
-- 20
select
	film.title,
	category.name
from film
join film_category on film.film_id = film_category.film_id
join category on film_category.category_id = category.category_id
where category.name in ('Action', 'Comedy')
group by film.title, category.name
having count(distinct category.name) = 1;
    
    
-- 21
select
	distinct title
from film
left join inventory on film.film_id = inventory.film_id
left join rental on inventory.inventory_id = rental.inventory_id
where rental.rental_date is null;
    
    
-- **** Triggers ***********************************************************************************************
-- 22
create table rental_log(
	log_id int auto_increment primary key,
	rental_id int,
	rental_date datetime,
	return_date datetime
);
    
delimiter //
create trigger log_rental_data
after insert on rental
for each row
begin
	insert into rental_log(rental_id, rental_date, return_date)
	values (new.rental_id, new.rental_date, new.return_date);
end//
delimiter ;
    
    
-- 23
delimiter //
create trigger last_update_assurance
before update on customer
for each row
begin
	set new.last_update = now();
end//
delimiter ;
    
    
-- 24
create table customer_email_log(
	log_id int auto_increment primary key,
	first_name varchar(45),
	last_name varchar(45),
	new_email varchar(50)
);
    
alter table customer_email_log
add old_email varchar(50),
add change_date datetime default now();
    
delimiter //
create trigger email_change_log
before update on customer
for each row
begin
	if old.email != new.email then
	insert into customer_email_log(first_name, last_name, new_email, old_email, change_date)
	values (old.first_name, old.last_name, new.email, old.email, now());
	end if;
end//
delimiter ;
    
    
-- 25
create table archived_rentals_log(
	log_id int auto_increment primary key,
	rental_id int,
	rental_date datetime,
	return_date datetime
);
    
delimiter //
create trigger archiving_old_rentals
before delete on rental
for each row
begin
	if old.rental_date < now() - interval 1 year then
	insert into archived_rentals_log(rental_id, rental_date, return_date)
	values (old.rental_id, old.rental_date, old.return_date);
	end if;
end//
delimiter ;
    
    
-- 26
delimiter //
create trigger check_rental_duration
before insert on rental
for each row
begin
	if new.return_date is not null and datediff(new.return_date, new.rental_date) > 30 then
	signal sqlstate "45000"
	set message_text = 'Rental duration cannot exceed 30 days.';
	end if;
end//
    
create trigger check_rental_duration_update
before update on rental
for each row
begin
	if new.return_date is not null and datediff(new.return_date, new.rental_date) > 30 then
	signal sqlstate "45000"
	set message_text = 'Rental duration cannot exceed 30 days.';
	end if;
end//
delimiter ;
    
    
-- **** Stored Procedures **************************************************************************
-- 27
delimiter //
create procedure retrieve_film_by_category(in category_name varchar(25))
begin
	select
		film.title,
		film.release_year,
		film.rental_rate
	from film
	join film_category on film.film_id = film_category.film_id
	join category on film_category.category_id = category.category_id
	where category.name = category_name;
end//
delimiter ;
    
call retrieve_film_by_category('Horror');
    
    
-- 28
delimiter //
create procedure customer_rental_data_retrieval(in input_customer_id smallint)
begin
	select
		rental_id,
        rental_date,
        return_date
	from rental
    where customer_id = input_customer_id;
end//
delimiter ;

call customer_rental_data_retrieval(2);