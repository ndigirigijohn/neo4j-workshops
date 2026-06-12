#!/usr/bin/env python3
"""Shamba — minimal console client for the Kenya agricultural graph on Neo4j Aura."""

import os
import sys

from dotenv import load_dotenv
from neo4j import GraphDatabase


def get_driver():
    uri = os.environ["NEO4J_URI"]
    user = os.environ.get("NEO4J_USER", "neo4j")
    password = os.environ["NEO4J_PASSWORD"]
    return GraphDatabase.driver(uri, auth=(user, password))


def verify_connection(session) -> str:
    return session.run('RETURN "Connected to Neo4j Aura" AS message').single()["message"]


def graph_summary(session) -> list[dict]:
    return session.run(
        """
        MATCH (n)
        RETURN labels(n)[0] AS label, count(*) AS count
        ORDER BY label
        """
    ).data()


def list_crops(session) -> list[dict]:
    return session.run(
        """
        MATCH (c:Crop)
        RETURN c.name AS name, c.unit AS unit
        ORDER BY c.name
        """
    ).data()


def main() -> None:
    load_dotenv()

    print("Shamba — agricultural graph console\n")

    missing = [key for key in ("NEO4J_URI", "NEO4J_PASSWORD") if not os.environ.get(key)]
    if missing:
        print(f"Missing env vars: {', '.join(missing)}")
        print("Copy .env.example to .env and add your Aura credentials.")
        sys.exit(1)

    driver = get_driver()
    try:
        driver.verify_connectivity()
        with driver.session() as session:
            print(verify_connection(session))

            print("\nGraph summary:")
            for row in graph_summary(session):
                print(f"  {row['label']}: {row['count']}")

            crops = list_crops(session)
            if not crops:
                print("\nNo crops found. Load workshops/workshop3/data/seed.cypher in Aura Browser.")
                sys.exit(1)

            print("\nCrops:")
            for row in crops:
                print(f"  - {row['name']} ({row['unit']})")
    except Exception as exc:
        print(f"Connection failed: {exc}")
        sys.exit(1)
    finally:
        driver.close()

    print("\nDone.")


if __name__ == "__main__":
    main()
