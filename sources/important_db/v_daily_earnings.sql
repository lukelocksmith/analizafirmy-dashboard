SELECT
    DATE(te.start_time AT TIME ZONE 'Europe/Warsaw') AS dzien,
    tm.name AS ekspert,
    tm.hourly_rate AS stawka,
    ROUND(SUM(te.duration_ms::numeric / 3600000), 2) AS godziny_total,
    ROUND(SUM(te.duration_ms::numeric / 3600000) FILTER (WHERE te.list_name != 'IMPORTANT'), 2) AS godziny_billable,
    ROUND(SUM(te.duration_ms::numeric / 3600000) FILTER (WHERE te.list_name = 'IMPORTANT'), 2) AS godziny_internal,
    ROUND(SUM(te.duration_ms::numeric / 3600000) * tm.hourly_rate, 0) AS zarobek_pln,
    ROUND(SUM(te.duration_ms::numeric / 3600000) FILTER (WHERE te.list_name != 'IMPORTANT') * tm.hourly_rate, 0) AS zarobek_billable_pln,
    STRING_AGG(DISTINCT te.list_name, ', ' ORDER BY te.list_name) AS projekty
FROM time_entries te
JOIN team_members tm ON te.user_clickup_id = tm.clickup_id
WHERE te.duration_ms > 0
  AND te.duration_ms < 57600000
  AND te.start_time >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(te.start_time AT TIME ZONE 'Europe/Warsaw'), tm.name, tm.hourly_rate
ORDER BY dzien DESC, zarobek_pln DESC
