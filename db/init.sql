-- Mock BEACON schema for local development

CREATE TABLE IF NOT EXISTS grants (
    id SERIAL PRIMARY KEY,
    grant_ref VARCHAR(50) UNIQUE NOT NULL,
    title TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'draft',
    total_value NUMERIC(12,2),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS applicants (
    id SERIAL PRIMARY KEY,
    grant_id INT REFERENCES grants(id),
    name TEXT NOT NULL,
    email TEXT,
    organisation TEXT
);

CREATE TABLE IF NOT EXISTS assessments (
    id SERIAL PRIMARY KEY,
    grant_id INT REFERENCES grants(id),
    assessor TEXT,
    score INT,
    outcome VARCHAR(20),
    assessed_at TIMESTAMPTZ
);

-- Seed data
INSERT INTO grants (grant_ref, title, status, total_value) VALUES
    ('GR-001', 'Community Infrastructure Fund', 'active', 250000.00),
    ('GR-002', 'Digital Skills Programme', 'draft', 75000.00),
    ('GR-003', 'Rural Development Grant', 'closed', 120000.00);

INSERT INTO applicants (grant_id, name, email, organisation) VALUES
    (1, 'Test Applicant', 'applicant@example.com', 'Test Org'),
    (2, 'Another Applicant', 'another@example.com', 'Another Org');

INSERT INTO assessments (grant_id, assessor, score, outcome, assessed_at) VALUES
    (1, 'assessor@example.com', 85, 'approved', NOW()),
    (3, 'assessor@example.com', 42, 'rejected', NOW());
