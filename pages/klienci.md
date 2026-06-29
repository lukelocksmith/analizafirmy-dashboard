# Klienci — LTV i przychody

```sql ltv_all
SELECT
    klient,
    ltv,
    aktywne_miesiace,
    avg_miesiac,
    godziny_total,
    stawka_crm,
    pierwsza_platnosc,
    ostatnia_platnosc,
    status_klienta
FROM v_client_ltv
ORDER BY ltv DESC
```

```sql ltv_active
SELECT * FROM v_client_ltv WHERE status_klienta = 'aktywny' ORDER BY ltv DESC
```

```sql ltv_risk
SELECT * FROM v_client_ltv WHERE status_klienta IN ('ryzyko', 'nieaktywny') ORDER BY ostatnia_platnosc DESC
```

```sql total_ltv
SELECT
    SUM(ltv) AS total_ltv,
    COUNT(*) AS liczba_klientow,
    COUNT(*) FILTER (WHERE status_klienta = 'aktywny') AS aktywni,
    COUNT(*) FILTER (WHERE status_klienta = 'ryzyko') AS ryzyko,
    COUNT(*) FILTER (WHERE status_klienta = 'nieaktywny') AS nieaktywni,
    ROUND(AVG(ltv), 0) AS avg_ltv,
    ROUND(AVG(avg_miesiac), 0) AS avg_mrr
FROM v_client_ltv
```

<BigValue data={total_ltv} value=total_ltv title="Łączny LTV (PLN)" fmt=num0/>
<BigValue data={total_ltv} value=liczba_klientow title="Klientów total"/>
<BigValue data={total_ltv} value=aktywni title="Aktywnych"/>
<BigValue data={total_ltv} value=avg_ltv title="Avg LTV" fmt=num0/>

## Ranking klientów — LTV

<BarChart
    data={ltv_all}
    x=klient
    y=ltv
    title="LTV per klient (PLN)"
    yAxisTitle="PLN"
    swapXY=true
/>

## Tabela LTV

<DataTable data={ltv_all} title="LTV per klient">
    <Column id=klient title="Klient"/>
    <Column id=status_klienta title="Status"/>
    <Column id=ltv title="LTV PLN" fmt=num0/>
    <Column id=avg_miesiac title="Avg/mies." fmt=num0/>
    <Column id=aktywne_miesiace title="Mies."/>
    <Column id=godziny_total title="Godz." fmt=num1/>
    <Column id=stawka_crm title="Stawka/h" fmt=num0/>
    <Column id=pierwsza_platnosc title="Od"/>
    <Column id=ostatnia_platnosc title="Do"/>
</DataTable>

## Klienci aktywni

<DataTable data={ltv_active}>
    <Column id=klient title="Klient"/>
    <Column id=ltv title="LTV PLN" fmt=num0/>
    <Column id=avg_miesiac title="Avg/mies." fmt=num0/>
    <Column id=aktywne_miesiace title="Mies."/>
    <Column id=ostatnia_platnosc title="Ostatnia płatność"/>
</DataTable>

## Ryzyko churnu / nieaktywni

<DataTable data={ltv_risk}>
    <Column id=klient title="Klient"/>
    <Column id=status_klienta title="Status"/>
    <Column id=ltv title="LTV PLN" fmt=num0/>
    <Column id=ostatnia_platnosc title="Ostatnia płatność"/>
    <Column id=aktywne_miesiace title="Mies. aktywny"/>
</DataTable>

## Terminowość płatności (DSO)

```sql dso
SELECT
    klient,
    liczba_faktur,
    avg_dni_vs_termin,
    min_dni,
    max_dni,
    faktur_spoznionych,
    pct_spoznionych
FROM v_dso
ORDER BY avg_dni_vs_termin DESC
```

<DataTable data={dso} title="Terminowość płatności per klient">
    <Column id=klient title="Klient"/>
    <Column id=liczba_faktur title="Faktur"/>
    <Column id=avg_dni_vs_termin title="Avg dni (- = przed terminem)" fmt=num1/>
    <Column id=min_dni title="Min dni" fmt=num0/>
    <Column id=max_dni title="Max dni" fmt=num0/>
    <Column id=faktur_spoznionych title="Spóźnionych"/>
    <Column id=pct_spoznionych title="% spóźn." fmt=num0/>
</DataTable>

## Trend przychodów — top klienci

```sql client_trend
SELECT
    strftime(miesiac, '%Y-%m') AS miesiac_label,
    klient,
    przychod
FROM v_client_monthly
WHERE miesiac >= '2026-01-01'
  AND klient IN (
      SELECT klient FROM v_client_ltv ORDER BY ltv DESC LIMIT 6
  )
ORDER BY miesiac, przychod DESC
```

<LineChart
    data={client_trend}
    x=miesiac_label
    y=przychod
    series=klient
    title="Przychód miesięczny — top 6 klientów (PLN)"
    yAxisTitle="PLN"
/>
