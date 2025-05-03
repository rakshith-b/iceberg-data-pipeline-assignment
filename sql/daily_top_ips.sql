SELECT ip, COUNT(*) as request_count
FROM hadoop_cat.db.logs
WHERE date_trunc('day', timestamp) = current_date
GROUP BY ip
ORDER BY request_count DESC
LIMIT 5;

