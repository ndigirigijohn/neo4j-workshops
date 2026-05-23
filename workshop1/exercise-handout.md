# Workshop 1 — Exercise Handout

**Kenya AI Challenge 2026 · Neo4j Track · 23 May 2026**

---

## Exercise 1: Connect to Neo4j Aura

1. Go to [console.neo4j.io](https://console.neo4j.io) → sign in
2. Open your running instance → click **Query** or **Open**
3. In the command bar, run:

```cypher
RETURN "Hello, Kenya AI Challenge!" AS message
```

✅ You are ready when you see the message returned.

---

## Exercise 2: Build the MarketGraph

**Step 1 — Model first (on paper)**

Before touching the keyboard:
- List 3–4 node types for an agricultural data problem
- Draw the relationships between them (with names and direction)
- Add key properties to each node type

**Step 2 — Create the seed graph**

Copy and run the Cypher below in your Neo4j Browser:

```cypher
CREATE (wanjiku:Farmer {name: "Wanjiku Mwangi", county: "Kirinyaga"})
CREATE (kamau:Farmer {name: "Kamau Njoroge", county: "Nakuru"})
CREATE (auma:Farmer {name: "Auma Otieno", county: "Kisumu"})
CREATE (maize:Crop {name: "Maize", unit: "90kg bag"})
CREATE (tomatoes:Crop {name: "Tomatoes", unit: "kg"})
CREATE (beans:Crop {name: "Beans", unit: "90kg bag"})
CREATE (wakulima:Market {name: "Wakulima Market", county: "Nairobi"})
CREATE (eldoret:Market {name: "Eldoret Wholesale", county: "Uasin Gishu"})
CREATE (kisumu:Market {name: "Kisumu Main Market", county: "Kisumu"})
CREATE (wanjiku)-[:GROWS]->(maize)
CREATE (wanjiku)-[:GROWS]->(beans)
CREATE (kamau)-[:GROWS]->(maize)
CREATE (kamau)-[:GROWS]->(tomatoes)
CREATE (auma)-[:GROWS]->(tomatoes)
CREATE (auma)-[:GROWS]->(beans)
CREATE (maize)-[:LISTED_AT {price: 3100, date: "2026-05-20"}]->(eldoret)
CREATE (maize)-[:LISTED_AT {price: 2400, date: "2026-05-20"}]->(wakulima)
CREATE (tomatoes)-[:LISTED_AT {price: 85, date: "2026-05-20"}]->(kisumu)
CREATE (tomatoes)-[:LISTED_AT {price: 110, date: "2026-05-20"}]->(wakulima)
CREATE (beans)-[:LISTED_AT {price: 8500, date: "2026-05-20"}]->(eldoret)
CREATE (beans)-[:LISTED_AT {price: 7200, date: "2026-05-20"}]->(wakulima)
CREATE (meghan:Buyer {name: "Meghan Wares Ltd"})
CREATE (rift:Buyer {name: "Rift Valley Processors"})
CREATE (meghan)-[:BUYS]->(tomatoes)
CREATE (meghan)-[:BUYS]->(beans)
CREATE (rift)-[:BUYS]->(maize)
```

**Step 3 — Explore visually**

```cypher
MATCH (n)-[r]->(m)
RETURN n, r, m
LIMIT 50
```

Click on nodes and relationships in the visual graph to see their properties.

---

## Exercise 3: Query the Graph

Run each query in order. Read the results and understand what they mean.

**Q1 — What crops does Kamau grow?**
```cypher
MATCH (f:Farmer {name: "Kamau Njoroge"})-[:GROWS]->(c:Crop)
RETURN c.name
```

**Q2 — Which markets sell maize above KSh 3,000?**
```cypher
MATCH (c:Crop {name: "Maize"})-[l:LISTED_AT]->(m:Market)
WHERE l.price > 3000
RETURN m.name, l.price
ORDER BY l.price DESC
```

**Q3 — Which markets should Wanjiku consider?**
```cypher
MATCH (f:Farmer {name: "Wanjiku Mwangi"})-[:GROWS]->(c:Crop)-[:LISTED_AT]->(m:Market)
RETURN f.name, c.name, m.name
```

**Q4 — Average and best price per crop**
```cypher
MATCH (c:Crop)-[l:LISTED_AT]->(m:Market)
RETURN c.name, avg(l.price) AS avgPrice, max(l.price) AS bestPrice
ORDER BY bestPrice DESC
```

**Q5 — Best market for each farmer's crops**
```cypher
MATCH (f:Farmer)-[:GROWS]->(c:Crop)-[l:LISTED_AT]->(m:Market)
RETURN f.name AS farmer, c.name AS crop, m.name AS bestMarket, l.price AS price
ORDER BY f.name, l.price DESC
```

**Q6 — Challenge: Which farmers grow what Rift Valley Processors buys?**
```cypher
MATCH (b:Buyer {name: "Rift Valley Processors"})-[:BUYS]->(c:Crop)<-[:GROWS]-(f:Farmer)
RETURN f.name, f.county, c.name
```

---

## Exercise 4: Import from CSV (if time permits)

**Import markets:**
```cypher
LOAD CSV WITH HEADERS FROM
  'https://raw.githubusercontent.com/ndigirigijohn/neo4j-workshops/main/workshop1/data/markets.csv'
AS row
MERGE (m:Market {name: row.market_name})
SET m.county = row.county,
    m.latitude = toFloat(row.latitude),
    m.longitude = toFloat(row.longitude)
RETURN count(m) AS marketsImported
```

**Import price listings:**
```cypher
LOAD CSV WITH HEADERS FROM
  'https://raw.githubusercontent.com/ndigirigijohn/neo4j-workshops/main/workshop1/data/price-listings.csv'
AS row
MATCH (c:Crop {name: row.crop_name})
MATCH (m:Market {name: row.market_name})
MERGE (c)-[l:LISTED_AT {date: row.date}]->(m)
SET l.price = toFloat(row.price_ksh)
```

**Verify:**
```cypher
MATCH (c:Crop)-[l:LISTED_AT]->(m:Market)
RETURN count(l) AS totalListings
```

---

## Transfer: Design Your Hackathon Graph

Fill this in with your team:

**Project Name:** _________________________________

**Nodes:**

| Label | Key Properties |
|---|---|
| | |
| | |
| | |
| | |

**Relationships:**

| Pattern | Properties |
|---|---|
| `( )-[:_______]->( )` | |
| `( )-[:_______]->( )` | |
| `( )-[:_______]->( )` | |

**The question your graph must answer:**

> ___________________________________________________

**Where will your data come from?**

> ___________________________________________________

---

## Quick Reference — Cypher Patterns

```cypher
// Find all nodes of a type
MATCH (n:Label) RETURN n

// Find by property
MATCH (n:Label {prop: "value"}) RETURN n

// Follow a relationship
MATCH (a)-[:REL]->(b) RETURN a, b

// Filter
WHERE n.prop > 100

// Sort and limit
ORDER BY n.prop DESC LIMIT 10

// Aggregations
count(n)   avg(r.prop)   max(r.prop)   min(r.prop)   sum(r.prop)

// Create node
CREATE (n:Label {prop: "value"})

// Create relationship
CREATE (a)-[:REL {prop: val}]->(b)

// Safe upsert
MERGE (n:Label {id: "unique_id"})

// Import CSV
LOAD CSV WITH HEADERS FROM 'url' AS row
```
