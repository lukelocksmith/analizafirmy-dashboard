<script>
  import { tick } from 'svelte';

  const CHAT_API = 'https://chat-api.important.is';
  const CHAT_KEY = '60801407a6271c582363b2dca48c2ea102e8196be8e66ca6';

  let chatOpen = false;
  let msgs = [];
  let inputVal = '';
  let busy = false;
  let msgsEl;

  async function scrollBottom() {
    await tick();
    if (msgsEl) msgsEl.scrollTop = msgsEl.scrollHeight;
  }

  async function sendMsg() {
    const q = inputVal.trim();
    if (!q || busy) return;
    inputVal = '';
    msgs = [...msgs, { role: 'user', content: q }];
    busy = true;
    await scrollBottom();
    try {
      const r = await fetch(`${CHAT_API}/chat`, {
        method: 'POST',
        body: JSON.stringify({ messages: msgs }),
        headers: { 'Content-Type': 'application/json', 'x-api-key': CHAT_KEY }
      });
      const d = await r.json();
      msgs = [...msgs, { role: 'assistant', content: d.answer || d.error || 'Błąd odpowiedzi' }];
    } catch {
      msgs = [...msgs, { role: 'assistant', content: 'Błąd połączenia z API.' }];
    }
    busy = false;
    await scrollBottom();
  }

  function onKey(e) {
    if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendMsg(); }
  }
</script>

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

<!-- Chat widget -->
<div style="position:fixed;bottom:28px;right:28px;z-index:9999;font-family:system-ui,-apple-system,sans-serif">

  {#if chatOpen}
  <div style="position:absolute;bottom:72px;right:0;width:380px;height:500px;background:#fff;border-radius:16px;box-shadow:0 8px 40px rgba(0,0,0,.18);display:flex;flex-direction:column;overflow:hidden;border:1px solid #e2e8f0">

    <!-- header -->
    <div style="padding:14px 18px;background:#2563eb;color:#fff;display:flex;align-items:center;justify-content:space-between">
      <span style="font-weight:600;font-size:15px">💬 Asystent finansowy</span>
      <button on:click={() => chatOpen = false} style="background:none;border:none;color:#fff;cursor:pointer;font-size:20px;line-height:1;padding:0">×</button>
    </div>

    <!-- messages -->
    <div bind:this={msgsEl} style="flex:1;overflow-y:auto;padding:16px;display:flex;flex-direction:column;gap:10px;scroll-behavior:smooth">
      <div style="background:#f1f5f9;border-radius:12px;padding:10px 14px;font-size:13.5px;color:#475569;max-width:90%">
        Cześć! Pytaj o przychody, marże, zaległości, klientów, zespół — mam dostęp do aktualnych danych.
      </div>
      {#each msgs as m}
        <div style="background:{m.role === 'user' ? '#2563eb' : '#f1f5f9'};color:{m.role === 'user' ? '#fff' : '#1e293b'};border-radius:12px;padding:10px 14px;font-size:13.5px;max-width:88%;align-self:{m.role === 'user' ? 'flex-end' : 'flex-start'};white-space:pre-wrap;line-height:1.5">
          {m.content}
        </div>
      {/each}
      {#if busy}
        <div style="background:#f1f5f9;border-radius:12px;padding:10px 14px;font-size:13.5px;color:#94a3b8;max-width:60%">
          Analizuję...
        </div>
      {/if}
    </div>

    <!-- input -->
    <div style="padding:12px;border-top:1px solid #e2e8f0;display:flex;gap:8px;align-items:center">
      <input
        bind:value={inputVal}
        on:keydown={onKey}
        placeholder="Np. jaki był przychód w maju?"
        disabled={busy}
        style="flex:1;padding:9px 13px;border:1px solid #cbd5e1;border-radius:8px;font-size:13.5px;outline:none;background:{busy ? '#f8fafc' : '#fff'}"
      />
      <button
        on:click={sendMsg}
        disabled={busy}
        style="padding:9px 16px;background:#2563eb;color:#fff;border:none;border-radius:8px;cursor:pointer;font-size:15px;opacity:{busy ? '.5' : '1'}"
      >→</button>
    </div>
  </div>
  {/if}

  <!-- toggle button -->
  <button
    on:click={() => chatOpen = !chatOpen}
    style="width:56px;height:56px;border-radius:50%;background:#2563eb;color:#fff;border:none;cursor:pointer;font-size:22px;box-shadow:0 4px 16px rgba(37,99,235,.45);transition:transform .15s"
    title="Asystent finansowy"
  >
    {chatOpen ? '✕' : '💬'}
  </button>

</div>
