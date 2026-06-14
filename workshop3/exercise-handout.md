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

> **Note — Python exercises (2–5) build on each other.** Run them in a single Python session (Jupyter notebook, interactive shell, or one script). The `driver` and `model` created in Exercise 2 are reused in Exercises 3, 4, and 5 — do not close the driver between exercises.

Confirm it loaded:
```cypher
MATCH (n)-[r]->(m)
RETURN labels(n)[0] AS from, type(r) AS rel, labels(m)[0] AS to, count(*) AS count
ORDER BY from, rel
```

---

## Exercise 1 — Check Descriptions and Vector Index

The seed script added descriptions to all 7 crops and created the vector index. Verify both before writing Python.

```cypher
// Check descriptions
MATCH (c:Crop)
RETURN c.name, c.description
ORDER BY c.name

// Check vector index is ONLINE
SHOW VECTOR INDEXES
```

You should see `crop_embeddings` with status `ONLINE` and 384 dimensions. If not — re-run the seed script.

---

## Exercise 2 — Generate and Store Embeddings

Save as `embed_crops.py` and run it:

```python
from sentence_transformers import SentenceTransformer
from neo4j import GraphDatabase
import os

model  = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")
driver = GraphDatabase.driver(os.environ["NEO4J_URI"],
                              auth=(os.environ["NEO4J_USER"],
                                    os.environ["NEO4J_PASSWORD"]))

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
# Keep driver and model open — used in Exercises 3, 4, and 5
```

> First run downloads the model (~90MB). Subsequent runs are instant.

Verify embeddings stored:
```cypher
MATCH (c:Crop) WHERE c.embedding IS NOT NULL
RETURN c.name, size(c.embedding) AS dimensions
```

All 7 crops should show 384 dimensions.

---

## Exercise 3 — Vector RAG: Search by Meaning

```python
from neo4j_graphrag.retrievers import VectorRetriever

retriever = VectorRetriever(
    driver=driver,
    index_name="crop_embeddings",
    embedder=model,
    return_properties=["name", "description", "unit"]
)

query   = "I need a protein-rich crop with a long shelf life"
results = retriever.search(query_text=query, top_k=3)

for i, r in enumerate(results.items, 1):
    print(f"{i}. {r.content}")
```

The query never mentions "Beans" — but Beans should rank highest because its description is semantically close to "protein-rich" and "long shelf life."

Also try:
- `"I need a leafy vegetable for a hotel kitchen"` → expect Sukuma Wiki
- `"Drought-resistant crop for dry regions"` → expect Sorghum

---

## Exercise 4 — Vector + Cypher: Meaning AND Structure

This retriever combines semantic search with a structured graph traversal — same crop matching, but now including live market prices.

```python
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
    embedder=model,
    retrieval_query=retrieval_query
)

results = vc_retriever.search(
    query_text="I need a protein-rich crop for long-distance transport",
    top_k=3
)

for r in results.items:
    print(r.content)
    print("---")
```

Compare this output to Exercise 3. The same crops appear — but now each result includes the market name, location, and price. That's the Cypher traversal.

---

## Exercise 5 — Connect to an LLM (Google Gemini)

Gemini exposes an OpenAI-compatible API — same `OpenAILLM` class, different endpoint.

```python
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

print(response.answer)
```

Expected answer (approximate):
> *"Based on current listings, Beans are a strong match — high protein, long shelf life. They are currently listed at Wakulima Market in Nairobi at KSh 7,200 per 90kg bag."*

---

## Exercise 6 — Text-to-Cypher (Concept Only)

*Facilitator-led — no hands-on today. For reference after the session.*

Text-to-Cypher lets the LLM generate a Cypher query from plain English and execute it directly against your graph.

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
