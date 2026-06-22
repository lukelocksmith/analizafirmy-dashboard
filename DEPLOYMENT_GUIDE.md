# BI Tools Deployment Guide
**Production-Ready Docker Compose Examples**

---

## 1. METABASE - PRODUCTION SETUP

### docker-compose.yml
```yaml
version: '3.8'

services:
  metabase:
    image: metabase/metabase:v0.62.1
    container_name: metabase
    ports:
      - "3000:3000"
    environment:
      # Database configuration
      MB_DB_TYPE: postgres
      MB_DB_HOST: postgres
      MB_DB_PORT: 5432
      MB_DB_DBNAME: metabase
      MB_DB_USER: metabase_user
      MB_DB_PASS: ${METABASE_DB_PASSWORD}
      
      # Admin setup
      MB_ADMIN_EMAIL: ${ADMIN_EMAIL}
      MB_ADMIN_PASSWORD: ${ADMIN_PASSWORD}
      
      # MCP Server configuration
      MB_AI_MCP_ENABLED: "true"
      
      # Session configuration
      MB_SESSION_COOKIES: "true"
      JAVA_TOOL_OPTIONS: "-Xmx2048m"
      
      # Timezone
      TIMEZONE: Europe/Warsaw
      
    depends_on:
      postgres:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 5
    networks:
      - metabase-net
    volumes:
      - metabase-plugins:/plugins

  postgres:
    image: postgres:14-alpine
    container_name: metabase-db
    environment:
      POSTGRES_DB: metabase
      POSTGRES_USER: metabase_user
      POSTGRES_PASSWORD: ${METABASE_DB_PASSWORD}
      POSTGRES_INITDB_ARGS: "-c max_connections=100"
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U metabase_user"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - metabase-net
    volumes:
      - metabase-db:/var/lib/postgresql/data
    ports:
      - "5432:5432"  # For external tools to query your data warehouse

volumes:
  metabase-db:
  metabase-plugins:

networks:
  metabase-net:
    driver: bridge
```

### .env.example
```bash
# Metabase Admin Credentials
ADMIN_EMAIL=admin@important.is
ADMIN_PASSWORD=SecurePassword123!

# PostgreSQL Database (Metabase metadata store)
METABASE_DB_PASSWORD=secure_postgres_pass_123

# Optional: External Data Warehouse Connection
# (Point Metabase to your actual data warehouse)
DATA_WAREHOUSE_HOST=data-warehouse.internal
DATA_WAREHOUSE_PORT=5432
DATA_WAREHOUSE_DB=analytics
DATA_WAREHOUSE_USER=analytics_user
DATA_WAREHOUSE_PASS=warehouse_password
```

### Startup Script
```bash
#!/bin/bash
# setup-metabase.sh

set -e

# Load environment
source .env

# Create Docker network (if doesn't exist)
docker network create metabase-net || true

# Start services
docker-compose up -d

# Wait for Metabase to be healthy
echo "Waiting for Metabase to be healthy..."
for i in {1..30}; do
  if curl -s http://localhost:3000/api/health > /dev/null; then
    echo "✅ Metabase is healthy"
    break
  fi
  echo "Waiting... ($i/30)"
  sleep 2
done

# Get initial setup token and print URL
echo ""
echo "🎉 Metabase is running!"
echo "📍 URL: http://localhost:3000"
echo "👤 Email: $ADMIN_EMAIL"
echo ""
echo "Next steps:"
echo "1. Complete initial setup in UI"
echo "2. Go to Admin > AI > MCP to enable Claude integration"
echo "3. Add your data sources"
```

### Backup Script
```bash
#!/bin/bash
# backup-metabase.sh

BACKUP_DIR="./backups"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="$BACKUP_DIR/metabase-backup-$DATE.sql"

mkdir -p "$BACKUP_DIR"

# Backup PostgreSQL database
docker exec metabase-db pg_dump -U metabase_user metabase > "$BACKUP_FILE"

# Compress
gzip "$BACKUP_FILE"

echo "✅ Backup created: ${BACKUP_FILE}.gz"

# Keep only last 7 days
find "$BACKUP_DIR" -name "*.gz" -mtime +7 -delete
```

---

## 2. LIGHTDASH - PRODUCTION SETUP

### docker-compose.yml
```yaml
version: '3.8'

services:
  lightdash:
    image: lightdash/lightdash:latest
    container_name: lightdash
    platform: linux/amd64
    ports:
      - "8080:8080"
    environment:
      # PostgreSQL Configuration (with pgvector)
      PGHOST: postgres
      PGPORT: 5432
      PGDATABASE: lightdash
      PGUSER: lightdash
      PGPASSWORD: ${DB_PASSWORD}
      
      # Security
      LIGHTDASH_SECRET: ${LIGHTDASH_SECRET_KEY}
      
      # dbt Configuration
      DBT_PROFILES_DIR: /app/.dbt
      
      # AI Integration
      LIGHTDASH_OPENAI_API_KEY: ${OPENAI_API_KEY}
      LIGHTDASH_ANTHROPIC_API_KEY: ${ANTHROPIC_API_KEY}
      
      # External Services
      LIGHTDASH_S3_BUCKET: ${S3_BUCKET_NAME}
      LIGHTDASH_S3_KEY: ${AWS_ACCESS_KEY}
      LIGHTDASH_S3_SECRET: ${AWS_SECRET_KEY}
      LIGHTDASH_S3_REGION: eu-central-1
      
      # Slack Integration
      LIGHTDASH_SLACK_CLIENT_ID: ${SLACK_CLIENT_ID}
      LIGHTDASH_SLACK_CLIENT_SECRET: ${SLACK_CLIENT_SECRET}
      
      # Google OAuth
      LIGHTDASH_GOOGLE_OAUTH_CLIENT_ID: ${GOOGLE_CLIENT_ID}
      LIGHTDASH_GOOGLE_OAUTH_CLIENT_SECRET: ${GOOGLE_CLIENT_SECRET}
      
      # Time Zone
      TZ: Europe/Warsaw
      
    depends_on:
      postgres:
        condition: service_healthy
      headless-browser:
        condition: service_started
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/api/health"]
      interval: 30s
      timeout: 10s
      retries: 5
    networks:
      - lightdash-net
    volumes:
      - ./dbt-project:/app/.dbt:ro
      - lightdash-data:/app/data

  postgres:
    image: pgvector/pgvector:pg15-latest
    container_name: lightdash-db
    environment:
      POSTGRES_DB: lightdash
      POSTGRES_USER: lightdash
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_INITDB_ARGS: "-c max_connections=100 -c shared_preload_libraries=vector"
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U lightdash"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - lightdash-net
    volumes:
      - lightdash-db:/var/lib/postgresql/data
    command: ["postgres", "-c", "shared_preload_libraries=vector"]

  headless-browser:
    image: browserless/chrome:latest
    container_name: lightdash-browser
    ports:
      - "3001:3000"
    restart: unless-stopped
    networks:
      - lightdash-net
    environment:
      DEFAULT_LAUNCH_ARGS: --no-sandbox,--disable-setuid-sandbox

  minio:
    image: minio/minio:latest
    container_name: lightdash-minio
    ports:
      - "9000:9000"
      - "9001:9001"
    environment:
      MINIO_ROOT_USER: ${MINIO_ROOT_USER:-minioadmin}
      MINIO_ROOT_PASSWORD: ${MINIO_ROOT_PASSWORD:-minioadmin}
    restart: unless-stopped
    networks:
      - lightdash-net
    volumes:
      - minio-data:/data
    command: server /data --console-address ":9001"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 10s
      retries: 3

  redis:
    image: redis:7-alpine
    container_name: lightdash-redis
    restart: unless-stopped
    networks:
      - lightdash-net
    volumes:
      - redis-data:/data

volumes:
  lightdash-db:
  lightdash-data:
  minio-data:
  redis-data:

networks:
  lightdash-net:
    driver: bridge
```

### .env.example
```bash
# PostgreSQL
DB_PASSWORD=secure_postgres_pass_456

# Lightdash Security
LIGHTDASH_SECRET_KEY=$(openssl rand -base64 32)

# AI Integration
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...

# AWS S3 (for file storage)
S3_BUCKET_NAME=lightdash-storage
AWS_ACCESS_KEY=AKIA...
AWS_SECRET_KEY=...
AWS_REGION=eu-central-1

# Slack
SLACK_CLIENT_ID=...
SLACK_CLIENT_SECRET=...

# Google OAuth
GOOGLE_CLIENT_ID=...
GOOGLE_CLIENT_SECRET=...

# MinIO (Local S3 alternative)
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin
```

### dbt Project Integration

Create `dbt-project/models/metrics.yml`:
```yaml
models:
  - name: orders
    description: "Order fact table"
    
    columns:
      - name: order_id
        data_type: integer
        description: "Primary key"
      
      - name: order_date
        data_type: date
      
      - name: net_amount
        data_type: numeric
      
      - name: vat_rate
        data_type: numeric
        description: "VAT rate (0.05, 0.08, 0.23)"

    metrics:
      # Financial Metrics
      - name: total_revenue
        label: "Total Revenue (PLN)"
        type: sum
        sql: "{{ column_name('net_amount') }}"
        description: "Sum of all net order amounts"
        time_grains: [day, week, month, quarter, year]
        filters:
          - field: status
            operator: "="
            value: "completed"
      
      - name: gross_revenue
        label: "Gross Revenue (23% VAT)"
        type: expression
        sql: "{{ metric('total_revenue') }} * 1.23"
        description: "Total revenue with standard VAT (23%)"
      
      - name: vat_collected
        label: "VAT Collected"
        type: expression
        sql: "{{ metric('total_revenue') }} * 0.23"
        description: "VAT amount collected (23% standard rate)"
      
      - name: order_count
        label: "Order Count"
        type: count
        description: "Total number of orders"
      
      - name: average_order_value
        label: "Average Order Value"
        type: expression
        sql: "{{ metric('total_revenue') }} / NULLIF({{ metric('order_count') }}, 0)"
        description: "Average net amount per order"
      
      # ZUS Metrics (Employee contributions)
      - name: employee_zus_total
        label: "Employee ZUS Cost"
        type: expression
        sql: "{{ metric('total_staff_salary') }} * 0.2026"  # 11.26% social + 9% health
        description: "Total employee ZUS contributions (11.26% + 9%)"
      
      # ZUS Metrics (Employer costs)
      - name: employer_zus_total
        label: "Employer ZUS Cost"
        type: expression
        sql: "{{ metric('total_staff_salary') }} * 0.2408"  # 14.84% social + 9% health + 0.24% labour
        description: "Total employer ZUS contributions (14.84% + 9% + 0.24%)"
```

---

## 3. APACHE SUPERSET - PRODUCTION SETUP

### docker-compose.yml
```yaml
version: '3.8'

services:
  superset:
    image: apache/superset:${SUPERSET_VERSION:-6.1.0}
    container_name: superset
    ports:
      - "8088:8088"
    environment:
      # Database Configuration
      SUPERSET_DATABASE_URI: postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}
      
      # Redis Cache
      REDIS_BROKER_URL: redis://redis:6379/0
      REDIS_RESULTS_BACKEND_URL: redis://redis:6379/1
      
      # Security
      SUPERSET_SECRET_KEY: ${SUPERSET_SECRET_KEY}
      SUPERSET_SQLALCHEMY_TRACK_MODIFICATIONS: "false"
      
      # Feature Flags
      SUPERSET_LOAD_EXAMPLES: "false"
      FEATURE_ENABLE_MCP_SERVER: "true"
      
      # Logging
      SUPERSET_LOG_LEVEL: INFO
      
      # Timezone
      SUPERSET_SQLALCHEMY_ENGINE_OPTIONS: '{"pool_size": 20}'
      
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8088/api/v1/datasets"]
      interval: 30s
      timeout: 10s
      retries: 5
    networks:
      - superset-net
    command:
      - /bin/sh
      - -c
      - |
        superset db upgrade && \
        superset init && \
        gunicorn \
          --bind 0.0.0.0:8088 \
          --workers 4 \
          --worker-class gthread \
          --threads 2 \
          --timeout 120 \
          --access-logfile - \
          --error-logfile - \
          superset.app:create_app()

  postgres:
    image: postgres:14-alpine
    container_name: superset-db
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-superset}
      POSTGRES_USER: ${POSTGRES_USER:-superset}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_INITDB_ARGS: "-c max_connections=200"
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - superset-net
    volumes:
      - superset-db:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    container_name: superset-redis
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - superset-net
    volumes:
      - superset-redis:/data

  celery-worker:
    image: apache/superset:${SUPERSET_VERSION:-6.1.0}
    container_name: superset-worker
    environment:
      SUPERSET_DATABASE_URI: postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}
      REDIS_BROKER_URL: redis://redis:6379/0
      SUPERSET_SECRET_KEY: ${SUPERSET_SECRET_KEY}
    command:
      - celery
      - --app=superset.tasks.celery_app:app
      - worker
      - --pool=prefork
      - --concurrency=4
      - -l
      - info
    depends_on:
      - postgres
      - redis
    restart: unless-stopped
    networks:
      - superset-net

  celery-beat:
    image: apache/superset:${SUPERSET_VERSION:-6.1.0}
    container_name: superset-beat
    environment:
      SUPERSET_DATABASE_URI: postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}
      REDIS_BROKER_URL: redis://redis:6379/0
      SUPERSET_SECRET_KEY: ${SUPERSET_SECRET_KEY}
    command:
      - celery
      - --app=superset.tasks.celery_app:app
      - beat
      - --loglevel=info
    depends_on:
      - postgres
      - redis
    restart: unless-stopped
    networks:
      - superset-net

volumes:
  superset-db:
  superset-redis:

networks:
  superset-net:
    driver: bridge
```

### .env.example
```bash
# Superset Configuration
SUPERSET_VERSION=6.1.0
SUPERSET_SECRET_KEY=$(openssl rand -base64 32)

# PostgreSQL (Superset metadata store)
POSTGRES_DB=superset
POSTGRES_USER=superset
POSTGRES_PASSWORD=secure_superset_pass

# Admin User (created after first startup)
ADMIN_USERNAME=admin
ADMIN_PASSWORD=SecurePassword123!
ADMIN_EMAIL=admin@important.is
```

---

## 4. n8n WORKFLOW - ClickUp + Notion to BI Sync

### n8n Workflow JSON (Lightdash/Metabase)

```json
{
  "name": "Sync ClickUp Tasks to dbt Models",
  "description": "Pulls ClickUp tasks and Notion data, calculates metrics, syncs to BI",
  "nodes": [
    {
      "name": "Schedule Trigger",
      "type": "n8n-nodes-base.cron",
      "typeVersion": 1,
      "position": [250, 300],
      "parameters": {
        "mode": "every",
        "interval": 1,
        "unit": "hours"
      }
    },
    {
      "name": "Get ClickUp Tasks",
      "type": "n8n-nodes-base.clickup",
      "typeVersion": 1,
      "position": [450, 150],
      "parameters": {
        "operation": "getTeamTasks",
        "teamId": "{{ $env.CLICKUP_TEAM_ID }}",
        "statuses": ["COMPLETED"],
        "archived": false,
        "include_subtasks": true
      },
      "credentials": {
        "clickupApi": "{{ $credentials.clickup }}"
      }
    },
    {
      "name": "Get Notion Pages",
      "type": "n8n-nodes-base.notion",
      "typeVersion": 1,
      "position": [450, 300],
      "parameters": {
        "operation": "getDatabase",
        "databaseId": "{{ $env.NOTION_BUDGET_DB_ID }}",
        "returnAll": true
      },
      "credentials": {
        "notionApi": "{{ $credentials.notion }}"
      }
    },
    {
      "name": "Transform ClickUp Data",
      "type": "n8n-nodes-base.code",
      "typeVersion": 1,
      "position": [650, 150],
      "parameters": {
        "language": "javascript",
        "mode": "runOnceForAllItems",
        "code": "return items.map(item => {\n  return {\n    task_id: item.json.id,\n    task_name: item.json.name,\n    assignee: item.json.assignees[0]?.username || null,\n    time_logged: item.json.time_logged || 0,\n    status: 'completed',\n    completed_at: item.json.date_closed || new Date().toISOString(),\n    priority: item.json.priority?.priority || 'normal'\n  };\n});"
      }
    },
    {
      "name": "Transform Notion Data",
      "type": "n8n-nodes-base.code",
      "typeVersion": 1,
      "position": [650, 300],
      "parameters": {
        "language": "javascript",
        "mode": "runOnceForAllItems",
        "code": "return items.map(item => {\n  return {\n    budget_id: item.json.id,\n    category: item.json.properties.Category?.select?.name || null,\n    planned_amount: item.json.properties['Planned Amount']?.number || 0,\n    actual_amount: item.json.properties['Actual Amount']?.number || 0,\n    month: item.json.properties.Month?.date?.start || null\n  };\n});"
      }
    },
    {
      "name": "Load to PostgreSQL - Tasks",
      "type": "n8n-nodes-base.postgres",
      "typeVersion": 1,
      "position": [850, 150],
      "parameters": {
        "operation": "insert",
        "schema": "public",
        "table": "{{ $env.DBT_SCHEMA }}_tasks",
        "columns": [
          {
            "column": "task_id",
            "type": "text"
          },
          {
            "column": "task_name",
            "type": "text"
          },
          {
            "column": "assignee",
            "type": "text"
          },
          {
            "column": "time_logged",
            "type": "numeric"
          },
          {
            "column": "completed_at",
            "type": "timestamp"
          }
        ]
      },
      "credentials": {
        "postgres": "{{ $credentials.postgres_data_warehouse }}"
      }
    },
    {
      "name": "Load to PostgreSQL - Budget",
      "type": "n8n-nodes-base.postgres",
      "typeVersion": 1,
      "position": [850, 300],
      "parameters": {
        "operation": "insert",
        "schema": "public",
        "table": "{{ $env.DBT_SCHEMA }}_budget",
        "columns": [
          {
            "column": "budget_id",
            "type": "text"
          },
          {
            "column": "category",
            "type": "text"
          },
          {
            "column": "planned_amount",
            "type": "numeric"
          },
          {
            "column": "actual_amount",
            "type": "numeric"
          },
          {
            "column": "month",
            "type": "date"
          }
        ]
      },
      "credentials": {
        "postgres": "{{ $credentials.postgres_data_warehouse }}"
      }
    },
    {
      "name": "Trigger dbt Run",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4,
      "position": [1050, 225],
      "parameters": {
        "url": "https://{{ $env.DBT_RPC_HOST }}:8580/cli/v1/invoke",
        "method": "POST",
        "headers": {
          "Content-Type": "application/json"
        },
        "body": {
          "command": "dbt run -m tag:metrics",
          "timeout_seconds": 300
        },
        "authentication": "genericCredentialType",
        "genericCredentials": {
          "username": "{{ $env.DBT_RPC_USER }}",
          "password": "{{ $env.DBT_RPC_PASSWORD }}"
        }
      }
    },
    {
      "name": "Send Slack Notification",
      "type": "n8n-nodes-base.slack",
      "typeVersion": 1,
      "position": [1250, 225],
      "parameters": {
        "text": "✅ ClickUp/Notion data synced to BI. dbt metrics refreshed.",
        "channel": "#analytics"
      },
      "credentials": {
        "slackApi": "{{ $credentials.slack }}"
      }
    }
  ],
  "connections": {
    "Schedule Trigger": {
      "main": [
        [
          {
            "node": "Get ClickUp Tasks",
            "type": "main",
            "index": 0
          },
          {
            "node": "Get Notion Pages",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Get ClickUp Tasks": {
      "main": [
        [
          {
            "node": "Transform ClickUp Data",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Get Notion Pages": {
      "main": [
        [
          {
            "node": "Transform Notion Data",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Transform ClickUp Data": {
      "main": [
        [
          {
            "node": "Load to PostgreSQL - Tasks",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Transform Notion Data": {
      "main": [
        [
          {
            "node": "Load to PostgreSQL - Budget",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Load to PostgreSQL - Tasks": {
      "main": [
        [
          {
            "node": "Trigger dbt Run",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Load to PostgreSQL - Budget": {
      "main": [
        [
          {
            "node": "Trigger dbt Run",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Trigger dbt Run": {
      "main": [
        [
          {
            "node": "Send Slack Notification",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  }
}
```

---

## 5. MONITORING & MAINTENANCE

### Health Check Script

```bash
#!/bin/bash
# health-check.sh

echo "=== BI Tools Health Check ==="
echo ""

# Check Metabase
echo "🔍 Checking Metabase..."
if curl -s http://localhost:3000/api/health > /dev/null; then
  echo "✅ Metabase: OK"
else
  echo "❌ Metabase: FAILED"
fi

# Check Lightdash
echo "🔍 Checking Lightdash..."
if curl -s http://localhost:8080/api/health > /dev/null; then
  echo "✅ Lightdash: OK"
else
  echo "❌ Lightdash: FAILED"
fi

# Check Superset
echo "🔍 Checking Superset..."
if curl -s http://localhost:8088/api/v1/datasets > /dev/null; then
  echo "✅ Superset: OK"
else
  echo "❌ Superset: FAILED"
fi

# Check PostgreSQL
echo "🔍 Checking PostgreSQL..."
if docker exec metabase-db pg_isready -U metabase_user > /dev/null 2>&1; then
  echo "✅ PostgreSQL: OK"
else
  echo "❌ PostgreSQL: FAILED"
fi

echo ""
echo "=== Docker Compose Status ==="
docker-compose ps
```

### Log Rotation

Add to `docker-compose.yml` for each service:
```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

### Database Maintenance

```sql
-- Weekly maintenance for Metabase PostgreSQL
VACUUM FULL ANALYZE;
REINDEX DATABASE metabase;

-- Monitor table sizes
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

---

**End of Deployment Guide**
