# BEACON — Component Structure

## Batch Framework Core (module: bfw)

### BatchController (BCN-BFW-CTRL)
- Layer: BL
- Orchestrates all batch job execution across all lines of business
- Parses dynamic runtime metadata, validates execution locks, manages batch transactions
- Called by: all JSL job specs

### BeaconContextLoaderListener (BCN-BCS-LDR)
- Layer: INT
- Bootstraps and lifecycle-manages distributed web application context profiles

### TimeIntervalCheckPointChunkListener (BCN-BFW-LSTN)
- Layer: DB
- Monitors execution performance and writes checkpoints for fault-tolerant job recovery
- DB tables: `BatchHash`, `BatchMonitor`
- Depended on by: all AC (Action Component) services

### BatchJobInstanceManager (BCN-BFW-MGR)
- Layer: DB
- Manages persistence for job instance and execution metadata
- DB tables: `BatchJobInstance`, `BatchJobExecution`
- Depended on by: BCN-BFW-CTRL, BCN-BFW-LSTN

### BFWBatchExecutionRestController (BCN-BFW-UI-001)
- Layer: UI
- REST API endpoints for external services to trigger and query BFW batch jobs
- Calls: BCN-BFW-CTRL

---

## Housing Line of Business (module: housing, prefix: hbl)

### HBLWTHDR.jcl (JCL-HBL-WTHDR)
- Layer: INT
- Mainframe JCL card orchestrating housing batch pipeline scheduling
- Triggers: hbl-withdrawal-job.xml

### hbl-withdrawal-job.xml (JSL-HBL-WTHDR)
- Layer: INT
- Spring Batch JSL defining transaction boundaries, chunk limits, and readers
- DB tables: `BatchJobInstance`
- Calls: BCN-BFW-CTRL

### AHSTRNExtractReader (BCN-HSE-RDR)
- Layer: BL
- ItemReader extracting transaction datasets from mainframe flat-file outputs
- Called by: BCN-BFW-CTRL

### HousingMemberMatchingEMService (EM-HBL-MATCH)
- Layer: BL
- Validates housing applications against citizen registries
- Called by: BCN-HSE-RDR

### HousingPropertyRetrievalDEService (DE-HBL-RETRV)
- Layer: BL
- Aggregates data across multi-source real estate ledgers
- DB tables: `housing_applications`
- Called by: EM-HBL-MATCH

### HousingEligibilityValidationRMService (RM-HBL-VALID)
- Layer: BL
- Drools rules engine — evaluates valuation and withdrawal limit policy thresholds
- DB tables: `grant_schemes`
- Called by: DE-HBL-RETRV

### HousingWithdrawalCommitACService (AC-HBL-COMMIT)
- Layer: DB
- Atomic transactions committing application status updates and audit entries
- DB tables: `housing_applications`, `audit_log`
- Called by: RM-HBL-VALID
- Depends on: BCN-BFW-LSTN

---

## Investment Line of Business (module: finance, prefix: inv)

### INVSETTL.jcl (JCL-INV-SETTL)
- Layer: INT
- Mainframe JCL card for outbound transactional records to partner clearing houses
- Triggers: inv-bank-settlement-job.xml

### inv-bank-settlement-job.xml (JSL-INV-SETTL)
- Layer: INT
- Spring Batch JSL mapping step constraints and item split strategies
- DB tables: `BatchJobInstance`
- Calls: BCN-BFW-CTRL

### INVJobExitCodeChangeListener (BCN-INV-LSTN)
- Layer: BL
- Evaluates final batch states to coordinate rollbacks or trigger subsequent jobs
- DB tables: `BatchJobExecution`
- Called by: BCN-BFW-CTRL

### InvestmentAccountMatchingEMService (EM-INV-MATCH)
- Layer: BL
- Links transaction clearing files to verified CPFIS accounts
- Called by: BCN-INV-LSTN

### InvestmentPortfolioRetrievalDEService (DE-INV-RETRV)
- Layer: BL
- Pulls holding configurations, total valuation units, and active fund boundaries
- DB tables: `investment_holding_ledger`
- Called by: EM-INV-MATCH

### InvestmentThresholdValidationRMService (RM-INV-VALID)
- Layer: BL
- Validates asset liquidations against mandated minimum retained limits
- DB tables: `cpf_member_balances`
- Called by: DE-INV-RETRV

### InvestmentOrderExecutionACService (AC-INV-COMMIT)
- Layer: DB
- Computes final allocation ledger offsets and saves cleared trade executions
- DB tables: `grant_transactions`, `budget_lines`
- Called by: RM-INV-VALID
- Depends on: BCN-BFW-LSTN

---

## Retirement / CPF Life (module: retirement, prefix: rss)

### RSSANNUT.jcl (JCL-RSS-ANNUT)
- Layer: INT
- Mainframe JCL running lifespan batch evaluation matrices across citizen cohorts
- Triggers: rss-annuity-payout-job.xml

### rss-annuity-payout-job.xml (JSL-RSS-ANNUT)
- Layer: INT
- Spring Batch JSL instantiating high-concurrency partition routines across demographic datasets
- DB tables: `BatchJobInstance`
- Calls: BCN-BFW-CTRL

### SARAMConstants (BCN-RSS-UTL)
- Layer: INT
- Static layout definitions for parsing mainframe flat file character markers and byte padding
- Read by: BCN-BFW-CTRL

### RetirementCohortMatchingEMService (EM-RSS-MATCH)
- Layer: BL
- Registers members into actuarial lifespan risk tracks based on age thresholds
- Called by: BCN-BFW-CTRL

### CpfLifePremiumRetrievalDEService (DE-RSS-RETRV)
- Layer: BL
- Looks up structural interest tracking and balance statements
- DB tables: `cpf_life_premiums`
- Called by: EM-RSS-MATCH

### CpfLifePayoutDeterminationRMService (RM-RSS-VALID)
- Layer: BL
- Calculates annuity yields across Standard, Basic, and Escalating lifeterm options
- DB tables: `actuarial_cohort_tables`
- Called by: DE-RSS-RETRV

### AnnuityPoolLedgerUpdateACService (AC-RSS-COMMIT)
- Layer: DB
- Commits payout state modifications into long-term holding registries
- DB tables: `annuity_pool_transactions`, `audit_log`
- Called by: RM-RSS-VALID
- Depends on: BCN-BFW-LSTN
