# 🚀 AWS VPC + EC2 + Apache using Terraform

This project demonstrates how to provision a **public AWS infrastructure** using **Terraform**, and automatically deploy an **Apache web server** on an **Ubuntu EC2 instance** using **user data**.

---

## 🧱 Architecture Overview

The infrastructure includes:

- Custom **VPC**
- **Public Subnet**
- **Internet Gateway**
- **Route Table** with internet access
- **Security Group** allowing SSH and HTTP
- **Ubuntu EC2 Instance**
- **Apache installed automatically via user_data**

---

## 📋 What I Built

### Project Structure
## 🗂 Project Structure

```bash
.
├── main.tf            # Core infrastructure resources
├── provider.tf        # AWS provider configuration
├── variables.tf       # Input variable definitions
├── terraform.tfvars   # Environment-specific variable values
├── locals.tf          # Local values for reuse and consistency
├── data.tf            # Data sources (AMI lookup, etc.)
├── outputs.tf         # Exported resource values
└── README.md          # Project documentation
```
### Generated key using aws cli
```bash
    aws ec2 create-key-pair \
    --key-name terraform-ec2-key \
    --key-format pem \
    --region eu-west-1 \
    --query 'KeyMaterial' \
    --output text > terraform-ec2-key.pem
```

### 1️⃣ Virtual Private Cloud (VPC)
- CIDR block: `10.0.0.0/16`
- Used as the private network boundary

### 2️⃣ Public Subnet
- Subnet created inside the VPC
- Associated with a route table that allows outbound internet traffic

### 3️⃣ Internet Gateway & Route Table
- Internet Gateway attached to the VPC
- Route table configured with:
- Subnet associated with this route table

### 4️⃣ Security Group
**Inbound rules**
- SSH (22) — allowed from a specific public IP
- HTTP (80) — allowed from anywhere

**Outbound rules**
- All traffic allowed

### 5️⃣ EC2 Instance
- Ubuntu AMI
- Instance type: `t3.micro`
- Public IP enabled
- Launched in the public subnet
- Security group attached
- Apache installed automatically using `user_data`

---

## 🧩 User Data (Apache Installation)

Apache is installed automatically at instance launch:

```bash
#!/bin/bash
apt update -y
apt install apache2 -y
systemctl start apache2
systemctl enable apache2

