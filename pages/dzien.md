# Dzienny zarobek zespołu

```sql ostatni_dzien
SELECT
    dzien,
    SUM(godziny_total) AS godziny_zespol,
    SUM(zarobek_pln) AS zarobek_zespol_pln,
    SUM(zarobek_billable_pln) AS zarobek_billable_pln,
    COUNT(DISTINCT ekspert) AS ekspertow
FROM v_daily_earnings
WHERE dzien = (SELECT MAX(dzien) FROM v_daily_earnings)
GROUP BY dzien
```

<BigValue
    data={ostatni_dzien}
    value=zarobek_zespol_pln
    title="Zarobek zespołu (ostatni dzień)"
    fmt=num0
/>

<BigValue
    data={ostatni_dzien}
    value=godziny_zespol
    title="Godziny łącznie"
    fmt=num1
/>

<BigValue
    data={ostatni_dzien}
    value=zarobek_billable_pln
    title="Billable PLN"
    fmt=num0
/>

<BigValue
    data={ostatni_dzien}
    value=dzien
    title="Ostatni zalogowany dzień"
/>

---

## Ostatni zalogowany dzień — kto ile zarobił

```sql dzien_osoby
SELECT
    ekspert,
    godziny_total,
    godziny_billable,
    godziny_internal,
    zarobek_pln,
    zarobek_billable_pln,
    projekty
FROM v_daily_earnings
WHERE dzien = (SELECT MAX(dzien) FROM v_daily_earnings)
ORDER BY zarobek_pln DESC
```

<DataTable data={dzien_osoby} title="Zarobek per osoba">
    <Column id=ekspert title="Osoba"/>
    <Column id=godziny_total title="Godziny" fmt=num2/>
    <Column id=godziny_billable title="Billable h" fmt=num2/>
    <Column id=zarobek_pln title="Zarobek PLN" fmt=num0/>
    <Column id=zarobek_billable_pln title="Billable PLN" fmt=num0/>
    <Column id=projekty title="Projekty"/>
</DataTable>

---

## Ostatnie 14 dni — dzienny zarobek

```sql dzien_14
SELECT
    dzien,
    ekspert,
    godziny_total,
    zarobek_pln
FROM v_daily_earnings
WHERE dzien >= (SELECT MAX(dzien) FROM v_daily_earnings) - INTERVAL '14 days'
ORDER BY dzien, ekspert
```

<BarChart
    data={dzien_14}
    x=dzien
    y=zarobek_pln
    series=ekspert
    title="Zarobek dzienny per osoba (PLN)"
    type=stacked
/>

---

## Ostatnie 30 dni — szczegółowa lista

```sql dzien_30
SELECT
    dzien,
    ekspert,
    godziny_total,
    godziny_billable,
    stawka,
    zarobek_pln,
    projekty
FROM v_daily_earnings
ORDER BY dzien DESC, zarobek_pln DESC
```

<DataTable data={dzien_30} title="Wszystkie dni (30 dni wstecz)" rows=30>
    <Column id=dzien title="Dzień"/>
    <Column id=ekspert title="Osoba"/>
    <Column id=godziny_total title="Godziny" fmt=num2/>
    <Column id=godziny_billable title="Billable h" fmt=num2/>
    <Column id=stawka title="Stawka" fmt=num0/>
    <Column id=zarobek_pln title="Zarobek PLN" fmt=num0/>
    <Column id=projekty title="Projekty"/>
</DataTable>
