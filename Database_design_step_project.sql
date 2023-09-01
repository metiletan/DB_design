-- Database design

CREATE DATABASE courses;
USE courses;
-- a.students: student_no, teacher_no, course_no, student_name, email, birth_date.

CREATE TABLE students (
    student_no INT NOT NULL,
    teacher_no INT NOT NULL,
    course_no INT NOT NULL,
    student_name VARCHAR(80),
    email VARCHAR(50),
    birth_date DATE NOT NULL,
    PRIMARY KEY (student_no, birth_date)
);
ALTER TABLE students
	PARTITION BY RANGE (YEAR(birth_date)) (
    PARTITION p1985  VALUES LESS THAN (1986),
	PARTITION p1986  VALUES LESS THAN (1987),
    PARTITION p1987  VALUES LESS THAN (1988),
    PARTITION p1988  VALUES LESS THAN (1989),
    PARTITION p1989  VALUES LESS THAN (1990),
    PARTITION p1990  VALUES LESS THAN (1991),
    PARTITION p1991  VALUES LESS THAN (1992),
    PARTITION p1992  VALUES LESS THAN (1993),
    PARTITION p1993  VALUES LESS THAN (1994),
    PARTITION p1994  VALUES LESS THAN (1995),
    PARTITION p1995  VALUES LESS THAN (1996),
    PARTITION p1996  VALUES LESS THAN (1997),
    PARTITION p1997  VALUES LESS THAN (1998),
    PARTITION p1998  VALUES LESS THAN (1999),
    PARTITION p1999  VALUES LESS THAN (2000),
    PARTITION p2000  VALUES LESS THAN (2001),
    PARTITION p2001  VALUES LESS THAN (2002),
    PARTITION p2002  VALUES LESS THAN (2003)
    );

CREATE INDEX idx_students_email ON courses.students (email);

-- b.teachers: teacher_no, teacher_name, phone_no
CREATE TABLE teachers (
    teacher_no INT NOT NULL,
    teacher_name VARCHAR(80),
    phone_no VARCHAR(20)
);
CREATE UNIQUE INDEX idx_teachers_phone_no ON courses.teachers (phone_no);

-- c.courses: course_no, course_name, start_date, end_date.
CREATE TABLE courses (
    course_no INT NOT NULL,
    course_name VARCHAR(150),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL
);

-- 2. Add test data

INSERT INTO students VALUES (101, 201, 3, 'Chernova Regina', 'regina@gmail.com', '1985-01-01'),
							(102, 201, 2, 'Aronova Marina', 'arna@gmail.com', '1992-06-22'),
                            (103, 202, 3, 'Denisov Igor', 'irg@gmail.com', '2000-07-23'),
                            (104, 202, 6, 'Belov Ivan', 'biv@gmail.com', '1999-04-11'),
                            (105, 203, 2, 'Gogol Petro', 'gopet@gmail.com', '1989-06-01'),
                            (106, 203, 3, 'Mummed Arham', 'mumarh@gmail.com', '1988-03-15'),
                            (107, 203, 6, 'Zuikova Anna', 'zuiann@gmail.com', '1995-06-07');
                               
INSERT INTO teachers VALUES (201, 'Odyntsov Ivan', '+380987651344'),
							(202,'Burkun Ksenia', '+380679951355'),
                            (203, 'Ponomaryov Igor', '+380738653374');
                            
INSERT INTO courses VALUES (2, 'Business Intelligence', '2022-01-08', '2022-06-08'),
							(3,'Basics of SQL', '2022-04-12', '2022-10-12'),
                            (6, 'JavaScript', '2022-06-08', '2022-12-08');
                            
-- 3. Work with db

EXPLAIN SELECT * FROM courses.students PARTITION (p1992);
-- # id, select_type, table, partitions, type, possible_keys, key, key_len, ref, rows, filtered, Extra
-- '1', 'SIMPLE', 'students', 'p1992', 'ALL', NULL, NULL, NULL, NULL, '1', '100.00', NULL

-- 4. Work with db

EXPLAIN SELECT * FROM courses.teachers
WHERE phone_no = '+380987651344';
-- # id, select_type, table, partitions, type, possible_keys, key, key_len, ref, rows, filtered, Extra
-- '1', 'SIMPLE', 'teachers', NULL, 'const', 'idx_teachers_phone_no', 'idx_teachers_phone_no', '83', 'const', '1', '100.00', NULL

ALTER TABLE teachers ALTER INDEX idx_teachers_phone_no INVISIBLE;
EXPLAIN SELECT * FROM courses.teachers
WHERE phone_no = '+380987651344';
-- # id, select_type, table, partitions, type, possible_keys, key, key_len, ref, rows, filtered, Extra
-- '1', 'SIMPLE', 'teachers', NULL, 'ALL', NULL, NULL, NULL, NULL, '3', '33.33', 'Using where'

-- 5. Work with duplicate values
INSERT INTO students VALUES (110, 201, 3, 'Lykov Alexandr', 'lyalex@gmail.com', '1989-09-17'),
							(111, 201, 3, 'Lykov Alexandr', 'lyalex@gmail.com', '1989-09-17'),
                            (112, 201, 3, 'Lykov Alexandr', 'lyalex@gmail.com', '1989-09-17');
                            
-- 6. Work with duplicate values
SELECT *
FROM students
WHERE email IN (
	SELECT email
	FROM students
	GROUP BY email
	HAVING COUNT(student_name) > 1
);

