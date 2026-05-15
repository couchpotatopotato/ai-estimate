from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from agents.agent1_runner import run_agent1
from agents.agent2_runner import run_agent2
import httpx
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="BEACON Effort Estimator API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_methods=["*"],
    allow_headers=["*"],
)

class EstimateRequest(BaseModel):
    urs_text: str

class EstimateResponse(BaseModel):
    urs_summary: str
    analysis_confidence: str
    confidence_note: str | None
    impacted_components: list
    effort_estimation: dict

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/estimate", response_model=EstimateResponse)
async def estimate(req: EstimateRequest):
    if not req.urs_text.strip():
        raise HTTPException(status_code=400, detail="URS text cannot be empty")

    try:
        logger.info("Running Agent 1 — impact analysis")
        agent1_output = await run_agent1(req.urs_text)
    except httpx.HTTPStatusError as e:
        if e.response.status_code == 429:
            raise HTTPException(status_code=429, detail="Gemini rate limit reached — wait a minute and try again.")
        raise HTTPException(status_code=502, detail=f"Gemini API error: {e.response.status_code}")

    if agent1_output["analysis_confidence"] == "low" and not agent1_output["impacted_components"]:
        return EstimateResponse(
            urs_summary=agent1_output["urs_summary"],
            analysis_confidence="low",
            confidence_note=agent1_output.get("confidence_note"),
            impacted_components=[],
            effort_estimation={}
        )

    logger.info("Running Agent 2 — effort estimation")
    effort = run_agent2(agent1_output["impacted_components"])

    return EstimateResponse(
        urs_summary=agent1_output["urs_summary"],
        analysis_confidence=agent1_output["analysis_confidence"],
        confidence_note=agent1_output.get("confidence_note"),
        impacted_components=agent1_output["impacted_components"],
        effort_estimation=effort
    )
