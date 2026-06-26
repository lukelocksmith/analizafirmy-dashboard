SELECT
    id,
    projekt_id,
    nazwa,
    kwota_netto,
    kwota_brutto,
    status,
    data_platnosci,
    termin,
    klient
FROM przychody
WHERE data_platnosci IS NOT NULL
ORDER BY data_platnosci DESC
