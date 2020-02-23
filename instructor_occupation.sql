-- Occupation of instructors during a certain period (season + year)
-- find instructor_id from given instructor_name, then
-- find instructors teaching_team_ids from instructor_id, then
-- find instructors course_id from teaching_team_id, then
-- find instructors course name from matching given period_season & course_year
CREATE OR REPLACE FUNCTION instructor_occupation(instructor_name  text, period_season season, course_year int)
returns setof varchar as 
$$ 
begin 
return query (
select c2.name from course c2
where (c2.season = period_season
and 
c2.year = course_year
and
c2.course_id IN (
select  course_id 
from teaches t2
where t2.teaching_team_id IN (
select ti.teaching_team_id from teachingteam_instructor ti
where ti.instructor_id = (
select i.instructor_id 
from instructor i
 where i.name = instructor_name)))
));
END
$$
LANGUAGE 'plpgsql';

--select instructor_occupation('HARRY', 'Spring',2020);
