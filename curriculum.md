# Workshop Curriculum

**Kenya AI Challenge 2026 — Neo4j Track**

Four workshops building from graph fundamentals to AI-powered graph applications. Each session is 2 hours, hands-on, and directly connected to your hackathon project.

---

## Workshop 1 — Introduction to Graph Databases
**23 May 2026**

Get up and running with Neo4j. Understand how graphs model connected data better than relational databases, write your first Cypher queries, and design a graph for your project.

**You will be able to:**
- Explain nodes, relationships, and properties
- Read and write Cypher (MATCH, CREATE, MERGE, WHERE, RETURN)
- Set up a free Neo4j Aura instance
- Import data from CSV
- Sketch a graph model for your hackathon project

---

## Workshop 2 — Graph Data Modeling, Management & Optimization
**6 June 2026**

Evolve your graph into a production-ready model. Learn how to structure data correctly, keep queries fast, and manage your database.

**You will be able to:**
- Apply graph data modeling best practices (intermediate nodes, specific relationship types)
- Use Cypher parameters
- Create indexes and constraints
- Profile queries with EXPLAIN and PROFILE
- Identify and fix slow queries in your own project

---

## Workshop 3 — Neo4j and Generative AI (GraphRAG)
**13 June 2026**

Add an AI layer to your graph. Learn how to connect your graph to an LLM using three retrieval patterns, and enable semantic search with vector indexes.

**You will be able to:**
- Explain GraphRAG and why graphs improve LLM answers
- Create a vector index and run semantic similarity queries
- Choose between Vector, Vector + Cypher, and Text-to-Cypher retrievers for different question types
- Build a Vector + Cypher retriever using the `neo4j-graphrag` Python package
- Connect GraphRAG to Google Gemini (free API via AI Studio)
- Design the retriever strategy for your own project

---

## Workshop 4 — Graph Data Science in Practice
**20 June 2026**

Discover patterns in your graph that no single query can find. Apply graph algorithms to reveal hubs, communities, and similarities across your entire dataset.

**You will be able to:**
- Create graph projections for analysis
- Run centrality algorithms to find the most connected nodes
- Detect communities of related nodes using Louvain
- Find similar nodes with node similarity
- Apply at least one algorithm to a real question in your project

---

## Technology Stack

| Tool | Purpose | Cost |
|---|---|---|
| [Neo4j AuraDB](https://console.neo4j.io) | Graph database | Free tier |
| [Google Gemini API](https://aistudio.google.com) | LLM inference (Workshop 3) | Free tier |
| [Featherless AI](https://featherless.ai) | LLM inference (hackathon partner) | Paid plans |
| [Lovable](https://lovable.dev) | Frontend builder | Free tier |
| [Masumi](https://masumi.network) | Agent payments | Partner |

**Starter app:** `workshops/shamba/` — console project that builds the Workshop 3 pipeline step by step.
