CREATE OR REPLACE FUNCTION check_max_courses_for_trainee ()
     RETURNS TRIGGER AS $$
 DECLARE
 BEGIN
 	IF(((SELECT 1 FROM enrollment JOIN course on (enrollment.course_id = course.course_id)
    		WHERE enrollment.trainee_id = NEW.trainee_id 
   			AND graduated = false 
    		AND course.year = (SELECT course.year FROM course WHERE course_id = NEW.course_id)
   			AND course.season = (SELECT course.season FROM course WHERE course_id = NEW.course_id)
    		AND course.presence = 'false'
    		HAVING COUNT(*) = 0) AND 
   		    (SELECT presence FROM course WHERE course_id = NEW.course_id) = 'ture'))
			THEN
			IF(SELECT 1 FROM enrollment JOIN course ON (enrollment.course_id = course.course_id)
			WHERE trainee_id = NEW.trainee_id 
				AND graduated = false 
				AND presence = (SELECT presence FROM course WHERE course_id = NEW.course_id)
				AND course.year = (SELECT course.year FROM course WHERE course_id = NEW.course_id)
				AND course.season = (SELECT course.season FROM course WHERE course_id = NEW.course_id)
				HAVING COUNT(*) >= 3)
			THEN
 			RAISE EXCEPTION 'Trainee is assigned to too many courses';
	   		End if;
		--END IF;
	ELSIF(((SELECT 1 FROM enrollment JOIN course on (enrollment.course_id = course.course_id)
    		WHERE enrollment.trainee_id = NEW.trainee_id 
   			AND graduated = false 
    		AND course.year = (SELECT course.year FROM course WHERE course_id = NEW.course_id)
   			AND course.season = (SELECT course.season FROM course WHERE course_id = NEW.course_id)
    		AND course.presence = 'false'
    		HAVING COUNT(*) = 0) AND 
   			(SELECT presence FROM course WHERE course_id = NEW.course_id) = 'true'))
			THEN
				IF(SELECT 1 FROM enrollment JOIN course on (enrollment.course_id = course.course_id)
				WHERE trainee_id = NEW.trainee_id
				AND graduated = false
				AND presence = (SELECT presence FROM course WHERE course_id = NEW.course_id)
				AND course.year = (SELECT course.year FROM course WHERE course_id = NEW.course_id)
				AND course.season = (SELECT course.season FROM course WHERE course_id = NEW.course_id)
		    	HAVING COUNT(*) >= 1)
				THEN
				RAISE EXCEPTION 'Trainee is assigned to too many courses';
				END IF;
		END IF;
	--END IF;
 	RAISE NOTICE 'hej';
 	RETURN NEW;
 END;
$$
LANGUAGE plpgsql;