# Przegląd — Important

```sql biezacy
SELECT
    p.miesiac,
    p.przychod,
    p.koszt_zespolu,
    p.marza_brutto,
    p.marza_procent,
    p.godziny_zespol,
    p.liczba_faktur,
    prev.przychod AS przychod_prev,
    prev.marza_procent AS marza_prev,
    ROUND(p.przychod - prev.przychod, 0) AS przychod_zmiana,
    ROUND(p.marza_procent - prev.marza_procent, 1) AS marza_zmiana
FROM v_monthly_pnl p
JOIN v_monthly_pnl prev
    ON prev.miesiac = (SELECT MAX(miesiac) FROM v_monthly_pnl WHERE miesiac < p.miesiac)
WHERE p.miesiac = (SELECT MAX(miesiac) FROM v_monthly_pnl)
```

```sql zaleglosci_suma
SELECT
    COUNT(*) AS ile_faktur,
    ROUND(SUM(kwota_netto), 0) AS kwota_total,
    MAX(dni_po_terminie) AS max_dni
FROM v_zaleglosci
```

```sql utilization_biezacy
SELECT
    ROUND(SUM(billable_h) / SUM(total_h) * 100, 1) AS utilization_pct,
    SUM(billable_h) AS billable_h,
    SUM(total_h) AS total_h
FROM v_team_utilization
WHERE miesiac = (SELECT MAX(miesiac) FROM v_team_utilization)
```

<BigValue
    data={biezacy}
    value=przychod
    title="Przychód (bież. miesiąc)"
    fmt=num0
    comparison=przychod_zmiana
    comparisonTitle="vs poprzedni mies."
    comparisonFmt=num0
/>

<BigValue
    data={biezacy}
    value=marza_procent
    title="Marża brutto"
    fmt=num1
    comparison=marza_zmiana
    comparisonTitle="vs poprzedni mies."
    comparisonFmt=num1
/>

<BigValue
    data={zaleglosci_suma}
    value=kwota_total
    title="Zaległości (PLN)"
    fmt=num0
/>

<BigValue
    data={utilization_biezacy}
    value=utilization_pct
    title="Utilization zespołu"
    fmt=num1
/>

---

## ⚠️ Do zrobienia teraz

```sql zaleglosci_lista
SELECT
    klient,
    kwota_netto AS kwota,
    termin,
    dni_po_terminie,
    nazwa
FROM v_zaleglosci
ORDER BY kwota DESC
```

<DataTable data={zaleglosci_lista} title="Faktury po terminie płatności">
    <Column id=klient title="Klient"/>
    <Column id=kwota title="Kwota PLN" fmt=num0/>
    <Column id=termin title="Termin"/>
    <Column id=dni_po_terminie title="Dni po terminie"/>
</DataTable>

```sql niezafakturowane
SELECT
    klient,
    SUM(godziny) AS godziny,
    COUNT(DISTINCT projekt_lista) AS projekty
FROM v_project_hours_2026
WHERE miesiac >= date_trunc('month', current_date - INTERVAL '1 month')
  AND klient NOT IN (
      SELECT DISTINCT klient FROM przychody
      WHERE data_platnosci >= date_trunc('month', current_date)
  )
GROUP BY klient
HAVING SUM(godziny) > 5
ORDER BY godziny DESC
```

---

## Ostatnie 3 miesiące

```sql ostatnie3
SELECT
    strftime(miesiac, '%Y-%m') AS miesiac_label,
    przychod,
    koszt_zespolu,
    marza_brutto,
    marza_procent,
    godziny_zespol
FROM v_monthly_pnl
ORDER BY miesiac DESC
LIMIT 3
```

<DataTable data={ostatnie3}>
    <Column id=miesiac_label title="Miesiąc"/>
    <Column id=przychod title="Przychód PLN" fmt=num0/>
    <Column id=koszt_zespolu title="Koszt PLN" fmt=num0/>
    <Column id=marza_brutto title="Marża PLN" fmt=num0/>
    <Column id=marza_procent title="Marża %" fmt=num1/>
    <Column id=godziny_zespol title="Godziny" fmt=num1/>
</DataTable>

---

## Klienci — bieżący miesiąc

```sql klienci_biezacy
SELECT
    klient,
    przychod,
    godziny,
    faktury
FROM v_client_monthly
WHERE miesiac = (SELECT MAX(miesiac) FROM v_client_monthly)
ORDER BY przychod DESC
```

<DataTable data={klienci_biezacy} title="Co płaci teraz">
    <Column id=klient title="Klient"/>
    <Column id=przychod title="PLN" fmt=num0/>
    <Column id=godziny title="Godziny" fmt=num1/>
</DataTable>

---

## Zespół — bieżący miesiąc

```sql team_biezacy
SELECT
    ekspert,
    billable_h,
    utilization_pct,
    koszt_total
FROM v_team_utilization
WHERE miesiac = (SELECT MAX(miesiac) FROM v_team_utilization)
ORDER BY billable_h DESC
```

<DataTable data={team_biezacy} title="Kto ile pracuje">
    <Column id=ekspert title="Osoba"/>
    <Column id=billable_h title="Godziny billowalne" fmt=num1/>
    <Column id=utilization_pct title="Utilization %" fmt=num1/>
    <Column id=koszt_total title="Koszt PLN" fmt=num0/>
</DataTable>
