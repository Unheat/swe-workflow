# 🛡️ SWE Workflow: Autonomous Disciplined Software Engineering

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Target Harnesses](https://img.shields.io/badge/Harnesses-Claude%20Code%20%7C%20DSH%20%7C%20Cursor%20%7C%20ZCode%20%7C%20Codex%20%7C%20OpenCode-blueviolet)](#supported-harnesses)

A battle-tested, autonomous software engineering workflow skill and judge suite for modern coding agents (Claude Code, DeepSeek Harness, Cursor, ZCode, Codex, OpenCode).

Combining **Karpathy surgical simplicity**, **CodePath Fail-to-Pass (F2P) test reproduction**, **ECC test runner auto-detection**, and **calibrated dual-gate judges (`judge-plan` & `judge-pr`)** to prevent regressions, hallucinated completions, and token-wasting loops.

---

## ⚡ Quick Start: 1-Command Installation

In your target project directory, run:

```bash
curl -fsSL https://raw.githubusercontent.com/Unheat/swe-workflow/main/setup.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/Unheat/swe-workflow.git /tmp/swe-workflow
bash /tmp/swe-workflow/setup.sh "$(pwd)"
```

Once installed, invoke `/swe-workflow` or the standalone judges `/judge-plan` and `/judge-pr` directly from any agent prompt or slash command.

---

## 🏗️ The 4-Phase Pipeline

```
┌────────────────────────────────────────────────────────────────────────┐
│                        swe-workflow Pipeline                           │
├────────────────────┬────────────────────┬──────────────────────────────┤
│ Phase 1: F2P       │ Phase 2: Plan &    │ Phase 3: Surgical Execution  │
│ Reproduction       │ Judge-Plan Gate    │ & Judge-PR Gate              │
├────────────────────┼────────────────────┼──────────────────────────────┤
│ 1. Auto-detect ECC │ 1. Draft plan      │ 1. Minimal surgical changes  │
│    test runner     │ 2. Subagent        │ 2. F2P test flips to Green   │
│ 2. Write Red test  │    evaluation      │ 3. Subagent judge-pr eval    │
│    proving failure │ 3. Gate pass (>=9) │ 4. Clean commit & report     │
└────────────────────┴────────────────────┴──────────────────────────────┘
```

### 1. Phase 1: F2P Test Reproduction (Red)
Before touching ANY implementation code, create an automated test that reproduces the bug or asserts the required new feature behavior. Execute the test to confirm failure:
* ❌ **Must fail for the exact reported reason**, not due to syntax or test harness configuration errors.

### 2. Phase 2: Plan & Calibrated Plan Judge Gate
Draft a grounded, step-by-step implementation plan. Evaluate against the calibrated **`judge-plan`** rubric:
* Grounded in actual codebase evidence.
* Strictly satisfies the user's explicit request with minimal complexity.
* Scored 0–10 across 5 calibrated dimensions; must score ≥ 9 to proceed.

### 3. Phase 3: Surgical Implementation (Green & Refactor)
Execute the plan with Karpathy Simplicity Invariants:
* **Simplicity First**: Minimal code to satisfy requirements. No speculative abstractions or unrequested configurability.
* **Surgical Precision**: Touch only what you must. Do not touch unrelated formatting or refactor working code.
* **Goal Verification**: Run test suite until the F2P test passes green with 0 regressions.

### 4. Phase 4: Calibrated PR Judge Gate
Before presenting the final deliverable to the human reviewer, evaluate against the calibrated **`judge-pr`** rubric:
* Requirements completeness and behavioral correctness.
* Automated test coverage with real assertions (no mock-only shortcuts).
* Code quality, absence of regressions, and clean documentation.

---

## 🧩 Included Skills & Subagents

| Skill / Subagent | Description |
|---|---|
| **`/swe-workflow`** | Main orchestrator running the full 4-phase disciplined pipeline. |
| **`/judge-plan`** | Independent plan evaluation subagent scoring requirements, evidence, and simplicity. |
| **`/judge-pr`** | Independent pull request / deliverable verification subagent before human review. |

---

## 🎯 Supported Agent Harnesses

Zero-config discovery across:
- **Claude Code**: `.claude/skills/`, `.claude/agents/`
- **DeepSeek Harness (DSH)**: `.dsh/skills/`, `.agent/agents/`
- **Cursor**: `.cursor/skills/`
- **ZCode**: `.zcode/skills/`, `.agents/skills/`
- **Codex / OpenCode**: `.codex/skills/`, `.opencode/skills/`

---

## 🧪 Calibrated Evals

The judge subagents (`judge-plan` and `judge-pr`) include deterministic validation evals under `eval/`:

```bash
# Run judge calibration evals
python3 eval/run_eval.py
```

---

## 📄 License

MIT © [Unheat](https://github.com/Unheat)
