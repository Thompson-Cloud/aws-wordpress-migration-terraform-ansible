# Automated WordPress Migration to AWS

An automated migration workflow for moving an existing **WordPress application and MySQL database to AWS** using **Terraform, Ansible, GitHub Actions, AWS Systems Manager, Amazon RDS, Amazon S3, AWS Secrets Manager, and GitHub OIDC**.

The project focuses on a specific operational problem: **reducing the manual coordination required to execute a familiar migration process reliably.**

The migration was developed in two stages:

- **V1 — Migration Baseline:** Established a reliable AWS migration path using Terraform and Ansible.
- **V2 — Migration Orchestration:** Removed the remaining manual coordination using GitHub Actions, OIDC, dynamic AWS resource discovery, and automated validation.

> **The engineer controls the intent. The automation handles the execution.**

---

## Architecture


![Automated WordPress Migration to AWS Architecture](docs/images/aws-wordpress-migration-architecture.png)

*Figure 1 — Automated WordPress migration architecture showing GitHub Actions orchestration, OIDC-based AWS authentication, Ansible configuration and migration through Systems Manager, and the WordPress EC2-to-RDS application path.*

- **Terraform** — provisions and manages AWS infrastructure
- **Ansible** — configures EC2 and performs the WordPress and MySQL migration
- **GitHub Actions** — coordinates migration stages
- **AWS Systems Manager** — provides Ansible connectivity without inbound SSH
- **GitHub OIDC** — provides temporary AWS credentials to the workflow
- **Amazon S3** — stores migration artifacts
- **AWS Secrets Manager** — provides RDS credentials
- **CloudWatch + SNS** — provide monitoring and notifications

Terraform remains outside the GitHub Actions migration workflow, keeping **infrastructure lifecycle and workload migration as separate responsibilities**.

---

## Migration Workflow

The migration is started manually using `workflow_dispatch`, allowing the engineer to select the target environment and initiate the migration intentionally.

```text
        Validate Artifacts ────┐
                               ├──► Preflight
        Validate Target ───────┘
                                  │
                                  ▼
                              Configure
                                  │
                                  ▼
                               Migrate
                                  │
                                  ▼
                               Validate
```

Each stage gates the next. Missing artifacts, invalid targets, or failed preflight checks stop the workflow before migration continues.

---

## Dynamic Target Discovery

The workflow discovers AWS resources using tags rather than hardcoded EC2 instance IDs or RDS endpoints.

```text
Project     = aws-wordpress-migration
Environment = lab
Role        = wordpress-app
```

The RDS database uses the corresponding `wordpress-db` role.

The engineer provides:

```text
Environment = lab
```

The automation discovers the infrastructure behind it.

For RDS, the workflow expects exactly one matching database and fails on missing or ambiguous targets rather than selecting one automatically.

---

## Key Engineering Decisions

| Decision | Reason |
|---|---|
| Terraform kept outside the migration workflow | Separates infrastructure lifecycle from workload migration |
| Ansible over Systems Manager | Avoids inbound SSH and SSH key management |
| Private RDS | Prevents direct public database exposure |
| GitHub OIDC | Avoids long-lived AWS credentials in GitHub |
| Tag-based resource discovery | Removes dependency on temporary AWS resource IDs |
| Secrets Manager | Keeps database credentials out of code and configuration files |
| `workflow_dispatch` | Keeps migration an intentional operational event |
| Strict RDS discovery | Fails safely when the target is missing or ambiguous |

---

## Results

The final GitHub Actions workflow completed all six migration stages successfully:

```text
✓ Validate Migration Artifacts
✓ Validate Target Environment
✓ Migration Preflight
✓ Configure WordPress
✓ Migrate Database
✓ Validate Migration
```

### Automated Migration Pipeline

![Successful GitHub Actions Migration](docs/images/github-actions-success.png)

### Migrated WordPress Application

![Migrated WordPress Application](docs/images/migrated-wordpress-site.png)

### AWS Validation

![AWS Infrastructure Validation](docs/images/aws-validation.png)

Migration success was validated at three levels:

```text
Pipeline
   +
AWS Infrastructure
   +
Application
   =
Migration Success
```

Validation confirmed that:

- EC2 was running and online through Systems Manager
- RDS was available, encrypted, and not publicly accessible
- The migrated WordPress application loaded successfully
- Migrated database content was present
- CloudWatch alarms were healthy

---

## Security Highlights

- Private Amazon RDS database
- RDS encryption at rest
- Encrypted EC2 root storage
- IMDSv2 enforcement
- No inbound SSH administration
- Security-group-to-security-group MySQL access
- S3 encryption and public-access blocking
- Database credentials stored in Secrets Manager
- GitHub OIDC instead of long-lived AWS access keys
- IAM-based access control

---

## Repository Structure

```text
.
├── .github/
│   └── workflows/
│       └── migrate-wordpress.yml
│
├── ansible/
│   ├── group_vars/
│   ├── inventory/
│   ├── playbooks/
│   └── tasks/
│
├── docs/
│   ├── AWS-WordPress-Migration-Technical-Documentation.pdf
│   └── images/
│
├── scripts/
│   └── validate-artifacts.sh
│
├── terraform/
│   ├── bootstrap/
│   ├── github-oidc/
│   └── infrastructure/
│
├── .gitignore
└── README.md
```

---

## Technology Stack

| Responsibility | Technology |
|---|---|
| Infrastructure as Code | Terraform |
| Configuration & Migration | Ansible |
| Migration Orchestration | GitHub Actions |
| AWS Authentication | GitHub OIDC |
| Compute | Amazon EC2 |
| Database | Amazon RDS for MySQL |
| Storage | Amazon S3 |
| Server Management | AWS Systems Manager |
| Secrets | AWS Secrets Manager |
| Identity & Access | AWS IAM |
| Monitoring | Amazon CloudWatch |
| Notifications | Amazon SNS |

---

## Scope

This project focuses on the **migration and automation workflow**, not on designing a complete production WordPress hosting platform.

The lab uses a cost-conscious Single-AZ database design and direct EC2 application access. Production requirements such as high availability, HTTPS, load balancing, scaling, backup/recovery, and formal cutover or rollback procedures would be evaluated separately based on workload requirements.

---

## Documentation

### Engineering Case Study

The full engineering story covers the transition from manually coordinated migration to orchestration, design decisions, OIDC troubleshooting, validation strategy, and lessons learned.

**[Read the engineering case study on Medium](ADD-MEDIUM-ARTICLE-URL-HERE)**

### Technical Documentation

For the detailed implementation:

**[View Full Technical Documentation](docs/AWS-WordPress-Migration-Technical-Documentation.pdf)**

---

## Outcome

The project transformed a familiar migration process from **manually coordinated execution** into a repeatable workflow with:

**dynamic resource discovery → temporary authentication → controlled sequencing → automated migration → end-to-end validation**

The engineer still controls **what environment to migrate into and when to start**.

**The automation handles the repetitive execution required to complete it reliably.**