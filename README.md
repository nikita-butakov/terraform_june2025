# 🚀 Terraform AWS EC2 Nginx Monitoring Project

This project provisions a basic AWS infrastructure using **Terraform** to deploy two EC2 instances with Nginx. The Frontend instance includes custom CloudWatch monitoring for HTTP request metrics via a `systemd` timer and a Bash script.

---

## 📌 Features

- 🧩 Custom VPC, Subnet, Internet Gateway, and Route Table
- 🔐 Separate security groups for Frontend and Backend
- 💻 EC2 Frontend instance with:
  - Nginx + `stub_status`
  - Bash script to send custom metrics to CloudWatch:
    - `Nginx/TotalRequests`
    - `Nginx/RequestsPerMinute`
  - Scheduled via `systemd timer`
- 💻 EC2 Backend instance with basic Nginx
- ⚙️ Parameterized configuration with variables:
  - AWS region, AMI ID, instance type, key pair

---

## 📁 Project Structure

```
terraform_june2025/
├── main.tf               # Main infrastructure configuration
├── variables.tf          # Input variables
├── scripts/
│   ├── nginx_front.sh    # Frontend EC2 user_data (CloudWatch setup)
│   └── nginx_back.sh     # Backend EC2 user_data
└── README.md
```

---

## 🧾 Requirements

- Terraform v1.0+
- AWS CLI configured (`aws configure`)
- An SSH key pair uploaded to AWS (e.g., `terrakey`)
- IAM role named `EC2CloudWatchPutMetrics` with permission to push metrics to CloudWatch

---

## 🚀 Usage

1. **Initialize Terraform**
   ```bash
   terraform init
   ```

2. **Preview changes**
   ```bash
   terraform plan
   ```

3. **Apply infrastructure**
   ```bash
   terraform apply
   ```

4. **Access Outputs**

   After deployment, Terraform will output:
   - Frontend EC2 public IP
   - Backend EC2 public IP

5. **Monitor Metrics**

   Go to [AWS CloudWatch Console](https://console.aws.amazon.com/cloudwatch/) → **Metrics** → **Custom/Nginx** to view:
   - TotalRequests
   - RequestsPerMinute

---

## 🧹 Cleanup

To destroy all resources and avoid charges:

```bash
terraform destroy
```

---

## 🧠 Notes

- The Frontend instance exposes `/nginx_status` on port `8080`
- Metrics are collected every second via `systemd timer`
- Metrics are sent using the AWS CLI (ensure proper IAM permissions)

---

## 📸 Demo (Screenshots)

### CloudWatch: Nginx Frontend Metrics
You can see requests sent from the Nginx frontend:
![CloudWatch Metrics](/screenshots/cloudwatch.JPG)

### 📊 Custom Dashboard
Useful CloudWatch dashboard showing request statistics:
![Dashboard](/screenshots/dashboard.JPG)

### 🧾 Terraform Output
Final output after running `terraform apply`:
![Terraform Output](/screenshots/output.JPG)

---

## 👨‍💻 Author

**Nikita Butakov**  
DevOps • Cloud • Automation

- 🔗 [LinkedIn](https://www.linkedin.com/in/nikita-butakov/)  
- 🐙 [GitHub](https://github.com/nikita-butakov)
_This project was created for self-learning and AWS DevOps practice._

---

