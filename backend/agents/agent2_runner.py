"""
Agent 2 — Effort Estimation Engine
Deterministic formula based on component count, complexity tier, and change type.

AMEND the COMPLEXITY_HOURS and CHANGE_TYPE_MULTIPLIER tables to match
your actual Excel formula inputs. These are placeholder defaults.
"""

# Base hours per complexity tier
COMPLEXITY_HOURS = {
    "L": 4,   # Low  — e.g. minor field addition, config change
    "M": 12,  # Med  — e.g. logic change, form update with validation
    "H": 32,  # High — e.g. new module, migration, cross-cutting change
}

# Multiplier per change type (applied on top of complexity base)
CHANGE_TYPE_MULTIPLIER = {
    "UI":  1.0,   # Frontend work — baseline
    "BL":  1.2,   # Business logic — slightly heavier due to testing burden
    "DB":  1.3,   # DB/schema — migration risk adds overhead
    "INT": 1.5,   # Integration — external dependency risk, contract negotiation
}

# Buffer multiplier (accounts for PR review, QA, deployment)
OVERHEAD_BUFFER = 1.2

def estimate_component(component: dict) -> dict:
    complexity = component.get("complexity", "M")
    change_type = component.get("change_type", "BL")

    base_hours = COMPLEXITY_HOURS.get(complexity, 12)
    multiplier = CHANGE_TYPE_MULTIPLIER.get(change_type, 1.0)
    raw_hours = base_hours * multiplier
    buffered_hours = round(raw_hours * OVERHEAD_BUFFER, 1)

    return {
        "component_id": component.get("component_id"),
        "component_name": component.get("component_name"),
        "change_type": change_type,
        "complexity": complexity,
        "estimated_hours": buffered_hours,
    }

def run_agent2(impacted_components: list) -> dict:
    if not impacted_components:
        return {
            "total_hours": 0,
            "total_days": 0,
            "component_breakdown": [],
            "summary": "No impacted components identified — no effort to estimate."
        }

    breakdown = [estimate_component(c) for c in impacted_components]
    total_hours = round(sum(r["estimated_hours"] for r in breakdown), 1)
    total_days = round(total_hours / 8, 1)

    complexity_summary = {
        "L": sum(1 for c in impacted_components if c.get("complexity") == "L"),
        "M": sum(1 for c in impacted_components if c.get("complexity") == "M"),
        "H": sum(1 for c in impacted_components if c.get("complexity") == "H"),
    }

    change_type_summary = {}
    for c in impacted_components:
        ct = c.get("change_type", "BL")
        change_type_summary[ct] = change_type_summary.get(ct, 0) + 1

    return {
        "total_hours": total_hours,
        "total_days": total_days,
        "component_breakdown": breakdown,
        "complexity_distribution": complexity_summary,
        "change_type_distribution": change_type_summary,
        "summary": f"{len(impacted_components)} component changes · {total_hours}h estimated · ~{total_days} dev days"
    }
