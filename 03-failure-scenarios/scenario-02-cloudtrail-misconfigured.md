# Scenario 02 – CloudTrail Misconfigured or Not Logging

## 1. Symptom

Security needs to investigate an action (for example, a change to an EC2 instance or IAM policy), but **no recent CloudTrail events are found**.

Possible indicators:

- CloudTrail console shows **no recent events**.
- S3 log bucket has no new objects for the last several hours.
- A security incident review finds gaps in historical logs.

## 2. Goal

Determine **why CloudTrail is not logging as expected**, and validate that:

- A multi-Region trail exists.
- It is actively logging.
- It writes to a secure S3 bucket.
- The S3 bucket policy actually allows CloudTrail to write.

## 3. Environment (This Lab)

- One AWS account.
- One VPC with public + private subnets, NAT, and an EC2 instance.
- A **single multi-Region CloudTrail trail**:
  - Name based on `${var.project_name}-cloudtrail`.
  - Sends logs to an S3 bucket:
    - `${var.project_name}-cloudtrail-logs-<random_suffix>`
  - Bucket has:
    - Versioning enabled
    - Server-side encryption enabled
    - Public access blocked
    - Bucket policy that allows `cloudtrail.amazonaws.com` to `GetBucketAcl` and `PutObject`.

## 4. Investigation Steps (How to Think About It)

1. **Check Trail Status**
   - Go to CloudTrail → *Trails*.
   - Is the trail **enabled** and **logging**?
   - Is it configured as **multi-Region**?

2. **Check S3 Bucket Configuration**
   - Is the S3 bucket shown in the trail config the same one you expect?
   - Does the bucket exist?
   - Is public access blocked?

3. **Check S3 Bucket Policy**
   - Confirm statements that:
     - Allow `cloudtrail.amazonaws.com` to call `s3:GetBucketAcl` on the bucket.
     - Allow `cloudtrail.amazonaws.com` to `s3:PutObject` into `AWSLogs/<account-id>/*` with condition `s3:x-amz-acl = bucket-owner-full-control`.

4. **Check for Recent Objects in S3**
   - Go to the log bucket → `AWSLogs/<account-id>/CloudTrail/`.
   - Confirm there are objects for **today’s date**.
   - If there are none:
     - Is CloudTrail logging turned off?
     - Is the trail pointing to the wrong bucket?
     - Is the S3 bucket policy missing or incorrect?

5. **Check CloudTrail Event History**
   - Use the **Event history** view.
   - Filter by:
     - Time range (last 1 hour / last 24 hours).
     - Event name (e.g., `StartInstances`, `StopInstances`).
   - If the event history is empty while you know actions were taken, something is wrong with logging.

## 5. Common Root Causes (In Real Environments)

Some realistic causes you might see:

- The trail was **stopped** or **deleted**.
- The trail is not **multi-Region**, and activity happened in another region.
- The trail was misconfigured to write to the wrong S3 bucket.
- S3 bucket policy denies CloudTrail writes.
- The trail is only logging **management events**, but the team expected data events.
- An SCP (service control policy) or org-level config changed behavior.

## 6. Root Cause in This Lab (If We Broke It on Purpose)

Examples of what could break logging here:

- Manually disabling logging on `${var.project_name}-cloudtrail`.
- Editing the trail to point at a **different** S3 bucket without updating the bucket policy.
- Deleting or modifying `aws_s3_bucket_policy.cloudtrail_logs` in Terraform and applying.

## 7. Remediation (Using Terraform)

For this lab, remediation would look like:

1. Ensure `aws_cloudtrail.main` is **present in Terraform** and applied.
2. Ensure the S3 bucket and bucket policy resources exist:
   - `aws_s3_bucket.cloudtrail_logs`
   - `aws_s3_bucket_policy.cloudtrail_logs`
3. Re-run:

   ```bash
   terraform plan
   terraform apply
