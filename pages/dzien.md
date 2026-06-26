# Dzienny zarobek zespołu

```sql ostatni_dzien
SELECT
    dzien,
    SUM(godziny_total) AS godziny_zespol,
    SUM(zarobek_pln) AS zarobek_zespol_pln,
    COUNT(DISTINCT ekspert) AS ekspertow
FROM v_daily_earnings
WHERE dzien = (SELECT MAX(dzien) FROM v_daily_earnings)
GROUP BY dzien
```

<BigValue
    data={ostatni_dzien}
    value=zarobek_zespol_pln
    title="Koszt pracy zespołu (PLN)"
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
    value=ekspertow
    title="Osób zalogowało czas"
/>

<BigValue
    data={ostatni_dzien}
    value=dzien
    title="Ostatni zalogowany dzień"
/>

---

## Kto ile zarobił — ostatni dzień

```sql dzien_osoby
SELECT
    ekspert,
    godziny_total AS godziny,
    zarobek_pln,
    projekty
FROM v_daily_earnings
WHERE dzien = (SELECT MAX(dzien) FROM v_daily_earnings)
ORDER BY zarobek_pln DESC
```

<DataTable data={dzien_osoby} title="Zarobek per osoba">
    <Column id=ekspert title="Osoba"/>
    <Column id=godziny title="Godziny" fmt=num2/>
    <Column id=zarobek_pln title="Koszt PLN" fmt=num0/>
    <Column id=projekty title="Projekty"/>
</DataTable>

---

## Ostatnie 14 dni

```sql dzien_14
SELECT
    dzien,
    ekspert,
    godziny_total AS godziny,
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
    title="Koszt pracy dzienny per osoba (PLN)"
    type=stacked
/>

---

## Szczegóły — ostatnie 30 dni

```sql dzien_30
SELECT
    dzien,
    ekspert,
    godziny_total AS godziny,
    stawka,
    zarobek_pln,
    projekty
FROM v_daily_earnings
ORDER BY dzien DESC, zarobek_pln DESC
```

<DataTable data={dzien_30} rows=30>
    <Column id=dzien title="Dzień"/>
    <Column id=ekspert title="Osoba"/>
    <Column id=godziny title="Godziny" fmt=num2/>
    <Column id=stawka title="Stawka" fmt=num0/>
    <Column id=zarobek_pln title="Koszt PLN" fmt=num0/>
    <Column id=projekty title="Projekty"/>
</DataTable>
