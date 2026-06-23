# P&L — Przychody vs Koszty

```sql pnl_data
SELECT
    strftime(miesiac, '%Y-%m') AS miesiac_label,
    miesiac,
    przychod,
    koszt_zespolu,
    marza_brutto,
    marza_procent,
    godziny_zespol,
    liczba_faktur
FROM v_monthly_pnl
ORDER BY miesiac DESC
```

```sql pnl_last_month
SELECT * FROM v_monthly_pnl
WHERE miesiac = (SELECT MAX(miesiac) FROM v_monthly_pnl)
```

```sql pnl_prev_month
SELECT * FROM v_monthly_pnl
WHERE miesiac = (SELECT MAX(miesiac) FROM v_monthly_pnl WHERE miesiac < (SELECT MAX(miesiac) FROM v_monthly_pnl))
```

<BigValue
  data={pnl_last_month}
  value=przychod
  title="Przychód (ostatni mies.)"
  fmt=num0
/>

<BigValue
  data={pnl_last_month}
  value=koszt_zespolu
  title="Koszt zespołu"
  fmt=num0
/>

<BigValue
  data={pnl_last_month}
  value=marza_brutto
  title="Marża brutto PLN"
  fmt=num0
/>

<BigValue
  data={pnl_last_month}
  value=marza_procent
  title="Marża %"
  fmt=num1
/>

## Przychód i koszt miesięczny

<BarChart
  data={pnl_data}
  x=miesiac_label
  y={["przychod", "koszt_zespolu"]}
  series_colors={["#2563eb", "#dc2626"]}
  title="Przychód vs Koszt zespołu (PLN)"
  yAxisTitle="PLN"
/>

## Marża brutto (%)

```sql pnl_marza
SELECT * FROM v_monthly_pnl
WHERE marza_procent IS NOT NULL
ORDER BY miesiac ASC
```

<LineChart
  data={pnl_marza}
  x=miesiac
  y=marza_procent
  title="Marża brutto % — trend"
  yAxisTitle="%"
  yMin=-20
/>

## Tabela P&L

<DataTable data={pnl_data} title="Miesięczny P&L">
  <Column id=miesiac_label title="Miesiąc"/>
  <Column id=przychod title="Przychód PLN" fmt=num0/>
  <Column id=koszt_zespolu title="Koszt PLN" fmt=num0/>
  <Column id=marza_brutto title="Marża PLN" fmt=num0/>
  <Column id=marza_procent title="Marża %" fmt=num1/>
  <Column id=godziny_zespol title="Godz." fmt=num1/>
  <Column id=liczba_faktur title="Faktury"/>
</DataTable>

## Klienci — łączny przychód

```sql klienci
SELECT
    klient,
    przychod_total,
    godziny_total,
    stawka_crm,
    liczba_miesiecy,
    pierwsza_platnosc,
    ostatnia_platnosc
FROM v_klienci_przychod
LIMIT 20
```

<DataTable data={klienci} title="Top klienci (billable)">
  <Column id=klient title="Klient"/>
  <Column id=przychod_total title="Przychód PLN" fmt=num0/>
  <Column id=godziny_total title="Godziny" fmt=num1/>
  <Column id=stawka_crm title="Stawka/h" fmt=num0/>
  <Column id=liczba_miesiecy title="Mies."/>
  <Column id=pierwsza_platnosc title="Od"/>
  <Column id=ostatnia_platnosc title="Do"/>
</DataTable>

## Zaległości — faktury po terminie

```sql zaleglosci
SELECT * FROM v_zaleglosci
```

<DataTable data={zaleglosci} title="Faktury po terminie płatności">
  <Column id=klient title="Klient"/>
  <Column id=kwota_netto title="Kwota PLN" fmt=num0/>
  <Column id=termin title="Termin"/>
  <Column id=dni_po_terminie title="Dni po terminie"/>
</DataTable>
