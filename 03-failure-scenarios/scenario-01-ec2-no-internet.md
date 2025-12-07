# Scenario 01 – EC2 Cannot Reach the Internet

## 1. Symptom

An EC2 instance in the VPC cannot reach the internet.
Examples of this symptom (once connectivity tools are set up):

- `yum update` or `dnf update` fails
- `curl https://example.com` hangs or times out
- `ping 8.8.8.8` does not succeed

The instance is running, but it has **no outbound internet connectivity**.

## 2. Goal

Investigate and explain **why** the instance cannot reach the internet by tracing:

- The subnet it's in
- The route table associated with that subnet
- Whether there is a NAT Gateway or Internet Gateway in the path
- Security group / NACL egress controls

Then fix it in a later step by adding the right network path and documenting the lesson learned.

## 3. Environment (Before Failure)

- VPC: `10.0.0.0/16`
- Public subnet: `10.0.1.0/24` (route to Internet Gateway)
- Private subnet: `10.0.2.0/24` (no route to NAT Gateway yet)
- EC2 instance:
  - Launched in **private subnet**
  - No public IP
  - Security group allows outbound traffic

## 4. Investigation Steps (How a Cloud Engineer Thinks)

1. **Check the instance details**
   - Which subnet is it in? (public or private)
   - Does it have a public IP?
   - Which security group is attached?

2. **Check the subnet’s route table**
   - Open VPC → Subnets → select the instance’s subnet → Route table.
   - Look for a default route: `0.0.0.0/0`
   - Where does that default route point?
     - Internet Gateway?
     - NAT Gateway?
     - Nowhere?

3. **Determine whether the subnet is meant to be public or private**
   - Public subnet: route to Internet Gateway + public IPs on instances
   - Private subnet: route to NAT Gateway (for outbound-only traffic)

4. **Check if a NAT Gateway exists**
   - Is there a NAT Gateway in any public subnet?
   - Is there a route from private subnet → NAT → IGW?

5. **Check security controls**
   - Security group egress allows outbound `0.0.0.0/0`?
   - NACL allows outbound and return traffic?

## 5. Root Cause (For This Lab)

For this lab, the root cause is:

- The EC2 instance was deliberately placed in a **private subnet** that:
  - Does **not** have a route to a NAT Gateway
  - Only has local VPC routes (e.g., `10.0.0.0/16`)

Therefore, traffic never leaves the VPC and the instance cannot access the internet.

## 6. Remediation (Implemented in Terraform)

1. Added an Elastic IP and NAT Gateway in the public subnet.
2. Created a dedicated private route table with:
   - Route: 0.0.0.0/0 → NAT Gateway
3. Associated the private subnet with the private route table.
4. Kept the EC2 instance in the private subnet (no public IP), but it now has outbound-only internet access via the NAT Gateway.

This aligns with the standard AWS pattern:

- Public subnet(s): route to Internet Gateway.
- Private subnet(s): route to NAT Gateway in public subnet.


## 7. Lesson / Pattern

When an EC2 instance without a public IP cannot reach the internet, walk this chain:

1. Is the instance in a **private subnet**?
2. Does that subnet’s route table have a `0.0.0.0/0` route to a **NAT Gateway**?
3. Is that NAT Gateway in a **public subnet** with a route to an **Internet Gateway**?
4. Do security groups and NACLs allow outbound traffic and replies?

**Pattern:**

> Private subnet → Route table → NAT Gateway (in public subnet) → Route table → Internet Gateway → Internet

If any link in this chain is missing, outbound internet access fails.
