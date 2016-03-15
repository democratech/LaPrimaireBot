\COPY candidates (name,gender,candidate_id,photo,country,email,zipCode,tel,program_theme,with_team,political_party,already_candidate,already_elected,website,twitter,facebook,other_media,summary,accepted) FROM 'candidats.csv' CSV HEADER DELIMITER ',';

UPDATE candidates
   SET city_id=c.city_id
  FROM (
		SELECT c.city_id, toto.name, toto.zipcode, c.name as ville
		  FROM cities as c
		 INNER JOIN (
				SELECT ca.name, ca.zipCode, MAX(ci.population) as max_pop
				  FROM cities AS ci
				 INNER JOIN candidates AS ca
				    ON (ci.zipcode=ca.zipcode)
				 GROUP BY ca.name,ca.zipcode
		       ) as toto
		    ON c.zipcode=toto.zipcode
		   AND c.population=toto.max_pop
       ) as c
 WHERE candidates.zipcode = c.zipcode;
