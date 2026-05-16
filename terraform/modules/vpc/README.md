# VPC Module

This module creates the network foundation for an environment.

## Resources

- VPC with DNS support and DNS hostnames enabled.
- Internet gateway.
- Public subnets across the requested availability zones.
- Public route table with a default route through the internet gateway.
- Route table associations for each public subnet.
- EKS control plane security group.
- ALB and microservices security group.

## Inputs

| Variable | Description |
| --- | --- |
| `environment` | Environment name used in names and tags. |
| `vpc_cidr` | CIDR block for the VPC. |
| `availability_zones` | Availability zones used to create public subnets. |
| `cluster_name` | Optional EKS cluster name used for Kubernetes subnet and VPC tags. |

## Outputs

- `vpc_id`
- `public_subnet_ids`
- `eks_cluster_security_group_id`
- `microservices_security_group_id`

## Notes

The public subnets are tagged with `kubernetes.io/role/elb = 1`, which allows
the AWS Load Balancer Controller to place internet-facing load balancers there.

The ALB security group currently opens HTTP, HTTPS, API gateway, Eureka,
Prometheus, and Grafana ports. Review these rules before using the module for a
production exposure model.