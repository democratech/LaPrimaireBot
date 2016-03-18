CREATE TABLE countries (
	name varchar(60) PRIMARY KEY,
	name_accent varchar(60),
	iso2 varchar(2),
	iso3 varchar(3),
	lat_deg double precision,
	lon_deg double precision
);

CREATE TABLE cities (
	city_id SERIAL PRIMARY KEY,
	slug varchar(60),
	name varchar(60),
	zipcode varchar(15),
	departement varchar(5),
	name_departement varchar(40),
	num_canton integer,
	num_commune integer,
	code_insee varchar(5),
	lat_deg double precision,
	lon_deg double precision,
	location point,
	population integer,
	country varchar(60) DEFAULT 'FRANCE' REFERENCES countries (name) 
);
CREATE INDEX cities_name_idx ON cities(name);
CREATE INDEX cities_zip_idx ON cities(zipCode);

CREATE TABLE citizens (
	user_id integer PRIMARY KEY, -- telegram ID
	email varchar(60),
	firstname varchar(30),
	lastname varchar(30),
	username varchar(30),
	registered timestamp DEFAULT CURRENT_TIMESTAMP,
	session jsonb,
	settings jsonb,
	city varchar(60), 
	city_id integer REFERENCES cities (city_id), -- for french cities
	country varchar(60) REFERENCES countries (name),
	last_updated timestamp DEFAULT CURRENT_TIMESTAMP -- date when the candidate has been addeed
);
CREATE INDEX citizens_email_idx ON citizens(email);

CREATE TABLE beta_codes (
	code varchar(10)
);

CREATE TABLE waiting_list (
	user_id integer REFERENCES citizens(user_id),
	firstname varchar(30),
	lastname varchar(30),
	registered timestamp DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tags (
	name varchar(25) PRIMARY KEY
);

CREATE TABLE citizens_tags (
	user_id integer REFERENCES citizens(user_id),
	name varchar(25) REFERENCES tags(name)
);

CREATE TABLE candidates (
	candidate_id bigint UNIQUE, -- the candidate official ID (used to construct URL)
	user_id integer REFERENCES citizens(user_id), -- if the candidate is also registered as a participating citizen
	name varchar(60),
	gender varchar(1) DEFAULT 'M',
	photo varchar(160),
	trello varchar(200), -- the candidate official trello
	loomio varchar(200), -- the candidate official loomio
	country varchar(20),
	zipcode varchar(15),
	city_id integer REFERENCES cities(city_id),
	email varchar(60),
	tel varchar(20),
	program_theme varchar(140),
	with_team boolean,
	political_party varchar(140),
	already_candidate varchar(140),
	already_elected varchar(140),
	job varchar(250),
	website varchar(250),
	twitter varchar(250),
	facebook varchar(250),
	youtube varchar(250),
	linkedin varchar(250),
	tumblr varchar(250),
	blog varchar(250),
	other_media text,
	summary text,
	date_added timestamp DEFAULT CURRENT_TIMESTAMP, -- date when the candidate has been addeed
	accepted boolean, -- the candidate has been accepted by the reviewers
	date_accepted timestamp,
	verified boolean, -- the candidate has been verified as being eligible
	date_verified timestamp,
	official boolean, -- the candidate accepted to participate to the primary and is officially running for president
	date_officialized timestamp,
	qualified boolean, -- the candidate is qualified
	date_qualified timestamp,
	last_updated timestamp DEFAULT CURRENT_TIMESTAMP -- date when the candidate has been addeed
);
CREATE INDEX candidates_name_idx ON candidates(name);

CREATE TABLE supporters (
	candidate_id bigint REFERENCES candidates(candidate_id) ON DELETE CASCADE,
	user_id integer REFERENCES citizens(user_id) ON DELETE CASCADE,
	support_date timestamp DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE donations (
	user_id integer REFERENCES citizens(user_id),
	donation_date timestamp DEFAULT CURRENT_TIMESTAMP,
	amount decimal,
	source varchar(20),
	anonymous boolean default false,
	recurring boolean default false
);	

CREATE TABLE reviewers (
	reviewer_id SERIAL PRIMARY KEY,
	user_id integer REFERENCES citizens(user_id),
	nb_reviews integer,
	trust_factor integer, -- 0 (cannot be trusted) to 5 (his reviews are very trustworthy)
	speed_factor integer -- 0 (does not answer) to 5 (very quick to answer)
);

CREATE TABLE humanbots (
	humanbot_id SERIAL PRIMARY KEY,
	user_id integer REFERENCES citizens(user_id),
	nb_answers integer,
	trust_factor integer, -- 0 (cannot be trusted) to 5 (his reviews are very trustworthy)
	speed_factor integer -- 0 (does not answer) to 5 (very quick to answer)
);

CREATE TABLE reviews (
	candidate_id bigint REFERENCES candidates(candidate_id),
	user_id integer REFERENCES citizens(user_id),
	date_asked timestamp,
	date_answered timestamp,
	answer smallint, -- 1/ yes 0/not sure -1/no
	result smallint,
	remark text
);

CREATE TABLE conversations (
	update_id integer PRIMARY KEY not null, -- telegram update id
	user_id integer REFERENCES citizens(user_id),
	humanbot_id integer REFERENCES humanbots(humanbot_id),
	message text,
	answer text,
	source jsonb,
	rating integer
);

CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
	   NEW.last_updated = now(); 
	   RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_citizen_timestamp BEFORE UPDATE
ON citizens FOR EACH ROW EXECUTE PROCEDURE 
update_timestamp();

CREATE TRIGGER update_candidate_timestamp BEFORE UPDATE
ON candidates FOR EACH ROW EXECUTE PROCEDURE 
update_timestamp();
