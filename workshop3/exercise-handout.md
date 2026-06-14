# Workshop 3 — Exercise Handout
**Kenya AI Challenge 2026 · Neo4j Track · 13 June 2026**

---

## Before You Start

**Starter project (optional):** [`workshops/shamba/`](../shamba/README.md) — console app with a virtual environment. See its README for setup. Exercises below map to Shamba Steps 2–5.

**Install dependencies before the session** (use a virtual environment — see Shamba README):
```bash
cd workshops/shamba
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

**Create `.env` first** in the `workshops/shamba` folder:
```bash
cd workshops/shamba
cp .env.example .env
```

Edit `workshops/shamba/.env` with your Aura credentials.

`workshops/shamba/main.py` now loads `.env` automatically, so you can run that script without exporting values again.

If you run exercise scripts directly from the shell, make sure these variables are available in your environment:
```bash
export NEO4J_URI="neo4j+s://your-instance.databases.neo4j.io"
export NEO4J_USER="neo4j"
export NEO4J_PASSWORD="your-password"
export GOOGLE_API_KEY="your-key"  # free at aistudio.google.com — no credit card
```

**Run the seed script** to set up the starting graph. Paste `data/seed.cypher` into your Neo4j Aura query tab.

> **Note — Python exercises (2–5) build on each other.** Run them in a single Python session using the shamba environment. The `driver` and `model` created in Exercise 2 are reused in Exercises 3, 4, and 5 — do not close the driver between exercises.

**All exercises run in `workshops/shamba/`** — this is where your `.env` file is, so environment variables load automatically. Create all exercise code in this folder.

---

## Exercise 1 — Check Descriptions and Vector Index

**Cypher only — run in Neo4j Aura Browser.**

The seed script added descriptions to all 7 crops and created the vector index. Verify both before writing Python.

```cypher
// Check descriptions
MATCH (c:Crop)
RETURN c.name, c.description
ORDER BY c.name;

// Check vector index is ONLINE
SHOW VECTOR INDEXES;
```

You should see `crop_embeddings` with status `ONLINE` and 384 dimensions. If not — re-run the seed script.

---

## Exercise 2 — Generate and Store Embeddings

**In `workshops/shamba/`, create a file called `exercises.py` and add this code:**

```python
from sentence_transformers import SentenceTransformer
from neo4j import GraphDatabase
from pathlib import Path
from dotenv import load_dotenv
import os

# Load environment variables from .env
PROJECT_ROOT = Path(__file__).resolve().parent
load_dotenv(PROJECT_ROOT / ".env")

# Setup — runs once, driver and model are reused in Exercises 3, 4, 5
model  = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")
driver = GraphDatabase.driver(os.environ["NEO4J_URI"],
                              auth=(os.environ["NEO4J_USER"],
                                    os.environ["NEO4J_PASSWORD"]))

# Adapter: wrap the SentenceTransformer so it exposes the
# `embed_query(text)` method expected by `neo4j_graphrag` retrievers
class SentenceTransformerEmbedder:
    def __init__(self, model: SentenceTransformer):
        self._model = model

    def embed_query(self, text: str) -> list[float]:
        emb = self._model.encode(text)
        try:
            return emb.tolist()
        except Exception:
            return [float(x) for x in emb]

# Exercise 2 — Generate and Store Embeddings
print("Exercise 2: Generating embeddings...")
with driver.session() as session:
    crops = session.run(
        "MATCH (c:Crop) RETURN c.name AS name, c.description AS desc"
    ).data()
    for crop in crops:
        if crop["desc"]:
            embedding = model.encode(crop["desc"]).tolist()
            session.run(
                "MATCH (c:Crop {name: $name}) SET c.embedding = $embedding",
                name=crop["name"], embedding=embedding
            )
            print(f"  Embedded: {crop['name']}")

print("Done.")

# Exercises 3, 4, 5 will be added here (before driver.close())

driver.close()
print("\nAll exercises complete.")
```

**Run it from `workshops/shamba/`:**
```bash
python exercises.py
```

> First run downloads the model (~90MB). Subsequent runs are instant. Your `.env` file is automatically loaded.

**Verify embeddings stored** (Cypher in Aura Browser):
```cypher
MATCH (c:Crop) WHERE c.embedding IS NOT NULL
RETURN c.name, size(c.embedding) AS dimensions
ORDER BY c.name;
```

All 7 crops should show 384 dimensions.

---

## Exercise 3 — Vector RAG: Search by Meaning

**Replace the line `# Exercises 3, 4, 5 will be added here (before driver.close())` in `workshops/shamba/exercises.py` with this code:**

```python
# Exercise 3 — Vector RAG: Search by Meaning
print("\nExercise 3: Vector search...")
from neo4j_graphrag.retrievers import VectorRetriever

retriever = VectorRetriever(
    driver=driver,
    index_name="crop_embeddings",
    embedder=SentenceTransformerEmbedder(model),
    return_properties=["name", "description", "unit"]
)

query   = "I need a protein-rich crop with a long shelf life"
results = retriever.search(query_text=query, top_k=3)

print(f"\nQuery: '{query}'")
for i, r in enumerate(results.items, 1):
    print(f"{i}. {r.content}")

# Exercise 4, 5 will be added here
```

**Test it** — the query never mentions "Beans", but Beans should rank highest because its description is semantically close to "protein-rich" and "long shelf life."

Also try these queries (change the `query` variable and re-run):
- `"I need a leafy vegetable for a hotel kitchen"` → expect Sukuma Wiki
- `"Drought-resistant crop for dry regions"` → expect Sorghum

---

## Exercise 4 — Vector + Cypher: Meaning AND Structure

**Replace the line `# Exercise 4, 5 will be added here` in `workshops/shamba/exercises.py` with this code:**

This exercise builds on Exercise 3 by adding structured graph traversal to find market prices.

```python
# Exercise 4 — Vector + Cypher: Meaning AND Structure
print("\nExercise 4: Vector + Cypher search...")
from neo4j_graphrag.retrievers import VectorCypherRetriever

retrieval_query = """
MATCH (node)-[:LISTED_IN]->(market:Market)-[:HAS_PRICE]->(price:PricePoint)
WHERE price.recordedAt >= date() - duration({days: 14})
RETURN node.name      AS crop,
       market.name    AS market,
       market.location AS location,
       price.price    AS price,
       price.unit     AS unit,
       score
ORDER BY score DESC, price DESC
LIMIT 5
"""

vc_retriever = VectorCypherRetriever(
    driver=driver,
    index_name="crop_embeddings",
    embedder=SentenceTransformerEmbedder(model),
    retrieval_query=retrieval_query
)

query = "I need a protein-rich crop for long-distance transport"
results = vc_retriever.search(query_text=query, top_k=3)

print(f"\nQuery: '{query}'")
for i, r in enumerate(results.items, 1):
    print(f"{i}. {r.content}")
    print("---")
```

**Compare to Exercise 3** — the same crops appear, but now each result includes the market name, location, and price. That's the Cypher traversal in action.

Note: `vc_retriever` is saved for use in Exercise 5.

---

## Exercise 5 — Connect to an LLM (Google Gemini)

**Add this code to the bottom of `workshops/shamba/exercises.py` (before `driver.close()`):**

This exercise uses the LLM to synthesize search results into a natural language answer.

```python
# Exercise 5 — LLM Synthesis (Google Gemini)
print("\nExercise 5: LLM synthesis...")
import os
from neo4j_graphrag.llm import OpenAILLM
from neo4j_graphrag.generation import GraphRAG
from openai import OpenAI

client = OpenAI(
    api_key=os.environ["GOOGLE_API_KEY"],
    base_url="https://generativelanguage.googleapis.com/v1beta/openai/"
)

llm = OpenAILLM(
    openai_client=client,
    model_name="gemini-2.5-flash",
    model_params={"max_tokens": 300}
)

rag      = GraphRAG(retriever=vc_retriever, llm=llm)
response = rag.search(
    query_text="I need a protein-rich crop that keeps well. Where in Nairobi?",
    retriever_config={"top_k": 3}
)

print(f"\nAnswer:\n{response.answer}")
```

**Expected output** (approximate):
> *"Based on current listings, Beans are a strong match — high protein, long shelf life. They are currently listed at Wakulima Market in Nairobi at KSh 7,200 per 90kg bag."*

---

## Cleanup — Close the Driver

**At the very end of `workshops/shamba/exercises.py`, add:**

```python
driver.close()
print("\nAll exercises complete.")
```

---

## Running All Exercises

Once you've added all exercise code to `workshops/shamba/exercises.py`, run it:

```bash
cd workshops/shamba
python exercises.py
```

The output will show each exercise running in sequence: embeddings → vector search → vector+Cypher → LLM synthesis.

---

## Exercise 6 — Text-to-Cypher (Concept Only)

*Facilitator-led — no hands-on today. For reference after the session.*

Text-to-Cypher lets the LLM generate a Cypher query from plain English and execute it directly against your graph. You can try this after the workshop if interested.

```python
from neo4j_graphrag.retrievers import Text2CypherRetriever

t2c_retriever = Text2CypherRetriever(
    driver=driver,
    llm=llm,
    neo4j_schema="""
    Node labels: Farm, Crop, Market, PricePoint, Buyer, Transaction
    Relationships:
      (Farm)-[:GROWS]->(Crop)
      (Crop)-[:LISTED_IN]->(Market)
      (Market)-[:HAS_PRICE]->(PricePoint {cropType, price, unit, recordedAt})
      (Farm)-[:KNOWS]->(Buyer)
    """
)
# "Which markets have maize above KSh 3,000 this week?"
# → LLM generates the MATCH query → executes → returns results
```

**Key principle:** if the schema description is wrong or incomplete, the LLM generates invalid Cypher. The schema is the most important thing to get right.

Full working example: GraphAcademy Course 4 sandbox.

---

## Transfer — Design Your Retrieval Strategy

**1. The question your LLM will answer:**
> `_______________________________________________`

**2. Which retriever type?**
- [ ] Vector — semantic similarity, no structured filters needed
- [ ] Vector + Cypher — semantic matching + graph traversal or filters
- [ ] Text-to-Cypher — fully structured question, well-defined schema

**3. Sketch the retrieval:**
- What text field do you embed? `_______________`
- What Cypher traversal runs after the match? `_______________`

---

## Quick Reference

```python
# Install
pip install neo4j neo4j-graphrag sentence-transformers openai

# Retriever types
VectorRetriever(...)           # semantic similarity only
VectorCypherRetriever(...)     # semantic + graph traversal
Text2CypherRetriever(...)      # LLM generates Cypher from English (concept)

# LLM (Google Gemini — OpenAI-compatible)
OpenAI(api_key=..., base_url="https://generativelanguage.googleapis.com/v1beta/openai/")
model_name = "gemini-2.5-flash"

# Full pipeline
rag = GraphRAG(retriever=vc_retriever, llm=llm)
response = rag.search(query_text="...", retriever_config={"top_k": 3})
print(response.answer)
```

```cypher
// Check vector index
SHOW VECTOR INDEXES

// Check embeddings stored
MATCH (c:Crop) WHERE c.embedding IS NOT NULL
RETURN c.name, size(c.embedding) AS dims
```
