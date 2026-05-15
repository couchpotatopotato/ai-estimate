# BEACON Effort Estimator

A 2-agent AI chatbot for estimating development effort from URS/AOR requirements against the BEACON batch processing system.

- **Agent 1** — Gemini analyses BEACON's codebase context and identifies impacted components
- **Agent 2** — Deterministic formula engine converts component impact into hours/days

---

## Prerequisites

- Docker + Docker Desktop
- A Google AI Studio API key (free): https://aistudio.google.com/apikey

---

## Setup

### 1. Clone and configure

```bash
git clone <your-repo>
cd beacon-estimator
cp .env.example .env
```

Edit `.env` and set your `GEMINI_API_KEY`.

### 2. Add your BEACON steering files

The `steering/` folder contains three files that describe BEACON's architecture to Agent 1. The more detailed these are, the better the impact analysis.

Generate them automatically using Kiro or Amazon Q Developer:
1. Open your BEACON codebase in Kiro
2. Click "Generate steering files" — auto-generates `product.md`, `tech.md`, `structure.md`
3. Replace the files in `./steering/` with the generated content

### 3. Run

```bash
# Local mock DB (no GCP needed)
docker compose --profile local up --build

# Cloud SQL (see Cloud DB section below)
docker compose --profile cloud up --build
```

Open http://localhost:5173

---

## Database

### Local (default)

Uses a local Postgres container seeded with mock BEACON schema from `db/init.sql`. No GCP setup needed.

`.env` settings:
```
DB_MODE=local
DB_HOST=db
DB_NAME=beacon
DB_USER=readonly_user
DB_PASSWORD=your_password_here
```

Run:
```bash
docker compose --profile local up --build
```

### Cloud SQL (Google Cloud Postgres)

1. **Enable public IP on your Cloud SQL instance** — GCP Console → Cloud SQL → your instance → Connections → Networking → Add `0.0.0.0/0` to authorised networks.

2. **Update `.env`** — comment out the local block and uncomment the cloud block:
   ```
   DB_MODE=cloud
   DATABASE_URL=postgresql://your_user:your_password@your_public_ip:5432/your_db_name
   ```
   Your public IP is shown on the Cloud SQL instance overview page.

3. **Run:**
   ```bash
   docker compose --profile cloud up --build
   ```

No gcloud login or proxy container needed — the backend connects directly.

---

## How to use

1. Paste a URS or AOR requirement into the chat input
2. Press **Ctrl+Enter** (or click Estimate)
3. Agent 1 identifies which BEACON components are impacted
4. Agent 2 calculates estimated hours per component
5. Download the markdown report with the ↓ button

### Example prompt

> The system shall update the housing withdrawal eligibility rules to enforce a new minimum retained balance of $20,000 in the CPF Ordinary Account before any withdrawal is approved. The new threshold must be validated during the rules management step and reflected in the audit log upon commit.

---

## Amending the effort formula

Edit `backend/agents/agent2_runner.py` to match your actual estimation formula:

```python
COMPLEXITY_HOURS = {
    "L": 4,   # Low  — minor isolated change
    "M": 12,  # Med  — logic change with some dependency risk
    "H": 32,  # High — significant rework or cross-cutting change
}

CHANGE_TYPE_MULTIPLIER = {
    "UI":  1.0,
    "BL":  1.2,
    "DB":  1.3,
    "INT": 1.5,
}
```

---

## Upgrading to Claude Sonnet (production)

1. Get an Anthropic API key: https://console.anthropic.com
2. Add to `.env`: `ANTHROPIC_API_KEY=sk-...`
3. In `backend/agents/agent1_runner.py`, swap the API call to use the Anthropic SDK
4. Set model to `claude-sonnet-4-6` and enable prompt caching on the system prompt

---

## Project structure

```
beacon-estimator/
├── backend/
│   ├── main.py                  # FastAPI app — POST /estimate endpoint
│   ├── agents/
│   │   ├── agent1_runner.py     # Gemini — impact analysis
│   │   └── agent2_runner.py     # Formula engine — effort calculation
│   ├── context/
│   │   └── steering_loader.py   # Loads steering .md files into Agent 1 context
│   └── db/
│       └── beacon_query.py      # Postgres query helper
├── frontend/
│   └── src/
│       ├── App.jsx              # Main chat layout
│       ├── components/
│       │   ├── ChatInput.jsx    # URS text input
│       │   ├── ResultsPanel.jsx # Estimation results + table
│       │   └── HistoryPanel.jsx # Past estimates sidebar
│       └── index.css            # Styles
├── steering/                    # BEACON architecture context for Agent 1
│   ├── product.md               # What BEACON does, modules, user roles
│   ├── tech.md                  # Tech stack and constraints
│   └── structure.md             # Component map with DB tables and relationships
├── db/
│   └── init.sql                 # Mock schema + seed data for local mode
├── docker-compose.yml
├── .env.example                 # Copy to .env and fill in your values
└── .gitignore
```
