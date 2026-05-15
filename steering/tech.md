# BEACON — Tech Stack

## Stack

- **Batch Framework** — Java / Spring Batch Engine
- **Business Logic** — Java / Spring Core, Drools Rules Engine (housing eligibility), Java Actuarial Core Engine (retirement)
- **Persistence** — Java / Hibernate DAO, Spring Tx / JPA
- **Integration** — IBM JCL / z/OS (mainframe job cards), Spring Batch JSL XML (job specifications)
- **Web/API** — Java / Spring REST
- **Context Bootstrap** — Java / Spring Servlet
- **Database** — PostgreSQL (Google Cloud SQL)

## Key technical constraints

- All DB changes require a migration script
- Mainframe JCL cards must be updated when batch pipeline steps change
- Spring Batch JSL XML must be updated when chunk limits, readers, or step boundaries change
- Drools rules engine used for housing eligibility — rule changes require `.drl` file updates
- Actuarial engine used for CPF Life payout calculations — changes require actuarial sign-off
- All Action Component (AC) writes are wrapped in Spring transactions — schema changes must preserve atomicity
- Audit log entries are mandatory for all AC commits
