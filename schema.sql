-- Schema dla dashboardu finansowego Important
-- Wszystkie kwoty w NUMERIC(10,2) - nigdy MONEY

CREATE TABLE IF NOT EXISTS projekty (
    id              TEXT PRIMARY KEY,          -- Notion page ID
    nazwa           TEXT NOT NULL,
    klient          TEXT,
    status          TEXT,                      -- Współpraca / Zakończona / etc.
    typ             TEXT,                      -- godzinowy / fix priced
    stawka_godz     NUMERIC(10,2),
    budzet          NUMERIC(10,2),
    clickup_url     TEXT,
    notion_url      TEXT,
    synced_at       TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS przychody (
    id              TEXT PRIMARY KEY,          -- Notion page ID
    projekt_id      TEXT REFERENCES projekty(id),
    nazwa           TEXT NOT NULL,
    kwota_netto     NUMERIC(10,2),
    kwota_brutto    NUMERIC(10,2),             -- netto + 23% VAT
    status          TEXT,                      -- Zapłacone / Faktura wystawiona / etc.
    data_platnosci  DATE,
    termin          DATE,
    faktura_url     TEXT,
    synced_at       TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS wynagrodzenia (
    id              TEXT PRIMARY KEY,          -- Notion page ID
    ekspert_id      TEXT NOT NULL,             -- Notion relation ID
    ekspert_nazwa   TEXT NOT NULL,
    miesiac         DATE NOT NULL,             -- 1. dzień miesiąca
    kwota_netto     NUMERIC(10,2),
    synced_at       TIMESTAMPTZ DEFAULT now(),
    UNIQUE (ekspert_id, miesiac)               -- deduplikacja
);

CREATE TABLE IF NOT EXISTS wydatki (
    id              TEXT PRIMARY KEY,
    nazwa           TEXT NOT NULL,
    kategoria       TEXT,                      -- Serwery / SaaS / Marketing / Sprzet / Inne
    kwota_netto     NUMERIC(10,2),
    cykl            TEXT,                      -- jednorazowy / miesięczny / roczny
    data            DATE,
    projekt_id      TEXT REFERENCES projekty(id),
    synced_at       TIMESTAMPTZ DEFAULT now()
);

-- Widoki pomocnicze
CREATE OR REPLACE VIEW v_miesieczne AS
SELECT
    DATE_TRUNC('month', p.data_platnosci)  AS miesiac,
    SUM(p.kwota_netto)                      AS przychody_netto,
    SUM(p.kwota_brutto)                     AS przychody_brutto,
    COALESCE(w.koszty_wynagrodzen, 0)       AS koszty_wynagrodzen,
    COALESCE(wyd.koszty_wydatkow, 0)        AS koszty_wydatkow,
    SUM(p.kwota_netto)
        - COALESCE(w.koszty_wynagrodzen, 0)
        - COALESCE(wyd.koszty_wydatkow, 0)  AS dochod_netto
FROM przychody p
LEFT JOIN (
    SELECT miesiac, SUM(kwota_netto) AS koszty_wynagrodzen
    FROM wynagrodzenia
    GROUP BY miesiac
) w ON DATE_TRUNC('month', p.data_platnosci) = w.miesiac
LEFT JOIN (
    SELECT DATE_TRUNC('month', data) AS miesiac, SUM(kwota_netto) AS koszty_wydatkow
    FROM wydatki
    GROUP BY 1
) wyd ON DATE_TRUNC('month', p.data_platnosci) = wyd.miesiac
WHERE p.status IN ('Zapłacone', 'Zapłacone (automat)')
GROUP BY 1, w.koszty_wynagrodzen, wyd.koszty_wydatkow
ORDER BY 1 DESC;
