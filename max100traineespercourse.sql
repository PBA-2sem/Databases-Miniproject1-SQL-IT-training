CREATE OR REPLACE FUNCTION max_100_trainees_per_course()
    RETURNS TRIGGER
    AS $$
BEGIN
    IF EXISTS (
        SELECT
            1
        FROM
            enrollment
        WHERE
            course_id = NEW.course_id
        HAVING
            COUNT(*) >= 100) THEN
    RAISE EXCEPTION 'A course must at maximum enroll 100 trainees';
END IF;
    RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';
CREATE TRIGGER Max100TraineesPerCourse
    BEFORE INSERT ON enrollment
    FOR EACH ROW
    EXECUTE PROCEDURE max_100_trainees_per_course();
