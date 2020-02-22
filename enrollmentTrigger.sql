CREATE OR REPLACE FUNCTION check_max_courses_for_trainee() 
RETURNS trigger AS $$
DECLARE
	BEGIN
	IF ((SELECT presence FROM course WHERE course_id = NEW.course_id) = 'false')
	THEN 
		IF EXISTS (SELECT 1 
				FROM enrollment JOIN course ON(enrollment.course_id = course.course_id)
				WHERE course.presence = 'false'
				AND enrollment.trainee_id = NEW.trainee_id 
				HAVING COUNT(*)>=3)
		THEN
		RAISE EXCEPTION 'Trainee is already assigned to 3 online courses';
		END IF;
	END IF;
	
	IF((SELECT presence FROM course WHERE course_id = NEW.course_id) = 'true')
	THEN
		IF EXISTS (SELECT 1 
				FROM enrollment JOIN course ON(enrollment.course_id = course.course_id)
				WHERE course.presence = 'true'
				AND enrollment.trainee_id = NEW.trainee_id 
				HAVING COUNT(*)>=1)
		THEN
		RAISE EXCEPTION 'Trainee is already assigned to an offline course';
		END IF;
	END IF;
	RAISE NOTICE 'You added %', (SELECT name FROM trainee WHERE trainee_id = NEW.trainee_id);
	RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER CheckAvailability
	BEFORE INSERT ON enrollment
	FOR EACH ROW EXECUTE PROCEDURE check_max_courses_for_trainee();
	
	
	
