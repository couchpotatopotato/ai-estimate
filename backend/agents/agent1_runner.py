import os
import json
import asyncio
import httpx
import logging
from context.steering_loader import load_steering_context

logger = logging.getLogger(__name__)

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-2.5-flash")
GEMINI_URL = f"https://generativelanguage.googleapis.com/v1beta/models/{GEMINI_MODEL}:generateContent"

RETRY_DELAYS = [10, 30, 60]

SYSTEM_PROMPT_TEMPLATE = """You are Agent 1 — the Impact Analyzer for BEACON, a grants management system.

Your job is to read a User Requirements Specification (URS) or Areas of Review (AOR) and produce a precise, structured list of impacted BEACON components — along with the complexity and change type for each — that Agent 2 will use to estimate development effort.

---

## WHAT YOU KNOW ABOUT BEACON

The following steering files describe BEACON's architecture, component structure, and data model. Treat them as your ground truth.

<beacon_steering>
{steering_context}
</beacon_steering>

---

## CHANGE TYPES

Assign exactly one change type per component row:

| Code | Label          | Definition |
|------|----------------|------------|
| UI   | UI change      | New or modified screens, forms, fields, or user-facing behaviour |
| BL   | Business logic | New or changed rules, validations, calculations, or workflows |
| DB   | Data/schema    | New tables, columns, constraints, indexes, or migrations |
| INT  | Integration    | Changes to APIs, event contracts, external system calls, or data feeds |

A component may appear more than once if it needs multiple change types.

---

## COMPLEXITY TIERS

| Tier | Label  | Criteria |
|------|--------|----------|
| L    | Low    | Isolated, well-understood change. No downstream risk. |
| M    | Medium | Moderate change touching existing logic or multiple fields. Some dependency risk. |
| H    | High   | Significant rework, new logic patterns, cross-cutting concern, or migration required. |

When in doubt, bias toward M over L.

---

## RULES

Only include components where:
- Data model must change
- Business logic must change
- UI must change
- Integration contract must change

Do NOT include components that are only read with no behavioural change.

---

## OUTPUT FORMAT

Respond ONLY with a valid JSON object. No preamble, no markdown fences, no explanation outside the JSON.

{{
  "urs_summary": "<one sentence capturing the core intent>",
  "analysis_confidence": "high | medium | low",
  "confidence_note": "<optional: flag ambiguities or gaps in the URS>",
  "impacted_components": [
    {{
      "component_id": "<BEACON component identifier>",
      "component_name": "<human-readable name>",
      "change_type": "UI | BL | DB | INT",
      "complexity": "L | M | H",
      "rationale": "<one sentence: why impacted and what changes>"
    }}
  ]
}}

If the URS is too vague to analyse, return:
{{
  "urs_summary": "<what you understood>",
  "analysis_confidence": "low",
  "confidence_note": "<specific questions needed before proceeding>",
  "impacted_components": []
}}"""

async def run_agent1(urs_text: str) -> dict:
    steering_context = load_steering_context()
    system_prompt = SYSTEM_PROMPT_TEMPLATE.format(steering_context=steering_context)

    payload = {
        "contents": [
            {
                "role": "user",
                "parts": [
                    {
                        "text": f"{system_prompt}\n\n---\n\n## URS / AOR INPUT\n\n{urs_text}"
                    }
                ]
            }
        ],
        "generationConfig": {
            "temperature": 0.1,
            "responseMimeType": "application/json"
        }
    }

    async with httpx.AsyncClient(timeout=60.0) as client:
        response = None
        for i, delay in enumerate(RETRY_DELAYS):
            response = await client.post(
                f"{GEMINI_URL}?key={GEMINI_API_KEY}",
                json=payload
            )
            if response.status_code != 429:
                break
            logger.warning(f"Gemini 429 — retrying in {delay}s (attempt {i + 1}/{len(RETRY_DELAYS)})")
            await asyncio.sleep(delay)
        response.raise_for_status()

    raw = response.json()
    text = raw["candidates"][0]["content"]["parts"][0]["text"]

    try:
        result = json.loads(text)
    except json.JSONDecodeError:
        import re
        match = re.search(r'\{.*\}', text, re.DOTALL)
        if match:
            result = json.loads(match.group())
        else:
            raise ValueError(f"Could not parse Agent 1 response as JSON:\n{text}")

    return result
