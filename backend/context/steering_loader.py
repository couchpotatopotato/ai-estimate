import os

STEERING_DIR = os.getenv("STEERING_DIR", "/app/steering")

STEERING_FILES = ["product.md", "tech.md", "structure.md"]

def load_steering_context() -> str:
    """
    Loads all BEACON steering .md files from STEERING_DIR into a single
    string to be injected into the Agent 1 system prompt.

    Add or rename files in STEERING_FILES to match your actual steering
    file names once generated from Kiro/Q Dev.
    """
    sections = []

    for filename in STEERING_FILES:
        filepath = os.path.join(STEERING_DIR, filename)
        if os.path.exists(filepath):
            with open(filepath, "r", encoding="utf-8") as f:
                content = f.read().strip()
            label = filename.replace(".md", "").upper()
            sections.append(f"### {label}\n\n{content}")
        else:
            sections.append(f"### {filename.upper()}\n\n[File not found — place {filename} in {STEERING_DIR}]")

    return "\n\n---\n\n".join(sections)
