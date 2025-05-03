SELECT 
  ip,
  COUNT(*) AS request_count
FROM 
  hadoop_cat.db.logs
WHERE 
  weekofyear(timestamp) = weekofyear(current_date)
  AND year(timestamp) = year(current_date)
GROUP BY 
  ip
ORDER BY 
  request_count DESC
LIMIT 5;

