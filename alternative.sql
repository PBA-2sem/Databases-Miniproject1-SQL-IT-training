--######### TABLES #########

drop type if exists season cascade;
create type season as enum ('Spring', 'Summer', 'Fall', 'Winter');

DROP TABLE IF EXISTS course CASCADE;
CREATE TABLE course (
    course_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    presence BOOLEAN NOT NULL,
    season season not null, 
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


--######### CONSTRAINTS #########

ALTER TABLE course ADD CONSTRAINT unique_courses UNIQUE (name, presence, season, year);
ALTER TABLE trainee ADD CONSTRAINT unique_trainees UNIQUE (name, email);
ALTER TABLE instructor ADD CONSTRAINT unique_instructors UNIQUE (name);


--######### FUNCTIONS #########

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


--######### DUMMY DATA #########

-- Create Course
insert into course (name,presence, season, year) values ('Databases', true, 'Spring', 2020); -- "offline"
insert into course (name,presence, season, year) values ('Test', false, 'Spring', 2020); -- online
insert into course (name,presence, season, year) values ('Large Systems', false, 'Spring', 2020); -- online
insert into course (name,presence, season, year) values ('System Integration', false, 'Spring', 2020); -- online

-- Create Trainee
insert into trainee (name, email) values ('Mathias', 'm@email.com');
insert into trainee (name, email) values ('Stanislav', 's@email.com');
insert into trainee (name, email) values ('Andreas', 'a@email.com');
insert into trainee (name, email) values ('Alexander', 'aa@email.com');

-- Create Instructor, will get id 1
INSERT INTO instructor (name) VALUES ('HARRY');

-- Create 3 teaching teams with id 1,2,3
INSERT INTO teaching_team (teaching_team_id) VALUES (1);
INSERT INTO teaching_team (teaching_team_id) VALUES (2);
INSERT INTO teaching_team (teaching_team_id) VALUES (3);


-- TODO - Below should be handled by rule?

-- Assign instructor with id 1 to teaching team 1 and 2
INSERT INTO teachingteam_instructor (teaching_team_id, instructor_id) VALUES (1, 1);
INSERT INTO teachingteam_instructor (teaching_team_id, instructor_id) VALUES (2, 1);

-- Enrollment TODO
-- Teaches TODO


--######### TESTING #########

-- Should fail
-- Course with same name, presence, season, year cannot be inserted multiple times
-- insert into course (name,presence, season, year) values ('Databases', true, 'Spring', 2020);

-- Should fail
-- Trainee with same name, email cannot be inserted multiple times

-- Should fail
-- Instructor with same name cannot be inserted multiple times
--INSERT INTO instructor (name) VALUES ('HARRY');

-- TODO?
-- teaching_team 

-- Should fail
-- Instructor with id 1 cannot be assigned to teaching team 3, as he is already assigned to teaching team 1 and 2
-- INSERT INTO teachingteam_instructor (teaching_team_id, instructor_id) VALUES (3, 1); 

-- Enrollment TODO?

-- Teaches TODO?


