# Factory Inventory Management System

A full-stack demo application for a Claude Code workshop — inventory management, order tracking, demand forecasting, and analytics for factory operations.

![Dashboard](docs/dashboard-screenshot.png)

## Tech Stack

- **Frontend**: Vue 3 + Vite (port 3000)
- **Backend**: Python FastAPI (port 8001)
- **Data**: In-memory mock data (no database)

## Features

- Dashboard with interactive filtering and key metrics
- Inventory tracking across multiple warehouses
- Order management with status tracking
- Demand forecasting with trend analysis
- Backlog monitoring
- Spending analytics

## Quick Start

**One-command startup:**
```bash
./scripts/start.sh
# Starts both backend and frontend
# Backend: http://localhost:8001
# Frontend: http://localhost:3000
# API Docs: http://localhost:8001/docs
```

**Manual startup:**

Backend:
```bash
cd server
uv venv && uv sync
uv run python main.py
```

Frontend:
```bash
cd client
npm install
npm run dev
```

## Architecture

For an overview of the system architecture, tech stack, data flow and API surface, open `docs/architecture.html` in a browser.

## Development Tooling

### Code formatting

The project uses pinned formatters, which are installed by the normal setup commands:

| Area | Formatter | Version | Config |
|------|-----------|---------|--------|
| `client/` (`.vue`, `.js`, `.ts`, `.css`, `.html`, `.json`) | Prettier | 3.9.10 (client devDependency) | `client/.prettierrc.json` |
| `server/`, `tests/` (`.py`) | Ruff | >= 0.17.3 (server dev dependency) | `[tool.ruff]` in `server/pyproject.toml` |

The configs follow the existing style: no semicolons, single quotes and 100-character lines for the frontend; 120-character lines and preserved quote style for Python.

To format by hand:
```bash
cd client && npx prettier --write src
cd server && uv run ruff format . ../tests --config pyproject.toml
```

Existing files have not been formatted yet. The first time a file is edited, the whole file may be reformatted, not just the changed lines. To keep those changes out of feature diffs, run the commands above once and commit the result on its own.

### Claude Code auto-format hook

`.claude/settings.json` registers a `PostToolUse` hook. After every Write or Edit by Claude Code, it runs `.claude/hooks/format.sh` on the changed file.

- Frontend files under `client/` go to Prettier. Python files under `server/` or `tests/` go to Ruff. All other files are skipped, as are `node_modules` and `dist`.
- The hook never blocks an edit. If a formatter is missing or fails, it shows a short message and leaves the file as written.

To set it up:
1. Install the formatters: run `npm install` in `client/` and `uv sync` in `server/`.
2. Start a new Claude Code session, or open `/hooks` once in a running session so the new settings file is loaded.
3. Review or disable the hook at any time via `/hooks`.

### Claude Code agents and skills

| Name | Type | Purpose |
|------|------|---------|
| `vue-expert` | Agent | Vue 3 frontend work. Required for creating or significantly changing `.vue` files. |
| `code-reviewer` | Agent | Read-only code review after significant changes |
| `security-auditor` | Agent | Security review of changed files |
| `debugger` | Agent | Investigates runtime errors and stack traces, reproduces them, and suggests root-cause fixes. It has no edit access. |
| `backend-api-test` | Skill | Conventions for pytest tests in `tests/backend/` |
| `saas-redesign` | Skill | Redesigns a Vue 3 app into a sidebar-based SaaS layout. It includes design tokens, an `AppSidebar` template and a QA checklist. |

Agents live in `.claude/agents/` and skills in `.claude/skills/`. Custom agents are loaded when a session starts.

## Known Issues and Open Work

These items were found during the sidebar redesign review and a debugging pass on the Dashboard. They are not yet fixed.

**Unfinished purchase-order and tasks features** (these cause the console errors on every page load)
- [ ] `Dashboard.vue` renders `<PurchaseOrderModal>`, but the component was never created or registered, so "Create PO" does nothing. Create `client/src/components/PurchaseOrderModal.vue` with:
  - props `isOpen`, `backlogItem` and `mode` (`create` or `view`)
  - events `close` and `po-created`
  - calls to the existing `api.createPurchaseOrder` and `api.getPurchaseOrderByBacklogItem`
- [ ] The backend has no `/api/purchase-orders` routes. The `PurchaseOrder` and `CreatePurchaseOrderRequest` models already exist in `server/main.py`. Add `POST /api/purchase-orders` and `GET /api/purchase-orders/{backlog_item_id}`, with tests.
- [ ] `Dashboard.vue` checks `item.purchase_order_id`, but `/api/backlog` returns `has_purchase_order`. Align these so "View PO" appears after a reload.
- [ ] The backend has no `/api/tasks` routes. `App.vue` calls `GET /api/tasks` on load, which returns 404. Either add GET, POST, PATCH and DELETE endpoints with tests, or make tasks client-side only.

**Sidebar follow-ups** (from code review of the redesign)
- [ ] `AppSidebar.vue` calls `localStorage` and `matchMedia` in `setup()` without guards. Wrap them so blocked storage or test environments cannot break the app shell.
- [ ] Below 768px, the closed mobile drawer is still reachable by keyboard and screen readers. It needs `inert` or `visibility: hidden`, focus management, and `aria-expanded` on the menu button.
- [ ] Close the mobile drawer when the viewport widens past the mobile breakpoint.
- [ ] Polish:
  - translate "Reports" and the new aria labels
  - give collapsed icon buttons accessible names
  - stop the sticky top bar taking up so much height at tablet widths
  - make the `.error` border visible
  - replace the remaining hard-coded colours with tokens

## API Endpoints

All endpoints support optional filtering via query params: `warehouse`, `category`, `status`, `month`

- `GET /api/inventory` - Inventory items
- `GET /api/orders` - Orders
- `GET /api/demand` - Demand forecasts
- `GET /api/backlog` - Backlog items
- `GET /api/dashboard/summary` - Summary statistics
- `GET /api/spending/*` - Spending data

## Demo Data

Mock data includes:
- Inventory items (Circuit Boards, Sensors, Actuators, Controllers)
- Orders spanning 12 months (Delivered, Shipped, Processing, Backordered)
- Demand forecasts with trends
- Backlog items
- Spending transactions

Data files: `server/data/*.json`

## Production Build

```bash
cd client
npm run build  # Output: client/dist/
```

## Platform Notes

**macOS/Linux:** The one-command startup script (`./scripts/start.sh`) and stop script (`./scripts/stop.sh`) work out of the box.

**Windows:** The shell scripts in `scripts/` are macOS/Linux only. Use the manual startup commands instead — run each in a separate terminal:

Backend:
```bash
cd server
uv venv && uv sync
uv run python main.py
```

Frontend:
```bash
cd client
npm install
npm run dev
```

To stop the servers, press Ctrl+C in each terminal window.

---

**Note:** Demo application with in-memory data. Not production-ready without database, authentication, and security implementation.
