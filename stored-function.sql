-- Stored Procedures and functions with SQL

-- Explore the payment table 
SELECT *
FROM payment;

-- Stored Procedure
-- Simulating a late fee charge

CREATE OR REPLACE PROCEDURE latefee(
	customer INTEGER,
	lateFeeAmount DECIMAL, -- DECIMAL is just saying float 
	transaction_id INTEGER
)
LANGUAGE plpgsql -- plgsql means postgress sql database
AS $$ -- $$ are essentially denoting the functionality 
BEGIN
	-- Add late fee to customer payment amount 
	UPDATE payment
	SET amount = amount + lateFeeAmount
	WHERE customer_id = customer AND payment_id = transaction_id;
	
	-- Commit the changes
	COMMIT;
END;
$$; 

-- Calling a Stored Procedure
CALL latefee(341, 5.00, 17503);



-- Validating changes
SELECT *
FROM payment 
WHERE payment_id = 17503
-- From this check, the amount went from 7.99 to 12.99 due to the latefee addition 



-- Dropping or Deleting the procedure
DROP PROCEDURE latefee;



-- For loop through a table based on a query
CREATE OR REPLACE PROCEDURE latefee2()
LANGUAGE plpgsql
AS $$
DECLARE
	t_row record;
BEGIN 
	FOR t_row IN SELECT * FROM payment LOOP
		UPDATE payment 
		SET amount = amount + 5
		WHERE payment_date > '02/17/2007' AND payment.payment_id = t_row.payment_id; -- needs ; since this is considered its own query 
	END LOOP;
END;
$$;

CALL latefee2()

SELECT * 
FROM payment



-- Stored functions example
-- STORED Function to insert data into actor table

CREATE OR REPLACE FUNCTION add_actor(
	_actor_id INTEGER,
	_first_name VARCHAR,
	_last_name VARCHAR,
	_last_update TIMESTAMP WITHOUT TIME ZONE
)
RETURNS void
AS $$ 
BEGIN 
	INSERT INTO actor(actor_id, first_name, last_name, last_update)
	VALUES(_actor_id, _first_name, _last_name, _last_update);
END;
$$
LANGUAGE plpgsql;


-- Calling a function is different than calling a procedure - we Use SELECT instead of CALL --> will return empty column since 
-- we are not specifying
SELECT add_actor(500, 'Dwayne', 'Johnson', NOW()::timestamp); -- actor_id: 500 to be: "Dwayne Johnson"

SELECT NOW() -- checking the timestamp of now()


SELECT add_actor(501, 'Eric', 'Jiang', NOW()::timestamp);


-- To get specified/ verifying successful additions to actor table
SELECT *
FROM actor
WHERE actor_id = 501


-- DELETE/DROP FUNCTION
DROP FUNCTION add_actor; 



SELECT *
FROM customer



-- Store #2 is closing down. All customers associated with store_id 2 are not considered inactive. 
-- Given this change in business, all customers from this store should have an active bool of False.
-- Write a procedure that changes active bool to False for these customers. 
SELECT *
FROM customer 
-- use a for function to change 
CREATE OR REPLACE PROCEDURE closed(
	activebool BOOLEAN
)
LANGUAGE plpgsql 
AS
$$
BEGIN 
	UPDATE customer
	SET activebool = False
	WHERE store_id = 2;
	COMMIT;
END;
$$;

SELECT activebool, customer_id, store_id
FROM customer
WHERE store_id = 2


-- All rentals that have a payment_date later than the rental return_date are considered late. Please
-- update all payment amounts to reflect a $3 late fee charge if applicable. 

-- Similar to what we did earlier but with subquerries
CREATE OR REPLACE PROCEDURE money()
LANGUAGE plpgsql
AS $$
DECLARE
	updated_late record;
BEGIN 
	FOR updated_late IN SELECT * FROM payment LOOP
		UPDATE payment 
		SET amount = amount + 3
		WHERE payment_date > '02/17/2007' AND payment.payment_id = updated_late.payment_id; -- needs ; since this is considered its own query 
	END LOOP;
END;
$$;

CALL money()


SELECT *
FROM payment
