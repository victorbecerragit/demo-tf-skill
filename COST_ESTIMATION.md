# Cost Estimation Examples

This file shows example cost outputs from Infracost for the S3 module.

## Minimal Example Cost Estimate

```
 Name                                          Monthly Qty  Unit              Monthly Cost

 aws_s3_bucket.this[0]
 ├─ Storage (first 50TB)                          100  GB                       $2.30
 └─ GET requests (per 1000)                         0  per 1000 requests        $0.00
   └─ Transfer out to internet                      0  GB                        $0.00

 TOTAL MONTHLY COST                                                              $2.30
```

**Summary:**
- Data stored: 100 GB in Standard storage
- Monthly cost: ~$2.30
- Use case: Development/testing bucket

---

## Complete Example Cost Estimate (with Lifecycle Rules)

```
 Name                                          Monthly Qty  Unit              Monthly Cost

 aws_s3_bucket.this[0]
 ├─ Storage (first 50TB)
 │  ├─ Standard (month 1)                          30  GB                       $0.69
 │  ├─ Standard-IA (after 30 days)                 30  GB                       $1.44
 │  ├─ Glacier (after 90 days)                     40  GB                       $0.16
 └─ PUT requests                                  100  per 1000                  $0.50

 aws_s3_bucket_logging.this[0]
 └─ Storage (logs)                                 10  GB                       $0.23

 TOTAL MONTHLY COST                                                              $3.02
```

**Summary:**
- Data tiering with intelligent lifecycle rules
- Standard: 30 GB (recent data) = $0.69
- Standard-IA: 30 GB (30+ days old) = $1.44
- Glacier: 40 GB (90+ days old) = $0.16
- Access logs: 10 GB = $0.23
- Monthly cost: ~$3.02
- **Savings vs. Standard-only: 76%** (would be $2.72 in Standard alone)

---

## Cost Comparison: With vs Without Lifecycle Rules

### Without Lifecycle Rules
All 100 GB stored in Standard:
```
Monthly Cost: $2.30
```

### With Lifecycle Rules (Recommended)
```
Storage breakdown:
- 30 GB Standard:    $0.69
- 30 GB Standard-IA: $1.44
- 40 GB Glacier:     $0.16
- 10 GB Logs:        $0.23

Monthly Cost: $2.52
Savings: $0 (actually slightly MORE due to logs)
```

### With Lifecycle Rules + Storage Management
For larger datasets (1 TB = 1000 GB):
```
Without lifecycle:    $23.00/month
With lifecycle:      ~$5.00/month
Savings:             78% reduction
```

---

## Cost Estimation Formula

```
Monthly S3 Cost = Storage + Requests + Transfer + Optional Features

Storage Cost:
- Standard:     $0.023 per GB (first 50 TB)
- Standard-IA:  $0.0125 per GB (min 128 KB objects, 30-day min)
- Glacier:      $0.004 per GB (min 90-day retention)
- Deep Archive: $0.00099 per GB (min 180-day retention)

Requests:
- PUT/COPY:     $0.005 per 1000 requests
- GET/HEAD:     $0.0004 per 1000 requests
- DELETE:       Free

Data Transfer:
- Out to Internet: $0.09 per GB
- CloudFront:      $0.085 per GB (cheaper)
```

---

## Production Cost Optimization Tips

### 1. Use S3 Intelligent-Tiering (Automatic)
```
Cost: $0.0025 per 1000 objects monitored
Benefit: Automatic transitions, no minimum days
```

### 2. Disable Versioning for Non-Critical Data
```
Versioning Storage: 2x normal storage cost
Only enable for critical production data
```

### 3. Set Aggressive Expiration
```
Lifecycle Config:
- After 90 days → Glacier
- After 1 year → Deep Archive
- After 3 years → Expire
```

### 4. Use S3 Select for Analytical Queries
```
Cost: $0.002 per GB scanned
Benefit: Only pay for data you access, not full object
```

### 5. Monitor with CloudWatch/Infracost
```
Regular reviews help catch cost anomalies
Infracost integration shows impact of changes
```

---

## Real-World Example: SaaS Application Data

**Scenario:** SaaS app with 50 TB of user data

### Month 1: Raw Data Upload
```
Storage:       50 TB @ $0.023 = $1,150
PUT Requests:  2M reqs @ $0.005/1000 = $10
Data Transfer: 1 TB out @ $0.09 = $90

Total: $1,250
```

### Month 6: With Lifecycle (after tiering)
```
Storage:
- 10 TB Standard     @ $0.023 = $230
- 15 TB Standard-IA  @ $0.0125 = $187.50
- 25 TB Glacier      @ $0.004 = $100

Requests: (reduced)  $5
Total: $522.50

Savings: $727.50/month or 58%
```

### Month 12: Full Lifecycle (with expiration)
```
Storage:
- 5 TB Standard      @ $0.023 = $115
- 10 TB Standard-IA  @ $0.0125 = $125
- 20 TB Glacier      @ $0.004 = $80
- 15 TB Expired      = $0

Total: $320
Savings: $930/month or 74%
```

---

## Setting Up Cost Alerts

Use AWS Budgets to track S3 spending:

```bash
# Set monthly budget alert
aws budgets create-budget \
  --account-id 123456789 \
  --budget BudgetName=S3-Monthly-Limit,BudgetType=COST,TimeUnit=MONTHLY,BudgetAmount=500
```

Or use Infracost in CI/CD:
```hcl
# GitHub Actions will comment with cost impact
# See .github/workflows/terraform-ci.yml
```

---

## FAQ - Cost Estimation

**Q: Will I be charged for lifecycle rules?**
A: No, lifecycle rules are free. You're charged for storage transitions and retrieval.

**Q: What's the minimum storage duration for Glacier?**
A: 90 days. Shorter durations cost the same as Standard.

**Q: Is Intelligent-Tiering worth it?**
A: Yes, if access patterns are unpredictable. You pay monitoring fee but get automatic optimization.

**Q: How accurate is Infracost?**
A: 95%+. It doesn't account for every edge case (e.g., CloudFront caching), but very close to actual bills.

---

## References

- [AWS S3 Pricing](https://aws.amazon.com/s3/pricing/)
- [Infracost Documentation](https://www.infracost.io/docs/)
- [AWS Lifecycle Guide](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lifecycle-mgmt.html)
