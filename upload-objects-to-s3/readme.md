# 🌐 AWS S3 Static Website with CloudFront (Terraform)

This project demonstrates how to deploy a **secure static website on AWS** using **Amazon S3**, **CloudFront**, and **Terraform**.
The setup follows AWS best practices by keeping the S3 bucket private and allowing access **only through CloudFront using Origin Access Control (OAC)**.

---

## 🚀 What This Project Does

The Terraform configuration provisions the following:

1. **Creates an S3 bucket**
2. **Blocks all public access** to the bucket
3. **Applies a bucket policy** allowing access only from CloudFront
4. **Configures CloudFront Origin Access Control (OAC)**
5. **Uploads multiple static files** to S3
6. **Enables S3 static website hosting**
7. **Serves the website globally via CloudFront**

---

## 🏗️ Architecture Overview

```
User
  ↓
CloudFront Distribution
  ↓ (OAC, SigV4)
Private S3 Bucket
```

* S3 bucket is **not public**
* CloudFront securely fetches objects using **OAC**
* Static files are served globally with low latency

---

## 📁 Project Structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── www/
│   ├── index.html
│   └── error.html
└── README.md
```

* `www/` contains static website files
* All files in `www/` are automatically uploaded to S3

---

## 🔐 Security Highlights

* ✅ **Public access blocked** on S3
* ✅ **No public bucket policy**
* ✅ **CloudFront Origin Access Control (OAC)** used instead of legacy OAI
* ✅ **Access restricted using `aws:SourceArn` condition**

---

## 🧩 Terraform Resources Used

* `aws_s3_bucket`
* `aws_s3_bucket_public_access_block`
* `aws_s3_bucket_policy`
* `aws_cloudfront_origin_access_control`
* `aws_cloudfront_distribution`
* `aws_s3_object`
* `aws_s3_bucket_website_configuration`

---

## ▶️ How to Deploy

### 1️⃣ Initialize Terraform

```bash
terraform init
```

### 2️⃣ Review the plan

```bash
terraform plan
```

### 3️⃣ Apply the configuration

```bash
terraform apply
```

---

## 🌍 Accessing the Website

After deployment, use the **CloudFront distribution domain name**:

```
https://<distribution-id>.cloudfront.net
```

(You can output this via Terraform if needed.)

---

## 🛠️ Notes & Improvements

* `viewer_protocol_policy` is currently set to `allow-all`

  * Can be changed to `redirect-to-https` for better security
* Custom domain + ACM certificate can be added later
* Cache behaviors can be tuned for performance

---

## 📚 Learning Outcomes

This project helped me practice:

* Secure S3 static website hosting
* CloudFront + OAC integration
* Writing restrictive S3 bucket policies
* Uploading multiple objects with Terraform
* Infrastructure as Code (IaC) using Terraform

---

## ✅ Status

✔ Working
✔ Secure
✔ Production-ready baseline

---

Feel free to clone, fork, or improve this setup 🚀

