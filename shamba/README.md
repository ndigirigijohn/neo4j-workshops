# Shamba

Console app for Workshop 3 — connect to Neo4j Aura, then build GraphRAG step by step.

Uses a **virtual environment** so dependencies do not clash with system Python.

---

## One-time setup

### 1. Create and activate a virtual environment

```bash
cd workshops/shamba
python3 -m venv .venv
source .venv/bin/activate        # Linux / macOS
# .venv\Scripts\activate         # Windows
```

If `python3 -m venv` fails on Ubuntu/Debian:

```bash
sudo apt install python3-venv
```

Confirm the venv is active — your prompt should show `(.venv)`:

```bash
which python
# should point to .../shamba/.venv/bin/python
```

### 2. Install dependencies

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

First install may take a few minutes (`sentence-transformers` pulls PyTorch).

### 3. Configure environment variables

```bash
cp .env.example .env
```

`main.py` automatically loads `.env` from the `workshops/shamba` folder when you run the app.

Edit `.env` with your Aura credentials:

| Variable | Required | When |
|---|---|---|
| `NEO4J_URI` | Yes | Step 1 |
| `NEO4J_USER` | Yes | Step 1 (usually `neo4j`) |
| `NEO4J_PASSWORD` | Yes | Step 1 |
| `GOOGLE_API_KEY` | Step 5 only | Free key from [aistudio.google.com](https://aistudio.google.com) |

### 4. Load the graph (Aura Browser)

If your Aura instance is empty, paste and run:

`workshops/workshop3/data/seed.cypher`

---

## Run (Step 1)

With the venv still active:

```bash
python main.py
```

Expected output: connection confirmation, node counts, and a list of 7 crops.

---

## Next steps

| Step | What you add | Workshop exercise |
|---|---|---|
| 1 | `main.py` — connect and inspect | Pre-session |
| 2 | `embed.py` — store vectors on crops | Exercise 2 |
| 3 | Vector search | Exercise 3 |
| 4 | Vector + Cypher | Exercise 4 |
| 5 | GraphRAG + Gemini | Exercise 5 |

Follow `PLAN.md` locally, or the [Workshop 3 exercise handout](../workshop3/exercise-handout.md).

---

## Every session

Activate the venv before running anything:

```bash
cd workshops/shamba
source .venv/bin/activate
python main.py
```

Deactivate when finished:

```bash
deactivate
```

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `ModuleNotFoundError` | Venv not active — run `source .venv/bin/activate` |
| `Connection failed` | Check `.env` URI and password |
| No crops listed | Run `seed.cypher` in Aura Browser |
| `pip install` very slow | Normal on first run; use a stable connection |
