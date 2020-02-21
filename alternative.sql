--######### TABLES #########

DROP TABLE IF EXISTS course CASCADE;
CREATE TABLE course (
    course_id SERIAL PRIMARY KEY,
    presence BOOLEAN NOT NULL,
    start_at DATE NOT NULL,
    end_at DATE NOT NULL,
    year INT NOT NULL
);

DROP TABLE IF EXISTS trainee CASCADE;
CREATE TABLE trainee (
    trainee_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS instructor CASCADE;
CREATE TABLE instructor (
    instructor_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS teaching_team CASCADE;
CREATE TABLE teaching_team (
    teaching_team_id SERIAL PRIMARY KEY
);

DROP TABLE IF EXISTS teachingteam_instructor CASCADE;
CREATE TABLE teachingteam_instructor (
    teaching_team_id INT,
    instructor_id INT,
    FOREIGN KEY (teaching_team_id) REFERENCES teaching_team(teaching_team_id),
    FOREIGN KEY (instructor_id) REFERENCES instructor(instructor_id),
    PRIMARY KEY (teaching_team_id, instructor_id)
);

DROP TABLE IF EXISTS enrollment CASCADE;
CREATE TABLE enrollment (
    trainee_id INT,
    course_id INT,
    graduated BOOLEAN NOT NULL,
    FOREIGN KEY (trainee_id) REFERENCES trainee(trainee_id),
    FOREIGN KEY (course_id) REFERENCES course(course_id),
    PRIMARY KEY (trainee_id, course_id)
);

DROP TABLE IF EXISTS teaches CASCADE;
CREATE TABLE teaches (
    teaching_team_id INT,
    course_id INT,
    FOREIGN KEY (teaching_team_id) REFERENCES teaching_team(teaching_team_id),
    FOREIGN KEY (course_id) REFERENCES course(course_id),
    PRIMARY KEY (teaching_team_id, course_id)
);


--######### FUNCTIONS #########

--https://w3resource.com/PostgreSQL/postgresql-triggers.php
CREATE OR REPLACE FUNCTION check_max_two_teams_for_instructors()
	RETURNS TRIGGER AS
$$
BEGIN
IF EXISTS (SELECT 1 
FROM teachingteam_instructor
WHERE instructor_id = NEW.instructor_id
HAVING COUNT(*)>= 2)
THEN 
RAISE EXCEPTION 'Instructor can only be allocated to two teaching teams at maximum'; 
END IF;
RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';


--######### TRIGGERS #########

Create Trigger MaxTwoTeamsPerInstructor
    BEFORE INSERT
    ON teachingteam_instructor 
    FOR EACH ROW
	EXECUTE PROCEDURE check_max_two_teams_for_instructors();


--######### TESTING #########

-- Create 3 teaching teams with id 1,2,3
INSERT INTO teaching_team (teaching_team_id) VALUES (1);
INSERT INTO teaching_team (teaching_team_id) VALUES (2);
INSERT INTO teaching_team (teaching_team_id) VALUES (3);

-- Create instructor, will get id 1
INSERT INTO instructor (name) VALUES ('HARRY');

-- assign instructor with id 1 to teaching team 1 and 2
INSERT INTO teachingteam_instructor (teaching_team_id, instructor_id) VALUES (1, 1);
INSERT INTO teachingteam_instructor (teaching_team_id, instructor_id) VALUES (2, 1);

-- Should fail
-- Instructor with id 1 cannot be assigned to teaching team 3, as he is already assigned to teaching team 1 and 2
INSERT INTO teachingteam_instructor (teaching_team_id, instructor_id) VALUES (3, 1); 