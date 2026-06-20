# Workshop 4 — Exercise Handout
**Kenya AI Challenge 2026 · Neo4j Track · 20 June 2026**

---

## Before You Start

**GDS requires a compatible Neo4j instance.** Neo4j AuraDB Free does *not* include GDS. You need one of:
- **Neo4j AuraDS** (free Data Science tier) — sign up at console.neo4j.io
- **Local Neo4j** with the GDS plugin installed
- **GraphAcademy Sandbox** — pre-configured with GDS and data

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

### Results

The projection loads **26 nodes** (10 farms, 9 crops, 7 markets) and **61 relationships** (23 `GROWS`, 24 `LISTED_IN`, 14 `SELLS_AT`). This in-memory snapshot is what every subsequent algorithm runs against — the underlying database is untouched until you use `write` mode.

**What this means for stakeholders:** The projection is the foundation — it defines whose story gets told. The 10 farms, 9 crops, and 7 markets included here represent a realistic slice of Kenya's agricultural value chain. Any stakeholder relying on analysis built from this projection — a buyer sourcing tool, a government inclusion report, a cooperative planning dashboard — can trust that the algorithms are running over the full picture, not a sample. If a farm or market is missing from the projection, it is invisible to every algorithm that follows.

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

### Results

**Wakulima Market** tops the list with the highest degree — it receives 7 crop `LISTED_IN` links and 4 farm `SELLS_AT` links, making it the network's central trading hub. **Kisumu Main Market** (7 connections) and **Eldoret Wholesale** (6 connections) follow.

Among farms, **Kamau Farm**, **Wanjiku Farm**, **Auma Farm**, and **Nafula Farm** are tied at the top — each grows 3 crops and sells at 2 markets (5 outgoing relationships). **Halima Farm** scores 1, connected only via `GROWS → Sorghum` with no `SELLS_AT` link at all. This is the first signal of financial exclusion: the farm exists in the graph through a single crop relationship and reaches no market directly.

**What this means for stakeholders:**
- **Farmers:** A high-degree market like Wakulima is where you want to be listed — more buyers, more price competition, and better market information. If your farm has a low degree score, it signals you are selling through too few channels and are vulnerable to price shocks if one buyer or market drops out.
- **Buyers (wholesalers, exporters, processors):** High-degree markets are efficient sourcing points — a buyer at Wakulima can access produce from many farms in one place. Low-degree farms represent untapped supply chains worth developing for exclusive or diversified sourcing.
- **Government and NGOs:** Degree score is a rapid proxy for market access. Farms scoring 1 or 2 are the first to receive extension officer visits, mobile market-linkage services, or enrollment in cooperative programmes.

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

### Results

**Wakulima Market** ranks first on PageRank as well as Degree. It connects to Maize — listed at 5 markets and grown by 5 farms — so its immediate neighbours are themselves among the most connected nodes in the graph.

**Kisumu Main Market** often scores higher on PageRank than its raw degree suggests, because Auma Farm and Wanjiku Farm (both high-degree) sell there. **Machakos Market** and **Mombasa Wholesale** rank lowest — they serve only Mutua Farm on the `SELLS_AT` side and carry 2 crop types. Their neighbours are not themselves well-connected, so little influence flows through them.

The key insight: a market with high Degree but lower PageRank sits at the edge of the network — many connections, but to nodes that are not themselves important.

**What this means for stakeholders:**
- **Farmers:** Selling at a high-PageRank market gives you access to buyers and price signals that flow through the whole network, not just one corner of it. A high-PageRank market is more likely to have competitive pricing and multiple buyer options.
- **Buyers:** Markets with high PageRank are better sourcing hubs because their suppliers are themselves well-integrated across the value chain. Low-PageRank markets (Machakos, Mombasa in this dataset) may have fewer backup suppliers and less price diversity.
- **Policymakers and infrastructure planners:** PageRank reveals which markets are genuine network hubs versus peripheral ones. Road upgrades, cold storage, or digital market platforms installed at high-PageRank markets will have the greatest systemic impact — improvements there propagate to the farms and buyers connected to them.

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

### Results

`nodePropertiesWritten` should be **26** for both write calls — every node in the projection receives a score, including crops.

The combined query returns all **7 markets** ordered by PageRank. You will notice that markets with similar `degreeScore` can differ significantly on `pageRankScore` — for example, Eldoret Wholesale and Kisumu Main Market may have similar raw degree but different PageRank because the farms connecting to each are not equally well-connected. Wakulima Market leads on both metrics.

**What this means for stakeholders:**
- **Developers and platform teams:** Scores stored as node properties can be queried by any application — a mobile app recommending the best market for a farmer's crop, a buyer dashboard ranking suppliers by network centrality, or a reporting pipeline feeding into Power BI or Looker.
- **Cooperatives and aggregators:** Combining Degree and PageRank in a single query lets a cooperative rank its member farms by market integration and identify which members need support to diversify their sales channels.
- **Fintechs and lenders:** `degreeScore` and `pageRankScore` together form a network-based market-access signal that can supplement traditional credit scoring — a farm well-connected to high-PageRank markets is demonstrably integrated into active trade, reducing default risk.

---

## Exercise 5 — Drop the Projection

Always clean up after running algorithms — projections consume memory. The `false` parameter means the query will not error if the projection was already dropped.

```cypher
CALL gds.graph.drop('farmMarketNetwork', false)
YIELD graphName
```

### Results

The query returns `graphName: "farmMarketNetwork"` confirming the projection was removed. Running `CALL gds.graph.list()` afterwards will no longer show it. The `degreeScore` and `pageRankScore` properties written to nodes in Exercise 4 remain in the database until explicitly removed.

**What this means for stakeholders:**
- **Platform and system operators:** In a production GDS deployment serving real farmers or buyers, projections should be dropped after each analysis job to free memory. The durable results — node properties like `degreeScore` — persist and remain accessible to all downstream applications without keeping the projection alive.
- **Data product owners:** This step is what makes GDS outputs reusable. Once scores are written to nodes, any team (agronomists, credit analysts, logistics planners) can query them with plain Cypher — no GDS knowledge required.

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

### Results

WCC finds **3 components**:

| Component | Farms | What it means |
|---|---|---|
| Main cluster | Kamau, Wanjiku, Auma, Maina, Nafula, Otieno, Chebet, Ndung'u | All connected through shared markets (Wakulima, Kisumu, Eldoret) and buyers (Rift Valley Processors, Meghan Wares, Lake Basin Exporters) |
| Mutua's island | Mutua | Sells only at Machakos and Mombasa, knows only Coast Packers — none of these overlap with the main cluster |
| Halima alone | Halima | No `SELLS_AT` and no `KNOWS` at all — completely disconnected |

The isolated-farms query returns **Halima Farm** and **Mutua Farm**. Both are priority targets for market-linkage interventions: Halima needs any buyer or market connection; Mutua needs a bridge into the main trading network.

**What this means for stakeholders:**
- **Farmers in isolated components:** Halima Farm and Mutua Farm are invisible to the main trading network — they are likely receiving below-market prices, missing demand signals, and excluded from buyer relationships that other farms enjoy. WCC gives them a data-backed case to bring to a cooperative or NGO: "I am structurally disconnected from the market."
- **Buyers:** The 8 farms in the main cluster represent reliable, connected supply. The 2 isolated farms are untapped supply chains — a buyer willing to invest in connecting them (transport, aggregation, mobile payments) gains access to new produce volumes, often at lower competition.
- **NGOs, government, and financial inclusion programmes:** WCC produces an automatically generated list of financially excluded farms that updates as the graph changes. It can trigger enrollment into mobile money programmes, input credit schemes, or cooperative membership drives — precisely targeted, not based on geography alone.

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

### Results

Louvain typically finds **3 communities** in this dataset:

| Community | Farms | Shared characteristics |
|---|---|---|
| Highland / Grain | Kamau, Maina, Chebet, Nafula | Grow Maize and/or Potatoes; sell at Eldoret Wholesale or Nakuru Market |
| Wakulima / Kisumu | Wanjiku, Auma, Otieno, Ndung'u | Grow Beans and/or Avocado; sell at Wakulima or Kisumu Main Market |
| Isolated | Mutua | Grows Mango and Capsicum; sells at Machakos and Mombasa — no crop or market overlap with other farms |

Halima Farm may join the Highland cluster (Sorghum is listed at Eldoret and Kitale) or form a singleton, depending on how Louvain resolves the weak link. Community IDs are arbitrary integers that vary between runs — focus on which farms share the same ID, not the ID value itself.

**Extension officer targeting:** each community maps to a natural coverage zone. Officers in the Eldoret region can serve the Highland cluster in a single circuit; Nairobi-based officers cover the Wakulima/Kisumu cluster. Mutua Farm's isolated community needs a dedicated visit — it cannot be reached by bulk community outreach.

**What this means for stakeholders:**
- **Farmers:** Knowing your community tells you which other farms face the same market conditions. Farms in the same community are natural candidates for a joint selling group — shared transport, bulk negotiation, and collective market information lower costs for everyone.
- **Buyers and aggregators:** Communities are natural procurement clusters. A buyer sourcing Maize and Potatoes can approach the Highland cluster (Kamau, Maina, Chebet, Nafula) as a group to negotiate volume, consistency, and logistics — far more efficient than contracting each farm individually.
- **Cooperatives and SACCOs:** Community membership suggests natural cooperative formation. Farms already sharing crops and markets are a lower-risk starting point for a new cooperative than farms grouped arbitrarily by location.
- **Policymakers:** Community detection makes county-level agricultural planning more precise. Each community corresponds to a regional supply chain that can be supported with targeted infrastructure investment, subsidy delivery, or weather-index insurance products.

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

### Results

The combined view ranks farms from most to least financially excluded:

| Farm | Degree | PageRank | Component | Community |
|---|---|---|---|---|
| Halima Farm | 1 | ~0.15 | isolated (alone) | singleton |
| Mutua Farm | 4 | low | isolated island | own cluster |
| Maina / Chebet / Otieno / Ndung'u | 3 | moderate | main | grain or Kisumu cluster |
| Kamau / Wanjiku / Auma / Nafula | 5 | high | main | respective community |

**How to read this:** a farm with low degree AND an isolated component AND a singleton community is the most excluded. Halima Farm hits all three flags — it is the first farm to target for intervention. Mutua Farm is disconnected from the main network but has its own internal market connections, so the intervention needed is different: market-linkage rather than basic outreach.

Farms with high degree, high PageRank, and membership in the main component are the network anchors — candidates for peer-connector roles in outreach programmes.

**What this means for stakeholders:**
- **Credit institutions and fintechs:** The combined score is a network-based creditworthiness signal. A farm with high degree, main-cluster membership, and an active community has demonstrated sustained market integration — a proxy for revenue reliability that complements or replaces thin transaction history for unbanked farmers.
- **Government and development programmes:** This ranked list directly informs which farms to enroll first in subsidised input schemes, guaranteed purchase programmes, or digital onboarding initiatives. The most excluded farms sit at the top — data-driven targeting, not guesswork.
- **Buyers and supply chain managers:** High-degree, high-PageRank farms in the main cluster are the most resilient sourcing partners — they have multiple market and buyer options, so they can fulfil volume commitments even if one channel is disrupted. These are the farms to build long-term contracts with.
- **Farmers themselves:** Any farmer can run this query on a graph that includes their own data and immediately see where they stand in the network. A low combined score is a signal to join a cooperative, diversify crops, or seek out a new market — not a judgment, but an actionable map of next steps.

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
