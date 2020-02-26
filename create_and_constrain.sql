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
    year SMALLINT NOT NULL
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
    ADD CONSTRAINT unique_trainees UNIQUE (email);


--######### FUNCTIONS #########
--Search names of graduates that have completed (graduated) a specific course

CREATE OR REPLACE FUNCTION trainees_graduated_course (course_name text)
    RETURNS SETOF varchar
    AS $$
BEGIN
    RETURN query (
        SELECT
            t.name
        FROM
            trainee t
            INNER JOIN enrollment e ON e.graduated = TRUE
                AND e.course_id = (
                    SELECT
                        c.course_id
                    FROM
                        course c
                WHERE
                    c.name = course_name));
END
$$
LANGUAGE 'plpgsql';


-- select trainees_graduated_course ('Databases')
--######### FUNCTIONS (TRIGGERED) #########

CREATE OR REPLACE FUNCTION check_max_two_teams_for_instructors ()
    RETURNS TRIGGER
    AS $$
BEGIN
    LOCK TABLE teachingteam_instructor;
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

CREATE OR REPLACE FUNCTION max_100_trainees_per_course ()
    RETURNS TRIGGER
    AS $$
BEGIN
    LOCK TABLE enrollment;
    IF EXISTS (
        SELECT
            1
        FROM
            enrollment
        WHERE
            course_id = NEW.course_id
        HAVING
            COUNT(*) >= 100) THEN
    RAISE EXCEPTION 'A course must at maximum enroll 100 trainees';
END IF;
    RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION check_max_courses_for_trainee ()
     RETURNS TRIGGER AS $$
 DECLARE
 BEGIN
 	IF((select count(*) FROM enrollment JOIN course on (enrollment.course_id = course.course_id)
    		WHERE enrollment.trainee_id = NEW.trainee_id 
   			AND graduated = false 
    		AND course.year = (SELECT course.year FROM course WHERE course_id = NEW.course_id)
   			AND course.season = (SELECT course.season FROM course WHERE course_id = NEW.course_id)
    		AND course.presence = true) = 0
    		AND 
   		    (SELECT presence FROM course WHERE course_id = NEW.course_id) = false)
			THEN
			IF(SELECT 1 FROM enrollment JOIN course ON (enrollment.course_id = course.course_id)
			WHERE trainee_id = NEW.trainee_id 
				AND graduated = false 
				HAVING COUNT(*) >= 3)
			THEN
 			RAISE EXCEPTION 'Trainee is assigned to too many courses';
            END IF;

	ELSIF((SELECT count(*) FROM enrollment JOIN course on (enrollment.course_id = course.course_id)
    		WHERE enrollment.trainee_id = NEW.trainee_id 
   			AND graduated = false 
    		AND course.year = (SELECT course.year FROM course WHERE course_id = NEW.course_id)
   			AND course.season = (SELECT course.season FROM course WHERE course_id = NEW.course_id)
    		AND course.presence = false) = 0 AND 
   			(SELECT presence FROM course WHERE course_id = NEW.course_id) = true)
			THEN
				IF(SELECT 1 FROM enrollment JOIN course on (enrollment.course_id = course.course_id)
				WHERE trainee_id = NEW.trainee_id
				AND graduated = false
		    	HAVING COUNT(*) >= 1)
				THEN
				RAISE EXCEPTION 'Trainee is assigned to too many courses';
				END IF;
    END IF;
    
 	RAISE NOTICE 'hej';
 	RETURN NEW;
 END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION instructor_occupation (instructor_name text, period_season season, course_year int)
    RETURNS SETOF varchar
    AS $$
BEGIN
    RETURN query (
        SELECT
            c2.name
        FROM
            course c2
        WHERE (c2.season = period_season
            AND c2.year = course_year
            AND c2.course_id IN (
                SELECT
                    course_id
                FROM
                    teaches t2
                WHERE
                    t2.teaching_team_id IN (
                        SELECT
                            ti.teaching_team_id
                        FROM
                            teachingteam_instructor ti
                        WHERE
                            ti.instructor_id = (
                                SELECT
                                    i.instructor_id
                                FROM
                                    instructor i
                                WHERE
                                    i.name = instructor_name)))));
END
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

CREATE TRIGGER Max100TraineesPerCourse
    BEFORE INSERT ON enrollment
    FOR EACH ROW
    EXECUTE PROCEDURE max_100_trainees_per_course ();

CREATE TRIGGER CheckAvailability
    BEFORE INSERT ON enrollment
    FOR EACH ROW
    EXECUTE PROCEDURE check_max_courses_for_trainee ();
