---
title: Dashboard Finansowy — Important
---

```sql pnl_current
SELECT
    przychod,
    koszt_zespolu,
    marza_brutto,
    marza_procent,
    godziny_zespol
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
ORDER BY miesiac ASC
```

<BigValue
  data={pnl_current}
  value=przychod
  title="Przychód (bieżący mies.)"
  fmt=num0
/>

<BigValue
  data={pnl_current}
  value=koszt_zespolu
  title="Koszt zespołu"
  fmt=num0
/>

<BigValue
  data={pnl_current}
  value=marza_brutto
  title="Marża brutto PLN"
  fmt=num0
/>

<BigValue
  data={pnl_current}
  value=marza_procent
  title="Marża %"
  fmt=num1
/>

## Trend przychodów i kosztów

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
  title="Marża brutto % — trend"
  yAxisTitle="%"
/>

## Nawigacja

- [P&L — szczegółowy P&L i klienci](/pnl)
- [Godziny — koszty i godziny zespołu](/godziny)
