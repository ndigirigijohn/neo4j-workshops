# Workshop 2 — Exercise Handout
**Kenya AI Challenge 2026 · Neo4j Track · 6 June 2026**

---

## Before You Start

Run the seed script to set up your graph. Open your Neo4j Aura instance, go to the Query tab, and paste the contents of `data/seed.cypher`. This creates a clean starting graph regardless of what you did in Workshop 1.

Confirm it worked:
```cypher
MATCH (n)-[r]->(m)
RETURN labels(n)[0] AS from, type(r) AS rel, labels(m)[0] AS to, count(*) AS count
ORDER BY from, rel
```

You should see rows covering `Farm→GROWS→Crop`, `Crop→LISTED_AT→Market`, `Buyer→BUYS→Crop`, and `Farm→KNOWS→Buyer`.

---

## Exercise 1 — Refactoring: Transaction Intermediate Node

The current model has `(Buyer)-[:BUYS]->(Crop)`. This works for capturing intent — but it cannot hold a quantity, agreed price, or payment status. We need a `Transaction` node.

**Step 1 — See the current model**
```cypher
MATCH (b:Buyer)-[r:BUYS]->(c:Crop)
RETURN b.name, c.name
```

**Step 2 — Create Transaction nodes**
```cypher
MATCH (b:Buyer)-[:BUYS]->(c:Crop)
MATCH (f:Farm)-[:GROWS]->(c)
MERGE (t:Transaction {
  id: randomUUID(),
  status: "pending",
  createdAt: datetime()
})
CREATE (f)-[:HAS_TRANSACTION]->(t)
CREATE (t)-[:INVOLVES]->(b)
CREATE (t)-[:FOR_CROP]->(c)
RETURN count(t) AS transactionsCreated
```

**Step 3 — Verify the new structure**
```cypher
MATCH (f:Farm)-[:HAS_TRANSACTION]->(t:Transaction)-[:INVOLVES]->(b:Buyer)
MATCH (t)-[:FOR_CROP]->(c:Crop)
RETURN f.name AS farm, b.name AS buyer, c.name AS crop, t.status
```

---

## Exercise 2 — Refactoring: PricePoint Nodes

Prices are stored as properties on `LISTED_AT` relationships. This means we can only hold one price per crop-market pair. We need `PricePoint` nodes so price history can accumulate over time.

**Step 1 — Migrate prices to PricePoint nodes**
```cypher
MATCH (c:Crop)-[l:LISTED_AT]->(m:Market)
MERGE (p:PricePoint {
  cropType: c.name,
  price: l.price,
  unit: c.unit,
  recordedAt: date(l.date),
  source: "seed"
})
MERGE (m)-[:HAS_PRICE]->(p)
MERGE (c)-[:LISTED_IN]->(m)
RETURN count(p) AS pricePointsCreated
```

**Step 2 — Query the new structure**
```cypher
MATCH (m:Market)-[:HAS_PRICE]->(p:PricePoint)
WHERE p.cropType = "Maize"
RETURN m.name, p.price, p.recordedAt
ORDER BY p.price DESC
```

**Step 3 — Add a more recent price to test history**
```cypher
MATCH (m:Market {name: "Eldoret Wholesale"})
MERGE (p:PricePoint {
  cropType: "Maize",
  price: 3250,
  unit: "90kg bag",
  recordedAt: date("2026-06-06"),
  source: "manual"
})
MERGE (m)-[:HAS_PRICE]->(p)
```

Now re-run Step 2 — you should see two Eldoret price records, at different dates.

---

## Exercise 3 — Cypher Parameters

Parameters make queries reusable and safe. Set them in the Neo4j Browser params panel before running the query.

**Set parameters:**
```cypher
:param cropType => "Maize"
:param minPrice => 3000
```

**Run a parameterised query:**
```cypher
MATCH (m:Market)-[:HAS_PRICE]->(p:PricePoint)
WHERE p.cropType = $cropType
  AND p.price >= $minPrice
RETURN m.name, p.price, p.recordedAt
ORDER BY p.price DESC
```

Change `:param cropType => "Beans"` and run again — same query, different results.

---

## Exercise 4 — Specific Node Labels

A node can carry more than one label. Use this when you need to query a subset of nodes directly.

```cypher
// Mark a buyer as a Wholesaler (adds a second label)
MATCH (b:Buyer {name: "Meghan Wares Ltd"})
SET b:Wholesaler

MATCH (b:Buyer {name: "Rift Valley Processors"})
SET b:Processor
```

Query only wholesalers — faster than filtering by a property:
```cypher
MATCH (b:Wholesaler)
RETURN b.name, b.county
```

---

## Exercise 5 — EXPLAIN and PROFILE

**The Cypher query lifecycle:** Parse → Plan → Execute → Result

`EXPLAIN` shows the *plan* without running. `PROFILE` runs the query and shows actual execution cost.

**Step 1 — EXPLAIN before indexes**
```cypher
EXPLAIN
MATCH (f:Farm {name: "Kamau Farm"})
RETURN f
```
Look for `NodeByLabelScan` — Neo4j is reading every Farm node to find one.

**Step 2 — Create indexes and a constraint**
```cypher
CREATE INDEX farm_name IF NOT EXISTS FOR (f:Farm) ON (f.name);
CREATE INDEX crop_name IF NOT EXISTS FOR (c:Crop) ON (c.name);
CREATE INDEX market_county IF NOT EXISTS FOR (m:Market) ON (m.county);
CREATE INDEX buyer_name IF NOT EXISTS FOR (b:Buyer) ON (b.name);
CREATE INDEX price_point_lookup IF NOT EXISTS FOR (p:PricePoint) ON (p.cropType, p.recordedAt);

CREATE CONSTRAINT market_name_unique IF NOT EXISTS
  FOR (m:Market) REQUIRE m.name IS UNIQUE;
```

Verify:
```cypher
SHOW INDEXES
```

**Step 3 — PROFILE after indexes**
```cypher
PROFILE
MATCH (f:Farm {name: "Kamau Farm"})
RETURN f
```
Look for `NodeIndexSeek` — the index is being used. Compare `db hits` before and after.

---

## Exercise 6 — Count Store

Neo4j keeps pre-computed counts for node labels and relationship types. These are instant — no scan needed.

```cypher
// These hit the Count Store — instant at any scale
MATCH (f:Farm) RETURN count(f) AS totalFarms
MATCH ()-[r:GROWS]->() RETURN count(r) AS totalGrowsRelationships

// This does NOT hit the Count Store — it scans after filtering
MATCH (f:Farm) WHERE f.county = "Nakuru" RETURN count(f)
```

---

## Exercise 7 — Breaking Down Queries with WITH

`WITH` pipes results from one query stage to the next — the graph equivalent of a SQL subquery.

**Without WITH — hard to debug:**
```cypher
MATCH (f:Farm)-[:GROWS]->(c:Crop)-[:LISTED_IN]->(m:Market)-[:HAS_PRICE]->(p:PricePoint)
WHERE p.recordedAt >= date() - duration({days: 30})
RETURN f.name, c.name, m.name, max(p.price) AS bestPrice
ORDER BY bestPrice DESC
```

**With WITH — staged and readable:**
```cypher
// Stage 1: find best recent price per crop per market
MATCH (m:Market)-[:HAS_PRICE]->(p:PricePoint)
WHERE p.recordedAt >= date() - duration({days: 30})
WITH m, p.cropType AS cropType, max(p.price) AS bestPrice

// Stage 2: find farms that grow those crops
MATCH (f:Farm)-[:GROWS]->(c:Crop {name: cropType})
RETURN f.name AS farm, cropType, m.name AS market, bestPrice
ORDER BY bestPrice DESC
LIMIT 10
```

You can test Stage 1 on its own — run just the first MATCH and WITH and RETURN the intermediate result before continuing.

---

## Challenge: The Recommendation Query

*"Which crops do buyers in my farm's network want — that I am not currently growing?"*

This is collaborative filtering: follow your farm's buyer connections, find what those buyers purchase, exclude what you already grow.

```cypher
:param myFarm => "Kamau Farm"
```

```cypher
MATCH (f:Farm {name: $myFarm})-[:KNOWS]->(b:Buyer)-[:BUYS]->(c:Crop)
WHERE NOT (f)-[:GROWS]->(c)
RETURN DISTINCT c.name AS suggestedCrop, count(b) AS buyerInterest
ORDER BY buyerInterest DESC
```

Try it with different farms. What does it reveal about network gaps?

---

## Quick Reference

```cypher
// Set a parameter
:param name => "value"

// Query lifecycle
EXPLAIN MATCH ...   -- shows plan, does not run
PROFILE MATCH ...   -- runs and shows db hits

// Count Store (fast)
MATCH (n:Label) RETURN count(n)

// Pipe results with WITH
MATCH ... WITH x, y  MATCH ... RETURN ...

// Show indexes
SHOW INDEXES

// Drop a projection (GDS — next workshop)
CALL gds.graph.drop('name')
```
