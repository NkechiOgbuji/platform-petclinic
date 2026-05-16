# EKS Module

This module creates the Kubernetes control plane, worker nodes, cluster OIDC
provider, and IAM roles needed by cluster add-ons.

## Resources

- EKS cluster IAM role.
- EKS cluster.
- EKS OIDC provider.
- Managed node group IAM role and managed node group.
- IRSA role for External Secrets Operator.
- IRSA role and policy for AWS Load Balancer Controller.
- IRSA role for the AWS EBS CSI driver.
- EKS add-ons:
  - `vpc-cni`
  - `kube-proxy`
  - `coredns`
  - `aws-ebs-csi-driver`

## Inputs

Key inputs:

- `cluster_name`
- `project_name`
- `environment`
- `cluster_version`
- `vpc_id`
- `subnet_ids`
- `cluster_security_group_ids`
- `endpoint_public_access`
- `endpoint_private_access`
- `enabled_cluster_log_types`
- Node sizing values: `node_instance_types`, `node_desired_size`,
  `node_min_size`, `node_max_size`, `node_disk_size`
- `github_actions_role_arn`
- `admin_role_arns`
- `tags`

## Outputs

- `cluster_name`
- `cluster_arn`
- `cluster_endpoint`
- `cluster_certificate_authority_data`
- `cluster_security_group_id`
- `node_security_group_id`
- `oidc_provider_arn`
- `oidc_provider_url`
- `node_role_arn`
- `external_secrets_role_arn`
- `lb_controller_role_arn`

## Access Model

This module creates IAM resources, but the environment root owns the
`aws-auth` ConfigMap. The root maps:

- the node role into Kubernetes node groups,
- the GitHub Actions role into `system:masters`,
- any additional admin role ARNs into `system:masters`.

## Add-On Relationship

This module creates IRSA roles and EKS-managed add-ons. The separate
`addons` module installs Helm charts such as External Secrets Operator, AWS Load
Balancer Controller, Argo CD, ExternalDNS, and kube-prometheus-stack.