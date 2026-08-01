use gym;

-- count number of session for each person

SELECT 
    m.User_ID,
    m.First_Name,
    m.Last_Name,
    COUNT(ws.Session_ID) AS Total_Sessions
FROM MEMBER m
LEFT JOIN workout_session ws ON m.User_ID = ws.User_ID
GROUP BY m.User_ID, m.First_Name, m.Last_Name
ORDER BY Total_Sessions DESC, m.First_Name;

-- Most common workout type for each subscription plan
SELECT 
sp.Subscription_Plan,
ws.Workout_Type,
COUNT(*) AS Frequency
FROM MEMBER m 
JOIN SUBSCRIPTION_PLAN sp ON m.Subscription_Plan=sp.Subscription_Plan
JOIN WORKOUT_SESSION ws ON m.User_ID=ws.User_ID
GROUP BY sp.Subscription_Plan,ws.Workout_Type
ORDER BY sp.Subscription_Plan,COUNT(*) DESC;

-- average Calories Burned for each person
SELECT
m.User_ID,
    m.First_Name,
    m.Last_Name,
    ROUND(AVG(ws.Calories_Burned),2) AS avg_calories
FROM MEMBER m JOIN WORKOUT_SESSION ws ON m.User_ID=ws.User_ID
GROUP BY m.User_ID,
    m.First_Name,
    m.Last_Name
ORDER BY AVG(ws.Calories_Burned) DESC;

-- Distribution of members by age and gender with their gym activity
SELECT
CASE
WHEN m.Age BETWEEN 18 AND 25 THEN '18-25'
WHEN m.Age BETWEEN 26 AND 35 THEN '26-35'
WHEN m.Age BETWEEN 36 AND 45 THEN '36-45' 
ELSE '46+'
END AS Age_Group,
m.Gender,
COUNT(DISTINCT m.User_ID) AS Total_Members,
COUNT(ws.Session_ID) AS Total_Sessions
FROM MEMBER m LEFT JOIN WORKOUT_SESSION ws ON m.User_ID=ws.User_ID
group by Age_Group,m.Gender
ORDER BY Age_Group;
-- -----------------------------------------------------------
-- Performance of each gym branch
SELECT
    gb.Gym_ID,
    gb.Location,
    COUNT(ws.Session_ID) AS Total_Sessions,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, ws.Checkin_Time, ws.Checkout_Time)),2) AS Avg_Session_Duration_Minutes
FROM gym_branch gb
LEFT JOIN workout_session ws
ON gb.Gym_ID = ws.Gym_ID
GROUP BY gb.Gym_ID, gb.Location
ORDER BY Total_Sessions DESC;


-- Peak Hours Distribution by Branch
SELECT
    gb.Location,
    HOUR(ws.Checkin_Time) AS Peak_Hour,
    COUNT(*) AS Number_of_Sessions
FROM workout_session ws
JOIN gym_branch gb
ON ws.Gym_ID = gb.Gym_ID
GROUP BY gb.Location, HOUR(ws.Checkin_Time)
ORDER BY gb.Location, Number_of_Sessions DESC;

-- Most Crowded Hour for Each Branch

WITH PeakHours AS (
    SELECT
        gb.Location,
        HOUR(ws.Checkin_Time) AS Peak_Hour,
        COUNT(*) AS Number_of_Sessions,
        ROW_NUMBER() OVER(
            PARTITION BY gb.Location
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM workout_session ws
    JOIN gym_branch gb
        ON ws.Gym_ID = gb.Gym_ID
    GROUP BY gb.Location, HOUR(ws.Checkin_Time)
)

SELECT
    Location,
    Peak_Hour,
    Number_of_Sessions
FROM PeakHours
WHERE rn = 1
ORDER BY Location;

-- Facilities vs Gym Usage
SELECT
    f.Facility_Name,
    COUNT(ws.Session_ID) AS Total_Sessions
FROM facility f
JOIN gym_facility gf
ON f.Facility_ID = gf.Facility_ID
LEFT JOIN workout_session ws
ON gf.Gym_ID = ws.Gym_ID
GROUP BY f.Facility_Name
ORDER BY Total_Sessions DESC;

-- Gym Type Performance Comparison
SELECT
    gb.gym_type,
    COUNT(DISTINCT gb.Gym_ID) AS Number_of_Branches,
    COUNT(ws.Session_ID) AS Total_Sessions,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, ws.Checkin_Time, ws.Checkout_Time)),2) AS Avg_Duration,
    SUM(ws.Calories_Burned) AS Total_Calories,
    ROUND(AVG(ws.Calories_Burned),2) AS Avg_Calories
FROM gym_branch gb
LEFT JOIN workout_session ws
ON gb.Gym_ID = ws.Gym_ID
GROUP BY gb.gym_type
ORDER BY Total_Calories DESC;

-- Top Gym Branches by Calories Burned
SELECT
    gb.Gym_ID,
    gb.Location AS Branch,
    SUM(ws.Calories_Burned) AS Total_Calories
FROM gym_branch gb
JOIN workout_session ws
ON gb.Gym_ID = ws.Gym_ID
GROUP BY gb.Gym_ID, gb.Location
ORDER BY Total_Calories DESC;
commit;



