WITH avg3 AS (
    SELECT
        ROUND(AVG(przychod), 0)       AS prognoza_przychod,
        ROUND(AVG(koszt_zespolu), 0)  AS prognoza_koszt,
        ROUND(AVG(marza_brutto), 0)   AS prognoza_marza,
        ROUND(AVG(marza_procent), 1)  AS prognoza_marza_pct,
        ROUND(AVG(godziny_zespol), 1) AS prognoza_godziny,
        COUNT(*)                      AS bazowe_miesiace
    FROM v_monthly_pnl
    WHERE miesiac >= date_trunc('month', CURRENT_DATE - INTERVAL '3 months')
      AND miesiac < date_trunc('month', CURRENT_DATE)
)
SELECT
    date_trunc('month', CURRENT_DATE + INTERVAL '1 month') AS miesiac_prognoza,
    prognoza_przychod,
    prognoza_koszt,
    prognoza_marza,
    prognoza_marza_pct,
    prognoza_godziny,
    bazowe_miesiace
FROM avg3
