-- Create tables
CREATE TABLE Crime (
 CrimeID INT PRIMARY KEY,
 IncidentType VARCHAR(255),
 IncidentDate DATE,
 Location VARCHAR(255),
 Description TEXT,
 Status VARCHAR(20)
);
CREATE TABLE Victim (
 VictimID INT PRIMARY KEY,
 CrimeID INT,
 Name VARCHAR(255),
 ContactInfo VARCHAR(255),
 Injuries VARCHAR(255),
 FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
);CREATE TABLE Suspect (
 SuspectID INT PRIMARY KEY,
 CrimeID INT,
 Name VARCHAR(255),
 Description TEXT,
 CriminalHistory TEXT,
 FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
);
-- Insert sample data
INSERT INTO Crime (CrimeID, IncidentType, IncidentDate, Location, Description, Status)
VALUES
 (1, 'Robbery', '2023-09-15', '123 Main St, Cityville', 'Armed robbery at a convenience store', 'Open'),
 (2, 'Homicide', '2023-09-20', '456 Elm St, Townsville', 'Investigation into a murder case', 'Under
Investigation'),
 (3, 'Theft', '2023-09-10', '789 Oak St, Villagetown', 'Shoplifting incident at a mall', 'Closed');
INSERT INTO Victim (VictimID, CrimeID, Name, ContactInfo, Injuries)
VALUES
 (1, 1, 'John Doe', 'johndoe@example.com', 'Minor injuries'),
 (2, 2, 'Jane Smith', 'janesmith@example.com', 'Deceased'), (3, 3, 'Alice Johnson', 'alicejohnson@example.com', 'None');
INSERT INTO Suspect (SuspectID, CrimeID, Name, Description, CriminalHistory)
VALUES
 (1, 1, 'Robber 1', 'Armed and masked robber', 'Previous robbery convictions'),
 (2, 2, 'Unknown', 'Investigation ongoing', NULL),
 (3, 3, 'Suspect 1', 'Shoplifting suspect', 'Prior shoplifting arrests');--1.Select all open incidentsSELECT * FROM Crime WHERE Status = 'Open';
--2.Find the total number of incidents
SELECT COUNT(*)FROM Crime;
--3.List all unique incident types
SELECT DISTINCT IncidentType FROM Crime;
--4.Retrieve incidents that occurred between '2023-09-01' and '2023-09-10'
SELECT * FROM Crime WHERE IncidentDate BETWEEN '2023-09-01' AND '2023-09-10';
--5.List persons involved in incidents in descending order of age
SELECT Name FROM (
    SELECT Name FROM Victim
    UNION ALL
    SELECT Name FROM Suspect
) AS CombinedNames
ORDER BY Name DESC;
--Alter tables
ALTER TABLE Victim ADD BirthDate DATE;
ALTER TABLE Suspect ADD BirthDate DATE;
--Sample data for Victim table
--Update birthdates for Victims
UPDATE Victim
SET BirthDate = '1990-01-01'
WHERE VictimID = 1;
UPDATE Victim
SET BirthDate = '1992-05-15'
WHERE VictimID = 2;
UPDATE Victim
SET BirthDate = '1989-03-08'
WHERE VictimID = 3;
--Update birthdates for Suspects
UPDATE Suspect
SET BirthDate = '1985-01-01'
WHERE SuspectID = 1;
UPDATE Suspect
SET BirthDate = '1988-08-20'
WHERE SuspectID = 2;
UPDATE Suspect
SET BirthDate = '1980-04-10'
WHERE SuspectID = 3; 
--6.Find the average age of persons involved in incidents.
SELECT AVG(Age) AS AverageAge
FROM (
    SELECT FLOOR(DATEDIFF(YEAR, BirthDate, GETDATE())) AS Age
    FROM (
        SELECT BirthDate FROM Victim
        UNION ALL
        SELECT BirthDate FROM Suspect
    ) AS AllPersons
) AS Ages;
--7.List incident types and their counts, only for open cases
SELECT IncidentType, COUNT(*) FROM Crime WHERE Status = 'Open' GROUP BY IncidentType;
--8.Find persons with names containing 'Doe'
WITH VictimNames AS (
    SELECT CAST(Name AS VARCHAR(MAX)) AS Name FROM Victim WHERE Name LIKE '%Doe%'
),
SuspectNames AS (
    SELECT CAST(Name AS VARCHAR(MAX)) AS Name FROM Suspect WHERE Name LIKE '%Doe%'
)
SELECT * FROM VictimNames
UNION
SELECT * FROM SuspectNames;
--9.Retrieve the names of persons involved in open cases and closed cases
SELECT Name FROM Victim
WHERE CrimeID IN (SELECT CrimeID FROM Crime WHERE Status = 'Open')
UNION
SELECT Name FROM Suspect
WHERE CrimeID IN (SELECT CrimeID FROM Crime WHERE Status = 'Open')
UNION
SELECT Name FROM Victim
WHERE CrimeID IN (SELECT CrimeID FROM Crime WHERE Status = 'Closed')
UNION
SELECT Name FROM Suspect
WHERE CrimeID IN (SELECT CrimeID FROM Crime WHERE Status = 'Closed');
--10.List incident types where there are persons aged 30 or 35 involved
SELECT DISTINCT c.IncidentType
FROM Crime c
JOIN (
    SELECT CrimeID, BirthDate FROM Victim
    UNION
    SELECT CrimeID, BirthDate FROM Suspect
) AS AllPersons ON c.CrimeID = AllPersons.CrimeID
WHERE FLOOR(DATEDIFF(YEAR, AllPersons.BirthDate, GETDATE()) / 365) IN (30, 35);
--11.Find persons involved in incidents of the same type as 'Robbery'
SELECT Name FROM Victim
WHERE CrimeID IN (SELECT CrimeID FROM Crime WHERE IncidentType = 'Robbery')
UNION
SELECT Name FROM Suspect
WHERE CrimeID IN (SELECT CrimeID FROM Crime WHERE IncidentType = 'Robbery');
--12.List incident types with more than one open case
SELECT IncidentType, COUNT(*) FROM Crime
WHERE Status = 'Open'
GROUP BY IncidentType HAVING COUNT(*) > 1;
--13.List all incidents with suspects whose names also appear as victims in other incidents
SELECT c.*, v.Name AS VictimName
FROM Crime c
JOIN Suspect s ON c.CrimeID = s.CrimeID
JOIN Victim v ON c.CrimeID = v.CrimeID AND s.Name = v.Name;
--14.Retrieve all incidents along with victim and suspect details
SELECT c.*, v.Name AS VictimName, s.Name AS SuspectName FROM Crime c
LEFT JOIN Victim v ON c.CrimeID = v.CrimeID
LEFT JOIN Suspect s ON c.CrimeID = s.CrimeID;
--15.Find incidents where the suspect is older than any victim
SELECT c.* FROM Crime c
JOIN Victim v ON c.CrimeID = v.CrimeID
JOIN Suspect s ON c.CrimeID = s.CrimeID
WHERE s.BirthDate > v.BirthDate;
--16.Find suspects involved in multiple incidents
SELECT SuspectID, Name FROM Suspect
GROUP BY SuspectID, Name
HAVING COUNT(CrimeID) > 1;
--17.List incidents with no suspects involved
SELECT * FROM Crime
WHERE CrimeID NOT IN (SELECT CrimeID FROM Suspect);
--18.List all cases where at least one incident is of type 'Homicide' and all other incidents are of type 'Robbery'
SELECT * FROM Crime
WHERE IncidentType = 'Homicide'
AND CrimeID IN (SELECT CrimeID FROM Crime WHERE IncidentType = 'Robbery');
--19.Retrieve a list of all incidents and the associated suspects, showing suspects for each incident, or 'No Suspect' if there are none
SELECT c.CrimeID, c.IncidentType, c.IncidentDate, 
    COALESCE(s.Name, 'No Suspect') AS SuspectName
FROM Crime c
LEFT JOIN Suspect s ON c.CrimeID = s.CrimeID;
--20.List all suspects who have been involved in incidents with incident types 'Robbery' or 'Assault'
SELECT s.* FROM Suspect s
JOIN (
    SELECT DISTINCT CrimeID
    FROM Crime
    WHERE IncidentType IN ('Robbery', 'Assault')
) AS filteredCrimes
ON s.CrimeID = filteredCrimes.CrimeID;