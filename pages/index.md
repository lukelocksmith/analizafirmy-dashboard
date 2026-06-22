---
title: Dashboard Finansowy — Important
---

```sql miesieczne
select * from v_miesieczne
limit 12
```

```sql kpi
select
    sum(przychody_netto)     as przychody_total,
    sum(koszty_wynagrodzen)  as wynagrodzenia_total,
    sum(koszty_wydatkow)     as wydatki_total,
    sum(dochod_netto)        as dochod_total
from v_miesieczne
```

<BigValue
  data={kpi}
  value=przychody_total
  title="Przychody (netto)"
  fmt=pln2
/>

<BigValue
  data={kpi}
  value=wynagrodzenia_total
  title="Wynagrodzenia"
  fmt=pln2
/>

<BigValue
  data={kpi}
  value=wydatki_total
  title="Koszty stałe"
  fmt=pln2
/>

<BigValue
  data={kpi}
  value=dochod_total
  title="Dochód netto"
  fmt=pln2
/>

---

## Miesięcznie

<BarChart
  data={miesieczne}
  x=miesiac
  y={["przychody_netto", "koszty_wynagrodzen", "koszty_wydatkow"]}
  labels=true
  title="Przychody vs Koszty"
/>

<LineChart
  data={miesieczne}
  x=miesiac
  y=dochod_netto
  title="Dochód netto (trend)"
/>

<DataTable data={miesieczne} />
