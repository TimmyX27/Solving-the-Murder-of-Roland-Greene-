-- Solving the Murder of Roland Greene

-- Project Overview 
-- This is a data-driven investigation into the murder of Roland Greene, a well-known art collector, who was
-- found dead in the vault room of his private estate at 8:00pm shortly after receiving a call at 7:55pm. Though
-- all 30 guests claim to have alibis, only one is lying. 

-- Analyst's Task
-- You have been assigned as the analyst to solve this murder by analyzing a collection of digital evidence to identify 
-- inconsistencies and zero in on the killer. 





-- Task 1: Import all the necessary datasets and information given.
CREATE TABLE 
	suspects_large(suspect_id INTEGER, name VARCHAR, role VARCHAR, relation_to_victim VARCHAR,
					alibi VARCHAR);

CREATE TABLE
	forensic_events_large(event_time TIMESTAMP, event_description VARCHAR);

CREATE TABLE
	call_records_large(call_id INTEGER, suspect_id INTEGER, call_time TIMESTAMP, call_duration VARCHAR,
						recipient_relation VARCHAR);

CREATE TABLE 
	access_logs_records(log_id INTEGER, suspect_id INTEGER, access_time TIMESTAMP,
						door_accessed VARCHAR, success_flag BOOLEAN);










-- Task 2: We will start by looking into the Evidence-Based Questions. 

-- Was anyone in the Vault Room shortly before or after the murder time (8pm)?
SELECT s.name, s.role, s.relation_to_victim, a.access_time, a.door_accessed, a.success_flag
FROM access_logs_records AS a
JOIN suspects_large AS s
	ON a.suspect_id = s.suspect_id
WHERE access_time BETWEEN '2025-06-01 19:55:00' AND '2025-06-01 20:05:00'
	AND door_accessed = 'Vault Room'
	AND success_flag = 'true';

-- New Evidence: Three persons accessed the Vault Room, shortly before and also after the murder time. 
-- Robin Ahmed, the Family Doctor at 7:56:35pm, 
-- Victor Shaw, the PR Manager at 8:04:53pm, and
-- Jamie Bennett, the cleaner at 8:00:55pm. 



-- What does the call log reveal about the final phone call? 
-- Roland Greene was said to have received a phone call at 7:55pm. 
SELECT s.name, s.role, s.relation_to_victim, c.call_time, c.call_duration, c.recipient_relation
FROM call_records_large AS c
JOIN suspects_large AS s
	ON c.suspect_id = s.suspect_id
WHERE call_time BETWEEN '2025-06-01 19:55:00' AND '2025-06-01 20:05:00'
	AND recipient_relation = 'Victim';

-- New Evidence: Roland Greene spoke to two persons before he was shot at 8:00pm.
-- He spoke to Victor Hale, the Driver at 7:55:45pm. This call lasted for 1 minute. 
-- He then spoke to Susan Knight, the Chef at 7:56:39pm. This call lasted for 6 minutes. 

-- Analyst's Thought: Susan Knight probably heard the gunshot as He was shot while on the call with her. 



-- Are there any inconsistencies between door access logs and alibi claims? 
SELECT s.name, s.role, s.relation_to_victim, a.access_time, a.door_accessed, a.success_flag, s.alibi
FROM access_logs_records AS a
JOIN suspects_large AS s
	ON a.suspect_id = s.suspect_id
WHERE access_time BETWEEN '2025-06-01 19:55:00' AND '2025-06-01 20:05:00'
	AND door_accessed = 'Vault Room'
	AND success_flag = 'true';

-- Analyst's Thought: Robin Ahmed is the only person confirmed inside the Vault Room with Roland during the pre-gunshot window, 8pm.
-- Robin's Alibi: “Left early” is clearly false, because logs show he was in the Vault.

-- Jamie Bennett entered right after the gunshot. Her alibi is also false. She is not the shooter, more like a witness or she 
-- discovered Roland's body. 

-- Victor Shaw entered also entered after the murder at 8:04:53pm. His alibi, "at home" is also completely false. 



-- What does the Forensic timeline say about the time and manner of death? 
SELECT *
FROM forensic_events_large
ORDER BY event_time ASC;

-- New Evidence: The victim was last seen alive at 7:57pm,
-- A gunshot was heard at 8:00pm,
-- Motion was detected in the Vault Hallway at 8:01:15,
-- The security feed was cut at 8:03pm, and
-- An emergency call was placed from the mansion at 8:05:45.










-- Task 3: Let's dig deeper into the timeline insights. 

-- Which suspect's movement pattern overlaps with critical time windows? 
SELECT s.name, a.door_accessed, a.access_time, s.alibi, f.event_description, f.event_time
FROM access_logs_records AS a
JOIN suspects_large AS s 
	ON a.suspect_id = s.suspect_id
JOIN forensic_events_large AS f 
  ON a.access_time BETWEEN f.event_time - INTERVAL '1 minute' 
                       AND f.event_time + INTERVAL '1 minute'
WHERE door_accessed = 'Vault Room'
ORDER BY a.access_time ASC;

-- New Evidence: Robin Ahmed, Jamie Bennett and Victor Shaw. 



-- How do the data sources contradict or confirm one another? 

-- Robin Ahmed is shown in the Vault Room at 7:56:35pm, moments before the victim was last seen alive at 19:57pm. 
-- This confirms he was with Roland just before the gunshot at 8:00pm. His alibi (“Left early”) is contradicted by the 
-- access logs, which place him at the scene during the murder window.

-- Jamie Bennett entered the Vault Room at 8:00:55pm, just seconds after the gunshot and before the motion was detected
-- in the hallway at 8:01:15pm. This timing confirms she likely triggered the motion sensor, but her alibi (“At home”) 
-- is contradicted access by the logs. The evidence suggests she arrived after the murder rather than committing it.

-- Victor Shaw accessed the Vault Room at 8:04:53pm, after the security feed had been cut at 8:03pm and shortly before the 
-- emergency call at 8:05:45. His alibi (“At hospital”) is contradicted by the access logs, confirming his presence at the scene, 
-- but only after the crime had already occurred.


