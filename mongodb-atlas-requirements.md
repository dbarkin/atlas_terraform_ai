# MongoDB Atlas on GCP: Requirements Specification

## 1. Introduction

This document outlines the functional and non-functional requirements for deploying MongoDB Atlas on Google Cloud Platform (GCP) using Terraform and GitHub Actions as the infrastructure-as-code (IaC) deployment pipeline.

## 2. Functional Requirements

### 2.1 Authentication and Access Management

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-1.1 | The system must authenticate with MongoDB Atlas using API keys | High |
| FR-1.2 | API keys must be stored securely and not be visible to users | High |
| FR-1.3 | The system must support passing organization ID and project ID as parameters to Terraform | High |
| FR-1.4 | Project users and roles must be assigned based on Google Cloud Identity Provider (IdP) | High |
| FR-1.5 | Database users must be predefined with unique passwords generated for each Terraform run | High |

### 2.2 Network Configuration

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-2.1 | The system must configure private endpoints for MongoDB Atlas connectivity | High |
| FR-2.2 | The system must create appropriate IP access lists for secure connectivity | High |
| FR-2.3 | The system must support network peering between GCP VPC and MongoDB Atlas. Comment: explicit VPC peering configuration could be clarified. | Medium |

### 2.3 Cluster Configuration

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-3.1 | The system must deploy MongoDB Atlas clusters across specified regions | High |
| FR-3.2 | The system must allow users to specify MongoDB Atlas cluster size via parameter | High |
| FR-3.3 | The system must configure a replica set with 3 members | High |
| FR-3.4 | The system must deploy 2 replica members in NORTH_AMERICA_NORTHEAST_2 region | High |
| FR-3.5 | The system must deploy 1 replica member in NORTH_AMERICA_NORTHEAST_1 region | High |
| FR-3.6 | The system must configure clusters across different Availability Zones | High |

### 2.4 Backup and Disaster Recovery

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-4.1 | The system must configure MongoDB Atlas automated backups with 7-day retention | High |
| FR-4.2 | The system must meet Recovery Time Objective (RTO) of 8 hours | High |
| FR-4.3 | The system must meet Recovery Point Objective (RPO) of 15 minutes via MongoDB Atlas backups | High |

### 2.5 Infrastructure as Code

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-5.1 | All infrastructure must be deployed using Terraform | High |
| FR-5.2 | Terraform state must be stored in a Google Cloud Storage bucket | High |
| FR-5.3 | Terraform state must implement a locking mechanism to prevent concurrent modifications | High |
| FR-5.4 | The system must support modular Terraform configuration for reusability | Medium |

## 3. Non-Functional Requirements

### 3.1 Security

| ID | Requirement | Priority |
|----|-------------|----------|
| NFR-1.1 | All sensitive information must be stored as secrets in GitHub Actions | High |
| NFR-1.2 | Database credentials must never be exposed in logs or outputs | High |
| NFR-1.3 | All network traffic between application and MongoDB Atlas must be encrypted | High |
| NFR-1.4 | Access to MongoDB Atlas must be restricted to authorized networks only | High |

### 3.2 Scalability

| ID | Requirement | Priority |
|----|-------------|----------|
| NFR-2.1 | The infrastructure must support automatic scaling of disk storage | Medium |
| NFR-2.2 | The Terraform configuration must support multiple environments (dev, test, prod) | Medium |
| NFR-2.3 | The infrastructure must support future expansion to additional regions | Low |

### 3.3 Reliability

| ID | Requirement | Priority |
|----|-------------|----------|
| NFR-3.1 | The system must maintain the specified RTO of 8 hours | High |
| NFR-3.2 | The system must maintain the specified RPO of 15 minutes | High |
| NFR-3.3 | The Terraform scripts must ensure the cluster maintains high availability during normal operations | High |

### 3.4 Performance

| ID | Requirement | Priority |
|----|-------------|----------|
| NFR-4.1 | The MongoDB Atlas cluster must be sized appropriately for the workload | Medium |
| NFR-4.2 | The system must support monitoring of cluster performance metrics | Medium |

### 3.5 CI/CD Pipeline

| ID | Requirement | Priority |
|----|-------------|----------|
| NFR-5.1 | The GitHub Actions workflow must include separate stages for init, plan, and apply | High |
| NFR-5.2 | The CI/CD pipeline must require approval before applying changes to production | High |
| NFR-5.3 | The pipeline must validate Terraform configurations before deployment | High |
| NFR-5.4 | The pipeline must support rolling back changes in case of failure | Medium |

### 3.6 Maintainability

| ID | Requirement | Priority |
|----|-------------|----------|
| NFR-6.1 | The Terraform code must be well-documented with comments | Medium |
| NFR-6.2 | The Terraform modules must follow a consistent naming convention | Medium |
| NFR-6.3 | The system must support versioning of infrastructure configurations | Medium |

## 4. Technical Constraints

| ID | Constraint | Description |
|----|------------|-------------|
| TC-1 | Terraform Version | Terraform version >= 1.0.0 |
| TC-2 | MongoDB Atlas Provider | MongoDB Atlas Terraform Provider version ~> 1.12.0 |
| TC-3 | GCP Services | Limited to GCP services available in NORTH_AMERICA_NORTHEAST_1 and NORTH_AMERICA_NORTHEAST_2 regions |
| TC-4 | GitHub Actions | GitHub-hosted runners for the CI/CD pipeline |

## 5. Implementation Approach

### 5.1 Terraform Modules Structure

```
├── modules/
│   ├── atlas-project/
│   ├── atlas-cluster/
│   ├── atlas-user/
│   ├── atlas-network/
│   └── gcp-resources/
├── environments/
│   ├── dev/
│   ├── test/
│   └── prod/
├── variables.tf
├── outputs.tf
└── main.tf
```

### 5.2 GitHub Actions Workflow Structure

```yaml
name: MongoDB Atlas Terraform

name: 'Terraform MongoDB Atlas'

on:
  push:
    branches: [ main ]
    paths:
      - 'terraform/**'
  pull_request:
    branches: [ main ]
    paths:
      - 'terraform/**'
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy (dev, staging, prod)'
        required: true
        default: 'dev'
        type: choice
        options:
          - dev
          - staging
          - prod
      cluster_size:
        description: 'MongoDB Atlas cluster size'
        required: true
        default: 'M10'
        type: choice
        options:
          - M10
          - M20
          - M30
          - M40
          - M50

permissions:
  contents: read
  pull-requests: write

env:
  TF_VAR_environment: ${{ github.event.inputs.environment || 'dev' }}
  TF_VAR_mongodb_atlas_cluster_size: ${{ github.event.inputs.cluster_size || 'M10' }}
  TF_LOG: INFO

jobs:
  terraform:
    name: 'Terraform'
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment || 'dev' }}
    
    defaults:
      run:
        shell: bash
        working-directory: ./terraform/environments/${{ github.event.inputs.environment || 'dev' }}

    steps:
    - name: Checkout
      uses: actions/checkout@v3

    - name: Auth to Google Cloud
      uses: google-github-actions/auth@v1
      with:
        credentials_json: ${{ secrets.GCP_SA_KEY }}

    - name: Set up Cloud SDK
      uses: google-github-actions/setup-gcloud@v1

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.3.0
        cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}

    - name: Terraform Format
      run: terraform fmt -check
      continue-on-error: false

    - name: Terraform Init
      id: init
      run: |
        terraform init \
          -backend-config="bucket=${{ secrets.TF_STATE_BUCKET }}" \
          -backend-config="prefix=terraform/${TF_VAR_environment}"

    - name: Terraform Validate
      id: validate
      run: terraform validate

    - name: Terraform Plan
      id: plan
      env:
        TF_VAR_mongodb_atlas_public_key: ${{ secrets.MONGODB_ATLAS_PUBLIC_KEY }}
        TF_VAR_mongodb_atlas_private_key: ${{ secrets.MONGODB_ATLAS_PRIVATE_KEY }}
        TF_VAR_mongodb_atlas_org_id: ${{ secrets.MONGODB_ATLAS_ORG_ID }}
        TF_VAR_mongodb_atlas_project_id: ${{ secrets.MONGODB_ATLAS_PROJECT_ID }}
        TF_VAR_gcp_project_id: ${{ secrets.GCP_PROJECT_ID }}
      run: terraform plan -no-color -input=false -out=tfplan
      continue-on-error: true

    - name: Update Pull Request
      uses: actions/github-script@v6
      if: github.event_name == 'pull_request'
      env:
        PLAN: "terraform\n${{ steps.plan.outputs.stdout }}"
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }}
        script: |
          const output = `#### Terraform Plan 📝\`${{ steps.plan.outcome }}\`
          
          <details><summary>Show Plan</summary>
          
          \`\`\`\n
          ${process.env.PLAN}
          \`\`\`
          
          </details>
          
          *Pushed by: @${{ github.actor }}, Action: \`${{ github.event_name }}\`*`;
          
          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: output
          })

    - name: Create Deployment Approval
      uses: trstringer/manual-approval@v1
      if: github.ref == 'refs/heads/main' && github.event_name == 'push' && (env.TF_VAR_environment == 'staging' || env.TF_VAR_environment == 'prod')
      with:
        secret: ${{ secrets.GITHUB_TOKEN }}
        approvers: ${{ vars.REQUIRED_APPROVERS }}
        minimum-approvals: 1
        issue-title: "Deploy to ${{ env.TF_VAR_environment }} environment"
        issue-body: "Please approve or deny the deployment to ${{ env.TF_VAR_environment }}"

    - name: Terraform Apply
      if: github.ref == 'refs/heads/main' && github.event_name == 'push'
      env:
        TF_VAR_mongodb_atlas_public_key: ${{ secrets.MONGODB_ATLAS_PUBLIC_KEY }}
        TF_VAR_mongodb_atlas_private_key: ${{ secrets.MONGODB_ATLAS_PRIVATE_KEY }}
        TF_VAR_mongodb_atlas_org_id: ${{ secrets.MONGODB_ATLAS_ORG_ID }}
        TF_VAR_mongodb_atlas_project_id: ${{ secrets.MONGODB_ATLAS_PROJECT_ID }}
        TF_VAR_gcp_project_id: ${{ secrets.GCP_PROJECT_ID }}
      run: terraform apply -auto-approve -input=false tfplan

    - name: Output MongoDB Connection Info
      if: github.ref == 'refs/heads/main' && github.event_name == 'push'
      run: |
        echo "MongoDB cluster deployment completed."
        echo "Cluster ID: $(terraform output -raw mongodb_cluster_id)"
        echo "Environment: ${{ env.TF_VAR_environment }}"
        echo "Cluster size: ${{ env.TF_VAR_mongodb_atlas_cluster_size }}"

    - name: Notify on Failure
      if: failure()
      uses: slackapi/slack-github-action@v1.23.0
      with:
        slack-bot-token: ${{ secrets.SLACK_BOT_TOKEN }}
        channel-id: 'deployments'
        text: "Terraform deployment to ${{ env.TF_VAR_environment }} failed. Check GitHub Actions run: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}"
```

## 6. Success Criteria

| ID | Criteria | Validation Method |
|----|----------|-------------------|
| SC-1 | MongoDB Atlas cluster is successfully deployed with the required configuration | Manual verification in MongoDB Atlas UI |
| SC-2 | Private endpoints are properly configured and accessible | Network connectivity tests |
| SC-3 | Backup and restore capabilities meet the specified RTO and RPO | Disaster recovery testing |
| SC-4 | CI/CD pipeline successfully deploys infrastructure changes | Review of GitHub Actions workflow runs |
| SC-5 | Users can be authenticated via Google Cloud IdP | Authentication testing |

## 7. Architecture Design

Modularity: The Terraform configuration is well-structured with modules for project, cluster, users, and network, aligning with the proposed structure in the requirements. However, the gcp-resources module isn’t explicitly separated—GCP resources are embedded in atlas-network and atlas-user.
Environment Separation: The workflow supports environment-specific deployments (dev, staging, prod) via variables, but the Terraform directory structure doesn’t fully reflect the environments/ folder approach suggested in the requirements.
High Availability: The 3-node replica set across two regions ensures HA, with appropriate priority settings (7 and 6) for election.
Networking: Private endpoints and IP access lists provide a secure architecture, though the CIDR block (10.0.0.0/16) should be validated against the actual GCP VPC configuration.

## 8. Security

Strengths: Sensitive data is well-protected (secrets, sensitive outputs, Secret Manager). Private endpoints enforce encrypted, restricted access.
Concerns:
The IP access list CIDR (10.0.0.0/16) is broad; consider tightening it to specific subnets.
No explicit audit logging or security group monitoring is configured (though Atlas may provide this).

## 9. Scalability

Strengths: Disk auto-scaling and cluster size options (M10-M200) provide flexibility. Multi-environment support is robust.
Concerns: No explicit provision for horizontal scaling (e.g., sharding beyond num_shards = 1) or additional regions beyond the initial two.

## 10. Maintainability

Strengths: Consistent naming and modular design aid maintainability. GitHub Actions workflow is clear and well-staged.
Concerns: Lack of detailed comments in Terraform files hinders onboarding and debugging. The absence of a rollback mechanism in the pipeline could complicate recovery.
