# Workshop 1 — Setup Instructions

**Kenya AI Challenge 2026 — Neo4j Track**

---

If you have not set up Neo4j yet, follow the steps below. Setup takes about 10 minutes. Ask your facilitator if you get stuck.

---

## Step 1: Create a Neo4j Aura Account

1. Go to [console.neo4j.io](https://console.neo4j.io)
2. Click **Sign up**
3. Sign up with your Google account (easiest) or create an email/password account

---

## Step 2: Create a Free Database Instance

1. After signing in, click **New Instance**
2. Choose **AuraDB Free**
3. Select any region (closest to Kenya is EU West or Africa if available)
4. Click **Create Instance**
5. **IMPORTANT — Save your credentials.** A popup will appear with your:
   - Connection URI (starts with `neo4j+s://...`)
   - Username (usually `neo4j`)
   - Password (auto-generated)
   
   Download the credentials file or copy the password somewhere safe. **This password is shown only once.** If you lose it, you will need to reset it in the console.

6. Wait 1–3 minutes for the instance to start. Status will change from "Creating" to "Running".

---

## Step 3: Open Neo4j Browser

1. Once your instance is running, click **Open** (or **Query**)
2. The Neo4j Browser will open in a new tab
3. You may be asked to sign in — use the username and password from Step 2

---

## Step 4: Confirm Your Setup

Run this query in the Neo4j Browser command bar (the `$` prompt at the top):

```cypher
RETURN "Hello, Kenya AI Challenge!" AS message
```

Press **Ctrl + Enter** or click the play button to run it. If you see the message returned, your setup is complete.

---

## Step 5: Install Neo4j Desktop (Optional)

Neo4j Browser in the cloud is all you need for the workshop. If you prefer a local desktop tool:

- Download Neo4j Desktop from [neo4j.com/download](https://neo4j.com/download/)
- Available for Windows, macOS, and Linux
- You can connect it to your Aura cloud instance

This is optional — the cloud browser works fine.

---

## What to Bring

- Laptop with Chrome or Firefox (Neo4j Browser works best in these)
- Your Neo4j Aura credentials (URI, username, password)
- Any initial ideas about what agricultural problem your team wants to solve

---

## Questions?

Post in the WhatsApp group or contact us before the session.
