---
title: Dashboard Finansowy — Important
redirect: /przeglad
---

```sql pnl_current
SELECT przychod, koszt_zespolu, marza_brutto, marza_procent, godziny_zespol
FROM v_monthly_pnl
WHERE miesiac = (SELECT MAX(miesiac) FROM v_monthly_pnl)
```

```sql pnl_trend
SELECT
    strftime(miesiac, '%Y-%m') AS miesiac_label,
    miesiac,
    przychod,
    koszt_zespolu,
    marza_brutto,
    marza_procent
FROM v_monthly_pnl
WHERE miesiac >= '2026-01-01'
ORDER BY miesiac ASC
```

```sql zaleglosci_kpi
SELECT COUNT(*) AS ile, ROUND(SUM(kwota_netto), 0) AS kwota FROM v_zaleglosci
```

```sql utilization_current
SELECT ROUND(SUM(billable_h) / SUM(total_h) * 100, 1) AS utilization_pct
FROM v_team_utilization
WHERE miesiac = (SELECT MAX(miesiac) FROM v_team_utilization)
```

<BigValue data={pnl_current} value=przychod title="Przychód (bież. mies.)" fmt=num0/>
<BigValue data={pnl_current} value=marza_brutto title="Marża brutto PLN" fmt=num0/>
<BigValue data={pnl_current} value=marza_procent title="Marża %" fmt=num1/>
<BigValue data={utilization_current} value=utilization_pct title="Utilization %" fmt=num1/>

## Przychód vs Koszt — 2026

<BarChart
    data={pnl_trend}
    x=miesiac_label
    y={["przychod", "koszt_zespolu"]}
    series_colors={["#2563eb", "#dc2626"]}
    title="Przychód vs Koszt zespołu (PLN)"
    yAxisTitle="PLN"
/>

<LineChart
    data={pnl_trend}
    x=miesiac_label
    y=marza_procent
    title="Marża brutto % — trend 2026"
    yAxisTitle="%"
/>

---

## Nawigacja

| Strona | Opis |
|--------|------|
| [P&L](/pnl) | Szczegółowy P&L, klienci, zaległości |
| [Klienci / LTV](/klienci) | LTV per klient, status, trend |
| [Projekty](/projekty) | Godziny per projekt i klient (ClickUp) |
| [Zespół](/team) | Utilization rate, godziny per osoba |
| [Godziny](/godziny) | Koszty zespołu per osoba i projekt |
