--######### DUMMY DATA #########
-- Create Course

INSERT INTO course (name, presence, season, year)
    VALUES ('Databases', TRUE, 'Spring', 2020);

-- "offline"
INSERT INTO course (name, presence, season, year)
    VALUES ('Test', FALSE, 'Spring', 2020);

-- online
INSERT INTO course (name, presence, season, year)
    VALUES ('Large Systems', FALSE, 'Spring', 2020);

-- online
INSERT INTO course (name, presence, season, year)
    VALUES ('System Integration', FALSE, 'Spring', 2020);

-- online
-- Create Trainee

INSERT INTO trainee (name, email)
    VALUES ('Mathias', 'm@email.com');

INSERT INTO trainee (name, email)
    VALUES ('Stanislav', 's@email.com');

INSERT INTO trainee (name, email)
    VALUES ('Andreas', 'a@email.com');

INSERT INTO trainee (name, email)
    VALUES ('Alexander', 'aa@email.com');

-- Create Instructor, will get id 1
INSERT INTO instructor (name)
    VALUES ('HARRY');

INSERT INTO instructor (name)
    VALUES ('HERMIONE');

-- Create 3 teaching teams with id 1,2,3
INSERT INTO teaching_team (teaching_team_id)
    VALUES (1);

INSERT INTO teaching_team (teaching_team_id)
    VALUES (2);

INSERT INTO teaching_team (teaching_team_id)
    VALUES (3);

-- Assign instructor with id 1 to teaching team 1 and 2
INSERT INTO teachingteam_instructor (teaching_team_id, instructor_id)
    VALUES (1, 1);

INSERT INTO teachingteam_instructor (teaching_team_id, instructor_id)
    VALUES (2, 1);

INSERT INTO teachingteam_instructor (teaching_team_id, instructor_id)
    VALUES (1, 2);

-- Enrollment TODO
-- Asssign teaching team to course

INSERT INTO teaches (teaching_team_id, course_id)
    VALUES (1, 1);