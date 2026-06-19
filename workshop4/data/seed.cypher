// ============================================================
// Workshop 4 — Seed Data
// Kenya AI Challenge 2026 — Neo4j Track
//
// This script creates the Workshop 4 starting graph from scratch.
// It represents the fully built state after Workshops 1–3:
//   - Refactored graph (PricePoint nodes, Transaction nodes)
//   - Indexes and constraints
//   - Crop descriptions (for semantic search context)
//   - Specific buyer labels (Wholesaler, Processor, Exporter)
//   - A larger, richer network so GDS algorithms yield interesting results
//
// NOTE: GDS (Graph Data Science) requires Neo4j AuraDS (not AuraDB Free)
// or a local Neo4j instance with the GDS plugin installed.
// If neither is available, use the GraphAcademy Sandbox (link in handout).
//
// Safe to run on any instance — MERGE throughout.
// The vector index is created but embeddings require Python (Workshop 3).
// ============================================================


// ── STEP 1: Farms — expanded network for richer GDS results ──

MERGE (kamau:Farm {name: "Kamau Farm"})
SET kamau.owner = "Kamau Njoroge", kamau.county = "Nakuru", kamau.location = "Nakuru"

MERGE (wanjiku:Farm {name: "Wanjiku Farm"})
SET wanjiku.owner = "Wanjiku Mwangi", wanjiku.county = "Kirinyaga", wanjiku.location = "Kirinyaga"

MERGE (auma:Farm {name: "Auma Farm"})
SET auma.owner = "Auma Otieno", auma.county = "Kisumu", auma.location = "Kisumu"

MERGE (maina:Farm {name: "Maina Farm"})
SET maina.owner = "Maina Kariuki", maina.county = "Uasin Gishu", maina.location = "Eldoret"

MERGE (nafula:Farm {name: "Nafula Farm"})
SET nafula.owner = "Nafula Wekesa", nafula.county = "Trans-Nzoia", nafula.location = "Kitale"

MERGE (otieno:Farm {name: "Otieno Farm"})
SET otieno.owner = "Otieno Odhiambo", otieno.county = "Kisumu", otieno.location = "Kisumu"

MERGE (chebet:Farm {name: "Chebet Farm"})
SET chebet.owner = "Chebet Rono", chebet.county = "Uasin Gishu", chebet.location = "Eldoret"

MERGE (mutua:Farm {name: "Mutua Farm"})
SET mutua.owner = "Mutua Kimani", mutua.county = "Machakos", mutua.location = "Machakos"

MERGE (halima:Farm {name: "Halima Farm"})
SET halima.owner = "Halima Abdi", halima.county = "Garissa", halima.location = "Garissa"

MERGE (ndung:Farm {name: "Ndung'u Farm"})
SET ndung.owner = "Ndung'u Waithaka", ndung.county = "Murang'a", ndung.location = "Murang'a";


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
    sorghum.description = "Drought-resistant cereal grain suited to arid and semi-arid regions. Used for flour, brewing, and animal feed. Long shelf life."

MERGE (mango:Crop {name: "Mango"})
SET mango.unit = "kg",
    mango.description = "Tropical stone fruit with seasonal availability. High sugar content, good for fresh consumption and juice processing. Export demand in premium varieties."

MERGE (capsicum:Crop {name: "Capsicum"})
SET capsicum.unit = "kg",
    capsicum.description = "Colourful pepper variety, used in salads, cooking, and export. High value per kg. Grown in warm regions with good irrigation.";


// ── STEP 3: Markets ──────────────────────────────────────────

MERGE (wakulima:Market {name: "Wakulima Market"})     SET wakulima.county = "Nairobi",      wakulima.location = "Nairobi CBD"
MERGE (eldoret:Market {name: "Eldoret Wholesale"})    SET eldoret.county = "Uasin Gishu",   eldoret.location = "Eldoret Town"
MERGE (kisumu:Market {name: "Kisumu Main Market"})    SET kisumu.county = "Kisumu",          kisumu.location = "Kisumu Town"
MERGE (nakuru:Market {name: "Nakuru Market"})         SET nakuru.county = "Nakuru",          nakuru.location = "Nakuru Town"
MERGE (kitale:Market {name: "Kitale Market"})         SET kitale.county = "Trans-Nzoia",     kitale.location = "Kitale Town"
MERGE (machakos:Market {name: "Machakos Market"})     SET machakos.county = "Machakos",      machakos.location = "Machakos Town"
MERGE (mombasa:Market {name: "Mombasa Wholesale"})    SET mombasa.county = "Mombasa",        mombasa.location = "Mombasa Port";


// ── STEP 4: Buyers with specific labels ──────────────────────

MERGE (meghan:Buyer {name: "Meghan Wares Ltd"})
SET meghan.county = "Nairobi", meghan.type = "Wholesaler"

MERGE (rift:Buyer {name: "Rift Valley Processors"})
SET rift.county = "Uasin Gishu", rift.type = "Processor"

MERGE (lake:Buyer {name: "Lake Basin Exporters"})
SET lake.county = "Kisumu", lake.type = "Exporter"

MERGE (greenleaf:Buyer {name: "Greenleaf Hotels"})
SET greenleaf.county = "Nairobi", greenleaf.type = "Hospitality"

MERGE (coastpacker:Buyer {name: "Coast Packers"})
SET coastpacker.county = "Mombasa", coastpacker.type = "Exporter";

MATCH (b:Buyer {name: "Meghan Wares Ltd"})       SET b:Wholesaler
MATCH (b:Buyer {name: "Rift Valley Processors"}) SET b:Processor
MATCH (b:Buyer {name: "Lake Basin Exporters"})   SET b:Exporter
MATCH (b:Buyer {name: "Greenleaf Hotels"})       SET b:Hospitality
MATCH (b:Buyer {name: "Coast Packers"})          SET b:Exporter;


// ── STEP 5: GROWS relationships ──────────────────────────────

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
MATCH (f:Farm {name: "Otieno Farm"}),  (c:Crop {name: "Tomatoes"})    MERGE (f)-[:GROWS]->(c);
MATCH (f:Farm {name: "Otieno Farm"}),  (c:Crop {name: "Avocado"})     MERGE (f)-[:GROWS]->(c);
MATCH (f:Farm {name: "Chebet Farm"}),  (c:Crop {name: "Maize"})       MERGE (f)-[:GROWS]->(c);
MATCH (f:Farm {name: "Chebet Farm"}),  (c:Crop {name: "Potatoes"})    MERGE (f)-[:GROWS]->(c);
MATCH (f:Farm {name: "Mutua Farm"}),   (c:Crop {name: "Mango"})       MERGE (f)-[:GROWS]->(c);
MATCH (f:Farm {name: "Mutua Farm"}),   (c:Crop {name: "Capsicum"})    MERGE (f)-[:GROWS]->(c);
MATCH (f:Farm {name: "Halima Farm"}),  (c:Crop {name: "Sorghum"})     MERGE (f)-[:GROWS]->(c);
// Halima Farm grows only Sorghum — no SELLS_AT or KNOWS, used to demonstrate WCC isolation
MATCH (f:Farm {name: "Ndung'u Farm"}), (c:Crop {name: "Beans"})       MERGE (f)-[:GROWS]->(c);
MATCH (f:Farm {name: "Ndung'u Farm"}), (c:Crop {name: "Avocado"})     MERGE (f)-[:GROWS]->(c);


// ── STEP 6: LISTED_IN and PricePoint nodes ───────────────────

MATCH (c:Crop {name: "Maize"}),       (m:Market {name: "Wakulima Market"})    MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Maize"}),       (m:Market {name: "Eldoret Wholesale"})  MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Maize"}),       (m:Market {name: "Kisumu Main Market"}) MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Maize"}),       (m:Market {name: "Nakuru Market"})      MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Maize"}),       (m:Market {name: "Kitale Market"})      MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Tomatoes"}),    (m:Market {name: "Wakulima Market"})    MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Tomatoes"}),    (m:Market {name: "Kisumu Main Market"}) MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Tomatoes"}),    (m:Market {name: "Nakuru Market"})      MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Tomatoes"}),    (m:Market {name: "Machakos Market"})    MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Beans"}),       (m:Market {name: "Wakulima Market"})    MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Beans"}),       (m:Market {name: "Eldoret Wholesale"})  MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Beans"}),       (m:Market {name: "Kitale Market"})      MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Potatoes"}),    (m:Market {name: "Wakulima Market"})    MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Potatoes"}),    (m:Market {name: "Nakuru Market"})      MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Avocado"}),     (m:Market {name: "Wakulima Market"})    MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Avocado"}),     (m:Market {name: "Kisumu Main Market"}) MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Avocado"}),     (m:Market {name: "Mombasa Wholesale"})  MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Sorghum"}),     (m:Market {name: "Kitale Market"})      MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Sorghum"}),     (m:Market {name: "Eldoret Wholesale"})  MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Mango"}),       (m:Market {name: "Machakos Market"})    MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Mango"}),       (m:Market {name: "Mombasa Wholesale"})  MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Capsicum"}),    (m:Market {name: "Wakulima Market"})    MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Sukuma Wiki"}), (m:Market {name: "Wakulima Market"})    MERGE (c)-[:LISTED_IN]->(m);
MATCH (c:Crop {name: "Sukuma Wiki"}), (m:Market {name: "Kisumu Main Market"}) MERGE (c)-[:LISTED_IN]->(m);

MATCH (m:Market {name: "Wakulima Market"})
MERGE (m)-[:HAS_PRICE]->(:PricePoint {cropType:"Maize",      price:2400, unit:"90kg bag",  recordedAt:date("2026-06-13"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(:PricePoint {cropType:"Tomatoes",   price:110,  unit:"kg",        recordedAt:date("2026-06-13"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(:PricePoint {cropType:"Beans",      price:7200, unit:"90kg bag",  recordedAt:date("2026-06-13"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(:PricePoint {cropType:"Potatoes",   price:2600, unit:"50kg bag",  recordedAt:date("2026-06-13"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(:PricePoint {cropType:"Avocado",    price:120,  unit:"kg",        recordedAt:date("2026-06-13"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(:PricePoint {cropType:"Sukuma Wiki",price:30,   unit:"bundle",    recordedAt:date("2026-06-13"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(:PricePoint {cropType:"Capsicum",   price:180,  unit:"kg",        recordedAt:date("2026-06-13"), source:"seed"});

MATCH (m:Market {name: "Eldoret Wholesale"})
MERGE (m)-[:HAS_PRICE]->(:PricePoint {cropType:"Maize",    price:3100, unit:"90kg bag",  recordedAt:date("2026-06-13"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(:PricePoint {cropType:"Beans",    price:8500, unit:"90kg bag",  recordedAt:date("2026-06-13"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(:PricePoint {cropType:"Potatoes", price:2400, unit:"50kg bag",  recordedAt:date("2026-06-13"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(:PricePoint {cropType:"Sorghum",  price:1800, unit:"90kg bag",  recordedAt:date("2026-06-13"), source:"seed"});

MATCH (m:Market {name: "Kisumu Main Market"})
MERGE (m)-[:HAS_PRICE]->(:PricePoint {cropType:"Maize",       price:2600, unit:"90kg bag",  recordedAt:date("2026-06-13"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(:PricePoint {cropType:"Tomatoes",    price:85,   unit:"kg",        recordedAt:date("2026-06-13"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(:PricePoint {cropType:"Avocado",     price:90,   unit:"kg",        recordedAt:date("2026-06-13"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(:PricePoint {cropType:"Sukuma Wiki",  price:25,   unit:"bundle",    recordedAt:date("2026-06-13"), source:"seed"});

MATCH (m:Market {name: "Nakuru Market"})
MERGE (m)-[:HAS_PRICE]->(:PricePoint {cropType:"Maize",    price:2900, unit:"90kg bag",  recordedAt:date("2026-06-13"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(:PricePoint {cropType:"Tomatoes", price:95,   unit:"kg",        recordedAt:date("2026-06-13"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(:PricePoint {cropType:"Potatoes", price:2200, unit:"50kg bag",  recordedAt:date("2026-06-13"), source:"seed"});

MATCH (m:Market {name: "Kitale Market"})
MERGE (m)-[:HAS_PRICE]->(:PricePoint {cropType:"Maize",   price:2800, unit:"90kg bag",  recordedAt:date("2026-06-13"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(:PricePoint {cropType:"Beans",   price:7800, unit:"90kg bag",  recordedAt:date("2026-06-13"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(:PricePoint {cropType:"Sorghum", price:1900, unit:"90kg bag",  recordedAt:date("2026-06-13"), source:"seed"});

MATCH (m:Market {name: "Machakos Market"})
MERGE (m)-[:HAS_PRICE]->(:PricePoint {cropType:"Tomatoes", price:90,  unit:"kg",        recordedAt:date("2026-06-13"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(:PricePoint {cropType:"Mango",    price:55,  unit:"kg",        recordedAt:date("2026-06-13"), source:"seed"});

MATCH (m:Market {name: "Mombasa Wholesale"})
MERGE (m)-[:HAS_PRICE]->(:PricePoint {cropType:"Avocado", price:150, unit:"kg",         recordedAt:date("2026-06-13"), source:"seed"})
MERGE (m)-[:HAS_PRICE]->(:PricePoint {cropType:"Mango",   price:70,  unit:"kg",         recordedAt:date("2026-06-13"), source:"seed"});


// ── STEP 7: Buyers, BUYS and KNOWS ───────────────────────────

MATCH (b:Buyer {name: "Meghan Wares Ltd"}),       (c:Crop {name: "Tomatoes"})    MERGE (b)-[:BUYS]->(c);
MATCH (b:Buyer {name: "Meghan Wares Ltd"}),       (c:Crop {name: "Beans"})       MERGE (b)-[:BUYS]->(c);
MATCH (b:Buyer {name: "Meghan Wares Ltd"}),       (c:Crop {name: "Avocado"})     MERGE (b)-[:BUYS]->(c);
MATCH (b:Buyer {name: "Rift Valley Processors"}), (c:Crop {name: "Maize"})       MERGE (b)-[:BUYS]->(c);
MATCH (b:Buyer {name: "Rift Valley Processors"}), (c:Crop {name: "Potatoes"})    MERGE (b)-[:BUYS]->(c);
MATCH (b:Buyer {name: "Rift Valley Processors"}), (c:Crop {name: "Sorghum"})     MERGE (b)-[:BUYS]->(c);
MATCH (b:Buyer {name: "Lake Basin Exporters"}),   (c:Crop {name: "Avocado"})     MERGE (b)-[:BUYS]->(c);
MATCH (b:Buyer {name: "Lake Basin Exporters"}),   (c:Crop {name: "Beans"})       MERGE (b)-[:BUYS]->(c);
MATCH (b:Buyer {name: "Greenleaf Hotels"}),       (c:Crop {name: "Tomatoes"})    MERGE (b)-[:BUYS]->(c);
MATCH (b:Buyer {name: "Greenleaf Hotels"}),       (c:Crop {name: "Sukuma Wiki"}) MERGE (b)-[:BUYS]->(c);
MATCH (b:Buyer {name: "Greenleaf Hotels"}),       (c:Crop {name: "Avocado"})     MERGE (b)-[:BUYS]->(c);
MATCH (b:Buyer {name: "Coast Packers"}),          (c:Crop {name: "Avocado"})     MERGE (b)-[:BUYS]->(c);
MATCH (b:Buyer {name: "Coast Packers"}),          (c:Crop {name: "Mango"})       MERGE (b)-[:BUYS]->(c);

MATCH (f:Farm {name: "Kamau Farm"}),   (b:Buyer {name: "Rift Valley Processors"}) MERGE (f)-[:KNOWS]->(b);
MATCH (f:Farm {name: "Wanjiku Farm"}), (b:Buyer {name: "Meghan Wares Ltd"})       MERGE (f)-[:KNOWS]->(b);
MATCH (f:Farm {name: "Wanjiku Farm"}), (b:Buyer {name: "Greenleaf Hotels"})       MERGE (f)-[:KNOWS]->(b);
MATCH (f:Farm {name: "Auma Farm"}),    (b:Buyer {name: "Lake Basin Exporters"})   MERGE (f)-[:KNOWS]->(b);
MATCH (f:Farm {name: "Auma Farm"}),    (b:Buyer {name: "Meghan Wares Ltd"})       MERGE (f)-[:KNOWS]->(b);
MATCH (f:Farm {name: "Maina Farm"}),   (b:Buyer {name: "Rift Valley Processors"}) MERGE (f)-[:KNOWS]->(b);
MATCH (f:Farm {name: "Otieno Farm"}),  (b:Buyer {name: "Lake Basin Exporters"})   MERGE (f)-[:KNOWS]->(b);
MATCH (f:Farm {name: "Chebet Farm"}),  (b:Buyer {name: "Rift Valley Processors"}) MERGE (f)-[:KNOWS]->(b);
MATCH (f:Farm {name: "Mutua Farm"}),   (b:Buyer {name: "Coast Packers"})          MERGE (f)-[:KNOWS]->(b);
MATCH (f:Farm {name: "Ndung'u Farm"}), (b:Buyer {name: "Meghan Wares Ltd"})       MERGE (f)-[:KNOWS]->(b);
// Halima Farm has NO KNOWS relationships — isolated for WCC demonstration


// ── STEP 8: SELLS_AT relationships (for GDS projection) ──────
// Explicit SELLS_AT complements LISTED_IN for GDS analysis.

MATCH (f:Farm {name: "Kamau Farm"}),   (m:Market {name: "Nakuru Market"})      MERGE (f)-[:SELLS_AT]->(m);
MATCH (f:Farm {name: "Kamau Farm"}),   (m:Market {name: "Wakulima Market"})    MERGE (f)-[:SELLS_AT]->(m);
MATCH (f:Farm {name: "Wanjiku Farm"}), (m:Market {name: "Wakulima Market"})    MERGE (f)-[:SELLS_AT]->(m);
MATCH (f:Farm {name: "Wanjiku Farm"}), (m:Market {name: "Kisumu Main Market"}) MERGE (f)-[:SELLS_AT]->(m);
MATCH (f:Farm {name: "Auma Farm"}),    (m:Market {name: "Kisumu Main Market"}) MERGE (f)-[:SELLS_AT]->(m);
MATCH (f:Farm {name: "Auma Farm"}),    (m:Market {name: "Wakulima Market"})    MERGE (f)-[:SELLS_AT]->(m);
MATCH (f:Farm {name: "Maina Farm"}),   (m:Market {name: "Eldoret Wholesale"})  MERGE (f)-[:SELLS_AT]->(m);
MATCH (f:Farm {name: "Nafula Farm"}),  (m:Market {name: "Kitale Market"})      MERGE (f)-[:SELLS_AT]->(m);
MATCH (f:Farm {name: "Nafula Farm"}),  (m:Market {name: "Eldoret Wholesale"})  MERGE (f)-[:SELLS_AT]->(m);
MATCH (f:Farm {name: "Otieno Farm"}),  (m:Market {name: "Kisumu Main Market"}) MERGE (f)-[:SELLS_AT]->(m);
MATCH (f:Farm {name: "Chebet Farm"}),  (m:Market {name: "Eldoret Wholesale"})  MERGE (f)-[:SELLS_AT]->(m);
MATCH (f:Farm {name: "Mutua Farm"}),   (m:Market {name: "Machakos Market"})    MERGE (f)-[:SELLS_AT]->(m);
MATCH (f:Farm {name: "Mutua Farm"}),   (m:Market {name: "Mombasa Wholesale"})  MERGE (f)-[:SELLS_AT]->(m);
MATCH (f:Farm {name: "Ndung'u Farm"}), (m:Market {name: "Wakulima Market"})    MERGE (f)-[:SELLS_AT]->(m);
// Halima Farm has no SELLS_AT — isolated for WCC demonstration


// ── STEP 9: Transaction nodes ─────────────────────────────────

MATCH (b:Buyer {name: "Rift Valley Processors"}), (c:Crop {name: "Maize"})
MATCH (f:Farm {name: "Kamau Farm"})-[:GROWS]->(c)
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

MATCH (b:Buyer {name: "Coast Packers"}), (c:Crop {name: "Mango"})
MATCH (f:Farm {name: "Mutua Farm"})-[:GROWS]->(c)
MERGE (t:Transaction {id: "txn-cp-mango-001"})
SET t.status = "completed", t.createdAt = datetime("2026-06-05T11:00:00")
MERGE (f)-[:HAS_TRANSACTION]->(t)
MERGE (t)-[:INVOLVES]->(b)
MERGE (t)-[:FOR_CROP]->(c);


// ── STEP 10: Indexes and constraints ─────────────────────────

CREATE INDEX farm_name        IF NOT EXISTS FOR (f:Farm)       ON (f.name);
CREATE INDEX crop_name        IF NOT EXISTS FOR (c:Crop)       ON (c.name);
CREATE INDEX market_county    IF NOT EXISTS FOR (m:Market)     ON (m.county);
CREATE INDEX buyer_name       IF NOT EXISTS FOR (b:Buyer)      ON (b.name);
CREATE INDEX price_crop_date  IF NOT EXISTS FOR (p:PricePoint) ON (p.cropType, p.recordedAt);

CREATE CONSTRAINT market_name_unique IF NOT EXISTS
  FOR (m:Market) REQUIRE m.name IS UNIQUE;


// ── STEP 11: Vector index (empty — embeddings require Python) ─

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
