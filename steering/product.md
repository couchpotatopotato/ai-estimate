# BEACON — Product Overview

BEACON is a batch processing grants and financial management system handling three lines of business: Housing withdrawals, Investment settlements, and Retirement/CPF Life annuity payouts.

## Key modules

- **Housing (hbl)** — Processes housing withdrawal applications, validates eligibility against policy thresholds, and commits approved transactions
- **Investment (inv/finance)** — Handles institutional investment settlement, links clearing files to CPFIS accounts, and executes trade allocations
- **Retirement/CPF Life (rss)** — Manages annuity payout determination across Standard, Basic, and Escalating lifeterm options for citizen cohorts
- **Batch Framework (bfw/bcs)** — Core orchestration layer managing job execution, checkpointing, fault recovery, and batch monitoring across all modules

## Processing flow

Each line of business follows the same pipeline pattern:
1. **JCL** — Mainframe job card triggers the batch pipeline
2. **JSL** — Spring Batch job spec defines steps, chunk limits, and readers
3. **BatchController** — Core orchestrator parses metadata and manages transactions
4. **EM (Entity Matching)** — Validates and matches records against citizen/account registries
5. **DE (Data Extension)** — Aggregates data from multi-source ledgers
6. **RM (Rules Management)** — Applies policy rules and threshold validations
7. **AC (Action Component)** — Commits final state changes and writes audit logs

## User roles

- Batch Operations — triggers and monitors JCL/batch jobs
- Finance Admin — oversees investment settlement and ledger reconciliation
- Housing Officer — manages withdrawal applications and grant scheme eligibility
- Retirement Admin — oversees CPF Life annuity cohort processing
- System Admin — manages batch framework configuration and monitoring
