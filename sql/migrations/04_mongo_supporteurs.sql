DROP TABLE mongo_supporteurs;
CREATE TABLE mongo_supporteurs (
	supporteur_id SERIAL PRIMARY KEY,
	firstname varchar(30),
	lastname varchar(30),
	email varchar(60),
	country varchar(60),
	zipcode varchar(15),
	reason text,
	created TIMESTAMP,
	tags text[]
);
