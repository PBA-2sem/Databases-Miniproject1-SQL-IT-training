--Search names of graduates that have completed (graduated) a specific course
-- select trainees_graduated_course ('Databases')
CREATE OR REPLACE FUNCTION trainees_graduated_course (course_name text)
RETURNS setof varchar as 
	$$ 
	begin 
	return query (
		select t.name 
		from trainee t
		inner join enrollment e
		on e.graduated = true
		and 
		e.course_id = (select c.course_id 
		from course c
		where c.name = course_name));
	END
	$$
LANGUAGE 'plpgsql';


drop function instructor_occupation(instructor_name  text, season text, year int);
--Occupation of instructors during a certain period (season + year)
CREATE OR REPLACE FUNCTION instructor_occupation(instructor_name  text, season text, year int)
returns setof int as 
$$ 
begin 
return query ( 
select ti.teaching_team_id from teachingteam_instructor ti
where ti.instructor_id = (
	select i.instructor_id 
	from instructor i
	 where i.name = instructor_name));
END
$$
LANGUAGE 'plpgsql';
  -- de 2 teaching teams som harry er på - TODO corse de teams er på..

select instructor_occupation('HARRY', 'Spring',2020);