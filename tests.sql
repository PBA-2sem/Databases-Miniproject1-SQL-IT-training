
--######### TESTING CONSTRAINS #########
-- Should fail
-- Course with same name, presence, season, year cannot be inserted multiple times
-- insert into course (name,presence, season, year) values ('Databases', true, 'Spring', 2020);

-- Should fail
-- Trainee with same name, email cannot be inserted multiple times
--insert into trainee (name, email) values ('Mathias', 'm@email.com');

-- Should fail
-- Add Trainee number 101 to course (course 11 LSD)
-- insert into enrollement (trainee_id, course_id, graduated) values (11, 1, FALSE);

-- Should fail
-- Instructor with same name cannot be inserted multiple times
--INSERT INTO instructor (name) VALUES ('HARRY');

-- Should fail
-- Instructor with id 1 cannot be assigned to teaching team 3, as he is already assigned to teaching team 1 and 15
-- INSERT INTO teachingteam_instructor (teaching_team_id, instructor_id) VALUES (3, 1);

-- Should fail
-- Assigning teaching team 8 to course 8 should not be possible (cause team 8 only has 1 member)
-- insert into teaches (teaching_team_id, course_id) values (8,8);

--######### TESTING FUNCTIONS #########

-- Should return instructor occupation in spring of 2020
-- select instructor_occupation('Rae', 'Spring', 2020);

-- Should 
--######### TESTING USER RIGHTS #########

-- ADMIN
-- SUPERUSER (Principal / office clerk)
-- INSTRUCTOR / TRAINEE