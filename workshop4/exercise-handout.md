# Workshop 4 — Exercise Handout
**Kenya AI Challenge 2026 · Neo4j Track · 20 June 2026**

---

## Before You Start

**GDS requires a compatible Neo4j instance.** Neo4j AuraDB Free does *not* include GDS. You need one of:
- **Neo4j AuraDS** (free Data Science tier) — sign up at console.neo4j.io
- **Local Neo4j** with the GDS plugin installed
- **GraphAcademy Sandbox** — pre-configured with GDS and data (link shared in WhatsApp group)

**Run the seed script** first. Paste `data/seed.cypher` into your Neo4j query tab.

Confirm it loaded:
```cypher
MATCH (n)-[r]->(m)
RETURN labels(n)[0] AS from, type(r) AS rel, labels(m)[0] AS to, count(*) AS count
ORDER BY from, rel
```

Verify GDS is available:
```cypher
RETURN gds.version()
```

If this returns an error, switch to the GraphAcademy Sandbox — everything below will work there.

**Clean start — run this if re-running any exercise** (safe to run even if projections don't exist yet):
```cypher
CALL gds.graph.drop('farmMarketNetwork', false) YIELD graphName;
```
```cypher
CALL gds.graph.drop('fullFarmNetwork', false) YIELD graphName;
```
```cypher
CALL gds.graph.drop('farmerCommunities', false) YIELD graphName;
```

Clear any GDS scores written to nodes from a previous run:
```cypher
MATCH (n)
WHERE n.degreeScore IS NOT NULL
   OR n.pageRankScore IS NOT NULL
   OR n.componentId IS NOT NULL
   OR n.communityId IS NOT NULL
REMOVE n.degreeScore, n.pageRankScore, n.componentId, n.communityId
```

See all projections currently loaded in memory:
```cypher
CALL gds.graph.list()
YIELD graphName, nodeCount, relationshipCount
```

---

## Exercise 1 — Create a Projection

A projection is an in-memory subgraph of selected nodes and relationships. Every GDS algorithm runs on a projection, not the full database.

```cypher
CALL gds.graph.project(
  'farmMarketNetwork',
  ['Farm', 'Market', 'Crop'],
  ['GROWS', 'LISTED_IN', 'SELLS_AT']
)
YIELD graphName, nodeCount, relationshipCount
```

Check what was included:
```cypher
CALL gds.graph.list('farmMarketNetwork')
YIELD graphName, nodeCount, relationshipCount, schema
```

---

## Exercise 2 — Degree Centrality: Most Connected Markets

```cypher
CALL gds.degree.stream('farmMarketNetwork')
YIELD nodeId, score
WITH gds.util.asNode(nodeId) AS node, score
WHERE node:Market OR node:Farm
RETURN labels(node)[0] AS nodeType,
       node.name        AS name,
       score            AS degree
ORDER BY degree DESC
LIMIT 10
```

**Questions to consider:**
- Which market has the highest degree? What does that mean?
- Which farm has the highest degree? Is it a surprise?
- Are any nodes at degree 1? What does that tell you?

---

## Exercise 3 — PageRank: Most Influential Markets

```cypher
CALL gds.pageRank.stream('farmMarketNetwork', {
  maxIterations: 20,
  dampingFactor: 0.85
})
YIELD nodeId, score
WITH gds.util.asNode(nodeId) AS node, score
WHERE node:Market
RETURN node.name AS market,
       round(score * 1000) / 1000 AS pageRankScore
ORDER BY pageRankScore DESC
LIMIT 10
```

**Compare with Degree:** Does the same market top both lists? A market high on Degree but lower on PageRank is connected to many nodes, but those nodes are not themselves well-connected. PageRank measures the *quality* of connections, not just quantity.

---

## Exercise 4 — Write Scores Back to Nodes

Now persist the scores so they can be queried with Cypher. Run each as a separate statement:

```cypher
CALL gds.degree.write('farmMarketNetwork', {
  writeProperty: 'degreeScore'
})
YIELD nodePropertiesWritten;
```

```cypher
CALL gds.pageRank.write('farmMarketNetwork', {
  maxIterations: 20,
  dampingFactor: 0.85,
  writeProperty: 'pageRankScore'
})
YIELD nodePropertiesWritten;
```

Query both scores together:
```cypher
MATCH (m:Market)
WHERE m.degreeScore IS NOT NULL
RETURN m.name, m.degreeScore, m.pageRankScore
ORDER BY m.pageRankScore DESC
```

---

## Exercise 5 — Drop the Projection

Always clean up after running algorithms — projections consume memory. The `false` parameter means the query will not error if the projection was already dropped.

```cypher
CALL gds.graph.drop('farmMarketNetwork', false)
YIELD graphName
```

---

## Exercise 6 — WCC: Find Isolated Farms

WCC (Weakly Connected Components) finds groups of nodes that are connected to each other but isolated from the rest of the graph. A farm with no direct market or buyer relationships is financially excluded.

Create a projection using only direct Farm ↔ Market and Farm ↔ Buyer connections. This is intentional — if we included `GROWS` and `LISTED_IN`, every farm would connect through its crops and nothing would appear isolated.

```cypher
CALL gds.graph.project(
  'fullFarmNetwork',
  ['Farm', 'Market', 'Buyer'],
  ['SELLS_AT', 'KNOWS']
)
YIELD graphName, nodeCount, relationshipCount
```

Run WCC:
```cypher
CALL gds.wcc.stream('fullFarmNetwork')
YIELD nodeId, componentId
WITH gds.util.asNode(nodeId) AS node, componentId
WHERE node:Farm
RETURN node.name     AS farm,
       node.location AS location,
       componentId
ORDER BY componentId
```

Write component IDs back:
```cypher
CALL gds.wcc.write('fullFarmNetwork', {
  writeProperty: 'componentId'
})
YIELD componentCount, nodePropertiesWritten
```

Find isolated farms — those alone in their own component:
```cypher
MATCH (f:Farm)
WHERE f.componentId IS NOT NULL
WITH f.componentId AS component, collect(f.name) AS farms, count(f) AS size
WHERE size = 1
RETURN farms[0] AS isolatedFarm, component
```

> Which farms are isolated? Halima Farm has no `SELLS_AT` and no `KNOWS` — no direct connections at all. Mutua Farm sells at Machakos and Mombasa and knows Coast Packers, but none of the other farms share those connections, so it forms its own small island. Both appear as isolated from the main network.

---

## Exercise 7 — Louvain: Detect Farmer Communities

Louvain finds dense neighbourhoods within the connected graph — natural clusters of farms that share crops and markets.

Drop the previous projection and create a new one:
```cypher
CALL gds.graph.drop('fullFarmNetwork', false);
```

```cypher
CALL gds.graph.project(
  'farmerCommunities',
  ['Farm', 'Crop', 'Market'],
  ['GROWS', 'LISTED_IN', 'SELLS_AT']
)
YIELD graphName, nodeCount, relationshipCount;
```

Run Louvain in stream mode first:
```cypher
CALL gds.louvain.stream('farmerCommunities')
YIELD nodeId, communityId
WITH gds.util.asNode(nodeId) AS node, communityId
WHERE node:Farm
RETURN node.name     AS farm,
       node.location AS location,
       communityId
ORDER BY communityId, farm
```

Write community IDs back:
```cypher
CALL gds.louvain.write('farmerCommunities', {
  writeProperty: 'communityId'
})
YIELD communityCount, nodePropertiesWritten
```

Count members per community:
```cypher
MATCH (f:Farm)
WHERE f.communityId IS NOT NULL
RETURN f.communityId        AS community,
       count(f)              AS memberCount,
       collect(f.name)       AS farms
ORDER BY memberCount DESC
```

**Interpretation questions:**
- What do farms in the same community have in common?
- Is any farm in a community by itself? What might that mean?
- How would you use this for extension officer targeting?

---

## Exercise 8 — The Full Picture

Combine all four scores for a complete view of each farm:

```cypher
MATCH (f:Farm)
WHERE f.degreeScore IS NOT NULL
   OR f.componentId IS NOT NULL
   OR f.communityId IS NOT NULL
RETURN f.name       AS farm,
       f.location   AS location,
       f.degreeScore     AS degree,
       f.pageRankScore   AS pageRank,
       f.componentId     AS component,
       f.communityId     AS community
ORDER BY coalesce(f.degreeScore, 0) ASC
```

The farms at the top (lowest degree, isolated component) are the most financially excluded — the first targets for outreach, credit products, or extension officer visits.

Clean up:
```cypher
CALL gds.graph.drop('farmerCommunities', false)
```

---

## Transfer Template

Use this for your team's project design:

**1. Which algorithm is most relevant to your project?**
Choose one: `Degree Centrality` / `PageRank` / `WCC` / `Louvain` / `Link Prediction` / `Path Finding`

**2. Complete this sentence:**
> "I want to run [algorithm] on [node labels] connected by [relationship types] to find [insight] because [business reason]."

**Example:**
> "I want to run Louvain on Farmers connected to Markets via SELLS_AT to find which farmers form regional selling clusters, because extension officers should receive community-based reports rather than individual farmer reports."

---

## Quick Reference

```cypher
-- Check GDS version
RETURN gds.version()

-- Project a subgraph
CALL gds.graph.project('name', ['Label'], ['REL_TYPE'])
YIELD graphName, nodeCount, relationshipCount

-- List all projections currently in memory
CALL gds.graph.list()
YIELD graphName, nodeCount, relationshipCount

-- Check if a specific projection exists
CALL gds.graph.exists('name') YIELD exists

-- Drop a projection (errors if not found)
CALL gds.graph.drop('name') YIELD graphName

-- Drop a projection safely — no error if it does not exist
CALL gds.graph.drop('name', false) YIELD graphName

-- Drop all three workshop projections (safe re-run block)
CALL gds.graph.drop('farmMarketNetwork', false) YIELD graphName;
CALL gds.graph.drop('fullFarmNetwork', false) YIELD graphName;
CALL gds.graph.drop('farmerCommunities', false) YIELD graphName;

-- Remove all GDS-written properties from nodes
MATCH (n)
WHERE n.degreeScore IS NOT NULL
   OR n.pageRankScore IS NOT NULL
   OR n.componentId IS NOT NULL
   OR n.communityId IS NOT NULL
REMOVE n.degreeScore, n.pageRankScore, n.componentId, n.communityId

-- Degree centrality (stream)
CALL gds.degree.stream('name') YIELD nodeId, score

-- PageRank (stream)
CALL gds.pageRank.stream('name', {maxIterations: 20, dampingFactor: 0.85}) YIELD nodeId, score

-- WCC (stream)
CALL gds.wcc.stream('name') YIELD nodeId, componentId

-- Louvain (stream)
CALL gds.louvain.stream('name') YIELD nodeId, communityId

-- Write mode (persists results as node properties)
CALL gds.degree.write('name', {writeProperty: 'degreeScore'}) YIELD nodePropertiesWritten

-- Resolve a nodeId to an actual node
gds.util.asNode(nodeId)

-- Check what GDS scores a node has (inspect any farm)
MATCH (f:Farm {name: 'Kamau Farm'})
RETURN f.degreeScore, f.pageRankScore, f.componentId, f.communityId

-- Count nodes per label in the main graph
CALL db.labels() YIELD label
CALL apoc.cypher.run('MATCH (n:' + label + ') RETURN count(n) AS count', {})
YIELD value
RETURN label, value.count AS nodeCount
ORDER BY nodeCount DESC
```
