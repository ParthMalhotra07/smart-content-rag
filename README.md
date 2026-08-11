# 🚀 Smart Content RAG Engine

**Project Overview**
A Retrieval-Augmented Generation (RAG) system that processes unstructured digital content (articles, media transcripts, newsroom reports) and answers natural-language questions with accurate, explainable, and fast responses. Built as an API service (FastAPI) that uses vector search (Pinecone) for retrieval, GPT-4 for answer synthesis, and PostgreSQL for metadata and audit logs. The system is designed to return both an answer and a justification for each question, powering next-generation content discovery platforms.

---

## 🌟 Key Features

* **Universal Ingestion**: Accepts document URLs (PDF/Word/HTML) and ingests them into a searchable vector index.
* **Semantic Retrieval**: Powered by Pinecone (or pluggable vector DB).
* **Explainable AI**: LLM synthesis using GPT-4 with explicit justifications citing retrieved chunks.
* **High Performance**: Fast responses targeted to be under **30 seconds** for the whole pipeline (retrieval + LLM inference).
* **Automation Ready**: API designed for programmatic workflows (content moderation, summarization, real-time context extraction).
* **Traceability**: Audit logs and provenance stored in PostgreSQL.

---

## 🏗️ Architecture

**Flow:**
```text
[Client] -> POST /hackrx/run -> [FastAPI App]
                              |- Download & chunk document (if not already ingested)
                              |- Embed chunks (OpenAI / local embedder)
                              |- Upsert into Pinecone index
                              |- Query Pinecone for top-K relevant chunks
                              |- Call GPT-4 with a retrieval-augmented prompt
                              |- Return answers + justification and save audit in Postgres
```

**Components:**
* **FastAPI**: HTTP API layer, request validation, orchestration.
* **Embeddings**: OpenAI embeddings or alternative.
* **Vector DB**: Pinecone for vector storage and nearest-neighbor search.
* **LLM**: GPT-4 (via OpenAI API) for final answer + explanation.
* **DB**: PostgreSQL for metadata, logs, and audit trail.
* **Storage**: Documents can be kept in object store (S3) or referenced by URL.

---

## 🔌 API Specification

**Endpoint**: `POST /hackrx/run`

Main endpoint that accepts a document URL and an array of questions. Returns an array of `answer` objects; each contains the `question`, `answer`, and `justification` (text that cites the retrieved chunks and explains reasoning).

**Request Payload:**
```json
{
  "document_url": "https://example.com/docs/claim123.pdf",
  "questions": [
    "What are the main themes of this content?",
    "List the key figures mentioned and their statements."
  ],
  "options": {
    "top_k": 5,
    "model": "gpt-4",
    "temperature": 0.0
  }
}
```

**Response Payload:**
```json
{
  "answers": [
    {
      "question": "What are the main themes of this content?",
      "answer": "The core theme revolves around the recent technological shifts outlined in Section 4.2.",
      "justification": "Supporting excerpts: [Chunk #12] 'recent technological shifts on 2024-11-12', [Chunk #5] 'the article covers these innovations'...",
      "sources": [
        {"chunk_id":"123","page":5,"text_snippet":"recent technological shifts on 2024-11-12"}
      ],
      "confidence": 0.87
    }
  ]
}
```
> **Note:** The `justification` field is required in the system design. It contains direct citations to the retrieved chunks (IDs and short snippets) and a concise explanation of how the answer was arrived at.

---

## ⚙️ Getting Started & Installation

**Prerequisites:**
* Python 3.10+
* PostgreSQL 12+
* Pinecone account & OpenAI account

**1. Environment Variables (`.env`)**
```env
OPENAI_API_KEY=sk-...
PINECONE_API_KEY=...
PINECONE_ENV=us-west1-gcp
PINECONE_INDEX=rag-insurance-index
DATABASE_URL=postgresql://user:pass@localhost:5432/rag_db
MODEL=gpt-4
EMBEDDING_MODEL=text-embedding-3-small
CHUNK_SIZE=1000
CHUNK_OVERLAP=200
MAX_TOP_K=10
```

**2. Local Setup**
```bash
git clone <repo-url>
cd smart-content-rag
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
Open `http://localhost:8000/docs` to view Swagger UI.

---

## 🧪 Testing & Evaluation

**API Testing (cURL):**
```bash
curl -X POST "http://localhost:8000/hackrx/run" \
 -H "Content-Type: application/json" \
 -d '{"document_url":"https://.../article.pdf","questions":["What is the core argument?"]}'
```

**Performance Targets:**
* **Accuracy / correctness**: Evaluated against a labeled test set (exact-match, F1).
* **Latency**: End-to-end response time < 30s.
* **Explainability**: Human evaluation of justifications for transparency.

---

## 🔒 Security & Best Practices

* **Prompt Engineering**: Use concise, deterministic prompts with low temperature (0.0–0.2). Limit `top_k` to avoid large token costs. Cache embeddings/index lookups.
* **Privacy**: Do not log sensitive PII unmasked. Store only metadata and minimal snippets required for justification. Follow applicable regulations (e.g., HIPAA).
* **Troubleshooting**: If experiencing slow responses, measure download, embedding, vector search, and LLM stages. Increase chunking parallelism or use larger `top_k` caching. For low-quality answers, increase `top_k` or refine chunking strategy.

---

**Status:** ✅ Actively Maintained (2026)
