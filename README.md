# Secure AWS Architecture Lab – Cause & Effect Edition

## 1. Purpose

This lab is not about memorizing every AWS service.

It is about learning to **think like a cloud engineer** by:
- Tracing where things live
- Understanding **why** systems fail or work
- Seeing patterns instead of random services
- Observing how **one decision can impact the entire environment**

The goal: build, intentionally break, investigate, and secure a small AWS environment using
**infrastructure as code (Terraform), automation (Python), and core AWS services**.

This project doubles as:
- A personal learning lab  
- A portfolio piece for cloud / cloud security / DevOps roles  
- A living reference of real-world failure scenarios, root cause analysis, and remediations  

---

## 2. High-Level Architecture (AWS-Only)

This lab builds a small, realistic AWS environment:

- **VPC**
  - 1 public subnet (for bastion / NAT)
  - 1 private subnet (for application EC2 instance)
  - Internet Gateway + NAT Gateway
  - Route tables for public and private subnets

- **Compute**
  - EC2 instance in private subnet (application)
  - Optional bastion host in public subnet for SSH access

- **Storage & Logging**
  - S3 bucket for centralized logs
  - AWS CloudTrail sending logs to S3
  - (Later) Additional logs: VPC Flow Logs, application logs

- **Security & IAM**
  - IAM roles for EC2, CloudTrail, logging
  - Least-privilege policies where possible
  - Security groups for controlled access in and out

- **Automation**
  - Terraform to provision the environment
  - Python scripts to detect misconfigurations (e.g., public S3 buckets, missing CloudTrail)

---

## 3. Learning Philosophy – Cause & Effect

Instead of “learn VPC” or “learn IAM” in isolation, this lab focuses on:

- **Starting from problems:**
  - “EC2 instance cannot reach the internet.”
  - “S3 bucket is accidentally public.”
  - “CloudTrail logs stopped showing new events.”

- **Following dependency chains:**
  - Identity → Permission → Network Path → Resource → Logs

- **Making intentional misconfigurations:**
  - Overly permissive IAM policies
  - Misconfigured security groups or NACLs
  - Public S3 access
  - Broken routing or missing NAT

Each scenario includes:
1. **The symptom** (what looks broken)
2. **The investigation steps** (how a cloud engineer thinks through it)
3. **The root cause** (the real issue under the hood)
4. **The remediation** (how to fix it)
5. **The lesson / pattern** (what to remember for next time)

---

## 4. Tech Stack

- **Cloud:** AWS
- **IaC:** Terraform
- **Automation / Scripting:** Python
- **OS:** Linux (EC2 instances)
- **Core AWS Services:**
  - VPC, Subnets, Route Tables, IGW, NAT Gateway
  - EC2
  - S3
  - CloudTrail
  - IAM

---

## 5. Repository Layout

- `01-architecture/`  
  High-level design, threat model, and data flow documentation.

- `02-infra-terraform/`  
  Terraform configuration for the environment (networking, compute, logging, IAM).

- `03-failure-scenarios/`  
  Realistic misconfigurations and outages with investigation + root cause walkthroughs.

- `04-automation/`  
  Python scripts and other tools that analyze the environment and detect issues.

- `05-evidence/`  
  Screenshots, sample logs, and notes captured while running scenarios.

---

## 6. How to Use This Lab

1. **Deploy the baseline environment** using Terraform in `02-infra-terraform/`.
2. **Run a failure scenario** from `03-failure-scenarios/`:
   - Introduce the misconfiguration (manually or via Terraform changes).
   - Observe what breaks.
3. **Investigate like a cloud engineer:**
   - Check IAM policies
   - Check networking & routes
   - Check security groups / NACLs
   - Check CloudTrail and other logs
4. **Fix the issue**, then document:
   - Root cause
   - Exact fix
   - What pattern or lesson it represents
5. **(Optional) Automate detection** with a Python script in `04-automation/`.

---

## 7. Future Enhancements

Planned expansions:

- Add VPC Flow Logs and analyze traffic for specific scenarios
- Integrate Security Hub and GuardDuty
- Add SNS or EventBridge for alerting
- Expand failure scenarios to cover:
  - Over-permissive IAM role exploitation
  - Data exfiltration patterns
  - Logging gaps and blind spots

---

## 8. Status

- [ ] Baseline Terraform environment created
- [ ] First EC2 + VPC + S3 + CloudTrail deployed
- [ ] Scenario 1: EC2 no internet – documented
- [ ] Scenario 2: Public S3 bucket – documented
- [ ] Python automation for detection started

This project is a work in progress and intentionally iterative.  
Each commit should represent a clearer understanding of **how cloud systems really behave**, not just new services learned.
