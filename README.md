# quickstart-ibm-filenet-content-manager
## IBM FileNet Content Manager on the AWS Cloud

**IBM FileNet Content Manager** enables you to create business apps with embedded content services, including content governance and lifecycle management, external file sharing, content collaboration, and video streaming.

This Quick Start reference deployment guide provides step-by-step instructions for deploying IBM FileNet Content Manager on the AWS Cloud. 

![Quick Start Architecture for IBM FileNet Content Manager](https://d0.awsstatic.com/partner-network/QuickStart/ibm-filenet-content-manager-architecture.png)

This Quick Start sets up the following:
- A highly available architecture that spans multiple Availability Zones.
- A VPC configured with public and private subnets, according to AWS best practices, to provide you with your own virtual network on AWS.
- In the public subnets:
  - Managed network address translation (NAT) gateways to allow outbound internet access for resources in the private subnets.
  - A Linux bastion host in an Auto Scaling group to allow inbound Secure Shell (SSH) access to EC2 instances in public and private subnets.
  - A remote desktop gateway host in an Auto Scaling group to provide secure remote access to instances in the private subnets.
- In the private subnets:
  - Active Directory domain controllers for Microsoft Active Directory deployed in two Availability Zones/private subnets for redundancy. The Active Directory service is used to provide Lightweight Directory Access Protocol (LDAP) services for the FileNet Content Manager components.
  - Oracle Database on an Amazon Relational Database Service (Amazon RDS) in a Multi-AZ configuration with asynchronous data replication among Availability Zones.FileNet Content Manager containers in an Amazon EKS cluster.
  - Amazon EFS, used as the underlying network file system, for configuration and content storage.

For architectural details, best practices, step-by-step instructions, and customization options, see the 
[deployment guide](https://fwd.aws/D975b).

To post feedback, submit feature ideas, or report bugs, use the **Issues** section of this GitHub repo.
If you'd like to submit code for this Quick Start, please review the [AWS Quick Start Contributor's Kit](https://aws-quickstart.github.io/).
