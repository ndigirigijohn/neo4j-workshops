// ============================================================
// Workshop 3 — Seed Data
// Kenya AI Challenge 2026 — Neo4j Track
//
// This script creates the Workshop 3 starting graph from scratch.
// It represents the FULLY REFACTORED state after Workshop 2:
//   - PricePoint nodes (not raw LISTED_AT relationship properties)
//   - Transaction intermediate nodes
//   - Indexes and constraints
//   - Crop descriptions (ready for vector embedding in the session)
//
// Safe to run on any Aura instance — uses MERGE throughout.
// The vector index is created here but embeddings are generated
// in the session using Python (sentence-transformers).
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


// ── STEP 2: Crops with descriptions ──────────────────────────

MERGE (maize:Crop {name: "Maize"})
SET maize.unit = "90kg bag",
    maize.description = "Staple grain crop, dried and sold in 90kg bags. Used for flour, animal feed, and ugali. Long shelf life, widely traded."

MERGE (tomatoes:Crop {name: "Tomatoes"})
SET tomatoes.unit = "kg",
    tomatoes.description = "Perishable red fruit vegetable, used in cooking and fresh salads. Sold by kg or crate. Requires refrigerated transport."

MERGE (beans:Crop {name: "Beans"})
SET beans.unit = "90kg bag",
    beans.description = "High-protein legume with long shelf life. Staple of Kenyan cooking, suitable for long-distance transport. Sold in 90kg bags."

MERGE (potatoes:Crop {name: "Potatoes"})
SET potatoes.unit = "50kg bag",
    potatoes.description = "Root vegetable grown in cool highland regions. Sold in 50kg bags. Moderate shelf life, widely consumed."

MERGE (avocado:Crop {name: "Avocado"})
SET avocado.unit = "kg",
    avocado.description = "Nutrient-dense fruit, high in healthy fats. Used fresh or for oil extraction. Strong export demand. Grows in warm highland areas."

MERGE (kale:Crop {name: "Sukuma Wiki"})
SET kale.unit = "bundle",
    kale.description = "Leafy green vegetable, vitamin-rich and highly perishable. Key ingredient in everyday Kenyan cooking. Sold in bundles at urban markets."

MERGE (sorghum:Crop {name: "Sorghum"})
SET sorghum.unit = "90kg bag",
    sorghum.description = "Drought-resistant cereal grain suited to arid and semi-arid regions. Used for flour, brewing, and animal feed. Long shelf life.";


// ── STEP 3: Markets ──────────────────────────────────────────

MERGE (wakulima:Market {name: "Wakulima Market"})    SET wakulima.county = "Nairobi",       wakulima.location = "Nairobi CBD"
MERGE (eldoret:Market {name: "Eldoret Wholesale"})   SET eldoret.county = "Uasin Gishu",    eldoret.location = "Eldoret Town"
MERGE (kisumu:Market {name: "Kisumu Main Market"})   SET kisumu.county = "Kisumu",           kisumu.location = "Kisumu Town"
MERGE (nakuru:Market {name: "Nakuru Market"})        SET nakuru.county = "Nakuru",           nakuru.location = "Nakuru Town"
MERGE (kitale:Market {name: "Kitale Market"})        SET kitale.county = "Trans-Nzoia",      kitale.location = "Kitale Town";


// ── STEP 4: Buyers ───────────────────────────────────────────

MERGE (meghan:Buyer {name: "Meghan Wares Ltd"})
SET meghan.county = "Nairobi", meghan.type = "Wholesaler"

MERGE (rift:Buyer {name: "Rift Valley Processors"})
SET rift.county = "Uasin Gishu", rift.type = "Processor"

MERGE (lake:Buyer {name: "Lake Basin Exporters"})
SET lake.county = "Kisumu", lake.type = "Exporter"

MERGE (greenleaf:Buyer {name: "Greenleaf Hotels"})
SET greenleaf.county = "Nairobi", greenleaf.type = "Hospitality";


// ── STEP 5: Specific buyer labels ────────────────────────────

MATCH (b:Buyer {name: "Meghan Wares Ltd"})      SET b:Wholesaler
MATCH (b:Buyer {name: "Rift Valley Processors"}) SET b:Processor
MATCH (b:Buyer {name: "Lake Basin Exporters"})   SET b:Exporter
MATCH (b:Buyer {name: "Greenleaf Hotels"})       SET b:Hospitality;


// ── STEP 6: GROWS relationships ──────────────────────────────

MATCH (f:Farm {name: "Kamau Farm"}),   (c:Crop {name: "Maize"})       MERGE (f)-[:GROWS]->(c);
MATCH (f:Farm {name: "Kamau Farm"}),   (c:Crop {name: "Tomatoes"})    MERGE (f)-[:GROWS]->(c);
MATCH (f:Farm {name: "Kamau Farm"}),   (c:Crop {name: "Potatoes"})    MERGE (f)-[:GROWS]->(c);
MATCH (f:Farm {name: "Wanjiku Farm"}), (c:Crop {name: "Maize"})       MERGE (f)-[:GROWS]->(c);
MATCH (f:Farm {name: "Wanjiku Farm"}), (c:Crop {name: "Beans"})       MERGE (f)-[:GROWS]->(c);
MATCH (f:Farm {name: "Wanjiku Farm"}), (c:Crop {name: "Sukuma Wiki"}) MERGE (f)-[:GROWS]->(c);
MATCH (f:Farm {name: "Auma Farm"}),    (c:Crop {name: "Tomatoes"})    MERGE (f)-[:GROWS]->(c);
MATCH (f:Farm {name: "Auma Farm"}),    (c:Crop {name: "Beans"})       MERGE (f)-[:GROWS]->(c);
MATCH (f:Farm {name: "Auma Farm"}),    (c:Crop {name: "Avocado"})     MERGE (f)-[:GROWS]->(c);
MATCH (f:Farm {name: "Maina Farm"}),   (c:Crop {name: "Maize"})       MERGE (f)-[:GROWS]->(c);
MATCH (f:Farm {name: "Maina Farm"}),   (c:Crop {name: "Potatoes"})    MERGE (f)-[:GROWS]->(c);
MATCH (f:Farm {name: "Nafula Farm"}),  (c:Crop {name: "Maize"})       MERGE (f)-[:GROWS]->(c);
MATCH (f:Farm {name: "Nafula Farm"}),  (c:Crop {name: "Beans"})       MERGE (f)-[:GROWS]->(c);
MATCH (f:Farm {name: "Nafula Farm"}),  (c:Crop {name: "Sorghum"})     MERGE (f)-[:GROWS]->(c);


// ── STEP 7: PricePoint nodes and LISTED_IN relationships ─────

MATCH (c:Crop {name: "Maize"}),       (m:Market {name: "Wakulima Market"})    MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Maize"}),       (m:Market {name: "Eldoret Wholesale"})  MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Maize"}),       (m:Market {name: "Kisumu Main Market"}) MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Maize"}),       (m:Market {name: "Nakuru Market"})      MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Maize"}),       (m:Market {name: "Kitale Market"})      MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Tomatoes"}),    (m:Market {name: "Wakulima Market"})    MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Tomatoes"}),    (m:Market {name: "Kisumu Main Market"}) MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Tomatoes"}),    (m:Market {name: "Nakuru Market"})      MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Tomatoes"}),    (m:Market {name: "Eldoret Wholesale"})  MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Beans"}),       (m:Market {name: "Wakulima Market"})    MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Beans"}),       (m:Market {name: "Eldoret Wholesale"})  MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Beans"}),       (m:Market {name: "Kitale Market"})      MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Potatoes"}),    (m:Market {name: "Wakulima Market"})    MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Potatoes"}),    (m:Market {name: "Nakuru Market"})      MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Avocado"}),     (m:Market {name: "Wakulima Market"})    MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Avocado"}),     (m:Market {name: "Kisumu Main Market"}) MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Sukuma Wiki"}), (m:Market {name: "Wakulima Market"})    MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Sukuma Wiki"}), (m:Market {name: "Kisumu Main Market"}) MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Sorghum"}),     (m:Market {name: "Kitale Market"})      MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Sorghum"}),     (m:Market {name: "Eldoret Wholesale"})  MERGE (c)-[:LISTED_IN]->(m);

MATCH (m:Market {name: "Wakulima Market"})
MERGE (m)-[:HAS_PRICE]->(p1:PricePoint {cropType:"Maize",    price:2400, unit:"90kg bag", recordedAt:date("2026-06-06"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(p2:PricePoint {cropType:"Tomatoes", price:110,  unit:"kg",       recordedAt:date("2026-06-06"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(p3:PricePoint {cropType:"Beans",    price:7200, unit:"90kg bag", recordedAt:date("2026-06-06"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(p4:PricePoint {cropType:"Potatoes", price:2600, unit:"50kg bag", recordedAt:date("2026-06-06"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(p5:PricePoint {cropType:"Avocado",  price:120,  unit:"kg",       recordedAt:date("2026-06-06"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(p6:PricePoint {cropType:"Sukuma Wiki", price:30, unit:"bundle",  recordedAt:date("2026-06-06"), source:"seed"});

MATCH (m:Market {name: "Eldoret Wholesale"})
MERGE (m)-[:HAS_PRICE]->(p1:PricePoint {cropType:"Maize",    price:3100, unit:"90kg bag", recordedAt:date("2026-06-06"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(p2:PricePoint {cropType:"Tomatoes", price:100,  unit:"kg",       recordedAt:date("2026-06-06"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(p3:PricePoint {cropType:"Beans",    price:8500, unit:"90kg bag", recordedAt:date("2026-06-06"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(p4:PricePoint {cropType:"Potatoes", price:2400, unit:"50kg bag", recordedAt:date("2026-06-06"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(p5:PricePoint {cropType:"Sorghum",  price:1800, unit:"90kg bag", recordedAt:date("2026-06-06"), source:"seed"});

MATCH (m:Market {name: "Kisumu Main Market"})
MERGE (m)-[:HAS_PRICE]->(p1:PricePoint {cropType:"Maize",      price:2600, unit:"90kg bag", recordedAt:date("2026-06-06"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(p2:PricePoint {cropType:"Tomatoes",   price:85,   unit:"kg",       recordedAt:date("2026-06-06"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(p3:PricePoint {cropType:"Beans",      price:7500, unit:"90kg bag", recordedAt:date("2026-06-06"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(p4:PricePoint {cropType:"Avocado",    price:90,   unit:"kg",       recordedAt:date("2026-06-06"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(p5:PricePoint {cropType:"Sukuma Wiki", price:25,   unit:"bundle",   recordedAt:date("2026-06-06"), source:"seed"});

MATCH (m:Market {name: "Nakuru Market"})
MERGE (m)-[:HAS_PRICE]->(p1:PricePoint {cropType:"Maize",    price:2900, unit:"90kg bag", recordedAt:date("2026-06-06"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(p2:PricePoint {cropType:"Tomatoes", price:95,   unit:"kg",       recordedAt:date("2026-06-06"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(p3:PricePoint {cropType:"Beans",    price:7500, unit:"90kg bag", recordedAt:date("2026-06-06"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(p4:PricePoint {cropType:"Potatoes", price:2200, unit:"50kg bag", recordedAt:date("2026-06-06"), source:"seed"});

MATCH (m:Market {name: "Kitale Market"})
MERGE (m)-[:HAS_PRICE]->(p1:PricePoint {cropType:"Maize",   price:2800, unit:"90kg bag", recordedAt:date("2026-06-06"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(p2:PricePoint {cropType:"Beans",   price:7800, unit:"90kg bag", recordedAt:date("2026-06-06"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(p3:PricePoint {cropType:"Sorghum", price:1900, unit:"90kg bag", recordedAt:date("2026-06-06"), source:"seed"});


// ── STEP 8: Buyers and BUYS relationships ────────────────────

MATCH (b:Buyer {name: "Meghan Wares Ltd"}),       (c:Crop {name: "Tomatoes"})    MERGE (b)-[:BUYS]->(c);
MATCH (b:Buyer {name: "Meghan Wares Ltd"}),       (c:Crop {name: "Beans"})       MERGE (b)-[:BUYS]->(c);
MATCH (b:Buyer {name: "Meghan Wares Ltd"}),       (c:Crop {name: "Avocado"})     MERGE (b)-[:BUYS]->(c);
MATCH (b:Buyer {name: "Rift Valley Processors"}), (c:Crop {name: "Maize"})       MERGE (b)-[:BUYS]->(c);
MATCH (b:Buyer {name: "Rift Valley Processors"}), (c:Crop {name: "Potatoes"})    MERGE (b)-[:BUYS]->(c);
MATCH (b:Buyer {name: "Lake Basin Exporters"}),   (c:Crop {name: "Avocado"})     MERGE (b)-[:BUYS]->(c);
MATCH (b:Buyer {name: "Lake Basin Exporters"}),   (c:Crop {name: "Beans"})       MERGE (b)-[:BUYS]->(c);
MATCH (b:Buyer {name: "Greenleaf Hotels"}),       (c:Crop {name: "Tomatoes"})    MERGE (b)-[:BUYS]->(c);
MATCH (b:Buyer {name: "Greenleaf Hotels"}),       (c:Crop {name: "Sukuma Wiki"}) MERGE (b)-[:BUYS]->(c);
MATCH (b:Buyer {name: "Greenleaf Hotels"}),       (c:Crop {name: "Avocado"})     MERGE (b)-[:BUYS]->(c);


// ── STEP 9: KNOWS relationships (Farm → Buyer) ───────────────

MATCH (f:Farm {name: "Kamau Farm"}),   (b:Buyer {name: "Rift Valley Processors"}) MERGE (f)-[:KNOWS]->(b);
MATCH (f:Farm {name: "Wanjiku Farm"}), (b:Buyer {name: "Meghan Wares Ltd"})       MERGE (f)-[:KNOWS]->(b);
MATCH (f:Farm {name: "Auma Farm"}),    (b:Buyer {name: "Lake Basin Exporters"})   MERGE (f)-[:KNOWS]->(b);
MATCH (f:Farm {name: "Auma Farm"}),    (b:Buyer {name: "Meghan Wares Ltd"})       MERGE (f)-[:KNOWS]->(b);
MATCH (f:Farm {name: "Maina Farm"}),   (b:Buyer {name: "Rift Valley Processors"}) MERGE (f)-[:KNOWS]->(b);
MATCH (f:Farm {name: "Wanjiku Farm"}), (b:Buyer {name: "Greenleaf Hotels"})       MERGE (f)-[:KNOWS]->(b);


// ── STEP 10: Transaction intermediate nodes ──────────────────

MATCH (b:Buyer {name: "Rift Valley Processors"}), (c:Crop {name: "Maize"})
MATCH (f:Farm)-[:GROWS]->(c)
MERGE (t:Transaction {id: "txn-rvp-maize-001"})
SET t.status = "completed", t.createdAt = datetime("2026-05-15T10:00:00")
MERGE (f)-[:HAS_TRANSACTION]->(t)
MERGE (t)-[:INVOLVES]->(b)
MERGE (t)-[:FOR_CROP]->(c);

MATCH (b:Buyer {name: "Meghan Wares Ltd"}), (c:Crop {name: "Beans"})
MATCH (f:Farm {name: "Wanjiku Farm"})-[:GROWS]->(c)
MERGE (t:Transaction {id: "txn-mw-beans-001"})
SET t.status = "pending", t.createdAt = datetime("2026-06-01T09:00:00")
MERGE (f)-[:HAS_TRANSACTION]->(t)
MERGE (t)-[:INVOLVES]->(b)
MERGE (t)-[:FOR_CROP]->(c);

MATCH (b:Buyer {name: "Lake Basin Exporters"}), (c:Crop {name: "Avocado"})
MATCH (f:Farm {name: "Auma Farm"})-[:GROWS]->(c)
MERGE (t:Transaction {id: "txn-lbe-avocado-001"})
SET t.status = "completed", t.createdAt = datetime("2026-05-20T14:00:00")
MERGE (f)-[:HAS_TRANSACTION]->(t)
MERGE (t)-[:INVOLVES]->(b)
MERGE (t)-[:FOR_CROP]->(c);

MATCH (b:Buyer {name: "Greenleaf Hotels"}), (c:Crop {name: "Sukuma Wiki"})
MATCH (f:Farm {name: "Wanjiku Farm"})-[:GROWS]->(c)
MERGE (t:Transaction {id: "txn-gh-kale-001"})
SET t.status = "pending", t.createdAt = datetime("2026-06-03T08:00:00")
MERGE (f)-[:HAS_TRANSACTION]->(t)
MERGE (t)-[:INVOLVES]->(b)
MERGE (t)-[:FOR_CROP]->(c);


// ── STEP 11: Indexes and constraints ─────────────────────────

CREATE INDEX farm_name        IF NOT EXISTS FOR (f:Farm)        ON (f.name);
CREATE INDEX crop_name        IF NOT EXISTS FOR (c:Crop)        ON (c.name);
CREATE INDEX market_county    IF NOT EXISTS FOR (m:Market)      ON (m.county);
CREATE INDEX buyer_name       IF NOT EXISTS FOR (b:Buyer)       ON (b.name);
CREATE INDEX price_crop_date  IF NOT EXISTS FOR (p:PricePoint)  ON (p.cropType, p.recordedAt);

CREATE CONSTRAINT market_name_unique IF NOT EXISTS
  FOR (m:Market) REQUIRE m.name IS UNIQUE;


// ── STEP 12: Vector index (empty — embeddings set via Python) ─

CREATE VECTOR INDEX crop_embeddings IF NOT EXISTS
FOR (c:Crop) ON (c.embedding)
OPTIONS {
  indexConfig: {
    `vector.dimensions`: 384,
    `vector.similarity_function`: 'cosine'
  }
};


// ── VERIFY ───────────────────────────────────────────────────

MATCH (n)-[r]->(m)
RETURN labels(n)[0] AS from, type(r) AS rel, labels(m)[0] AS to, count(*) AS count
ORDER BY from, rel;
