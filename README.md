## Demo applicaton

A monorepo containing 3 tasks

## Part 1: Working with docker

Node application resides in the src folder. Tests for it reside in test folder.

To test:

```
npm test
```

to run:

```
npm start
```

Dockerfile is in the root folder. Docker image is built & pushed to AWS ECR after push to main/src, main/test or package.json

## Part 2: Working with CI/CD

You can observe pipeline in GitHub Actions folder .github. There are 3 pipelines:

- main.yaml - Builds & tests & pushes to the repo hello application
- demo-chart.yaml - Packages & pushed helm chart
- terraform.yaml - To manually run terraform apply/destroy to manage infrastructure

## Part 3: Working with Helm & Terraform

Helm chart is provided in demo-chart folder. It has it`s own pipeline
Terraform scripts atre in terraform folder.
Terraform state is stored in S3 bucket on AWS. So you can run terraform scripts locally & from github actions
It creates VPS, subnets, EKS cluster & installs needed roles to cluster and load balancer controller to K8s so
After terraform the application can be deployed without any issues and be exposed to public.

## Setup & running

To implement 2 and 3 step you must have valid AWS subscription with GitHub OIDC provider to IAM. ARN ow this role must be added to GitHub Actions Secrets. As well as the repo

Basically to reproduce the env there are such steps:

- Clone the repository and change secrets.
- Run terraform apply in the bootstrap folder to init S3 bucket. (For fresh install delete terraform.tfstate)
- Either locally or using GitHub actions run terraform apply (wait 20min)
- Login to AWS console or use AWS CLI.
- Install helm chart via Helm Chart action or manually:

```
helm install --set registry=$REGISTRY demo oci://$REGISTRY/demo-chart
```

- Test or use created cluster
