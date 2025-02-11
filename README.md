# AWS EKS **Auto Mode Private** Terraform 
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
  Login ec2 bastion host using private key ec2-bastion-key.pem
```

```cython
  aws configure 
  aws_access_key_id - The AWS access key part of your credentials
  aws_secret_access_key - The AWS secret access key part of your credentials
  aws_session_token - The session token part of your credentials (session tokens only)
```

```cython
  aws eks --region <region-code> update-kubeconfig --name <cluster_name>
```


```cython
  kubectl apply -f /home/ec2-user/k8s_resources/node-pool-amd.yaml
  kubectl apply -f /home/ec2-user/k8s_resources/deployment-amd.yaml
```

- Test your configuration.

- Check worker nodeclass and nodepools ready state True.
```cython
 kubectl get nodeclass
 kubectl get nodepools
```
```cython
  kubectl apply -f /home/ec2-user/k8s_resources/deployment-arm.yaml
  kubectl apply -f /home/ec2-user/k8s_resources/deployment-amd.yaml
```
- Check node auto-provisioning.
```cython
   kubectl get  nodeclaim
```
- Check kube events log.
```cython
   kubectl get events   --sort-by=.metadata.creationTimestamp --watch
```
- Check get pods.
```cython
   kubectl get pods 
```
- Check de-provisioning  node .
```cython
   kubectl delete deployment inflate-arm
```
- Check node de-provisioning.
```cython
   kubectl get  nodeclaim
```
## Deleting the cluster
Then delete the EKS related resources:

```
cd eks-cluster
terraform destroy -var-file="./environment/dev.tfvars"
cd -
```

