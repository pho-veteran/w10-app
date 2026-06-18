# W10 Lab App

A note-taking web application with full AWS infrastructure, deployed via GitOps using ArgoCD on Minikube.

## Architecture

```
Internet → ALB → EC2 (private subnet) → Minikube → Kubernetes Pods
```

- **App**: Express.js API + static frontend running in K8s pods
- **Infrastructure**: Terraform-managed AWS (VPC, ALB, EC2, NAT, SSM)
- **GitOps**: ArgoCD syncs from [pho-veteran/w10-gitops](https://github.com/pho-veteran/w10-gitops)
- **Observability**: Prometheus + Grafana exposed via ALB
- **Deployments**: Argo Rollouts for progressive delivery

## Project Structure

```
├── app/                    # Express.js application
│   ├── server.js           # API server with Prometheus metrics
│   ├── server.test.js      # Tests (node:test)
│   ├── public/             # Static frontend (notes UI)
│   ├── scripts/build.js    # Build script → dist/
│   └── Dockerfile          # Container image
├── terraform/              # Main infrastructure stack
│   └── modules/
│       ├── network/        # VPC, subnets, NAT, IGW
│       ├── security/       # Security groups (ALB, EC2)
│       ├── ec2/            # Private instance, SSM, key pair
│       └── alb/            # Load balancer, listeners, targets
├── bootstrap/terraform/    # S3 state bucket + GitHub OIDC
├── .github/workflows/      # CI/CD pipeline
└── task.sh                 # Helper CLI for common operations
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| App | Node.js 20, Express 4, prom-client |
| Container | Docker, Docker Hub |
| Orchestration | Minikube, Kubernetes, Argo Rollouts |
| GitOps | ArgoCD, Kustomize |
| Infrastructure | Terraform, AWS (VPC, EC2, ALB, S3, IAM) |
| Observability | Prometheus, Grafana |
| CI/CD | GitHub Actions, OIDC |

## Quick Start

### App Development

```bash
cd app
npm install
npm test        # Run tests
npm start       # Start server (port 3000)
npm run build   # Build to dist/
```

### Infrastructure

```bash
# Bootstrap (first time only)
./task.sh bootstrap:validate
./task.sh bootstrap:apply

# Deploy infrastructure
./task.sh infra:apply

# Connect to EC2
./task.sh ssm          # SSM session
./task.sh ssh          # SSH access

# GitOps
./task.sh gitops:status
./task.sh gitops:sync
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/health` | Health check |
| GET | `/api/notes` | List all notes |
| POST | `/api/notes` | Create a note |
| DELETE | `/api/notes/:id` | Delete a note |
| GET | `/metrics` | Prometheus metrics |
| GET | `/api/debug/infra` | Infrastructure info |

## CI/CD Pipeline

Triggered on push to `main` or pull requests:

1. **Test** — lint, unit tests, build verification, Terraform validate
2. **Plan** — Terraform plan on PRs
3. **Publish** — Build & push Docker image, update GitOps repo image overlays with tag + digest
4. **Apply** — Terraform apply on infrastructure changes

### Required Secrets

| Secret/Variable | Purpose |
|----------------|---------|
| `AWS_GITHUB_ACTIONS_ROLE_ARN` | AWS OIDC role for Terraform |
| `DOCKERHUB_USERNAME` | Docker Hub registry auth |
| `DOCKERHUB_TOKEN` | Docker Hub registry auth |
| `GITOPS_REPO_TOKEN` | Push image overlay updates to GitOps repo |
| `TF_STATE_BUCKET` | S3 bucket for Terraform state |

## Infrastructure Details

- **Region**: `ap-southeast-1`
- **VPC CIDR**: `10.42.0.0/16`
- **EC2**: Private subnet, accessible via SSM only
- **ALB Ports**: 80 (app), 8080 (ArgoCD), 8081 (Grafana), 8082 (Prometheus)
- **State**: Remote S3 backend with versioning and encryption
