ALTER TABLE candidates ADD PRIMARY KEY (candidate_id);
ALTER TABLE supporters ADD PRIMARY KEY (user_id,candidate_id);
ALTER TABLE candidates ADD COLUMN wikipedia varchar(250);
ALTER TABLE candidates ADD COLUMN instagram varchar(250);
ALTER TABLE candidates ADD COLUMN proposed boolean NOT NULL;
CREATE TABLE candidates_views (
	candidate_id bigint REFERENCES candidates(candidate_id) ON DELETE CASCADE,
	user_id integer REFERENCES citizens(user_id) ON DELETE CASCADE,
	nb_views integer DEFAULT 0,
	favorite boolean DEFAULT false,
	last_view timestamp DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE candidates_views ADD PRIMARY KEY (user_id,candidate_id);
