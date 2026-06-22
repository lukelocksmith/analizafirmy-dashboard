# Comprehensive BI/Analytics Tools Analysis
**For Polish Agency Financial Dashboard Use Case**
**Analysis Date: June 2026**

---

## EXECUTIVE SUMMARY

| Tool | Docker Complexity | AI/MCP Ready | Financial Suitability | Maintenance | Polish Fit | Overall Score |
|------|------------------|-------------|----------------------|------------|-----------|---------------|
| **Metabase** | 2/5 | 5/5 ⭐ | 3/5 | 5/5 | 3/5 | 4.2/5 |
| **Apache Superset** | 3/5 | 5/5 ⭐ | 4/5 | 5/5 | 3/5 | 4.0/5 |
| **Lightdash** | 2/5 | 5/5 ⭐ | 4/5 | 4/5 | 3.5/5 | 4.1/5 |
| **Grafana + BI Plugins** | 3/5 | 3/5 | 2/5 | 4/5 | 2/5 | 2.8/5 |
| **Evidence.dev** | 3/5 | 3/5 | 3/5 | 3/5 | 2/5 | 2.8/5 |
| **Redash** | 3/5 | 3/5 | 3/5 | 2/5 | 2.5/5 | 2.7/5 |

**RECOMMENDATION**: **Metabase** for quick deployment with AI integration, or **Lightdash** for code-first approach with dbt metrics.

---

## 1. METABASE

### 1.1 Docker & Deployment Complexity: **2/5** (Very Easy)

**Official Repository**: [github.com/metabase/metabase](https://github.com/metabase/metabase)
- **Stars**: 47.6k
- **Latest Release**: v0.62.1.2 (June 2026)
- **Last Update**: June 20, 2026

**Minimal Docker Compose** (development):
```yaml
version: '3.8'
services:
  metabase:
    image: metabase/metabase:latest
    ports:
      - "3000:3000"
    environment:
      MB_DB_TYPE: postgres
      MB_DB_DBNAME: metabase
      MB_DB_HOST: postgres
      MB_DB_USER: mbuser
      MB_DB_PASS: password
    depends_on:
      - postgres
    
  postgres:
    image: postgres:14-alpine
    environment:
      POSTGRES_DB: metabase
      POSTGRES_USER: mbuser
      POSTGRES_PASSWORD: password
    volumes:
      - metabase-db:/var/lib/postgresql/data

volumes:
  metabase-db:
```

**Key Environment Variables**:
- `MB_DB_TYPE`: postgres, mysql, h2
- `MB_DB_HOST`, `MB_DB_DBNAME`, `MB_DB_USER`, `MB_DB_PASS`
- `MB_JETTY_PORT`: Default 3000
- `MB_ADMIN_EMAIL`, `MB_ADMIN_PASSWORD`

**Production Requirements**:
- **Memory**: 1 CPU + 2GB RAM (baseline); scale 1 CPU + 1GB RAM per 40 concurrent users
- **PostgreSQL Database**: Dedicated instance, weekly VACUUM/ANALYZE, daily backups
- **Database Backend**: PostgreSQL recommended (MySQL supported)

**Infrastructure Complexity**: 2 services (Metabase + PostgreSQL). Clean, simple networking.

---

### 1.2 AI/Code-First Architecture: **5/5** ⭐ (Excellent)

**MCP Server Support** ✅ NATIVE
- Metabase includes official MCP server at `/api/metabase-mcp`
- OAuth 2.0 authentication (embedded server)
- Admin panel: **Admin > AI > MCP**

**MCP Capabilities**:
```
Tools exposed to Claude/ChatGPT/Cursor:
- search(query)           → Find tables, metrics, cards, dashboards
- read_entity(id)         → Fetch entity details
- query(table, filters)   → Construct queries
- execute_query(query)    → Run and return results
- save_question(...)      → Create dashboards/questions
```

**REST API Strength**: **4/5**
- Endpoint: `POST /api/dashboard` → Create dashboards
- Endpoint: `POST /api/card` → Create questions/cards
- Query Language: **MBQL** (Metabase Query Language) - custom JSON format
- API Keys: Supported for programmatic access
- Serialization: YAML export/import for dashboard preloading

**Code-First Readiness**:
- ✅ Dashboards can be created via REST API (JSON)
- ✅ Serialization support (YAML/JSON for versioning)
- ✅ API key authentication
- ✅ MCP integration ready

---

### 1.3 Financial & Accounting Features: **3/5** (Limited but Functional)

**Financial Modeling Package**: ✅ Available
- Pre-built metrics store (PostgreSQL backend)
- Sample SaaS financial models

**Calculated Fields & Expressions**:
```
Supported operations:
- Mathematical: +, -, *, /, abs(), ceil(), floor(), power()
- Aggregations: Sum([Price]), Count(), Avg()
- Percentage: Share([Total] > 50) → returns % as decimal
- Date Arithmetic: dateDiff([date1], [date2])
- Custom Columns: Derived calculations
```

**Example VAT Calculation** (for Poland 23%):
```sql
-- Custom column in Metabase:
[NetAmount] * 1.23 → GrossAmount
```

**Limitations**:
- ❌ No built-in VAT rate schedules (0%, 5%, 8%, 23%)
- ❌ No ZUS percentage tracking (11.26%, 9.76% etc.)
- ❌ No reverse charge logic
- ❌ No split payment support (wpłata podzielona)
- ⚠️ JOIN operations supported via SQL, but UI limited

**Financial Dashboard Suitable For**:
- Revenue tracking
- Cost aggregation
- Time-based rollups (monthly, quarterly)
- Simple percentage/delta calculations
- Margin analysis

---

### 1.4 Maintenance & Community: **5/5** (Excellent)

| Metric | Value |
|--------|-------|
| GitHub Stars | 47.6k |
| Open Issues | 4,071 |
| Release Frequency | Weekly (latest June 2026) |
| Last Commit | June 20, 2026 |
| Commercial Support | ✅ Available (Metabase Cloud) |
| Community Discussions | Active on Discourse |

**Release Quality**: High. Frequent patches, clear changelog.

**Upgrade Path**: Minor/patch updates are safe; major versions require testing.

---

### 1.5 Polish-Specific Fit: **3/5** (Partial)

**What Works**:
- ✅ PLN currency support (standard Postgres feature)
- ✅ Polish date format (configurable)
- ✅ Multi-language UI (Polish supported)

**What Doesn't Work**:
- ❌ No built-in VAT rate calculator (0%, 5%, 8%, 23% rates)
- ❌ No ZUS contribution tracking
- ❌ No reverse charge logic for B2B invoices
- ❌ No split payment webhook support

**n8n Integration**: ✅ NATIVE
- [n8n Metabase integration](https://n8n.io/integrations/metabase/) with 10+ actions
- Workflow templates available
- Can automate Notion/ClickUp → Metabase data sync

---

### 1.6 Key GitHub Repos & Docker Patterns

**Official Dev Docker Compose**: 
- [metabase/metabase/dev/docker-compose.yml](https://github.com/metabase/metabase/blob/master/dev/docker-compose.yml)
- Includes PostgreSQL, MySQL, MongoDB sample databases

**Community Production Setups**:
- [AiratTop/metabase-self-hosted](https://github.com/AiratTop/metabase-self-hosted) - Production-ready with backup scripts
- [MilhosOU/metabase-docker-compose](https://github.com/MilhosOU/metabase-docker-compose) - SSL certificate support
- [QueraTeam/metabase](https://github.com/QueraTeam/metabase) - PostgreSQL backend

**Recommended Production Setup**:
```yaml
version: '3.8'
services:
  metabase:
    image: metabase/metabase:v0.62.1
    environment:
      MB_DB_TYPE: postgres
      MB_DB_HOST: postgres
      MB_DB_DBNAME: metabase
      MB_DB_USER: metabase_user
      MB_DB_PASS: ${METABASE_DB_PASSWORD}
      MB_ADMIN_EMAIL: ${ADMIN_EMAIL}
      MB_ADMIN_PASSWORD: ${ADMIN_PASSWORD}
    ports:
      - "3000:3000"
    depends_on:
      - postgres
    restart: unless-stopped
    healthcheck:
      test: curl -f http://localhost:3000/api/health
      
  postgres:
    image: postgres:14-alpine
    environment:
      POSTGRES_DB: metabase
      POSTGRES_USER: metabase_user
      POSTGRES_PASSWORD: ${METABASE_DB_PASSWORD}
    volumes:
      - metabase-data:/var/lib/postgresql/data
    restart: unless-stopped
```

---

## 2. APACHE SUPERSET

### 2.1 Docker & Deployment Complexity: **3/5** (Moderate)

**Official Repository**: [github.com/apache/superset](https://github.com/apache/superset)
- **Stars**: 73.4k (largest community)
- **Latest Release**: 6.1.0 (May 2026)
- **Last Commit**: 1,562+ commits since 6.1.0
- **Apache Project**: Enterprise-grade governance

**Docker Compose Files** (Multiple options):
- `docker-compose.yml` (Full development)
- `docker-compose-light.yml` (Minimal)
- `docker-compose-non-dev.yml` (Production-like)
- `docker-compose-image-tag.yml` (Versioned images)

**Key Services**:
- Superset application (Python/Flask/React)
- PostgreSQL metadata database
- Redis cache
- Celery worker (query execution)
- Celery beat scheduler

**Memory Requirements**: **Minimum 6GB** for Docker daemon if handling larger datasets.

**Key Environment Variables**:
- `SUPERSET_DATABASE_URI`: PostgreSQL connection
- `REDIS_BROKER_URL`: Redis for async tasks
- `SUPERSET_SECRET_KEY`: Security key
- `SUPERSET_LOAD_EXAMPLES`: Load sample dashboards

**Production Database Support**:
- PostgreSQL (recommended)
- MySQL (with SQLAlchemy drivers)
- External data warehouse connections: Snowflake, BigQuery, ClickHouse, etc.

---

### 2.2 AI/Code-First Architecture: **5/5** ⭐ (Excellent)

**MCP Server Support** ✅ NATIVE
- Apache Superset includes MCP integration
- Custom AI agent capabilities via extensions
- Connect Claude, ChatGPT, Cursor via MCP
- Natural language chart/dashboard generation

**REST API Strength**: **4/5**
- Comprehensive API for dashboard/chart CRUD
- Virtual datasets for JOIN operations
- Metric definitions via SQL expressions

**Code-First Features**:
- ✅ Virtual metrics (semantic layer)
- ✅ Virtual calculated columns
- ✅ dbt metrics integration
- ✅ YAML/JSON configuration support
- ✅ Database migrations tracked

**Example Virtual Metric** (Financial):
```sql
-- Semantic layer metric:
recovery_rate = SUM(recovered) / SUM(confirmed)
-- Used as calculated column in charts
```

---

### 2.3 Financial & Accounting Features: **4/5** (Good)

**Virtual Metrics & Semantic Layer**:
- Define reusable metrics once (recovery_rate, profit_margin, etc.)
- Available across all dashboards
- Prevents metric duplication

**JOIN Operations**: ✅ EXCELLENT
```sql
-- Virtual Dataset: fact table + dimensions
SELECT 
  f.revenue,
  f.cost,
  d.region,
  d.product_type
FROM fact_sales f
JOIN dim_regions d ON f.region_id = d.id
```

**Calculated Fields**:
```sql
-- Virtual calculated column:
CAST(recovery_rate AS FLOAT)
-- Hash joins efficient for dimensional data
```

**Example VAT Calculation**:
```sql
-- Metric in semantic layer:
gross_amount = net_amount * 1.23  -- Poland 23% VAT
```

**Financial Dashboards**:
- ✅ Revenue trend tracking
- ✅ Cost aggregation (JOINs to dimension tables)
- ✅ Percentage/delta calculations
- ✅ Time-based rollups (GROUP BY month, quarter)
- ✅ Multi-currency support (via database)

**Limitations**:
- ❌ No built-in VAT rate schedules
- ❌ No ZUS contribution formulas
- ⚠️ GROUP BY limitations in Virtual Datasets (can cause double-aggregation)

---

### 2.4 Maintenance & Community: **5/5** (Excellent)

| Metric | Value |
|--------|-------|
| GitHub Stars | 73.4k (Most popular) |
| Release Model | Apache + enterprise backing |
| Release Cycle | Regular (6.1.0 in May) |
| Commits Since Last | 1,562+ |
| Community | Large (Slack, discussions) |
| Commercial Support | Preset (managed service) |

**Stability**: High. Rigorous Apache release process.

---

### 2.5 Polish-Specific Fit: **3/5** (Partial)

- ✅ PLN currency (database-level)
- ✅ Polish UI localization
- ❌ No VAT rate schedules
- ❌ No ZUS tracking
- ⚠️ Virtual Datasets have GROUP BY gotchas (not ideal for complex aggregations)

**n8n Integration**: ✅ Available
- Can sync data to Superset
- Webhook support for alerts

---

### 2.6 Key GitHub Repos & Docker Patterns

**Official Repository**: [apache/superset](https://github.com/apache/superset)

**Helm Chart** (Kubernetes): [apache/superset/helm/superset](https://github.com/apache/superset/tree/master/helm/superset)

**Recommended Production Docker Compose**:
```yaml
version: '3.8'
services:
  superset:
    image: apache/superset:${SUPERSET_VERSION:-latest}
    environment:
      SUPERSET_DATABASE_URI: postgresql://user:pass@postgres:5432/superset
      REDIS_BROKER_URL: redis://redis:6379/0
      SUPERSET_SECRET_KEY: ${SUPERSET_SECRET}
      SUPERSET_LOAD_EXAMPLES: 'false'
    ports:
      - "8088:8088"
    depends_on:
      - postgres
      - redis
    restart: unless-stopped

  postgres:
    image: postgres:14-alpine
    environment:
      POSTGRES_DB: superset
      POSTGRES_USER: superset
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - superset-db:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    restart: unless-stopped

  celery-worker:
    image: apache/superset:${SUPERSET_VERSION:-latest}
    command: celery --app=superset.tasks.celery_app:app worker
    environment:
      SUPERSET_DATABASE_URI: postgresql://user:pass@postgres:5432/superset
      REDIS_BROKER_URL: redis://redis:6379/0
    depends_on:
      - postgres
      - redis

volumes:
  superset-db:
```

---

## 3. LIGHTDASH

### 3.1 Docker & Deployment Complexity: **2/5** (Very Easy)

**Official Repository**: [github.com/lightdash/lightdash](https://github.com/lightdash/lightdash)
- **Stars**: 3.8k
- **MIT License**: ✅ Fully open source
- **Recent Releases**: 0.3055.0+ (active development)
- **PR Velocity**: Very high (multiple releases/month)

**Official Docker Compose** (GitHub):
```yaml
version: '3.8'
services:
  lightdash:
    image: lightdash/lightdash:latest
    platform: linux/amd64
    ports:
      - "8080:8080"
    environment:
      PGHOST: postgres
      PGPORT: 5432
      PGDATABASE: lightdash
      PGUSER: lightdash
      PGPASSWORD: ${DB_PASSWORD}
      LIGHTDASH_SECRET: ${LIGHTDASH_SECRET}
    depends_on:
      - postgres
      - headless-browser
    
  postgres:
    image: pgvector/pgvector:pg15-latest
    environment:
      POSTGRES_DB: lightdash
      POSTGRES_USER: lightdash
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - lightdash-db:/var/lib/postgresql/data

  headless-browser:
    image: browserless/chrome:latest
    ports:
      - "3001:3000"

  minio:
    image: minio/minio:latest
    ports:
      - "9000:9000"
      - "9001:9001"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    volumes:
      - minio-data:/data

volumes:
  lightdash-db:
  minio-data:
```

**Key Environment Variables**:
- `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, `PGPASSWORD`: PostgreSQL
- `LIGHTDASH_SECRET`: Session encryption
- Google OAuth, OpenAI/Anthropic AI settings
- S3/MinIO bucket configuration
- Slack, GitHub integrations

**Infrastructure**: 4-5 services (Lightdash, PostgreSQL pgvector, headless browser, MinIO, optional Redis)

---

### 3.2 AI/Code-First Architecture: **5/5** ⭐ (Excellent)

**AI Agents**: ✅ NATIVE & ADVANCED
- LLM-powered agents (OpenAI, Anthropic, Azure, Bedrock)
- MCP integration (Cloud Pro tier)
- Natural language dashboard generation
- Auto-generates derived metrics

**Code-First Philosophy**: ✅ STRONGEST IN CLASS
- All metrics/dimensions defined in **dbt .yml files** (YAML)
- Version-controlled business logic
- CI/CD ready (deployable via git)
- Cursor/Copilot integration for fast development
- Preview environments mirror dbt dev workflow

**Example dbt Metrics Definition** (YAML):
```yaml
models:
  - name: orders
    columns:
      - name: order_id
        description: "Primary key"
    
    metrics:
      - name: total_revenue
        type: sum
        sql: "{{ column_name('amount') }}"
        filters:
          - field: status
            operator: "="
            value: "completed"
        description: "Total revenue from completed orders"
      
      - name: gross_margin
        type: expression
        sql: "{{ metric('total_revenue') }} / {{ metric('total_cost') }}"
        description: "Gross margin percentage"
```

**REST API**: **4/5**
- Dashboard creation via API
- Webhook support for reports
- Query execution via API

**MCP Server**: ✅ Available (Cloud Pro)
- Query execution
- Metric discovery
- Dashboard creation

---

### 3.3 Financial & Accounting Features: **4/5** (Good)

**Metrics Framework**:
- Reusable financial metrics (revenue, cost, margin)
- Calculated metrics from base metrics
- AI agents can create new metrics from natural language

**JOIN & Aggregation**: ✅ EXCELLENT
- dbt models handle JOINs natively
- Lightdash respects dbt lineage
- Support for star schema (fact + dimensions)

**Example Financial Metrics** (dbt YAML):
```yaml
metrics:
  - name: net_revenue
    type: sum
    sql: "{{ column_name('gross_amount') }} - {{ column_name('vat_amount') }}"
  
  - name: monthly_revenue
    type: sum
    sql: "{{ column_name('amount') }}"
    time_grains: [month, quarter, year]
  
  - name: revenue_percentage_of_total
    type: expression
    sql: "{{ metric('net_revenue') }} / SUM({{ column_name('amount') }})"
```

**Time-Based Aggregation**: ✅ NATIVE (time_grains support)

**Limitations**:
- ❌ No built-in VAT schedules
- ❌ No ZUS formulas
- ⚠️ Requires dbt project (not a drawback for data teams)

**Financial Dashboard Suitable For**:
- SaaS MRR/ARR tracking
- Revenue cohort analysis
- Churn & expansion metrics
- Invoice/billing dashboards
- Multi-tenant financial reports

---

### 3.4 Maintenance & Community: **4/5** (Good)

| Metric | Value |
|--------|-------|
| GitHub Stars | 3.8k |
| Release Velocity | Very high (0.3055.0+) |
| License | MIT (fully open) |
| Commercial Offering | Lightdash Cloud |
| Community | Growing (Slack, GitHub) |
| pgvector Integration | ✅ (AI embeddings ready) |

**Stability**: Good but newer than Metabase/Superset. Regular releases indicate active development.

---

### 3.5 Polish-Specific Fit: **3.5/5** (Good)

**What Works**:
- ✅ PLN currency (via dbt transformations)
- ✅ Polish date format
- ✅ Code-first approach (Polish team comfort with dbt)

**What Needs Custom Work**:
- ⚠️ VAT calculations via dbt metrics
- ⚠️ ZUS tracking via calculated metrics
- ⚠️ Split payment logic in dbt models

**n8n Integration**: ⚠️ Partial
- Can sync data to Lightdash via API
- Better for dbt-to-ClickUp/Notion workflows

---

### 3.6 Key Repos & Docker Patterns

**Official Repository**: [lightdash/lightdash](https://github.com/lightdash/lightdash)

**Docker Compose**: [lightdash/docker-compose.yml](https://github.com/lightdash/lightdash/blob/main/docker-compose.yml)

**Additional Resources**:
- [Lightdash Helm Charts](https://github.com/lightdash/helm-charts) - Kubernetes
- [Terraform Provider](https://github.com/ubie-oss/terraform-provider-lightdash)

---

## 4. GRAFANA + BI PLUGINS

### 4.1 Docker & Deployment Complexity: **3/5** (Moderate)

**Repository**: [github.com/grafana/grafana](https://github.com/grafana/grafana)
- **Stars**: 74.6k (most starred)
- **Latest Release**: v12.4.4 (June 2026)
- **Status**: v13.0.1 available (recently fixed)

**Basic Docker Compose**:
```yaml
version: '3.8'
services:
  grafana:
    image: grafana/grafana:12.4.4
    ports:
      - "3000:3000"
    environment:
      GF_SECURITY_ADMIN_PASSWORD: ${ADMIN_PASSWORD}
      GF_DATABASE_TYPE: postgres
      GF_DATABASE_HOST: postgres:5432
      GF_DATABASE_NAME: grafana
      GF_DATABASE_USER: grafana
      GF_DATABASE_PASSWORD: ${DB_PASSWORD}
      GF_INSTALL_PLUGINS: volkovlabs-table-panel
    depends_on:
      - postgres
    volumes:
      - grafana-data:/var/lib/grafana

  postgres:
    image: postgres:14-alpine
    environment:
      POSTGRES_DB: grafana
      POSTGRES_USER: grafana
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - grafana-db:/var/lib/postgresql/data

volumes:
  grafana-data:
  grafana-db:
```

**Key BI Plugins** (Community-maintained):
- **Business Table** (volkovlabs-table-panel) - Advanced data tables
- **Business Charts** (Apache ECharts integration)
- **Business Variable** - Dynamic dashboard variables
- **Business Media** - Media file display

**BI Plugin Maintenance**: Grafana Labs committed to maintenance **until July 2026** for Grafana 12.x compatibility.

---

### 4.2 AI/Code-First Architecture: **3/5** (Limited)

**MCP Support**: ⚠️ Limited
- No native MCP server
- Third-party implementations exist but not official

**REST API**: **3/5**
- Dashboard creation via API
- But not optimized for code-first workflows
- Configuration-as-code less mature than Superset

**Code-First Readiness**: ⚠️ Partial
- Dashboards can be defined in JSON
- Provisioning via config files exists
- But UI-first tool, not code-first

---

### 4.3 Financial & Accounting Features: **2/5** (Poor)

**Primary Use Case**: Observability/monitoring, not financial BI

**Limitations**:
- ❌ No semantic layer (virtual metrics)
- ❌ Limited JOIN support in UI
- ❌ Business Table plugin not optimized for accounting data
- ⚠️ Dashboards are visualization-first, not metric-first

**Financial Unsuitable For**:
- ❌ Revenue/cost tracking (no clean metrics layer)
- ❌ Cohort/segment analysis
- ❌ Complex financial calculations

**Use Case**: Market data visualization, infrastructure monitoring dashboards.

---

### 4.4 Maintenance & Community: **4/5** (Good)

| Metric | Value |
|--------|-------|
| GitHub Stars | 74.6k (Most popular) |
| Latest Release | v12.4.4 (June 2026) |
| BI Plugin Support | Until July 2026 |
| Business Input Plugin | v12.x only (minimal updates) |

---

### 4.5 Polish-Specific Fit: **2/5** (Poor)

- ✅ UI localization available
- ❌ Not optimized for financial dashboards
- ❌ No VAT/ZUS support

---

## 5. EVIDENCE.DEV

### 5.1 Docker & Deployment Complexity: **3/5** (Moderate)

**Repository**: [github.com/evidence-dev/evidence](https://github.com/evidence-dev/evidence)
- **Stars**: 6.4k
- **License**: MIT
- **Type**: Static site generator (BI as code)
- **Architecture**: SvelteKit + Node.js

**Deployment Model**:
- Builds to **static HTML** (no runtime required)
- Deployment to: GitHub Pages, Vercel, Netlify, self-hosted
- No database needed for static content

**Docker Setup** (Optional, for dev):
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY . .
RUN npm install && npm run build
EXPOSE 3000
CMD ["npm", "run", "preview"]
```

**Key Environment Variables**:
- `EVIDENCE_SOURCE__[source_name]__[option]`: Data source config
- GitHub Actions workflow for automatic builds

**Infrastructure**: Minimal (static hosting only)

---

### 5.2 AI/Code-First Architecture: **3/5** (Code-First, Limited AI)

**Code-First Philosophy**: ✅ STRONG
- Dashboards written in **SQL + Markdown**
- Version-controlled in Git
- Deployable via CI/CD
- No drag-and-drop UI

**Example Evidence Dashboard** (SQL + Markdown):
```markdown
# Revenue Dashboard

## Monthly Revenue

\`\`\`sql
SELECT 
  DATE_TRUNC('month', order_date) as month,
  SUM(amount) as total_revenue
FROM orders
WHERE status = 'completed'
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month DESC
\`\`\`

<BarChart 
  data={data}
  x=month
  y=total_revenue
/>
```

**MCP Support**: ⚠️ Limited
- No native MCP server
- Can be integrated via REST API

**REST API**: **2/5**
- Limited API exposure (static generation focus)
- No dashboard creation endpoint

---

### 5.3 Financial & Accounting Features: **3/5** (Adequate)

**Capabilities**:
- ✅ SQL-based calculations (VAT, ZUS formulas)
- ✅ Custom SQL expressions
- ✅ JOIN operations via SQL
- ✅ Time-based grouping

**Example VAT Calculation** (SQL):
```sql
SELECT 
  order_id,
  net_amount,
  net_amount * 0.23 as vat_amount,
  net_amount * 1.23 as gross_amount
FROM invoices
WHERE country = 'PL'
```

**Limitations**:
- ❌ Dashboards static (no interactive filters at runtime)
- ❌ No real-time updates (rebuild required)
- ⚠️ Limited interactivity (static charts)

---

### 5.4 Maintenance & Community: **3/5** (Growing)

| Metric | Value |
|--------|-------|
| GitHub Stars | 6.4k |
| License | MIT |
| Release Activity | Ongoing |
| Community Size | Growing |

---

### 5.5 Polish-Specific Fit: **2/5** (Poor)

- ⚠️ No localization out-of-box
- ⚠️ Static content (not ideal for real-time financial dashboards)
- ⚠️ Rebuild needed for data updates

**Best Use Case**: Static reporting (monthly/quarterly financial reports).

---

## 6. REDASH

### 6.1 Docker & Deployment Complexity: **3/5** (Moderate)

**Repository**: [github.com/getredash/redash](https://github.com/getredash/redash)
- **Stars**: 28.6k
- **Status**: Community-led project (transitioned 2026)
- **Latest Release**: v26.3.0 (June 2026)
- **Volunteers**: 7 maintainers

**Docker Compose Services**:
- Redash server (Python/Flask)
- Redash worker (query execution)
- PostgreSQL (metadata)
- Redis (caching)

**Key Environment Variables**:
- `REDASH_DATABASE_URL`: PostgreSQL connection
- `REDASH_REDIS_URL`: Redis
- `REDASH_SECRET_KEY`: Session encryption
- `REDASH_COOKIE_SECRET`: CSRF protection

**Memory**: 4GB+ recommended

---

### 6.2 AI/Code-First Architecture: **3/5** (Limited)

**MCP Support**: ⚠️ Partial
- Third-party MCP implementations available
- No native support

**REST API**: **2/5**
- Query execution requires 3 steps (refresh, poll status, get results)
- No dashboard creation API (primarily UI-based)
- Webhook destination for alerts only

**Code-First Readiness**: ⚠️ Poor
- Primarily UI-driven
- Queries can be version-controlled but dashboards are not
- Limited programmatic dashboard definition

---

### 6.3 Financial & Accounting Features: **3/5** (Adequate)

**Capabilities**:
- ✅ SQL queries for custom calculations
- ✅ JOIN operations via SQL
- ✅ Webhook support for notifications

**Limitations**:
- ❌ No semantic layer
- ❌ No metric reuse framework
- ❌ Limited calculated field support in UI
- ⚠️ Query API is cumbersome (3-step process)

---

### 6.4 Maintenance & Community: **2/5** (Declining)

| Metric | Value |
|--------|-------|
| GitHub Stars | 28.6k |
| Status | Community-led (volunteers) |
| Recent Activity | Reduced (transition period) |
| Open Issues | 624 PRs, 28 help-wanted |

**Concern**: Limited volunteer bandwidth for new features or rapid bug fixes.

---

### 6.5 Polish-Specific Fit: **2.5/5** (Limited)

- ⚠️ No built-in financial features
- ⚠️ Community support may be slow

---

## 7. COMPARATIVE ANALYSIS

### 7.1 Docker Complexity Ranking

```
1. Lightdash        (2/5) - 4-5 services, pgvector ready
2. Metabase         (2/5) - 2 services, simplest setup
3. Evidence.dev     (3/5) - Node.js + build, static hosting
4. Redash           (3/5) - 4 services (server, worker, DB, Redis)
5. Superset         (3/5) - 5+ services (app, DB, Redis, Celery worker/beat)
6. Grafana          (3/5) - PostgreSQL, plugins to manage
```

### 7.2 MCP/AI Integration Ranking

```
1. Metabase  (5/5) - Native MCP server, OAuth built-in
2. Superset  (5/5) - Native MCP integration, AI-native
3. Lightdash (5/5) - MCP + native AI agents (Cloud Pro)
4. Grafana   (3/5) - No native support
5. Redash    (3/5) - Third-party MCP only
6. Evidence  (3/5) - Limited API exposure
```

### 7.3 Financial Dashboard Suitability

```
1. Lightdash  (4/5) - dbt metrics, derived calculations
2. Superset   (4/5) - Virtual metrics, semantic layer, JOINs
3. Metabase   (3/5) - Custom expressions, basic calculations
4. Redash     (3/5) - SQL queries, no semantic layer
5. Evidence   (3/5) - SQL-based, but static
6. Grafana    (2/5) - Monitoring-first, not financial-first
```

### 7.4 Polish Agency Use Case: n8n Integration

**Recommended Flow**:
```
Notion (Tasks)  ──→  n8n workflow  ──→  Lightdash (dbt models)
ClickUp (Time)  ──→               ──→  Metabase  (dashboards)
Stripe (Revenue) ──→              ──→  Superset  (reports)
```

**n8n Actions Available**:

| Tool | Metabase | Superset | Lightdash | Grafana | Redash | Evidence |
|------|----------|----------|-----------|---------|--------|----------|
| Create dashboard | ✅ | ✅ | ✅ API | ❌ Limited | ❌ No | ❌ No |
| Execute query | ✅ | ✅ | ✅ | ❌ | ⚠️ Slow | ❌ |
| Sync data | ✅ | ✅ | ✅ | ❌ | ✅ | ⚠️ |
| Webhooks | ✅ | ✅ | ✅ | ⚠️ | ✅ | ❌ |

---

## 8. POLISH-SPECIFIC REQUIREMENTS: VAT & ZUS

### 8.1 VAT Requirements

**Poland VAT Rates**:
- 23% - Standard rate (most goods/services)
- 8% - Reduced rate (food, books)
- 5% - Very reduced (food staples)
- 0% - Exports, certain services

**Implementation Approach**:

**Metabase**:
```sql
-- Custom column formula:
CASE 
  WHEN product_category = 'food_basic' THEN net_amount * 1.05
  WHEN product_category = 'food' THEN net_amount * 1.08
  ELSE net_amount * 1.23
END AS gross_amount
```

**Lightdash (dbt)**:
```yaml
metrics:
  - name: gross_amount_pl
    type: expression
    sql: |
      CASE 
        WHEN {{ column_name('vat_rate') }} = '5%' THEN {{ column_name('net_amount') }} * 1.05
        WHEN {{ column_name('vat_rate') }} = '8%' THEN {{ column_name('net_amount') }} * 1.08
        ELSE {{ column_name('net_amount') }} * 1.23
      END
```

**Superset**:
```sql
-- Virtual metric in semantic layer:
CASE 
  WHEN vat_rate = 0.05 THEN net_amount * 1.05
  WHEN vat_rate = 0.08 THEN net_amount * 1.08
  ELSE net_amount * 1.23
END
```

### 8.2 ZUS Requirements

**ZUS Contribution Rates** (Employee + Employer):
- Social Insurance (emerytury): 11.26% (employee) + 14.84% (employer)
- Health Insurance: 9% (employee) + 9% (employer)
- Labour Fund: 0.24% (employer)

**Implementation** (Lightdash example):
```yaml
metrics:
  - name: employee_zus_total
    type: expression
    sql: "gross_salary * 0.2026"  # 11.26% + 9%
  
  - name: employer_zus_cost
    type: expression
    sql: "gross_salary * 0.2408"  # 14.84% + 9% + 0.24%
```

### 8.3 Split Payment Support

**Mechanism**: Bank automatically splits B2B invoice payments:
- NET amount → Supplier account
- VAT amount → Separate VAT account

**Tracking in BI Tool**:
```sql
-- Lightdash dbt model:
SELECT 
  invoice_id,
  net_amount,
  vat_amount,
  CASE 
    WHEN split_payment_required THEN 'vat_account'
    ELSE 'normal'
  END as payment_destination
FROM invoices
```

---

## 9. FINAL RECOMMENDATIONS

### 9.1 Quick Deployment (MVP) → **METABASE**

**Best for**: Agency getting BI quickly, executives want dashboards, not building complex pipelines

**Setup Time**: 30 minutes (docker-compose up)

**Strengths**:
- Easiest deployment (2 services)
- Native MCP support (AI integration)
- REST API for programmatic dashboards
- n8n integration ready

**Polish Adaptation Work**:
- Create custom VAT calculation columns
- Build ZUS contribution dashboard
- Set up n8n workflow: ClickUp → Metabase metrics

**Architecture**:
```
Notion/ClickUp → n8n → PostgreSQL ← Metabase (with custom columns)
```

---

### 9.2 Code-First (Mature Data Team) → **LIGHTDASH**

**Best for**: Teams using dbt, wanting version-controlled metrics, AI-powered analysis

**Setup Time**: 1-2 hours (with dbt project)

**Strengths**:
- Metrics defined in dbt YAML (version-controlled)
- AI agents (Anthropic integration)
- MCP support (Claude integration)
- Derived metrics from natural language

**Polish Adaptation Work**:
- Define VAT/ZUS metrics in dbt models
- Set up CI/CD pipeline for dbt + Lightdash
- Configure n8n: ClickUp → dbt models → Lightdash

**Architecture**:
```
ClickUp/Notion → n8n → dbt → Lightdash (semantic layer) → AI agents
```

---

### 9.3 Enterprise Scale → **APACHE SUPERSET**

**Best for**: Large organizations, complex analytics, multi-datasource federation

**Setup Time**: 2-3 hours (services + configuration)

**Strengths**:
- Most mature ecosystem (73.4k stars)
- Virtual metrics (semantic layer)
- MCP native support
- Helm charts for Kubernetes

**Polish Adaptation Work**:
- Define virtual metrics for VAT/ZUS
- Configure external data warehouses (Snowflake, BigQuery)
- Set up Celery workers for heavy queries

**Architecture**:
```
Multiple Data Sources → Superset → Virtual Metrics → Dashboards/MCP
```

---

### 9.4 Polish Agency Standard Stack

```yaml
Tech Stack:
  - Data Warehouse: PostgreSQL (self-hosted) or BigQuery
  - Transformation: dbt (for metrics)
  - BI Tool: Metabase (quick) OR Lightdash (code-first)
  - Automation: n8n (Notion/ClickUp sync)
  - AI Integration: Claude MCP (via Metabase/Lightdash)

Polish Financial Features:
  - Custom dbt models for VAT (0%, 5%, 8%, 23%)
  - ZUS contribution tracking metrics
  - Split payment detection & reporting
  - PLN currency formatting
  - Monthly revenue rollups

n8n Workflows:
  - ClickUp tasks → Lightdash revenue forecast
  - Notion budget → Metabase variance analysis
  - Stripe webhook → Real-time revenue dashboard
```

---

## 10. GITHUB REPOS SUMMARY TABLE

| Tool | Stars | Main Repo | Docker Compose | Latest Release | Maintenance |
|------|-------|-----------|-----------------|----------------|-------------|
| **Metabase** | 47.6k | metabase/metabase | dev/docker-compose.yml | v0.62.1.2 (Jun 2026) | ✅ Active |
| **Superset** | 73.4k | apache/superset | Multiple (light/prod) | 6.1.0 (May 2026) | ✅ Apache-backed |
| **Lightdash** | 3.8k | lightdash/lightdash | main/docker-compose.yml | 0.3055.0+ | ✅ Very active |
| **Grafana** | 74.6k | grafana/grafana | Included | v12.4.4 (Jun 2026) | ✅ Active |
| **Evidence** | 6.4k | evidence-dev/evidence | No (static gen) | Recent releases | ✅ Active |
| **Redash** | 28.6k | getredash/redash | In wiki/discussions | v26.3.0 (Jun 2026) | ⚠️ Volunteer-driven |

---

## SOURCES

- [Metabase GitHub](https://github.com/metabase/metabase)
- [Metabase MCP Server Documentation](https://www.metabase.com/docs/latest/ai/mcp)
- [Apache Superset GitHub](https://github.com/apache/superset)
- [Superset Docker Compose Guide](https://superset.apache.org/docs/installation/docker-compose/)
- [Lightdash GitHub](https://github.com/lightdash/lightdash)
- [Lightdash Docker Compose](https://github.com/lightdash/lightdash/blob/main/docker-compose.yml)
- [Grafana GitHub](https://github.com/grafana/grafana)
- [Grafana BI Plugins Blog](https://grafana.com/blog/business-intelligence-plugins-for-grafana-whats-next)
- [Evidence.dev GitHub](https://github.com/evidence-dev/evidence)
- [Redash GitHub](https://github.com/getredash/redash)
- [n8n Metabase Integration](https://n8n.io/integrations/metabase/)
- [Metabase Custom Expressions](https://www.metabase.com/docs/latest/questions/query-builder/expressions)
- [Lightdash Metrics Reference](https://docs.lightdash.com/references/metrics)
- [Metabase Production Deployment Guide](https://www.metabase.com/learn/metabase-basics/administration/administration-and-operation/metabase-in-production)

---

**Analysis Complete | June 2026**
