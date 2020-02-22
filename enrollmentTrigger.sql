CREATE OR REPLACE FUNCTION check_max_courses_for_trainee() 
RETURNS trigger AS $$
DECLARE
	BEGIN
	IF EXISTS (SELECT 1 
				FROM enrollment JOIN course ON(enrollment.course_id = course.course_id)
				WHERE course.presence = TRUE
				AND enrollment.trainee_id = NEW.trainee_id 
				HAVING COUNT(*)>=1)
		THEN
		RAISE EXCEPTION 'Trainee is already assigned to a course';
		END IF;
	RAISE NOTICE '%', (SELECT name FROM trainee WHERE trainee_id = NEW.trainee_id);
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER CheckAvailability ON enrollment

CREATE TRIGGER CheckAvailability
	BEFORE INSERT ON enrollment
	FOR EACH ROW EXECUTE PROCEDURE check_max_courses_for_trainee();
	
	
	
