SELECT
    date_trunc('month', te.start_time AT TIME ZONE 'Europe/Warsaw') AS miesiac,
    COALESCE(te.list_name, 'brak')                                   AS projekt,
    COALESCE(te.folder_name, '')                                     AS folder,
    ROUND(SUM(te.duration_ms::numeric / 3600000), 2)                 AS godziny,
    ROUND(SUM(te.duration_ms::numeric / 3600000 * tm.hourly_rate), 0) AS koszt_pln,
    COUNT(DISTINCT te.user_clickup_id)                               AS osob,
    STRING_AGG(DISTINCT tm.name, ', ')                               AS eksperci
FROM time_entries te
JOIN team_members tm ON te.user_clickup_id = tm.clickup_id
WHERE te.duration_ms > 0
  AND te.duration_ms < 57600000
  AND te.list_name IS NOT NULL
  AND te.list_name != ''
  AND te.start_time >= '2025-01-01'
GROUP BY
    date_trunc('month', te.start_time AT TIME ZONE 'Europe/Warsaw'),
    te.list_name,
    te.folder_name
ORDER BY miesiac DESC, godziny DESC
