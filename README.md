# Three-Tier Web Architecture on AWS

This repository provides a production-grade, highly available three-tier web application architecture on AWS, automated with Terraform.

## 🚀 Quick Start (One-Line)

You can deploy the entire infrastructure and application with a single command:

```bash
./scripts/deploy.sh
```

*Note: Ensure you have `terraform` and `aws-cli` installed and configured before running.*

## 📂 Project Structure

- **[src/](./src)**: Application source code.
    - **[backend/](./src/backend)**: Node.js Express API (Optimized with async/await & pooling).
    - **[frontend/](./src/frontend)**: React.js SPA.
    - **[nginx/](./src/nginx)**: Nginx configuration templates.
- **[terraform/](./terraform)**: AWS Infrastructure as Code (VPC, ALB, ASG, Aurora DB).
- **[docs/](./docs)**: Detailed guides and implementation steps.
- **[scripts/](./scripts)**: Automation scripts, including the `deploy.sh` master script.

For local running instructions, see **[docs/RUNNING.md](./docs/RUNNING.md)**.

