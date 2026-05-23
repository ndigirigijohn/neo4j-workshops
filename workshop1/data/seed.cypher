// ============================================================
// Workshop 1 — Seed Data
// Kenya AI Challenge 2026 — Neo4j Track
// Run this in Neo4j Browser to create the mini MarketGraph
// ============================================================

// --- Farmers ---
CREATE (wanjiku:Farmer {name: "Wanjiku Mwangi", county: "Kirinyaga", phone: "+254712345678"})
CREATE (kamau:Farmer {name: "Kamau Njoroge", county: "Nakuru", phone: "+254723456789"})
CREATE (auma:Farmer {name: "Auma Otieno", county: "Kisumu", phone: "+254734567890"})
CREATE (maina:Farmer {name: "Maina Kariuki", county: "Uasin Gishu", phone: "+254745678901"})
CREATE (nafula:Farmer {name: "Nafula Wekesa", county: "Trans-Nzoia", phone: "+254756789012"})

// --- Crops ---
CREATE (maize:Crop {name: "Maize", unit: "90kg bag"})
CREATE (tomatoes:Crop {name: "Tomatoes", unit: "kg"})
CREATE (beans:Crop {name: "Beans", unit: "90kg bag"})
CREATE (potatoes:Crop {name: "Potatoes", unit: "50kg bag"})
CREATE (avocado:Crop {name: "Avocado", unit: "kg"})

// --- Markets ---
CREATE (wakulima:Market {name: "Wakulima Market", county: "Nairobi"})
CREATE (eldoret:Market {name: "Eldoret Wholesale", county: "Uasin Gishu"})
CREATE (kisumu:Market {name: "Kisumu Main Market", county: "Kisumu"})
CREATE (nakuru:Market {name: "Nakuru Market", county: "Nakuru"})
CREATE (kitale:Market {name: "Kitale Market", county: "Trans-Nzoia"})

// --- Buyers ---
CREATE (meghan:Buyer {name: "Meghan Wares Ltd", county: "Nairobi"})
CREATE (rift:Buyer {name: "Rift Valley Processors", county: "Uasin Gishu"})
CREATE (lake:Buyer {name: "Lake Basin Exporters", county: "Kisumu"})

// --- GROWS relationships ---
CREATE (wanjiku)-[:GROWS]->(maize)
CREATE (wanjiku)-[:GROWS]->(beans)
CREATE (kamau)-[:GROWS]->(maize)
CREATE (kamau)-[:GROWS]->(tomatoes)
CREATE (kamau)-[:GROWS]->(potatoes)
CREATE (auma)-[:GROWS]->(tomatoes)
CREATE (auma)-[:GROWS]->(beans)
CREATE (auma)-[:GROWS]->(avocado)
CREATE (maina)-[:GROWS]->(maize)
CREATE (maina)-[:GROWS]->(potatoes)
CREATE (nafula)-[:GROWS]->(maize)
CREATE (nafula)-[:GROWS]->(beans)

// --- LISTED_AT relationships with prices ---
CREATE (maize)-[:LISTED_AT {price: 2400, date: "2026-05-20"}]->(wakulima)
CREATE (maize)-[:LISTED_AT {price: 3100, date: "2026-05-20"}]->(eldoret)
CREATE (maize)-[:LISTED_AT {price: 2600, date: "2026-05-20"}]->(kisumu)
CREATE (maize)-[:LISTED_AT {price: 2900, date: "2026-05-20"}]->(nakuru)
CREATE (maize)-[:LISTED_AT {price: 2800, date: "2026-05-20"}]->(kitale)

CREATE (tomatoes)-[:LISTED_AT {price: 110, date: "2026-05-20"}]->(wakulima)
CREATE (tomatoes)-[:LISTED_AT {price: 85, date: "2026-05-20"}]->(kisumu)
CREATE (tomatoes)-[:LISTED_AT {price: 95, date: "2026-05-20"}]->(nakuru)
CREATE (tomatoes)-[:LISTED_AT {price: 100, date: "2026-05-20"}]->(eldoret)

CREATE (beans)-[:LISTED_AT {price: 7200, date: "2026-05-20"}]->(wakulima)
CREATE (beans)-[:LISTED_AT {price: 8500, date: "2026-05-20"}]->(eldoret)
CREATE (beans)-[:LISTED_AT {price: 7800, date: "2026-05-20"}]->(kitale)
CREATE (beans)-[:LISTED_AT {price: 7500, date: "2026-05-20"}]->(nakuru)

CREATE (potatoes)-[:LISTED_AT {price: 2600, date: "2026-05-20"}]->(wakulima)
CREATE (potatoes)-[:LISTED_AT {price: 2200, date: "2026-05-20"}]->(nakuru)
CREATE (potatoes)-[:LISTED_AT {price: 2400, date: "2026-05-20"}]->(eldoret)

CREATE (avocado)-[:LISTED_AT {price: 120, date: "2026-05-20"}]->(wakulima)
CREATE (avocado)-[:LISTED_AT {price: 90, date: "2026-05-20"}]->(kisumu)

// --- BUYS relationships ---
CREATE (meghan)-[:BUYS]->(tomatoes)
CREATE (meghan)-[:BUYS]->(beans)
CREATE (meghan)-[:BUYS]->(avocado)
CREATE (rift)-[:BUYS]->(maize)
CREATE (rift)-[:BUYS]->(potatoes)
CREATE (lake)-[:BUYS]->(avocado)
CREATE (lake)-[:BUYS]->(beans)

// --- Verify ---
MATCH (n)-[r]->(m)
RETURN count(r) AS totalRelationships
