-- data definition

CREATE TABLE crew_members
(
    crew_member_id SERIAL PRIMARY KEY,
    first_name VARCHAR,
    last_name VARCHAR,
    birth_date DATE
)
;

CREATE INDEX crew_members_birth_date_idx
    ON crew_members (birth_date)
;

CREATE TABLE aircrafts
(
    aircraft_id SERIAL PRIMARY KEY,
    aircraft_model VARCHAR
)
;

CREATE TABLE crew_member_aircraft
(
    crew_member_id INTEGER REFERENCES crew_members,
    aircraft_id INTEGER REFERENCES aircrafts,
    constraint id PRIMARY KEY (crew_member_id, aircraft_id)
)
;

-- data manipulation

INSERT INTO public.crew_members (first_name, last_name, birth_date) VALUES ('John', 'Oldman', '1905-01-01');
INSERT INTO public.crew_members (first_name, last_name, birth_date) VALUES ('Jack', 'Oldman', '1905-01-01');
INSERT INTO public.crew_members (first_name, last_name, birth_date) VALUES ('Howard', 'Hughes', '1905-12-24');
INSERT INTO public.crew_members (first_name, last_name, birth_date) VALUES ('Franjo', 'Kluz', '1913-09-14');
INSERT INTO public.crew_members (first_name, last_name, birth_date) VALUES ('Maggie', 'O''Connell', '1962-12-06');
INSERT INTO public.crew_members (first_name, last_name, birth_date) VALUES ('Chuck', 'Yeagger', '1923-02-13');
INSERT INTO public.crew_members (first_name, last_name, birth_date) VALUES ('Steve', 'Unexperienced', '2001-01-02');

INSERT INTO aircrafts (aircraft_model) VALUES ('Cessna-175');
INSERT INTO aircrafts (aircraft_model) VALUES ('H-4 Hercules');
INSERT INTO aircrafts (aircraft_model) VALUES ('Cirrus SR22');
INSERT INTO aircrafts (aircraft_model) VALUES ('Bell X-5');
INSERT INTO aircrafts (aircraft_model) VALUES ('Airbus-A320');
INSERT INTO aircrafts (aircraft_model) VALUES ('Boeing-747');


INSERT INTO crew_member_aircraft (crew_member_id, aircraft_id)
SELECT  crew_members.crew_member_id, aircrafts.aircraft_id
FROM crew_members, aircrafts
WHERE crew_members.first_name = 'John' AND aircrafts.aircraft_model IN ('Cessna-175');

INSERT INTO crew_member_aircraft (crew_member_id, aircraft_id)
SELECT  crew_members.crew_member_id, aircrafts.aircraft_id
FROM crew_members, aircrafts
WHERE crew_members.first_name = 'Jack' AND aircrafts.aircraft_model IN ('Cessna-175', 'H-4 Hercules', 'Boeing-747');

INSERT INTO crew_member_aircraft (crew_member_id, aircraft_id)
SELECT  crew_members.crew_member_id, aircrafts.aircraft_id
FROM crew_members, aircrafts
WHERE crew_members.first_name = 'Howard' AND aircrafts.aircraft_model IN ('H-4 Hercules');

INSERT INTO crew_member_aircraft (crew_member_id, aircraft_id)
SELECT  crew_members.crew_member_id, aircrafts.aircraft_id
FROM crew_members, aircrafts
WHERE crew_members.first_name = 'Franjo' AND aircrafts.aircraft_model IN ('Cessna-175', 'H-4 Hercules');


INSERT INTO crew_member_aircraft (crew_member_id, aircraft_id)
SELECT  crew_members.crew_member_id, aircrafts.aircraft_id
FROM crew_members, aircrafts
WHERE crew_members.first_name = 'Maggie' AND aircrafts.aircraft_model IN ('Cessna-175', 'Cirrus SR22');


INSERT INTO crew_member_aircraft (crew_member_id, aircraft_id)
SELECT  c.crew_member_id, a.aircraft_id
FROM crew_members c, aircrafts a
WHERE c.first_name = 'Chuck' AND a.aircraft_model IN ('Cessna-175', 'Bell X-5', 'Cirrus SR22', 'Boeing-747');



-- Queries: ------------------------------------------------------------------
--
-- Find name of the oldest crew member
-- if two or more have the same birth date, returns all candidates

SELECT
    first_name,
    last_name,
    birth_date
FROM
    crew_members
WHERE
    birth_date = (SELECT MIN(birth_date) FROM crew_members);

 
-- Find name of the n-th crew member (second oldest, fifth oldest and so on)

CREATE OR REPLACE FUNCTION get_oldest_crew_member (int)
RETURNS crew_members AS $$
    SELECT *
    FROM crew_members
    ORDER BY birth_date ASC, crew_member_id
    LIMIT 1
    OFFSET $1-1
$$ LANGUAGE SQL;


-- second oldest
select first_name, last_name from get_oldest_crew_member (2);

-- fifth oldest
select first_name, last_name from get_oldest_crew_member (5);




-- Find name of the most experienced crew member - that one who knows most aircrafts
-- if two or more have the same experience, returns only one candidate ordered by PK
-- excludes candidates with zero experience
SELECT
    Cm.first_name,
    Cm.last_name,
    COUNT(*) AS "experience"
FROM
    crew_members cm INNER JOIN crew_member_aircraft cma
    ON cm.crew_member_id = cma.crew_member_id
GROUP BY 
    cm.first_name, cm.last_name, cm.crew_member_id
ORDER BY
    COUNT(*) DESC, cm.crew_member_id
LIMIT 1;

-- Find name of the most experienced crew member - that one who knows most aircrafts
-- if two or more have the same experience, returns all candidates
-- excludes candidates with zero experience

SELECT
    Cm.first_name,
    Cm.last_name,
    COUNT(*) AS "experience"
FROM
    crew_members cm INNER JOIN crew_member_aircraft cma
    ON cm.crew_member_id = cma.crew_member_id
GROUP BY 
    cm.first_name, cm.last_name
HAVING COUNT(*) =
(
        SELECT COUNT(*) AS cnt
        FROM
            crew_members cm2 INNER JOIN crew_member_aircraft cma2
            ON cm2.crew_member_id = cma2.crew_member_id
        GROUP BY 
            cm2.crew_member_id
        ORDER BY
            COUNT(*) DESC
        LIMIT 1
)


-- Find name of the least experienced crew member - that one who knows least aircrafts (counting from zero)
-- if two or more have the same experience, returns only first candidate ordered by PK
-- includes candidate with zero experience
SELECT
    Cm.first_name,
    Cm.last_name,
    COUNT(cma.crew_member_id) AS "experience"
FROM
    crew_members cm LEFT JOIN crew_member_aircraft cma
    ON cm.crew_member_id = cma.crew_member_id
GROUP BY 
    cm.first_name, cm.last_name, cm.crew_member_id
ORDER BY
    COUNT(cma.crew_member_id) ASC, cm.crew_member_id
LIMIT 1;



-- Find name of the least experienced crew member - that one who knows least aircrafts (counting from zero)
-- if two or more have the same experience, returns all candidates
-- includes candidates with zero experience
SELECT
    Cm.first_name,
    Cm.last_name,
    COUNT(cma.crew_member_id) AS "experience"
FROM
    crew_members cm LEFT JOIN crew_member_aircraft cma
    ON cm.crew_member_id = cma.crew_member_id
GROUP BY 
    cm.first_name, cm.last_name
HAVING COUNT(cma.crew_member_id) =
(
        SELECT COUNT(cma2.crew_member_id) AS cnt
        FROM
            crew_members cm2 LEFT JOIN crew_member_aircraft cma2
            ON cm2.crew_member_id = cma2.crew_member_id
        GROUP BY 
            cm2.crew_member_id
        ORDER BY
            COUNT(cma2.crew_member_id) ASC
        LIMIT 1
)

