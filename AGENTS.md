# Agent Skills System Repo

CRITICAL: When a task is about agent design, routing, skills, mode selection, or maintaining this repo, read `agent-skills-system/SKILL.md` immediately and treat it as the source of truth.

## Adapter Rules

- Keep one active mode per phase
- Do not duplicate the full system in this file
- This file is the shared adapter for Codex, OpenCode, Cursor, and Windsurf
- Keep `README.md`, `CLAUDE.md`, `GEMINI.md`, `.continue/rules/agent-skills-system.md`, `.agents/skills/agent-skills-system/SKILL.md`, and `agent-skills-system/agents/openai.yaml` aligned with the canonical skill
- If an adapter and the canonical skill disagree, the canonical skill wins
