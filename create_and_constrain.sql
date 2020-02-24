--######### TABLES #########
DROP TYPE IF EXISTS season CASCADE;

CREATE TYPE season AS enum (
    'Spring',
    'Summer',
    'Fall',
    'Winter'
);

DROP TABLE IF EXISTS course CASCADE;

CREATE TABLE course (
    course_id serial PRIMARY KEY,
    name varchar(255) NOT NULL,
    presence boolean NOT NULL,
    season season NOT NULL,
    year int NOT NULL
);

DROP TABLE IF EXISTS trainee CASCADE;

CREATE TABLE trainee (
    trainee_id serial PRIMARY KEY,
    name varchar(255) NOT NULL,
    email varchar(255) NOT NULL
);

DROP TABLE IF EXISTS instructor CASCADE;

CREATE TABLE instructor (
    instructor_id serial PRIMARY KEY,
    name varchar(255) NOT NULL
);

DROP TABLE IF EXISTS teaching_team CASCADE;

CREATE TABLE teaching_team (
    teaching_team_id serial PRIMARY KEY
);

DROP TABLE IF EXISTS teachingteam_instructor CASCADE;

CREATE TABLE teachingteam_instructor (
    teaching_team_id int,
    instructor_id int,
    FOREIGN KEY (teaching_team_id) REFERENCES teaching_team (teaching_team_id),
    FOREIGN KEY (instructor_id) REFERENCES instructor (instructor_id),
    PRIMARY KEY (teaching_team_id, instructor_id)
);

DROP TABLE IF EXISTS enrollment CASCADE;

CREATE TABLE enrollment (
    trainee_id int,
    course_id int,
    graduated boolean NOT NULL,
    FOREIGN KEY (trainee_id) REFERENCES trainee (trainee_id),
    FOREIGN KEY (course_id) REFERENCES course (course_id),
    PRIMARY KEY (trainee_id, course_id)
);

DROP TABLE IF EXISTS teaches CASCADE;

CREATE TABLE teaches (
    teaching_team_id int,
    course_id int,
    FOREIGN KEY (teaching_team_id) REFERENCES teaching_team (teaching_team_id),
    FOREIGN KEY (course_id) REFERENCES course (course_id),
    PRIMARY KEY (teaching_team_id, course_id)
);

--######### CONSTRAINTS #########
ALTER TABLE course
    ADD CONSTRAINT unique_courses UNIQUE (name, presence, season, year);

ALTER TABLE trainee
    ADD CONSTRAINT unique_trainees UNIQUE (name, email);

ALTER TABLE instructor
    ADD CONSTRAINT unique_instructors UNIQUE (name);

   
--######### FUNCTIONS #########
--Search names of graduates that have completed (graduated) a specific course
CREATE OR REPLACE FUNCTION trainees_graduated_course (course_name text)
RETURNS setof varchar as 
	$$ 
	begin 
	return query (
		select t.name 
		from trainee t
		inner join enrollment e
		on e.graduated = true
		and 
		e.course_id = (select c.course_id 
		from course c
		where c.name = course_name));
	END
	$$
LANGUAGE 'plpgsql';
-- select trainees_graduated_course ('Databases')


--######### FUNCTIONS (TRIGGERED) #########
CREATE OR REPLACE FUNCTION check_max_two_teams_for_instructors ()
    RETURNS TRIGGER
    AS $$
BEGIN
    IF EXISTS (
        SELECT
            1
        FROM
            teachingteam_instructor
        WHERE
            instructor_id = NEW.instructor_id
        HAVING
            COUNT(*) >= 2) THEN
    RAISE EXCEPTION 'Instructor can only be allocated to two teaching teams at maximum';
END IF;
    RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION min_two_instructors_per_teaching_team ()
    RETURNS TRIGGER
    AS $$
BEGIN
    IF EXISTS (
        SELECT
            1
        FROM
            teachingteam_instructor
        WHERE
            teaching_team_id = NEW.teaching_team_id
        HAVING
            COUNT(*) < 2) THEN
    RAISE EXCEPTION 'A course must have a teaching team consisting of atleast two instructors';
END IF;
    RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';


--######### TRIGGERS #########
CREATE TRIGGER MaxTwoTeamsPerInstructor
    BEFORE INSERT ON teachingteam_instructor
    FOR EACH ROW
    EXECUTE PROCEDURE check_max_two_teams_for_instructors ();

CREATE TRIGGER MinTwoInstructorPerTeachingTeam
    BEFORE INSERT ON teaches
    FOR EACH ROW
    EXECUTE PROCEDURE min_two_instructors_per_teaching_team ();
