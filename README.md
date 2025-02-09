# AWS EKS **Auto Mode** Terraform 
eks cluster auto mode with customized  node class and node pools with amd64 and arm64

This repo provides the Terraform configuration to deploy a demo app running on an AWS EKS Cluster with Auto Mode enabled, using best practices.

### Provisioning EKS Cluster
- Clone the repo 
```cython
  git clone https://github.com/ganislp/eks-cluster-auto-mode.git
```
- Go to `eks-cluster-auto-mode/teraaform-minifrsts` directory and initialize terraform
```cython
  cd /eks-cluster-auto-mode/teraaform-minifrsts/
  terraform init
```
- Create terraform workspace. Possible value `dev`, `prod`
```cython
  terraform workspace create dev
  terraform workspace select dev
```

### Make sure:

- Provide Existing vpc id 

- Private Subnet has the following tags
  ```cython
   kubernetes.io/cluster/<cluster-name> = shared
   Name = <cluster-name>-private-subnet
  ```

- Now deploy infra
```cython
  terraform apply -var-file="./environment/dev.tfvars"
```
**Following resources will be created once you apply terraform**

- EKS Cluster Auto Mode Enabled

### Connecting to your EKS Cluster

Now that we have all the resources needed in AWS, so we can connect to kubernetes cluster from management machine.
- Install kubectl. All the step to install kubectl can be found [here](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html).

```cython
  aws eks --region <region-code> update-kubeconfig --name <cluster_name>
```
- Test your configuration.
```cython
  kubectl get svc
```
- Check worker nodes by running.
```cython
  kubectl get nodes
```


## Deleting the cluster

First, delete the Kubernetes resources as shown below. This will give Ingress and Service related Load Balancers a chance to delete before the other AWS resources are removed.

Then delete the EKS related resources:

```
cd eks-cluster
terraform destroy -var-file="./environment/dev.tfvars"
cd -
```

