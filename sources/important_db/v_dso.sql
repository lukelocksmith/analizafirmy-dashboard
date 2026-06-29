SELECT
    klient,
    COUNT(*)                                                              AS liczba_faktur,
    ROUND(AVG(data_platnosci - termin), 1)                                AS avg_dni_vs_termin,
    ROUND(AVG(GREATEST((data_platnosci - termin)::int, 0)), 1)            AS avg_opoznienie,
    MIN(data_platnosci - termin)                                          AS min_dni,
    MAX(data_platnosci - termin)                                          AS max_dni,
    COUNT(*) FILTER (WHERE data_platnosci > termin)                       AS faktur_spoznionych,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE data_platnosci > termin) / COUNT(*), 0
    )                                                                     AS pct_spoznionych
FROM przychody
WHERE termin IS NOT NULL
  AND data_platnosci IS NOT NULL
  AND kwota_netto > 0
GROUP BY klient
ORDER BY avg_dni_vs_termin DESC
