CREATE TABLE users (
	email varchar(60) PRIMARY KEY,
	email_status integer DEFAULT 0, -- 0==unknown / 1==email valid but declared spam / 2==email valid  / -1=email soft-bounced / -2=email bounced
	email_detail text, -- bounce details provided by Mandrill
	validation_level integer DEFAULT 0, -- bit1 email validated / bit2 phone validated / bit3 facebook validated / bit4 cb validated
	firstname varchar(30),
	lastname varchar(30),
	telephone varchar(30),
	registered timestamp DEFAULT CURRENT_TIMESTAMP,
	city varchar(60), 
	city_id integer REFERENCES cities (city_id), -- for french cities
	zipcode varchar(15),
	country varchar(60) REFERENCES countries (name),
	last_updated timestamp DEFAULT CURRENT_TIMESTAMP, -- date when the candidate has been addeed
	telegram_id integer REFERENCES citizens (user_id),
	donateur_id integer REFERENCES donateurs (donateur_id),
	tags text[],
	user_key varchar(80) UNIQUE
);

-- CREATE TRIGGER update_user_timestamp BEFORE UPDATE
-- ON users FOR EACH ROW EXECUTE PROCEDURE 
-- update_timestamp();

-- CREATE TRIGGER update_user_timestamp BEFORE UPDATE
-- ON users FOR EACH ROW EXECUTE PROCEDURE 
-- update_timestamp();


-- insert depuis mongo_supporteurs
-- insert into users (email,firstname,lastname,registered,country,zipcode,tags) select email,firstname,lastname,created,country,zipcode,tags from mongo_supporteurs

-- insert depuis les utilisateur telegram
-- insert into users (email,validation_level,firstname,lastname,registered,city,city_id,country,last_updated,telegram_id) select email,2,firstname,lastname,registered,city,city_id,country,last_updated,user_id from citizens where email not in (select c.email from citizens as c inner join users as u on (u.email=c.email))

-- insert depuis les signataires de l'appel_aux_maires
-- insert into users (email,firstname,lastname,registered,last_updated,tags) select email,firstname,lastname,min(signed) as registered, min(signed) as last_updated,ARRAY['appel_aux_maires']::text[] from appel_aux_maires where email not in (select u.email from users as u inner join appel_aux_maires as a on (a.email=u.email)) group by email,firstname,lastname;

-- insert depuis les donateurs 
-- insert into users (email,firstname,lastname,zipcode,donateur_id,registered,last_updated) select email,firstname,lastname,zipcode,donateur_id,created as registered,created as last_updated from donateurs where email not in (select u.email from users as u inner join donateurs as d on (d.email=u.email))
