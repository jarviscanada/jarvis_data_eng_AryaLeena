-- Display the latest 5 host usage records
SELECT *
FROM host_usage
ORDER BY "timestamp" DESC
    LIMIT 5;

--Identify servers with high CPU usage
SELECT h.hostname,u.cpu_idle,100 - u.cpu_idle AS cpu_usage,u."timestamp"
FROM host_info h JOIN host_usage u
ON h.id = u.host_id
WHERE (100 - u.cpu_idle) > 20
ORDER BY u."timestamp" DESC;

-- Find duplicate host usage records
SELECT host_id,
       "timestamp",
       COUNT(*) AS duplicate_count
FROM host_usage
GROUP BY host_id, "timestamp"
HAVING COUNT(*) > 1;