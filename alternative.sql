######### TABLES #########

DROP TABLE IF EXISTS course;
CREATE TABLE course (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    presence BOOLEAN NOT NULL,
    start_at DATE NOT NULL,
    end_at DATE NOT NULL,
    year INT NOT NULL
);

DROP TABLE IF EXISTS trainee;
CREATE TABLE trainee (
    trainee_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS instructor;
CREATE TABLE instructor (
    instructor_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS teaching_team;
CREATE TABLE teaching_team (
    teaching_team_id INT AUTO_INCREMENT PRIMARY KEY
);

DROP TABLE IF EXISTS teachingteam_instructor;
CREATE TABLE teachingteam_instructor (
    teaching_team_id INT,
    instructor_id INT,
    FOREIGN KEY (teaching_team_id) REFERENCES teaching_team(teaching_team_id),
    FOREIGN KEY (instructor_id) REFERENCES instructor(instructor_id),
    PRIMARY KEY (teaching_team_id, instructor_id)
);

DROP TABLE IF EXISTS enrollment;
CREATE TABLE enrollment (
    trainee_id INT,
    course_id INT,
    graduated BOOLEAN NOT NULL,
    FOREIGN KEY (trainee_id) REFERENCES trainee(trainee_id),
    FOREIGN KEY (course_id) REFERENCES course(course_id),
    PRIMARY KEY (trainee_id, course_id)
);

DROP TABLE IF EXISTS teaches;
CREATE TABLE teaches (
    teaching_team_id INT,
    course_id INT,
    FOREIGN KEY (teaching_team_id) REFERENCES teaching_team(teaching_team_id),
    FOREIGN KEY (course_id) REFERENCES course(course_id),
    PRIMARY KEY (teaching_team_id, course_id)
);

######### CONSTRAINTS #########

# Den nedstående DELIMITER TING var åbenbart nødvendig for at syntaksen
# for Trigger'en var valid. wodoo magic

DELIMITER /
Create Trigger MaxTwoTeamsPerInstructor
    Before Insert
    On teachingteam_instructor 
    For Each Row
Begin

If Exists (
	Select 1
	From teachingteam_instructor
	Where instructor_id = New.instructor_id
	Having Count(*) >= 2 -- Max count - 1
	)
THEN	
   SIGNAL SQLSTATE '45000' 
   SET MESSAGE_TEXT = 'Instructor can only be allocated to two teaching teams at maximum';
END IF;

End; /


INSERT INTO teaching_team (teaching_team_id) VALUES (0); /
INSERT INTO teaching_team (teaching_team_id) VALUES (0); / 
INSERT INTO teaching_team (teaching_team_id) VALUES (0); /

INSERT INTO instructor (name) VALUES ('HARRY'); /

INSERT INTO teachingteam_instructor (teaching_team_id, instructor_id) VALUES (1, 1) /
INSERT INTO teachingteam_instructor (teaching_team_id, instructor_id) VALUES (2, 1) /

# Instructor med ID 1 kan nu ikke sættes på teaching team 3, da han allerede er på 1 & 2.
INSERT INTO teachingteam_instructor (teaching_team_id, instructor_id) VALUES (3, 1) /

select * from teaching_team; /
select * from teachingteam_instructor; /


