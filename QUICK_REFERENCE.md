# BI Tools - Quick Reference Guide
**Polish Agency Financial Dashboard Stack**

---

## TL;DR RECOMMENDATIONS

### For Rapid MVP (Weeks 1-2)
```
USE: Metabase
WHY: Simplest deployment (30 min), native MCP for Claude integration
EFFORT: 2-3 days to production dashboard
COST: Free (self-hosted)
```

### For Mature Data Team (Weeks 2-4)
```
USE: Lightdash
WHY: Code-first with dbt, version-controlled metrics, AI agents
EFFORT: 1-2 weeks (includes dbt model setup)
COST: Free (self-hosted) + AI integration costs
```

### For Enterprise Scale (Weeks 4+)
```
USE: Apache Superset
WHY: Largest ecosystem, multi-datasource, Kubernetes-ready
EFFORT: 3-4 weeks (infrastructure + federation)
COST: Free (self-hosted)
```

---

## DEPLOYMENT TIME COMPARISON

| Tool | Docker | Config | First Dashboard | Polish Features | Total |
|------|--------|--------|-----------------|-----------------|-------|
| **Metabase** | 5min | 10min | 30min | 2-3h | **<1 day** |
| **Lightdash** | 10min | 20min | 2h | 4-6h | **1-2 days** |
| **Superset** | 15min | 30min | 1h | 6-8h | **2-3 days** |
| **Grafana** | 10min | 15min | 1h | ❌ Limited | **~2h** |
| **Evidence** | 5min | 20min | 1h | 4-6h | **1 day** |
| **Redash** | 15min | 25min | 45min | 3-4h | **1-2 days** |

---

## FEATURE MATRIX

### ✅ Fully Supported

| Feature | Metabase | Superset | Lightdash | Grafana | Evidence | Redash |
|---------|----------|----------|-----------|---------|----------|--------|
| MCP Server (Claude) | ✅ | ✅ | ✅ | ❌ | ❌ | ⚠️ |
| REST API | ✅ | ✅ | ✅ | ⚠️ | ❌ | ⚠️ |
| Custom SQL | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| JOIN Operations | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| Calculated Fields | ✅ | ✅ | ✅ | ❌ | ✅ | ⚠️ |
| Semantic Layer | ⚠️ | ✅ | ✅ | ❌ | ❌ | ❌ |
| AI Integration | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| dbt Integration | ⚠️ | ⚠️ | ✅ | ❌ | ❌ | ❌ |
| n8n Integration | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ |
| PostgreSQL | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## POLISH FINANCIAL FEATURES CHECKLIST

### What Every Tool Needs (Custom Implementation)

**VAT Handling**:
```sql
-- Implement in all tools:
CASE 
  WHEN vat_category = 'standard' THEN net * 1.23
  WHEN vat_category = 'reduced' THEN net * 1.08
  WHEN vat_category = 'super_reduced' THEN net * 1.05
  ELSE net
END AS gross_amount
```

**ZUS Tracking** (Choose your tool):
- **Lightdash** (Recommended): Define in dbt YAML metrics
- **Metabase**: Custom columns with formulas
- **Superset**: Virtual metrics in semantic layer
- **Redash**: SQL queries

**Split Payment Detection**:
```sql
-- For all tools:
SELECT 
  invoice_id,
  net_amount,
  vat_amount,
  CASE 
    WHEN split_payment_required THEN 'vat_account'
    ELSE 'normal'
  END as payment_routing
FROM invoices
WHERE country_code = 'PL'
```

---

## INSTALLATION COMMANDS

### Metabase (Production-Ready)
```bash
# Clone and deploy
git clone https://github.com/metabase/metabase.git
cd metabase
cp /path/to/docker-compose.yml .
cp /path/to/.env .env

# Start
docker-compose up -d

# Check
docker-compose logs -f metabase
open http://localhost:3000
```

### Lightdash (With dbt)
```bash
# Clone repository
git clone https://github.com/lightdash/lightdash.git
cd lightdash

# Prepare dbt project
mkdir -p dbt-project/models
cp /path/to/metrics.yml dbt-project/models/

# Deploy
docker-compose up -d

# Monitor
docker-compose logs -f lightdash
open http://localhost:8080
```

### Superset (Enterprise)
```bash
# Clone Apache Superset
git clone https://github.com/apache/superset.git
cd superset

# Use provided docker-compose
docker-compose -f docker-compose-non-dev.yml up -d

# Initialize
docker-compose exec superset superset db upgrade
docker-compose exec superset superset init

# Access
open http://localhost:8088
```

---

## n8n WORKFLOW QUICK START

### ClickUp → PostgreSQL → Lightdash

1. **Create n8n Workflow**:
   - Trigger: Schedule (hourly)
   - Node 1: ClickUp Get Team Tasks
   - Node 2: Code (transform data)
   - Node 3: PostgreSQL Insert
   - Node 4: Trigger dbt run (webhook)
   - Node 5: Slack notification

2. **Environment Variables**:
   ```
   CLICKUP_TEAM_ID=xxxxx
   DBT_SCHEMA=raw_clickup
   ```

3. **Schedule**: Run every hour (or on-demand)

4. **Monitoring**: Check Slack notifications

---

## AI INTEGRATION (MCP)

### Claude Code + Metabase

```bash
# In Claude Code settings:
1. Go to settings.json
2. Add MCP server:
{
  "mcpServers": {
    "metabase": {
      "command": "curl",
      "args": ["-X", "POST", "http://localhost:3000/api/metabase-mcp"]
    }
  }
}
3. Restart Claude Code
4. Ask: "Create a revenue dashboard"
```

### Claude Code + Lightdash

```bash
# Cloud Pro tier includes MCP
# Local: Use Anthropic API key
# In Lightdash settings:
1. Set LIGHTDASH_ANTHROPIC_API_KEY
2. Enable AI agents
3. Ask: "Show me monthly revenue trends"
```

---

## BACKUP & DISASTER RECOVERY

### Automated Daily Backup

```bash
#!/bin/bash
# backup-all-bi-tools.sh

DATE=$(date +%Y-%m-%d)
BACKUP_DIR="/backups/bi-tools/$DATE"
mkdir -p "$BACKUP_DIR"

# Metabase PostgreSQL
docker exec metabase-db pg_dump -U metabase_user metabase | gzip > "$BACKUP_DIR/metabase.sql.gz"

# Lightdash PostgreSQL (includes pgvector data)
docker exec lightdash-db pg_dump -U lightdash lightdash | gzip > "$BACKUP_DIR/lightdash.sql.gz"

# Superset PostgreSQL
docker exec superset-db pg_dump -U superset superset | gzip > "$BACKUP_DIR/superset.sql.gz"

# dbt project (if using Lightdash)
tar -czf "$BACKUP_DIR/dbt-project.tar.gz" ./dbt-project/

# Clean old backups (keep 7 days)
find /backups/bi-tools -type d -mtime +7 -exec rm -rf {} \;

echo "✅ Backup completed: $BACKUP_DIR"
```

### Restore from Backup

```bash
# Metabase
zcat metabase.sql.gz | docker exec -i metabase-db psql -U metabase_user metabase

# Lightdash
zcat lightdash.sql.gz | docker exec -i lightdash-db psql -U lightdash lightdash

# dbt
tar -xzf dbt-project.tar.gz
```

---

## PERFORMANCE TUNING

### PostgreSQL Optimization

```sql
-- Add indexes for common queries
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_net_amount ON orders(net_amount);
CREATE INDEX idx_orders_status ON orders(status);

-- Analyze table sizes
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Enable pgvector index (Lightdash)
CREATE INDEX idx_embeddings_vector 
ON embeddings USING hnsw (embedding vector_cosine_ops);
```

### Memory Management

```yaml
# In docker-compose.yml:
services:
  metabase:
    environment:
      JAVA_TOOL_OPTIONS: "-Xmx2048m"  # 2GB max
  
  superset:
    environment:
      SUPERSET_WORKERS: 4
      SUPERSET_THREADS: 2
```

### Query Caching (Redis)

```yaml
# All tools benefit from Redis:
redis:
  image: redis:7-alpine
  ports:
    - "6379:6379"
  command: redis-server --maxmemory 1gb --maxmemory-policy allkeys-lru
```

---

## TROUBLESHOOTING MATRIX

| Issue | Metabase | Lightdash | Superset |
|-------|----------|-----------|----------|
| **Can't connect to PostgreSQL** | Check `MB_DB_HOST` env | Check `PGHOST` | Check `SUPERSET_DATABASE_URI` |
| **Dashboard loads slowly** | Increase `JAVA_TOOL_OPTIONS` | Query dbt models | Add Redis cache |
| **MCP not working** | Enable `Admin > AI > MCP` | Check `ANTHROPIC_API_KEY` | Verify `FEATURE_ENABLE_MCP_SERVER` |
| **Out of memory** | Increase Docker memory | Increase container limits | Scale Celery workers |
| **dbt queries failing** | N/A | Check dbt profiles.yml | Use virtual datasets |

---

## COST COMPARISON (Annual, Self-Hosted)

| Tool | Image | DB | Redis | Infrastructure | AI Integration | **Total** |
|------|-------|----|----|---|---|---|
| **Metabase** | Free | €0 | €0 | €1,200 (1 server) | Claude API (pay-as-you-go) | **~€1,200** |
| **Lightdash** | Free | €0 | €50 | €1,500 (2 servers) | Claude API (pay-as-you-go) | **~€1,550** |
| **Superset** | Free | €0 | €50 | €2,400 (HA setup) | Claude API (pay-as-you-go) | **~€2,450** |
| **Grafana** | Free | €0 | €50 | €1,500 (2 servers) | ❌ | **~€1,550** |
| **Evidence** | Free | N/A (static) | N/A | €600 (hosting) | Claude API (pay-as-you-go) | **~€600** |

**Cloud SaaS Alternatives**:
- Metabase Cloud: €100-400/month
- Lightdash Cloud: €299-999/month
- Superset on Preset: €300-1,500/month
- Grafana Cloud: €50-500/month

---

## INTEGRATION WITH IMPORTANT.IS STACK

### Recommended Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    n8n Automation                           │
├──────────────┬──────────────┬──────────────┬────────────────┤
│              │              │              │                │
▼              ▼              ▼              ▼                ▼
ClickUp      Notion        Stripe       WordPress      Google Sheets
 (Tasks)     (Docs)       (Revenue)    (Blog Stats)    (Reports)
│              │              │              │                │
└──────────────┴──────────────┴──────────────┴────────────────┘
                              │
                              ▼
                    PostgreSQL (Data Warehouse)
                              │
                    ┌─────────┴──────────┐
                    │                    │
                    ▼                    ▼
              dbt Models            Raw Tables
              (Lightdash)           (Metabase)
                    │                    │
                    └─────────┬──────────┘
                              │
                    ┌─────────┴──────────┐
                    │                    │
                    ▼                    ▼
            Claude Code (MCP)      Slack Dashboards
            (AI Analysis)          (Notifications)
```

### Setup Checklist

- [ ] Deploy PostgreSQL (managed: AWS RDS, Hetzner DB)
- [ ] Set up n8n workflows (ClickUp, Notion, Stripe webhooks)
- [ ] Choose BI tool (Metabase or Lightdash)
- [ ] Configure dbt project (if using Lightdash)
- [ ] Enable MCP in BI tool
- [ ] Connect Claude Code to MCP server
- [ ] Create first dashboard
- [ ] Set up daily backups
- [ ] Configure Slack notifications
- [ ] Test end-to-end workflow

---

## SUPPORT & RESOURCES

### Official Documentation
- **Metabase**: https://www.metabase.com/docs
- **Superset**: https://superset.apache.org/docs
- **Lightdash**: https://docs.lightdash.com
- **Grafana**: https://grafana.com/docs
- **Evidence**: https://docs.evidence.dev
- **Redash**: https://redash.io/help

### Communities
- Metabase: https://discourse.metabase.com
- Superset: https://github.com/apache/superset/discussions
- Lightdash: Slack community
- n8n: https://community.n8n.io

### Paid Support
- Metabase Cloud (managed)
- Preset (Superset managed)
- Lightdash Cloud
- Grafana Cloud

---

**Last Updated**: June 2026
**For Polish Agencies**: Customize VAT/ZUS calculations in your chosen tool
**Recommendation**: Start with Metabase (fast) → migrate to Lightdash (scalable) as data team grows
