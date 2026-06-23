# Godziny i koszty zespołu

```sql monthly_costs
SELECT
    strftime(miesiac, '%Y-%m') AS miesiac_label,
    miesiac,
    koszty_godziny,
    suma_godzin,
    liczba_osob
FROM v_monthly_costs
ORDER BY miesiac DESC
```

```sql monthly_hours
SELECT * FROM v_monthly_hours
ORDER BY miesiac DESC, godziny DESC
```

```sql hours_by_project
SELECT * FROM v_monthly_hours_by_project
ORDER BY miesiac DESC, godziny DESC
```

<BigValue
  data={monthly_costs}
  value=koszty_godziny
  title="Koszty czerwiec 2026 (PLN)"
  fmt=num0
  where="miesiac = '2026-06-01'"
/>

<BigValue
  data={monthly_costs}
  value=suma_godzin
  title="Godziny czerwiec 2026"
  fmt=num1
  where="miesiac = '2026-06-01'"
/>

## Koszty miesięczne (godziny × stawka)

<BarChart
  data={monthly_costs}
  x=miesiac_label
  y=koszty_godziny
  title="Koszty zespołu PLN/miesiąc"
  yAxisTitle="PLN"
/>

## Godziny per osoba

```sql current_month_by_person
SELECT
    ekspert,
    stawka,
    godziny,
    koszt_pln
FROM v_monthly_hours
WHERE miesiac >= '2026-06-01' AND miesiac < '2026-07-01'
ORDER BY godziny DESC
```

<DataTable data={current_month_by_person} title="Czerwiec 2026 — godziny per osoba">
  <Column id=ekspert title="Osoba"/>
  <Column id=stawka title="Stawka/h" fmt=num0/>
  <Column id=godziny title="Godziny" fmt=num1/>
  <Column id=koszt_pln title="Koszt PLN" fmt=num0/>
</DataTable>

## Top projekty — ostatnie 3 miesiące

```sql recent_projects
SELECT
    projekt,
    przestrzen,
    SUM(godziny) AS godziny_total
FROM v_monthly_hours_by_project
WHERE miesiac >= '2026-04-01'
GROUP BY projekt, przestrzen
ORDER BY godziny_total DESC
LIMIT 15
```

<DataTable data={recent_projects} title="Projekty kwiecień–czerwiec 2026">
  <Column id=projekt title="Projekt/Lista"/>
  <Column id=przestrzen title="Space"/>
  <Column id=godziny_total title="Godziny" fmt=num1/>
</DataTable>
