# AWS VPC Network with EC2 Instances (Public/Private Subnets)

### Prerequisites

1.  **Terraform:** Install Terraform (v1.0+ recommended).
2.  **AWS CLI:** Configure your AWS credentials with sufficient permissions (VPC, EC2, IAM) locally.


### Deployment Steps

1.  **Initialize Terraform:**
    ```bash
    terraform init
    ```

2.  **Review Variables:**
    Review the default values in `variables.tf`. For production deployments, it is recommended to create a custom variable file (e.g., `.tfvars`) to override the defaults.

    To use a custom file:
    ```bash
    # Create or modify your terraform.tfvars file
    # nano terraform.tfvars 
    ```

3.  **Plan the Deployment:**
    Generate an execution plan to see exactly what Terraform will create.
    ```bash
    terraform plan
    # If using a custom file:
    # terraform plan -var-file=".tfvars"
    ```

4.  **Apply the Configuration:**
    Execute the plan to create the AWS resources.
    ```bash
    terraform apply
    # If using a custom file:
    # terraform apply -var-file=".tfvars"
    ```
    Confirm the operation by typing `yes`.

5.  **Retrieve SSH Key:**
    After a successful apply, your private SSH key is stored in the Terraform state and echoed in the `private_key` output. **Securely save this key**, as it is required to access your EC2 instances.

### Cleanup

To destroy all resources created by this configuration:

```bash
terraform destroy