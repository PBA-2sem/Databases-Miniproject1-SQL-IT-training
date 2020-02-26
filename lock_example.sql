-- TO CREATE EXAMPLE FOR LOCK / RACE CONDITION

------- ADD this to constraint function
-- PERFORM pg_sleep(10);



----- ADD TO COURSE 1 (99 enrolled) THIS SHOULD BE RUN IN SEPERATE FILES
-- insert into enrollment (trainee_id, course_id, graduated) values (999, 1, TRUE);

-- insert into enrollment (trainee_id, course_id, graduated) values (1000, 1, TRUE);

------ HELPER STUFF
-- select * from enrollment e ;

-- delete from enrollment where trainee_id = 100;

