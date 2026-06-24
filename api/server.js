const express = require('express');
const { Pool } = require('pg');
const Anthropic = require('@anthropic-ai/sdk');
const cors = require('cors');

const app = express();

const origins = (process.env.CORS_ORIGINS || 'https://dashboard.important.is,http://localhost:3000').split(',');
app.use(cors({ origin: origins }));
app.use(express.json({ limit: '50kb' }));

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

async function buildContext() {
  const [pnl, clients, ltv, overdue, team] = await Promise.all([
    pool.query(`
      SELECT to_char(miesiac, 'YYYY-MM') AS m,
             przychod::int, koszt_zespolu::int, marza_brutto::int,
             ROUND(marza_procent::numeric, 1) AS marza_pct,
             godziny_zespol::int, liczba_faktur
      FROM v_monthly_pnl ORDER BY miesiac DESC LIMIT 6
    `),
    pool.query(`
      SELECT klient, przychod::int, godziny::int
      FROM v_client_monthly
      WHERE miesiac = (SELECT MAX(miesiac) FROM v_client_monthly)
      ORDER BY przychod DESC
    `),
    pool.query(`
      SELECT klient, ltv::int, status_klienta
      FROM v_client_ltv ORDER BY ltv DESC LIMIT 20
    `),
    pool.query(`
      SELECT klient, kwota_netto::int, dni_po_terminie, termin::text
      FROM v_zaleglosci ORDER BY kwota_netto DESC
    `),
    pool.query(`
      SELECT ekspert, ROUND(billable_h::numeric, 1) AS billable_h,
             ROUND(utilization_pct::numeric, 1) AS util_pct, koszt_total::int
      FROM v_team_utilization
      WHERE miesiac = (SELECT MAX(miesiac) FROM v_team_utilization)
      ORDER BY billable_h DESC
    `)
  ]);

  const lines = [
    '=== DANE FINANSOWE — AGENCJA IMPORTANT ===',
    '',
    'P&L ostatnie 6 miesięcy (przychód / koszt / marża / marża%):',
    ...pnl.rows.map(r =>
      `  ${r.m}: ${r.przychod} zł / ${r.koszt_zespolu} zł / ${r.marza_brutto} zł (${r.marza_pct}%), ${r.godziny_zespol}h, ${r.liczba_faktur} faktur`
    ),
    '',
    'Klienci bieżący miesiąc:',
    ...clients.rows.map(r => `  ${r.klient}: ${r.przychod} zł, ${r.godziny}h`),
    '',
    'LTV klientów:',
    ...ltv.rows.map(r => `  ${r.klient}: ${r.ltv} zł (${r.status_klienta})`),
    '',
    `Zaległe faktury (${overdue.rows.length}):`,
    ...(overdue.rows.length
      ? overdue.rows.map(r => `  ${r.klient}: ${r.kwota_netto} zł — ${r.dni_po_terminie} dni po terminie (${r.termin})`)
      : ['  Brak zaległości']),
    '',
    'Zespół bieżący miesiąc:',
    ...team.rows.map(r => `  ${r.ekspert}: ${r.billable_h}h billable, ${r.util_pct}% utilization, koszt ${r.koszt_total} zł`),
  ];

  return lines.join('\n');
}

const CHAT_API_KEY = process.env.CHAT_API_KEY;

app.post('/chat', async (req, res) => {
  if (CHAT_API_KEY && req.headers['x-api-key'] !== CHAT_API_KEY) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  const { messages } = req.body;
  if (!Array.isArray(messages) || messages.length === 0) {
    return res.status(400).json({ error: 'Brak wiadomości' });
  }

  try {
    const context = await buildContext();

    const response = await anthropic.messages.create({
      model: process.env.CLAUDE_MODEL || 'claude-haiku-4-5-20251001',
      max_tokens: 1200,
      system: `Jesteś CFO agencji marketingowej Important. Odpowiadasz po polsku, konkretnie i rzeczowo — podajesz liczby z danych, nie ogólniki. Używaj zwięzłych odpowiedzi (max 3-4 zdania lub krótka lista). Jeśli pytanie wykracza poza dostępne dane, powiedz wprost.

${context}`,
      messages: messages.slice(-10).map(({ role, content }) => ({ role, content }))
    });

    res.json({ answer: response.content[0].text });
  } catch (err) {
    console.error('Chat error:', err.message);
    res.status(500).json({ error: 'Błąd API — spróbuj ponownie' });
  }
});

app.get('/health', (_, res) => res.json({ ok: true }));

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => console.log(`Chat API running on :${PORT}`));
