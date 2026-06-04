// ============================================================
// Workshop 2 — Seed Data
// Kenya AI Challenge 2026 — Neo4j Track
//
// This script creates the Workshop 2 starting graph from scratch.
// Safe to run on any Aura instance — uses MERGE throughout.
// Running it multiple times will not create duplicates.
//
// Graph state: flat model (Workshop 1 equivalent) using Farm nodes.
// The refactoring exercises in Workshop 2 evolve this into the
// full model with PricePoint and Transaction nodes.
// ============================================================


// ── STEP 1: Farms ────────────────────────────────────────────

MERGE (kamau:Farm {name: "Kamau Farm"})
SET kamau.owner = "Kamau Njoroge", kamau.county = "Nakuru", kamau.phone = "+254723456789"

MERGE (wanjiku:Farm {name: "Wanjiku Farm"})
SET wanjiku.owner = "Wanjiku Mwangi", wanjiku.county = "Kirinyaga", wanjiku.phone = "+254712345678"

MERGE (auma:Farm {name: "Auma Farm"})
SET auma.owner = "Auma Otieno", auma.county = "Kisumu", auma.phone = "+254734567890"

MERGE (maina:Farm {name: "Maina Farm"})
SET maina.owner = "Maina Kariuki", maina.county = "Uasin Gishu", maina.phone = "+254745678901"

MERGE (nafula:Farm {name: "Nafula Farm"})
SET nafula.owner = "Nafula Wekesa", nafula.county = "Trans-Nzoia", nafula.phone = "+254756789012";


// ── STEP 2: Crops ────────────────────────────────────────────

MERGE (maize:Crop {name: "Maize"})       SET maize.unit = "90kg bag"
MERGE (tomatoes:Crop {name: "Tomatoes"}) SET tomatoes.unit = "kg"
MERGE (beans:Crop {name: "Beans"})       SET beans.unit = "90kg bag"
MERGE (potatoes:Crop {name: "Potatoes"}) SET potatoes.unit = "50kg bag"
MERGE (avocado:Crop {name: "Avocado"})   SET avocado.unit = "kg";


// ── STEP 3: Markets ──────────────────────────────────────────

MERGE (wakulima:Market {name: "Wakulima Market"})    SET wakulima.county = "Nairobi"
MERGE (eldoret:Market {name: "Eldoret Wholesale"})   SET eldoret.county = "Uasin Gishu"
MERGE (kisumu:Market {name: "Kisumu Main Market"})   SET kisumu.county = "Kisumu"
MERGE (nakuru:Market {name: "Nakuru Market"})        SET nakuru.county = "Nakuru"
MERGE (kitale:Market {name: "Kitale Market"})        SET kitale.county = "Trans-Nzoia";


// ── STEP 4: Buyers ───────────────────────────────────────────

MERGE (meghan:Buyer {name: "Meghan Wares Ltd"})
SET meghan.county = "Nairobi", meghan.type = "Wholesaler"

MERGE (rift:Buyer {name: "Rift Valley Processors"})
SET rift.county = "Uasin Gishu", rift.type = "Processor"

MERGE (lake:Buyer {name: "Lake Basin Exporters"})
SET lake.county = "Kisumu", lake.type = "Exporter";


// ── STEP 5: GROWS relationships ──────────────────────────────

MATCH (f:Farm {name: "Kamau Farm"}),    (c:Crop {name: "Maize"})    MERGE (f)-[:GROWS]->(c)
MATCH (f:Farm {name: "Kamau Farm"}),    (c:Crop {name: "Tomatoes"}) MERGE (f)-[:GROWS]->(c)
MATCH (f:Farm {name: "Kamau Farm"}),    (c:Crop {name: "Potatoes"}) MERGE (f)-[:GROWS]->(c)
MATCH (f:Farm {name: "Wanjiku Farm"}),  (c:Crop {name: "Maize"})    MERGE (f)-[:GROWS]->(c)
MATCH (f:Farm {name: "Wanjiku Farm"}),  (c:Crop {name: "Beans"})    MERGE (f)-[:GROWS]->(c)
MATCH (f:Farm {name: "Auma Farm"}),     (c:Crop {name: "Tomatoes"}) MERGE (f)-[:GROWS]->(c)
MATCH (f:Farm {name: "Auma Farm"}),     (c:Crop {name: "Beans"})    MERGE (f)-[:GROWS]->(c)
MATCH (f:Farm {name: "Auma Farm"}),     (c:Crop {name: "Avocado"})  MERGE (f)-[:GROWS]->(c)
MATCH (f:Farm {name: "Maina Farm"}),    (c:Crop {name: "Maize"})    MERGE (f)-[:GROWS]->(c)
MATCH (f:Farm {name: "Maina Farm"}),    (c:Crop {name: "Potatoes"}) MERGE (f)-[:GROWS]->(c)
MATCH (f:Farm {name: "Nafula Farm"}),   (c:Crop {name: "Maize"})    MERGE (f)-[:GROWS]->(c)
MATCH (f:Farm {name: "Nafula Farm"}),   (c:Crop {name: "Beans"})    MERGE (f)-[:GROWS]->(c);


// ── STEP 6: LISTED_AT relationships (flat model — to be refactored) ──

MATCH (c:Crop {name: "Maize"}),    (m:Market {name: "Wakulima Market"})  MERGE (c)-[:LISTED_AT {price: 2400, date: "2026-06-06"}]->(m)
MATCH (c:Crop {name: "Maize"}),    (m:Market {name: "Eldoret Wholesale"}) MERGE (c)-[:LISTED_AT {price: 3100, date: "2026-06-06"}]->(m)
MATCH (c:Crop {name: "Maize"}),    (m:Market {name: "Kisumu Main Market"}) MERGE (c)-[:LISTED_AT {price: 2600, date: "2026-06-06"}]->(m)
MATCH (c:Crop {name: "Maize"}),    (m:Market {name: "Nakuru Market"})    MERGE (c)-[:LISTED_AT {price: 2900, date: "2026-06-06"}]->(m)
MATCH (c:Crop {name: "Maize"}),    (m:Market {name: "Kitale Market"})    MERGE (c)-[:LISTED_AT {price: 2800, date: "2026-06-06"}]->(m)

MATCH (c:Crop {name: "Tomatoes"}), (m:Market {name: "Wakulima Market"})  MERGE (c)-[:LISTED_AT {price: 110, date: "2026-06-06"}]->(m)
MATCH (c:Crop {name: "Tomatoes"}), (m:Market {name: "Kisumu Main Market"}) MERGE (c)-[:LISTED_AT {price: 85, date: "2026-06-06"}]->(m)
MATCH (c:Crop {name: "Tomatoes"}), (m:Market {name: "Nakuru Market"})    MERGE (c)-[:LISTED_AT {price: 95, date: "2026-06-06"}]->(m)
MATCH (c:Crop {name: "Tomatoes"}), (m:Market {name: "Eldoret Wholesale"}) MERGE (c)-[:LISTED_AT {price: 100, date: "2026-06-06"}]->(m)

MATCH (c:Crop {name: "Beans"}),    (m:Market {name: "Wakulima Market"})  MERGE (c)-[:LISTED_AT {price: 7200, date: "2026-06-06"}]->(m)
MATCH (c:Crop {name: "Beans"}),    (m:Market {name: "Eldoret Wholesale"}) MERGE (c)-[:LISTED_AT {price: 8500, date: "2026-06-06"}]->(m)
MATCH (c:Crop {name: "Beans"}),    (m:Market {name: "Kitale Market"})    MERGE (c)-[:LISTED_AT {price: 7800, date: "2026-06-06"}]->(m)
MATCH (c:Crop {name: "Beans"}),    (m:Market {name: "Nakuru Market"})    MERGE (c)-[:LISTED_AT {price: 7500, date: "2026-06-06"}]->(m)

MATCH (c:Crop {name: "Potatoes"}), (m:Market {name: "Wakulima Market"})  MERGE (c)-[:LISTED_AT {price: 2600, date: "2026-06-06"}]->(m)
MATCH (c:Crop {name: "Potatoes"}), (m:Market {name: "Nakuru Market"})    MERGE (c)-[:LISTED_AT {price: 2200, date: "2026-06-06"}]->(m)
MATCH (c:Crop {name: "Potatoes"}), (m:Market {name: "Eldoret Wholesale"}) MERGE (c)-[:LISTED_AT {price: 2400, date: "2026-06-06"}]->(m)

MATCH (c:Crop {name: "Avocado"}),  (m:Market {name: "Wakulima Market"})  MERGE (c)-[:LISTED_AT {price: 120, date: "2026-06-06"}]->(m)
MATCH (c:Crop {name: "Avocado"}),  (m:Market {name: "Kisumu Main Market"}) MERGE (c)-[:LISTED_AT {price: 90, date: "2026-06-06"}]->(m);


// ── STEP 7: BUYS relationships ───────────────────────────────

MATCH (b:Buyer {name: "Meghan Wares Ltd"}),      (c:Crop {name: "Tomatoes"}) MERGE (b)-[:BUYS]->(c)
MATCH (b:Buyer {name: "Meghan Wares Ltd"}),      (c:Crop {name: "Beans"})    MERGE (b)-[:BUYS]->(c)
MATCH (b:Buyer {name: "Meghan Wares Ltd"}),      (c:Crop {name: "Avocado"})  MERGE (b)-[:BUYS]->(c)
MATCH (b:Buyer {name: "Rift Valley Processors"}),(c:Crop {name: "Maize"})    MERGE (b)-[:BUYS]->(c)
MATCH (b:Buyer {name: "Rift Valley Processors"}),(c:Crop {name: "Potatoes"}) MERGE (b)-[:BUYS]->(c)
MATCH (b:Buyer {name: "Lake Basin Exporters"}),  (c:Crop {name: "Avocado"})  MERGE (b)-[:BUYS]->(c)
MATCH (b:Buyer {name: "Lake Basin Exporters"}),  (c:Crop {name: "Beans"})    MERGE (b)-[:BUYS]->(c);


// ── STEP 8: KNOWS relationships (Farm → Buyer network) ───────

MATCH (f:Farm {name: "Kamau Farm"}),   (b:Buyer {name: "Rift Valley Processors"}) MERGE (f)-[:KNOWS]->(b)
MATCH (f:Farm {name: "Wanjiku Farm"}), (b:Buyer {name: "Meghan Wares Ltd"})       MERGE (f)-[:KNOWS]->(b)
MATCH (f:Farm {name: "Auma Farm"}),    (b:Buyer {name: "Lake Basin Exporters"})   MERGE (f)-[:KNOWS]->(b)
MATCH (f:Farm {name: "Auma Farm"}),    (b:Buyer {name: "Meghan Wares Ltd"})       MERGE (f)-[:KNOWS]->(b)
MATCH (f:Farm {name: "Maina Farm"}),   (b:Buyer {name: "Rift Valley Processors"}) MERGE (f)-[:KNOWS]->(b);


// ── VERIFY ───────────────────────────────────────────────────

MATCH (n)-[r]->(m)
RETURN labels(n)[0] AS from, type(r) AS rel, labels(m)[0] AS to, count(*) AS count
ORDER BY from, rel;
