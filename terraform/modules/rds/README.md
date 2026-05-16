# RDS Module

This module creates the Petclinic MySQL database and stores its generated
credentials in AWS Secrets Manager.

## Resources

- Random database password.
- DB subnet group.
- RDS security group.
- MySQL ingress from the EKS cluster security group.
- MySQL ingress from the EKS node security group.
- RDS MySQL instance.
- Secrets Manager secret and secret version for database connection values.

## Database Secret

The secret name is:

```text
petclinic/<environment>/terraform/database
```

The secret JSON includes:

- `username`
- `password`
- `host`
- `port`
- `dbname`
- `MYSQL_HOST`
- `MYSQL_USER`
- `MYSQL_PASSWORD`
- `MYSQL_DATABASE`

The `petclinic-secrets` Helm chart maps these values into the Kubernetes
`mysql-secret`.

## Inputs

| Variable | Description |
| --- | --- |
| `environment` | Environment name. |
| `vpc_id` | VPC where RDS security group is created. |
| `subnet_ids` | Subnets used by the DB subnet group. |
| `eks_security_group_id` | EKS cluster security group allowed to access MySQL. |
| `eks_node_security_group_id` | EKS node security group allowed to access MySQL. |
| `db_name` | Database name. |
| `db_username` | Master username. |
| `db_instance_class` | RDS instance class. |
| `db_allocated_storage` | Storage size in GB. |
| `multi_az` | Whether to enable Multi-AZ. |
| `backup_retention_period` | Backup retention in days. |

## Outputs

- `db_endpoint`
- `db_port`
- `db_name`
- `db_secret_arn`
- `db_secret_name`
- `db_security_group_id`

## Environment Behavior

For `dev`, final snapshots and deletion protection are disabled. For non-dev
environments, final snapshots and deletion protection are enabled.