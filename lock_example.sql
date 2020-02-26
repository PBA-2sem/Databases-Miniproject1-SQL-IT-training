-- TO CREATE EXAMPLE FOR LOCK / RACE CONDITION

------- ADD this to constraint function
-- CREATE OR REPLACE FUNCTION max_100_trainees_per_course ()
--     RETURNS TRIGGER
--     AS $$
-- BEGIN
--     -- LOCK TABLE enrollment;
--     IF EXISTS (
--         SELECT
--             1
--         FROM
--             enrollment
--         WHERE
--             course_id = NEW.course_id
--         HAVING
--             COUNT(*) >= 100) THEN
--     RAISE EXCEPTION 'A course must at maximum enroll 100 trainees';
-- END IF;
--     PERFORM pg_sleep(10);
--     RETURN NEW;
-- END;
-- $$
-- LANGUAGE 'plpgsql';



----- ADD TO COURSE 1 (99 enrolled) THIS SHOULD BE RUN IN SEPERATE FILES
-- insert into enrollment (trainee_id, course_id, graduated) values (999, 1, TRUE);

-- insert into enrollment (trainee_id, course_id, graduated) values (1000, 1, TRUE);

------ HELPER STUFF
-- select * from enrollment e ;

-- delete from enrollment where trainee_id = 100;

