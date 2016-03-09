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
	country varchar(20) DEFAULT 'FRANCE'
);
CREATE INDEX cities_name_idx ON cities(name);
CREATE INDEX cities_zip_idx ON cities(zipCode);

CREATE TABLE citizens (
	user_id SERIAL PRIMARY KEY,
	telegram_id integer,
	email varchar(60),
	firstname varchar(30),
	lastname varchar(30),
	username varchar(30),
	registered timestamp DEFAULT CURRENT_TIMESTAMP,
	session jsonb,
	beta_tester boolean DEFAULT false,
	reviewer boolean DEFAULT false,
	city_id integer REFERENCES cities(city_id)
);
CREATE INDEX citizens_tg_idx ON citizens(telegram_id);
CREATE INDEX citizens_email_idx ON citizens(email);

CREATE TABLE tags (
	name varchar(25) PRIMARY KEY
);

CREATE TABLE citizens_tags (
	user_id integer REFERENCES citizens(user_id),
	name varchar(25) REFERENCES tags(name)
);

CREATE TABLE candidates (
	candidate_id SERIAL PRIMARY KEY,
	user_id integer REFERENCES citizens(user_id), -- if the candidate is also registered as a participating citizen
	name varchar(60),
	gender varchar(1),
	uuid varchar(140), -- the candidate official ID (used to construct URL)
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
	qualified boolean, -- the candidate accepted to participate to the primary and is officially running for president
	date_qualified timestamp
);
CREATE INDEX candidates_name_idx ON candidates(name);

CREATE TABLE supporters (
	candidate_id integer REFERENCES candidates(candidate_id),
	user_id integer REFERENCES citizens(user_id),
	support_date timestamp,
	removed boolean,
	removed_date timestamp
);

CREATE TABLE donations (
	user_id integer REFERENCES citizens(user_id),
	donation_date timestamp,
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


CREATE TYPE accept_candidate AS ENUM ('oui','non','not sure');
CREATE TABLE reviews (
	candidate_id integer REFERENCES candidates(candidate_id),
	user_id integer REFERENCES citizens(user_id),
	date_asked timestamp,
	date_answered timestamp,
	answer accept_candidate,
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
