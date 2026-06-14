from sentence_transformers import SentenceTransformer
from neo4j import GraphDatabase
from pathlib import Path
from dotenv import load_dotenv
import os

# Load environment variables from .env
PROJECT_ROOT = Path(__file__).resolve().parent
load_dotenv(PROJECT_ROOT / ".env")

# Setup — runs once, driver and model are reused in Exercises 3, 4, 5
model  = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")

# Adapter: wrap the SentenceTransformer so it exposes the
# `embed_query(text)` method expected by neo4j_graphrag EmbedderModel
class SentenceTransformerEmbedder:
    def __init__(self, model: SentenceTransformer):
        self._model = model

    def embed_query(self, text: str) -> list[float]:
        emb = self._model.encode(text)
        # ensure a plain Python list of floats
        try:
            return emb.tolist()
        except Exception:
            return [float(x) for x in emb]
driver = GraphDatabase.driver(os.environ["NEO4J_URI"],
                              auth=(os.environ["NEO4J_USER"],
                                    os.environ["NEO4J_PASSWORD"]))

# Single place to change the user query used by Exercises 3, 4 and 5
USER_QUERY = os.environ.get("SHAMBA_USER_QUERY") or (
    """
Nahitaji mboga ya kupika ugali kutoka kwa shamba iliyo karibu na mimi; niko Kiambu.
Napenda kujua aina zinazopendekezwa, jinsi zinavyopakiwa/uzito wa kuuza, na bei za kawaida
ili niandae usafirishaji na uhifadhi.
"""
)

# Exercise 2 — Generate and Store Embeddings
print("Exercise 2: Generating embeddings...")
with driver.session() as session:
    crops = session.run(
        "MATCH (c:Crop) RETURN c.name AS name, c.description AS desc"
    ).data()
    for crop in crops:
        if crop["desc"]:
            embedding = model.encode(crop["desc"]).tolist()
            session.run(
                "MATCH (c:Crop {name: $name}) SET c.embedding = $embedding",
                name=crop["name"], embedding=embedding
            )
            print(f"  Embedded: {crop['name']}")

print("Done.")

# Exercise 3 — Vector RAG: Search by Meaning
print("\nExercise 3: Vector search...")
from neo4j_graphrag.retrievers import VectorRetriever

retriever = VectorRetriever(
    driver=driver,
    index_name="crop_embeddings",
    embedder=SentenceTransformerEmbedder(model),
    return_properties=["name", "description", "unit"]
)

results = retriever.search(query_text=USER_QUERY, top_k=3)

print(f"\nQuery: '{USER_QUERY}'")
for i, r in enumerate(results.items, 1):
    print(f"{i}. {r.content}")

    
# Exercise 4 — Vector + Cypher: Meaning AND Structure
print("\nExercise 4: Vector + Cypher search...")
from neo4j_graphrag.retrievers import VectorCypherRetriever

retrieval_query = """
MATCH (node)-[:LISTED_IN]->(market:Market)-[:HAS_PRICE]->(price:PricePoint)
WHERE price.recordedAt >= date() - duration({days: 14})
RETURN node.name      AS crop,
       market.name    AS market,
       market.location AS location,
       price.price    AS price,
       price.unit     AS unit,
       score
ORDER BY score DESC, price DESC
LIMIT 5
"""

vc_retriever = VectorCypherRetriever(
    driver=driver,
    index_name="crop_embeddings",
    embedder=SentenceTransformerEmbedder(model),
    retrieval_query=retrieval_query
)

results = vc_retriever.search(query_text=USER_QUERY, top_k=3)

print(f"\nQuery: '{USER_QUERY}'")
for i, r in enumerate(results.items, 1):
    print(f"{i}. {r.content}")
    print("---")



# Exercise 5 — LLM Synthesis (Google Gemini)
print("\nExercise 5: LLM synthesis...")
import os
from neo4j_graphrag.llm import OpenAILLM
from neo4j_graphrag.generation import GraphRAG
llm = OpenAILLM(
    model_name="gemini-2.5-flash",
    # Increase max_tokens so the LLM can return a paragraph or two
    model_params={"max_tokens": 512},
    api_key=os.environ.get("GOOGLE_API_KEY"),
    base_url="https://generativelanguage.googleapis.com/v1beta/openai/",
)

rag      = GraphRAG(retriever=vc_retriever, llm=llm)
response = rag.search(
    query_text=USER_QUERY,
    retriever_config={"top_k": 3}
)

print(f"\nAnswer:\n{response.answer}")

driver.close()
print("\nAll exercises complete.")