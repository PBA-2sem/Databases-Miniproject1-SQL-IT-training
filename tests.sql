--######### TESTING CONSTRAINS #########
-- Should fail
-- Course with same name, presence, season, year cannot be inserted multiple times
-- insert into course (name,presence, season, year) values ('Databases', true, 'Spring', 2020);

-- Should fail
-- Trainee with same email cannot be inserted multiple times
-- insert into trainee (name, email) values ('Mathias', 'm@email.com');

-- Should fail
-- Add Trainee number 101 to course (course 11 LSD)
-- insert into enrollement (trainee_id, course_id, graduated) values (11, 1, FALSE);

-- Should fail
-- Instructor with id 1 cannot be assigned to teaching team 3, as he is already assigned to teaching team 1 and 15
-- INSERT INTO teachingteam_instructor (teaching_team_id, instructor_id) VALUES (3, 1);

-- Should fail
-- Assigning teaching team 8 to course 8 should not be possible (cause team 8 only has 1 member)
-- insert into teaches (teaching_team_id, course_id) values (8,8);

--######### TESTING FUNCTIONS #########

-- Should return instructor occupation in spring of 2020
-- select instructor_occupation('Rae', 'Spring', 2020);


-- -- Should return most popular courses
-- SELECT (Select course.name from course where course_id = enrollment.course_id), 
-- COUNT(enrollment.course_id) 
-- FROM enrollment 
-- GROUP BY name
-- ORDER BY count(course_id) desc

-- -- Current availability: Returns all available courses by counting the numbers of attendees on the course
-- SELECT (Select name from course where course_id = enrollment.course_id), (Select season from course where course_id = enrollment.course_id),(Select "year" from course where course_id = enrollment.course_id),
-- 100-count(enrollment.course_id) AS "Availability"
-- From enrollment Group by enrollment.course_id, enrollment.graduated 
-- Having COUNT(*)<=99
-- and graduated = false
-- ORDER BY count(enrollment.course_id) ASC;
 

-- Should 
--######### TESTING USER RIGHTS #########

-- SUPERUSER (Principal / office clerk)
-- INSTRUCTOR / TRAINEE