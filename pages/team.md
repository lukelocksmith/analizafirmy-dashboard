# Zespół — godziny i utilization

```sql team_current
SELECT
    ekspert,
    stawka,
    billable_h,
    internal_h,
    total_h,
    utilization_pct,
    koszt_total,
    koszt_billable
FROM v_team_utilization
WHERE miesiac = (SELECT MAX(miesiac) FROM v_team_utilization)
ORDER BY billable_h DESC
```

```sql team_monthly
SELECT
    strftime(miesiac, '%Y-%m') AS miesiac_label,
    miesiac,
    ekspert,
    billable_h,
    internal_h,
    total_h,
    utilization_pct,
    koszt_total
FROM v_team_utilization
WHERE miesiac >= '2026-01-01'
ORDER BY miesiac DESC, billable_h DESC
```

```sql team_summary_monthly
SELECT
    strftime(miesiac, '%Y-%m') AS miesiac_label,
    miesiac,
    SUM(billable_h) AS billable_h,
    SUM(internal_h) AS internal_h,
    SUM(total_h) AS total_h,
    ROUND(SUM(billable_h) / SUM(total_h) * 100, 1) AS utilization_pct,
    SUM(koszt_total) AS koszt_total
FROM v_team_utilization
WHERE miesiac >= '2026-01-01'
GROUP BY miesiac, miesiac_label
ORDER BY miesiac DESC
```

```sql total_current
SELECT
    SUM(billable_h) AS billable_h,
    SUM(total_h) AS total_h,
    ROUND(SUM(billable_h) / SUM(total_h) * 100, 1) AS utilization_pct,
    SUM(koszt_total) AS koszt_total
FROM v_team_utilization
WHERE miesiac = (SELECT MAX(miesiac) FROM v_team_utilization)
```

<BigValue data={total_current} value=billable_h title="Godziny billowalne (bież.)" fmt=num1/>
<BigValue data={total_current} value=utilization_pct title="Utilization %" fmt=num1/>
<BigValue data={total_current} value=koszt_total title="Koszt zespołu (bież.)" fmt=num0/>

## Utilization — bieżący miesiąc

<DataTable data={team_current} title="Bieżący miesiąc per osoba">
    <Column id=ekspert title="Osoba"/>
    <Column id=stawka title="Stawka/h" fmt=num0/>
    <Column id=billable_h title="Billable h" fmt=num1/>
    <Column id=internal_h title="Internal h" fmt=num1/>
    <Column id=total_h title="Total h" fmt=num1/>
    <Column id=utilization_pct title="Utilization %" fmt=num1/>
    <Column id=koszt_total title="Koszt PLN" fmt=num0/>
</DataTable>

## Utilization trend (2026)

<LineChart
    data={team_summary_monthly}
    x=miesiac_label
    y=utilization_pct
    title="Utilization % zespołu — trend 2026"
    yAxisTitle="%"
    yMin=70
    yMax=100
/>

## Godziny per osoba per miesiąc

<BarChart
    data={team_monthly}
    x=miesiac_label
    y=billable_h
    series=ekspert
    title="Godziny billowalne per osoba"
    yAxisTitle="Godziny"
    type=stacked
/>

## Tabela pełna — 2026

<DataTable data={team_monthly} title="Godziny i koszty per osoba (2026)">
    <Column id=miesiac_label title="Miesiąc"/>
    <Column id=ekspert title="Osoba"/>
    <Column id=billable_h title="Billable h" fmt=num1/>
    <Column id=internal_h title="Internal h" fmt=num1/>
    <Column id=utilization_pct title="Util. %" fmt=num1/>
    <Column id=koszt_total title="Koszt PLN" fmt=num0/>
</DataTable>

## Koszty vs godziny (2026)

<BarChart
    data={team_summary_monthly}
    x=miesiac_label
    y={["billable_h", "internal_h"]}
    series_colors={["#2563eb", "#94a3b8"]}
    title="Godziny billowalne vs wewnętrzne"
    type=stacked
    yAxisTitle="Godziny"
/>
