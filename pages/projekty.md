# Projekty — godziny per projekt (2026)

```sql projects_current
SELECT
    klient,
    projekt_lista,
    SUM(godziny) AS godziny,
    SUM(liczba_osob) AS osoby
FROM v_project_hours_2026
WHERE miesiac = (SELECT MAX(miesiac) FROM v_project_hours_2026)
GROUP BY klient, projekt_lista
ORDER BY godziny DESC
```

```sql projects_by_client_month
SELECT
    strftime(miesiac, '%Y-%m') AS miesiac_label,
    miesiac,
    klient,
    SUM(godziny) AS godziny
FROM v_project_hours_2026
GROUP BY miesiac, miesiac_label, klient
ORDER BY miesiac DESC, godziny DESC
```

```sql projects_total_2026
SELECT
    klient,
    SUM(godziny) AS godziny_total,
    COUNT(DISTINCT strftime(miesiac, '%Y-%m')) AS aktywne_miesiace
FROM v_project_hours_2026
GROUP BY klient
ORDER BY godziny_total DESC
```

```sql top_projects_kpis
SELECT
    SUM(godziny) AS total_h,
    COUNT(DISTINCT klient) AS klientow,
    COUNT(DISTINCT projekt_lista) AS projektow
FROM v_project_hours_2026
WHERE miesiac = (SELECT MAX(miesiac) FROM v_project_hours_2026)
```

<BigValue data={top_projects_kpis} value=total_h title="Godziny bież. miesiąc" fmt=num1/>
<BigValue data={top_projects_kpis} value=klientow title="Aktywnych klientów"/>
<BigValue data={top_projects_kpis} value=projektow title="Aktywnych projektów"/>

## Bieżący miesiąc — godziny per projekt

<BarChart
    data={projects_current}
    x=projekt_lista
    y=godziny
    title="Godziny per projekt (bieżący miesiąc)"
    swapXY=true
    yAxisTitle="Godziny"
/>

<DataTable data={projects_current} title="Bieżący miesiąc">
    <Column id=klient title="Klient"/>
    <Column id=projekt_lista title="Lista ClickUp"/>
    <Column id=godziny title="Godziny" fmt=num1/>
    <Column id=osoby title="Osób"/>
</DataTable>

## Godziny per klient — trend 2026

<BarChart
    data={projects_by_client_month}
    x=miesiac_label
    y=godziny
    series=klient
    title="Godziny per klient miesięcznie (2026)"
    type=stacked
    yAxisTitle="Godziny"
/>

## Łącznie 2026 — ranking klientów wg godzin

<DataTable data={projects_total_2026} title="Suma godzin 2026 per klient">
    <Column id=klient title="Klient"/>
    <Column id=godziny_total title="Godziny total" fmt=num1/>
    <Column id=aktywne_miesiace title="Mies. aktywny"/>
</DataTable>

## Koszty projektów (ClickUp time × stawka)

```sql project_costs_current
SELECT
    projekt,
    folder,
    godziny,
    koszt_pln,
    osob,
    eksperci
FROM v_project_costs
WHERE miesiac = (SELECT MAX(miesiac) FROM v_project_costs)
ORDER BY koszt_pln DESC
```

```sql project_costs_kpis
SELECT
    SUM(godziny) AS total_h,
    SUM(koszt_pln) AS total_koszt
FROM v_project_costs
WHERE miesiac = (SELECT MAX(miesiac) FROM v_project_costs)
```

<BigValue data={project_costs_kpis} value=total_koszt title="Koszt pracy — bieżący mies. (PLN)" fmt=num0/>
<BigValue data={project_costs_kpis} value=total_h title="Godziny bieżący mies." fmt=num1/>

<DataTable data={project_costs_current} title="Koszty per projekt — bieżący miesiąc">
    <Column id=projekt title="Projekt"/>
    <Column id=godziny title="Godziny" fmt=num1/>
    <Column id=koszt_pln title="Koszt PLN" fmt=num0/>
    <Column id=osob title="Osób"/>
    <Column id=eksperci title="Kto"/>
</DataTable>

```sql project_costs_trend
SELECT
    strftime(miesiac, '%Y-%m') AS miesiac_label,
    projekt,
    koszt_pln
FROM v_project_costs
WHERE miesiac >= date_trunc('year', current_date)
ORDER BY miesiac DESC, koszt_pln DESC
```

<BarChart
    data={project_costs_trend}
    x=miesiac_label
    y=koszt_pln
    series=projekt
    title="Koszt pracy per projekt — trend 2026"
    type=stacked
    yAxisTitle="PLN"
/>

## Szczegóły — wszystkie miesiące

```sql projects_detail
SELECT
    strftime(miesiac, '%Y-%m') AS miesiac_label,
    klient,
    projekt_lista,
    godziny,
    liczba_osob AS osoby
FROM v_project_hours_2026
ORDER BY miesiac DESC, godziny DESC
```

<DataTable data={projects_detail} title="Wszystkie projekty 2026">
    <Column id=miesiac_label title="Miesiąc"/>
    <Column id=klient title="Klient"/>
    <Column id=projekt_lista title="Projekt (ClickUp lista)"/>
    <Column id=godziny title="Godziny" fmt=num1/>
    <Column id=osoby title="Osób"/>
</DataTable>
