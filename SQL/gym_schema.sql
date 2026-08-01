CREATE DATABASE GYM;
USE GYM;

/*
Table Subscription
*/
CREATE TABLE SUBSCRIPTION_PLAN
(
Subscription_Plan VARCHAR(50) PRIMARY KEY,
Monthly_Price DECIMAL(6,2),
Features VARCHAR(255)

);

/*
Table Member
*/
CREATE TABLE MEMBER
(
User_ID VARCHAR(20) PRIMARY KEY,
First_Name varchar(50) ,
Last_Name varchar(50),
Age INT,
Gender VARCHAR(20),
Birthdate DATE,
Sign_up_Date DATE,
Location VARCHAR(50),
Subscription_Plan VARCHAR(50) NOT NULL,
foreign key (Subscription_Plan) REFERENCES SUBSCRIPTION_PLAN(Subscription_Plan)

);

/*
Table Gym branch
*/
CREATE TABLE GYM_BRANCH
(
Gym_ID VARCHAR(20) PRIMARY KEY,
Location VARCHAR(50),
gym_type VARCHAR(20)
);

/*
Table Facility
*/
CREATE TABLE FACILITY
(
Facility_ID INT auto_increment PRIMARY KEY,
Facility_Name VARCHAR(50)

);

/*
Table Gym Facility
*/
CREATE TABLE GYM_FACILITY
(
Gym_ID VARCHAR(20) NOT NULL,
Facility_ID INT NOT NULL,
PRIMARY KEY(Gym_ID,Facility_ID),
foreign key (Gym_ID) REFERENCES GYM_BRANCH(Gym_ID),
FOREIGN KEY (Facility_ID) REFERENCES FACILITY(Facility_ID)

);



/*
Table Workout Session
*/
CREATE TABLE WORKOUT_SESSION
(
Session_ID INT auto_increment PRIMARY KEY,
User_ID VARCHAR(20) NOT NULL,
Gym_ID VARCHAR(20) NOT NULL,
Checkin_Time DATETIME,
Checkout_Time DATETIME,
Workout_Type VARCHAR(50),
Calories_Burned INT,
FOREIGN KEY(User_ID) REFERENCES MEMBER(User_ID),
FOREIGN KEY (Gym_ID) REFERENCES GYM_BRANCH(Gym_ID)


);

/*
Show all the tables
 */
SHOW tables;

/*
Describe each table that we created
*/
DESC SUBSCRIPTION_PLAN;
DESC WORKOUT_SESSION;
DESC FACILITY;
DESC GYM_FACILITY;
DESC GYM_BRANCH;
DESC MEMBER;


/*
Show Foreign Keys
*/
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'GYM'
AND REFERENCED_TABLE_NAME IS NOT NULL;


/*
Testing rows of every table
*/
SELECT COUNT(*) FROM WORKOUT_SESSION; -- 304500
SELECT COUNT(*) FROM SUBSCRIPTION_PLAN; -- 3
SELECT COUNT(*) FROM GYM_BRANCH; -- 10
SELECT COUNT(*) FROM FACILITY; -- 6
SELECT COUNT(*) FROM GYM_FACILITY; -- 30



-- Insert facility names uniquely
INSERT INTO FACILITY (Facility_Name) VALUES
('Basketball Court'), 
('Climbing Wall'),
('CrossFit'),
('Sauna'),
('Swimming Pool'),
('Yoga Classes');

SELECT * FROM FACILITY;


-- Link each gym to its facilities
INSERT INTO GYM_FACILITY (Gym_ID, Facility_ID) VALUES
('gym_1', 2), ('gym_1', 5), ('gym_1', 1), -- Climbing Wall, Swimming Pool, Basketball Court
('gym_2', 2), ('gym_2', 6), ('gym_2', 4), -- Climbing Wall, Yoga Classes, Sauna
('gym_3', 4), ('gym_3', 2), ('gym_3', 5), -- Sauna, Climbing Wall, Swimming Pool
('gym_4', 2), ('gym_4', 1), ('gym_4', 5), -- Climbing Wall, Basketball Court, Swimming Pool
('gym_5', 1), ('gym_5', 3), ('gym_5', 5), -- Basketball Court, CrossFit, Swimming Pool
('gym_6', 5), ('gym_6', 2), ('gym_6', 4), -- Swimming Pool, Climbing Wall, Sauna
('gym_7', 4), ('gym_7', 1), ('gym_7', 5), -- Sauna, Basketball Court, Swimming Pool
('gym_8', 1), ('gym_8', 4), ('gym_8', 3), -- Basketball Court, Sauna, CrossFit
('gym_9', 4), ('gym_9', 3), ('gym_9', 6), -- Sauna, CrossFit, Yoga Classes
('gym_10', 5), ('gym_10', 4), ('gym_10', 3); -- Swimming Pool, Sauna, CrossFit


SELECT * FROM GYM_FACILITY;

-- join to see facility names instead of IDs
SELECT gf.Gym_ID, f.Facility_Name
FROM GYM_FACILITY gf
JOIN FACILITY f ON gf.Facility_ID = f.Facility_ID
ORDER BY CAST(SUBSTRING_INDEX(gf.Gym_ID, '_', -1) AS UNSIGNED);


select* from workout_session;

/*
Correct
*/
-- check datatime not empty
ALTER TABLE workout_session MODIFY Checkin_Time DATETIME NOT NULL;
-- check birthdate not empty
ALTER TABLE member MODIFY Birthdate DATE NOT NULL;
-- sign up date not empty
ALTER TABLE member MODIFY Sign_up_Date DATE NOT NULL;
-- add constraint checking age must be 18 or older
ALTER TABLE member ADD CONSTRAINT chk_age CHECK (Age >= 18);
-- Add index on Checkin_Time
CREATE INDEX idx_checkin ON workout_session(Checkin_Time);

SELECT COUNT(*) FROM workout_session WHERE Checkout_Time > Checkin_Time;
-- Discovered Issues
-- Checkout_Time NOT NULL -> fails, 6,082 real null exist.
-- Calories_Burned NOT NULL -> fails, 9,050 real null exist.
-- constraint chk_time (Checkout_Time > Checkin_Time) -> fails, 295,438 rows have checkout > checkin.
-- Duplicate rows -> 4,500 rows not yet removed.
-- Workout_Type inconsistent casing/whitespace -> 15,225 rows not yet standardized.



