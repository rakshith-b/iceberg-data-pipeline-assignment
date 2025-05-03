SELECT 
  user_agent,
  COUNT(*) AS request_count
FROM 
  hadoop_cat.db.logs
WHERE 
  date(timestamp) = current_date
GROUP BY 
  user_agent
ORDER BY 
  request_count DESC
LIMIT 5;

