-- 1. TRUNCATE REPO REGISTRY (FRESH START)
TRUNCATE TABLE component_relationships, beacon_components CASCADE;

-- =============================================================================
-- 2. INSERT ACTUAL CODEBASE REPOSITORY COMPONENT FOOTPRINTS
-- =============================================================================
INSERT INTO beacon_components (component_id, component_name, module, layer, description, tech_stack, db_tables) VALUES

-- -----------------------------------------------------------------------------
-- FRAMEWORK CORE & COMMON UTILITIES (Module: bfw / bcs)
-- -----------------------------------------------------------------------------
('BCN-BFW-CTRL', 'BatchController', 'bfw', 'BL', 'Core service orchestrator parsing dynamic runtime metadata, validating execution locks, and managing batch transactions.', 'Java / Spring Batch Engine', ARRAY[]::text[]),
('BCN-BCS-LDR', 'BeaconContextLoaderListener', 'bfw', 'INT', 'Bootstraps and lifecycle-manages unified distributed web application context profiles across containers.', 'Java / Spring Servlet', ARRAY[]::text[]),
('BCN-BFW-LSTN', 'TimeIntervalCheckPointChunkListener', 'bfw', 'DB', 'Chunk processing listener monitoring execution performance metrics and writing automated checkpoints to allow fault-tolerant job recovery.', 'Java / Spring Batch', ARRAY['BatchHash', 'BatchMonitor']),
('BCN-BFW-MGR', 'BatchJobInstanceManager', 'bfw', 'DB', 'Core system manager class coordinating persistence operations for BatchJobInstance and BatchJobExecution metadata.', 'Java / Hibernate DAO', ARRAY['BatchJobInstance', 'BatchJobExecution']),
('BCN-BFW-UI-001', 'BFWBatchExecutionRestController', 'bfw', 'UI', 'Exposes public RESTful API endpoints for external microservices to trigger and query running BFW batch jobs.', 'Java / Spring REST', ARRAY[]::text[]),

-- -----------------------------------------------------------------------------
-- HOUSING LINE OF BUSINESS (Module: housing | Prefix: hbl)
-- -----------------------------------------------------------------------------
('JCL-HBL-WTHDR', 'HBLWTHDR.jcl', 'housing', 'INT', 'Mainframe Job Control Language card orchestrating scheduling and step initialization sequences for housing batch pipelines.', 'IBM JCL / z/OS', ARRAY[]::text[]),
('JSL-HBL-WTHDR', 'hbl-withdrawal-job.xml', 'housing', 'INT', 'Spring Batch JSL (Job Specification Language) defining transaction boundaries, chunk limits, and readers.', 'Spring Batch JSL XML', ARRAY['BatchJobInstance']),
('BCN-HSE-RDR', 'AHSTRNExtractReader', 'housing', 'BL', 'Spring Batch ItemReader engineered to extract transaction datasets compiled from mainframe flat-file outputs.', 'Java / Spring Batch', ARRAY[]::text[]),
('EM-HBL-MATCH', 'HousingMemberMatchingEMService', 'housing', 'BL', 'Processing Module Entity Matching service validating public/private housing applications against citizen registries.', 'Java / Spring Core', ARRAY[]::text[]),
('DE-HBL-RETRV', 'HousingPropertyRetrievalDEService', 'housing', 'BL', 'Processing Module Data Extension service managing data aggregation across multi-source real estate ledgers.', 'Java / Spring Core / Hibernate', ARRAY['housing_applications']),
('RM-HBL-VALID', 'HousingEligibilityValidationRMService', 'housing', 'BL', 'Processing Module Rules Management service running policy threshold matrices evaluating valuation and withdrawal limits.', 'Java / Drools Engine', ARRAY['grant_schemes']),
('AC-HBL-COMMIT', 'HousingWithdrawalCommitACService', 'housing', 'DB', 'Processing Module Action Component layer handling atomic transactions, writing application status updates, and logging audits.', 'Java / Spring Tx / JPA', ARRAY['housing_applications', 'audit_log']),

-- -----------------------------------------------------------------------------
-- INVESTMENT LINE OF BUSINESS (Module: finance | Prefix: inv)
-- -----------------------------------------------------------------------------
('JCL-INV-SETTL', 'INVSETTL.jcl', 'finance', 'INT', 'Mainframe Job Control Language card processing transactional outbound records to partner clearing houses.', 'IBM JCL / z/OS', ARRAY[]::text[]),
('JSL-INV-SETTL', 'inv-bank-settlement-job.xml', 'finance', 'INT', 'Spring Batch JSL mapping step constraints and item split strategies for institutional liquidity settlements.', 'Spring Batch JSL XML', ARRAY['BatchJobInstance']),
('BCN-INV-LSTN', 'INVJobExitCodeChangeListener', 'finance', 'BL', 'Job execution listener evaluating final batch states to coordinate rollbacks or pass parameters to subsequent triggers.', 'Java / Spring Batch', ARRAY['BatchJobExecution']),
('EM-INV-MATCH', 'InvestmentAccountMatchingEMService', 'finance', 'BL', 'Processing Module Entity Matching service linking transaction clearing files to verified CPFIS accounts.', 'Java / Spring Core', ARRAY[]::text[]),
('DE-INV-RETRV', 'InvestmentPortfolioRetrievalDEService', 'finance', 'BL', 'Processing Module Data Extension service pulling holding configurations, total valuation units, and active fund boundaries.', 'Java / Spring Core', ARRAY['investment_holding_ledger']),
('RM-INV-VALID', 'InvestmentThresholdValidationRMService', 'finance', 'BL', 'Processing Module Rules Management service validating asset liquidations against mandated minimum retained limits.', 'Java / Spring Core', ARRAY['cpf_member_balances']),
('AC-INV-COMMIT', 'InvestmentOrderExecutionACService', 'finance', 'DB', 'Processing Module Action Component computing final allocation ledger offsets and saving cleared trade executions.', 'Java / Spring Tx / JPA', ARRAY['grant_transactions', 'budget_lines']),

-- -----------------------------------------------------------------------------
-- RETIREMENT LINE OF BUSINESS / CPF LIFE (Module: retirement | Prefix: rss)
-- -----------------------------------------------------------------------------
('JCL-RSS-ANNUT', 'RSSANNUT.jcl', 'retirement', 'INT', 'Mainframe Job Control Language running the primary lifespan batch evaluation matrices across citizen cohorts.', 'IBM JCL / z/OS', ARRAY[]::text[]),
('JSL-RSS-ANNUT', 'rss-annuity-payout-job.xml', 'retirement', 'INT', 'Spring Batch JSL instantiating high-concurrency partition routines across demographic datasets.', 'Spring Batch JSL XML', ARRAY['BatchJobInstance']),
('BCN-RSS-UTL', 'SARAMConstants', 'retirement', 'INT', 'Static layout definitions detailing character markers and byte padding for parsing mainframe flat files.', 'Java / Static Utility', ARRAY[]::text[]),
('EM-RSS-MATCH', 'RetirementCohortMatchingEMService', 'retirement', 'BL', 'Processing Module Entity Matching engine registering members into actuarial lifespan risk tracks based on age thresholds.', 'Java / Spring Core', ARRAY[]::text[]),
('DE-RSS-RETRV', 'CpfLifePremiumRetrievalDEService', 'retirement', 'BL', 'Processing Module Data Extension service looking up structural interest tracking and balance statements.', 'Java / Spring Core', ARRAY['cpf_life_premiums']),
('RM-RSS-VALID', 'CpfLifePayoutDeterminationRMService', 'retirement', 'BL', 'Processing Module Rules Management service calculating annuity yields across Standard, Basic, and Escalating lifeterm options.', 'Java / Actuarial Core Engine', ARRAY['actuarial_cohort_tables']),
('AC-RSS-COMMIT', 'AnnuityPoolLedgerUpdateACService', 'retirement', 'DB', 'Processing Module Action Component committing payout state modifications into isolated long-term holding registries.', 'Java / Spring Tx / JPA', ARRAY['annuity_pool_transactions', 'audit_log']);

-- =============================================================================
-- 3. LINK COMPONENT RELATIONSHIPS (END-TO-END REPO TRACING)
-- =============================================================================
INSERT INTO component_relationships (source_id, target_id, relationship_type) VALUES
-- Core Infrastructure Maps
('BCN-BFW-UI-001', 'BCN-BFW-CTRL', 'CALLS'),
('BCN-BFW-CTRL', 'BCN-BFW-MGR', 'DEPENDS_ON'),
('BCN-BFW-LSTN', 'BCN-BFW-MGR', 'DEPENDS_ON'),

-- Housing Codebase Flow Trace
('JCL-HBL-WTHDR', 'JSL-HBL-WTHDR', 'TRIGGERS'),       -- Mainframe JCL spins up the Spring Batch JSL configuration
('JSL-HBL-WTHDR', 'BCN-BFW-CTRL', 'CALLS'),         -- JSL initializes execution jobs within Core BatchController
('BCN-BFW-CTRL', 'BCN-HSE-RDR', 'CALLS'),           -- BatchController orchestrates the flat file parser
('BCN-HSE-RDR', 'EM-HBL-MATCH', 'CALLS'),           -- Parsed records feed into Entity Matching (EM) Layer
('EM-HBL-MATCH', 'DE-HBL-RETRV', 'CALLS'),          -- EM matches pass to Data Extension (DE) to extend data models
('DE-HBL-RETRV', 'RM-HBL-VALID', 'CALLS'),          -- Extended data reaches Rules Management (RM) validation
('RM-HBL-VALID', 'AC-HBL-COMMIT', 'CALLS'),         -- Validated results prompt Action Component (AC) database updates
('AC-HBL-COMMIT', 'BCN-BFW-LSTN', 'DEPENDS_ON'),    -- AC relies on the transactional Checkpoint listener

-- Investment Codebase Flow Trace
('JCL-INV-SETTL', 'JSL-INV-SETTL', 'TRIGGERS'),
('JSL-INV-SETTL', 'BCN-BFW-CTRL', 'CALLS'),
('BCN-BFW-CTRL', 'BCN-INV-LSTN', 'CALLS'),
('BCN-INV-LSTN', 'EM-INV-MATCH', 'CALLS'),
('EM-INV-MATCH', 'DE-INV-RETRV', 'CALLS'),
('DE-INV-RETRV', 'RM-INV-VALID', 'CALLS'),
('RM-INV-VALID', 'AC-INV-COMMIT', 'CALLS'),
('AC-INV-COMMIT', 'BCN-BFW-LSTN', 'DEPENDS_ON'),

-- Retirement Codebase Flow Trace
('JCL-RSS-ANNUT', 'JSL-RSS-ANNUT', 'TRIGGERS'),
('JSL-RSS-ANNUT', 'BCN-BFW-CTRL', 'CALLS'),
('BCN-BFW-CTRL', 'BCN-RSS-UTL', 'READS'),
('BCN-BFW-CTRL', 'EM-RSS-MATCH', 'CALLS'),
('EM-RSS-MATCH', 'DE-RSS-RETRV', 'CALLS'),
('DE-RSS-RETRV', 'RM-RSS-VALID', 'CALLS'),
('RM-RSS-VALID', 'AC-RSS-COMMIT', 'CALLS'),
('AC-RSS-COMMIT', 'BCN-BFW-LSTN', 'DEPENDS_ON');