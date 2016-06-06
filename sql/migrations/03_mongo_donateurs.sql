DROP TABLE donateurs;
CREATE TABLE donateurs (
	donateur_id SERIAL PRIMARY KEY,
	origin VARCHAR(30),
	recurring integer DEFAULT 0,
	created TIMESTAMP,
	anonymous integer DEFAULT 0,
	amount numeric,
	currency VARCHAR(10),
	firstname varchar(30),
	lastname varchar(30),
	email varchar(60),
	adresse varchar(200),
	city varchar(60), 
	zipcode varchar(15),
	comment text
);
