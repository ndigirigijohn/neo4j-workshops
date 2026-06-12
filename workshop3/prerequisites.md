# Workshop 3 — Prerequisites

Complete this setup **before the session**. Allow ~20 minutes (first install may take longer).

---

## 1. Load graph data

If your Aura instance is empty or you have not run the Workshop 3 seed:

1. Open [Neo4j Aura Browser](https://console.neo4j.io)
2. Paste and run `data/seed.cypher` from this folder

---

## 2. Python environment

From the workshops repo:

```bash
cd workshops/shamba
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

On Ubuntu/Debian, if `venv` fails:

```bash
sudo apt install python3-venv
```

---

## 3. Environment variables

```bash
cp .env.example .env
```

Edit `.env`:

| Variable | Source |
|---|---|
| `NEO4J_URI` | Aura console |
| `NEO4J_USER` | Usually `neo4j` |
| `NEO4J_PASSWORD` | Aura console |
| `GOOGLE_API_KEY` | [aistudio.google.com](https://aistudio.google.com) — free, no credit card |

---

## 4. Test

```bash
source .venv/bin/activate
python main.py
```

Expected: `Connected to Neo4j Aura` and a list of **7 crops**.

---

## During the session

- Keep your virtual environment active (`source .venv/bin/activate`)
- Exercises 2–5 run in **one Python session** — do not close the driver between exercises
- Exercise handout: `exercise-handout.md`
