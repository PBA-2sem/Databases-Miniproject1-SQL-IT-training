CREATE OR REPLACE FUNCTION check_max_courses_for_trainee ()
     RETURNS TRIGGER AS $$
 DECLARE
    --presence text;
  --  season text;
--    year text;
 BEGIN
-- presence = 'SELECT presence FROM course WHERE course_id =' || NEW.course_id;
-- season = 'SELECT season FROM course WHERE course_id =' || NEW.course_id;
--year = 'SELECT year FROM course WHERE course_id =' || NEW.course_id;

 IF(SELECT 1 FROM enrollment JOIN course on (enrollment.course_id = course.course_id)
	WHERE enrollment.trainee_id = NEW.trainee_id 
	AND graduated = false 
	AND course.year = (SELECT course.year FROM course WHERE course_id = NEW.course_id)
	AND course.season = (SELECT course.season FROM course WHERE course_id = NEW.course_id)
	HAVING COUNT(*) >=1)
 THEN
 	IF((SELECT presence FROM course  WHERE course_id = NEW.course_id) = 'false')
	THEN
	RAISE NOTICE 'in false';
 		IF(SELECT 1 FROM enrollment JOIN course ON (enrollment.course_id = course.course_id)
		WHERE trainee_id = NEW.trainee_id 
		AND graduated = false 
		AND course.year = (SELECT course.year FROM course WHERE course_id = NEW.course_id)
		AND course.season = (SELECT course.season FROM course WHERE course_id = NEW.course_id)
		HAVING COUNT(*) >= 3)
		THEN
 		RAISE EXCEPTION 'Trainee is assigned to too many courses';
		END IF;
	END IF;
	IF((SELECT presence FROM course WHERE course_id = NEW.course_id) = 'true')
		THEN
			RAISE NOTICE 'in true';
			IF(SELECT 1 FROM enrollment JOIN course on (enrollment.course_id = course.course_id)
			WHERE trainee_id = NEW.trainee_id
			AND graduated = false 
			AND course.year = (SELECT course.year FROM course WHERE course_id = NEW.course_id)
			AND course.season = (SELECT course.season FROM course WHERE course_id = NEW.course_id)
		    HAVING COUNT(*) >= 1)
			THEN
			RAISE EXCEPTION 'Trainee is assigned to too many courses';
		END IF;
	END IF;
END IF;
 	RAISE NOTICE 'hej';
 	RETURN NEW;
 END;
$$
LANGUAGE plpgsql;
