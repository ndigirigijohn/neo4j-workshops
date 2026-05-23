# Workshop 1 — Introduction to Neo4j & Graph Databases

**Kenya AI Challenge 2026 — Neo4j Track**
**Date:** Saturday, 23 May 2026 · 2:00 PM – 5:00 PM

---

## Learning Objectives

By the end of this workshop, you will be able to:

1. Explain what a graph database is and when it is the right tool for a problem
2. Model a real-world problem as nodes, relationships, and properties
3. Read and write basic Cypher queries (MATCH, CREATE, WHERE, RETURN)
4. Set up a free Neo4j Aura instance and connect to it
5. Import a small dataset and query it
6. Describe how a graph structure fits your hackathon project idea

---

## Agenda

| Time | Topic |
|---|---|
| 2:00 – 2:09 | Opening |
| 2:09 – 2:36 | Graph Concepts & Cypher Introduction |
| 2:36 – 2:56 | Exercise 1: Neo4j Aura Setup |
| 2:56 – 3:26 | Exercise 2: Build a Mini Market Graph |
| 3:26 – 3:56 | Exercise 3: Query the Graph |
| 3:56 – 4:26 | Exercise 4: Importing Data from CSV |
| 4:26 – 4:33 | Buffer / Q&A |
| 4:33 – 4:51 | Design Your Hackathon Graph |
| 4:51 – 5:00 | Wrap-up & Feedback |

---

## 1. What is a Graph Database?

In a graph database, data is stored as **things** (nodes) and the **connections between them** (relationships). That is the entire model.

### The Building Blocks

**Node** — represents a thing: a Farmer, a Market, a Crop, a Buyer. Each node has a **label** (its type) and **properties** (its attributes).

**Relationship** — a named, directional connection between two nodes. Relationships can also carry properties.

**Property** — a key-value pair on a node or relationship: `name: "Wanjiku"`, `price: 3100`, `date: "2026-05-20"`.

**Label** — the type of a node, written with a colon: `:Farmer`, `:Market`, `:Crop`.

### Example: An Agricultural Knowledge Graph

```
(Farmer)-[:GROWS]->(Crop)
(Farmer)-[:SELLS_AT]->(Market)
(Market)-[:LOCATED_IN]->(County)
(Buyer)-[:BUYS]->(Crop)
(Crop)-[:LISTED_AT {price: 3100, date: "2026-05-20"}]->(Market)
```

Each line reads like a sentence: *"A Farmer GROWS a Crop."* *"A Crop is LISTED AT a Market with a price of 3,100."*

### Why Graphs?

When your data has many connections, graphs are faster and more natural than relational databases.

Answering *"which buyers purchase crops grown by farmers in Kisumu County?"* requires three JOINs in SQL. In a graph, you follow the relationships directly — one pattern, one query.

---

## 2. Cypher — Neo4j's Query Language

Cypher lets you query and update a graph by drawing the pattern you want to find. The syntax mirrors the graph itself.

### Reading Data: MATCH

**Find all farmers:**
```cypher
MATCH (f:Farmer)
RETURN f.name, f.county
```

**Find crops a specific farmer grows:**
```cypher
MATCH (f:Farmer {name: "Wanjiku"})-[:GROWS]->(c:Crop)
RETURN c.name
```

**Find markets selling maize above KSh 3,000:**
```cypher
MATCH (c:Crop {name: "Maize"})-[l:LISTED_AT]->(m:Market)
WHERE l.price > 3000
RETURN m.name, l.price
ORDER BY l.price DESC
```

Read Cypher left to right: `(node)-[:RELATIONSHIP]->(node)`.

### Writing Data: CREATE and MERGE

**Create nodes and a relationship:**
```cypher
CREATE (f:Farmer {name: "Kamau", county: "Nakuru"})
CREATE (c:Crop {name: "Tomatoes"})
CREATE (f)-[:GROWS]->(c)
```

**MERGE** — creates the node if it does not exist, matches it if it does:
```cypher
MERGE (m:Market {name: "Gikomba Market", county: "Nairobi"})
```

### Key Cypher Patterns

| Pattern | Purpose |
|---|---|
| `MATCH (n:Label) RETURN n` | Find all nodes of a type |
| `MATCH (n {prop: val}) RETURN n` | Find by property value |
| `MATCH (a)-[:REL]->(b) RETURN a, b` | Follow a relationship |
| `WHERE n.prop > value` | Filter results |
| `ORDER BY n.prop DESC LIMIT 10` | Sort and limit |
| `count(n)`, `avg(r.prop)`, `max(r.prop)` | Aggregations |
| `CREATE (n:Label {prop: val})` | Create a node |
| `CREATE (a)-[:REL {prop: val}]->(b)` | Create a relationship |
| `MERGE (n:Label {id: val})` | Create or match |
| `LOAD CSV WITH HEADERS FROM url AS row` | Import from CSV |

---

## 3. Exercises

Full exercise steps and Cypher queries are in **[exercise-handout.md](exercise-handout.md)**.

| Exercise | What you will do |
|---|---|
| **Exercise 1** | Connect to Neo4j Aura — set up your free cloud database |
| **Exercise 2** | Build a mini MarketGraph — create farmers, crops, markets, and relationships |
| **Exercise 3** | Query the graph — 6 progressive Cypher queries from basic to multi-hop |
| **Exercise 4** | Import from CSV — load Kenya market data into your graph |

---

## 4. Next Steps

1. **Keep your Aura instance** — you will use it in Workshop 2 on June 6
2. **Save your credentials** — the password cannot be recovered if lost
3. **Before Workshop 2:** Add at least 5 nodes relevant to your own project idea
4. **Office hours** — watch WhatsApp for the schedule; bring your graph design questions
