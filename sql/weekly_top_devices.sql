SELECT user_agent, COUNT(*) as request_count
FROM hadoop_cat.db.logs
WHERE date_trunc('week', timestamp) = date_trunc('week', current_date)
GROUP BY user_agent
ORDER BY request_count DESC
LIMIT 5;

