\COPY cities (departement,slug,name,zipCode,num_commune,code_insee,num_canton,population,lon_deg,lat_deg) FROM 'villes_france.csv' CSV HEADER DELIMITER ',';
