# Terraform and infrastructure set-up and Configurations for TransFast client

> LAST MODIFY DATE: 9. Mar. 2022.

All the necessary configuration for this client, related to infrastructure will
be stored in this repository.

---

## TODO-s

1. Setup Readyness and livelyness k8s probes
2. Expose Grafana monitoring dashboard to a separate service/loadbalancer.
3. Re-examine resource requests/limits ~> Setup scaling as needed
4. Try to test e2e and performance if possible with k6

After all of that steps are done and dusted in this prod cluster:

1.  Look into the possibility for creation of Helm Chart for the full scale Syllo deployment
2.  In AWS staging cluster, test/explore possible solutions for IaC terraform pipeline

---

## DEPLOYMENT PROCEDURES

> This repository is used to deploy the code from the Syllo repository, there is no source code for Syllo project here.

### OVERRIDES

Folders `./deployment/packages/<service_name>` can contain override `.env.patch` files for each service. During the build/deploy stage, these files are merged with the `.env.dev` files set as defaults in Syllo project. This way we can set specific variables per each client. Override files should contail only the necessary overrides, everything else is taken from defaults in syllo project.

### ADDITIONS

Folders `./deployment/packages/<service_name>` can contain additional files that may be needed for this client, or in some extreme cases the file with the exact same file name as the file that needs to be completely replaced.

### DEPLOYMENT Overview

Before a deploy it may be a good idea to backup production Postgres DB with something like:

```sh
ssh -i ~/.ssh/correct_aws_ssh_key -f -N -L 5432:some_client-prod-rds.cluster-abc123456.eu-west-1.rds.amazonaws.com:5432 ec2-user@11.22.33.44 -v
pg_dump -c -C -Fp -O -U admin_user -h localhost -p 5432 database_name > desired_dump_file.sql
```

There is a _GitLab variable `$VERSION`_ that needs to be updated for each release, so that `.env` variables are _configured correctly_ and so that the _correct version_ of the code is pulled for building and deployment.

To _start the deployment_, under `GitLab Client Repo -> CI/CD -> Pipelines -> Run Pipeline` choose develop, stage or master branch and click `Run Pipeline`

- _DEVELOP_ branch: To deploy to `development` environment, this build will pull the code from `syllo/develop` branch, merge overrides within this repo and then build/deploy to the environment.

- _STAGE_ branch: To deploy to `staging` environment, this build will pull the code from `syllo/stage` branch, merge overrides within this repo and then build/deploy to the environment

- _MASTER_ branch: To deploy to `production` environment, this build will pull the code from `syllo/v$VERSION` tag, merge overrides within this repo and then build and push images to ECR repository. After this, a manual deployment is executed by modifying `Deployment` manifest documents in `./k8s-services` with the correct versions, url for the ECR repository, image version to deploy and any additional ENV settings or variables. Then deployment is initiated for each service with `kubectl apply -f <path_to_service_deployment.yml>`

### Deployment to production cluster

Directory `k8s-services` holds all necessary configurations to deploy all syllo microservices. Deployment is done by changing the version tag number in `<service_name>-deployment.yaml` file for each service being deployed, and updating `env` section with new or changed environment variables if needed.

Then, after connecting to _Pannovate Office VPN_:

- manual deployment is executed by modifying `Deployment` documents with the correct versions, url for the ECR repository, image version to deploy and any additional ENV settings or variables in `./k8s-services/*/<service_name>-deployment.yml`. If data is sensitive and needs protection, `base64` can be used to obscure this information and updated in `<service_name-secrets.yaml`.
- Then, deployment is initiated for each service with `kubectl apply -f <path_to_service_deployment.yml>`.
  - Optionally if new encrypted data is added to the `Secrets` document, run `kubectl apply -f <path_to_service_secrets.yml>` before deployment,
  - or if deployment is unchanged run `kubectl rollout restart deployment -n <service_name_space>` after secrets are applied.
- Check that everything is allright with `kubectl get pods -A` for no restarts
  and `kubectl logs <service-deployment-revision-number> -n <service-name-space>` for logs.

Deployment deploys the image to the cluster, creating new pods and terminating existing pods according to strategy defined in a deployment file. We are using `RollingUpdate` so, this way, there should be no downtime.

### UNDO LAST DEPLOYMENT

If the last deployment was restarting pods or there are errors in logs, the fastest way is to do a rollback of the deployment with:
`kubectl rollout undo deployment -n <service-name-space>`

### RESTART CURRENT DEPLOYMENT

Sometimes it may be necessary to manually restart a service (in this case a pod - furthermore the deployment that spinned up the pod(s)). This can happen for many reasons, but sometimes during the deployment of a new version, it can take a long time for automated process to terminate and spin up new pods, so if the pod seems stuck in the "CreatingContainer" phase, it can help to do the restart:
`kubectl rollout restart deployment -n <service-name-space>`

---

## Helpfull commands

- `kubectl get pods -n tnb-<service_namespace>` - shows brief state info for a service.
- `kubectl logs tnb-apigw-deployment-68ffd88ff6-6lwzh --container syllo-<container_name -n tnb-<service_namespace>` - shows the log file for a specified pod
- `kubectl describe pods -n <service_namespace>` - shows detailed information about each pod in a namespace
- `kubectl exec --stdin --tty <service_deployment> -n <service_namespace> -- /bin/sh` - attach directly to a running pod (docker)

---

## Services

Get service IP and port with:

```sh
kubectl get services -n <service_name>
```

api-gateway:

- 172.20.186.235
- server:
  - port: 10001
- alb:
  - port: 80, 443

as:

- 172.20.251.247 : 10004

config:

- 172.20.49.246 : 10008

cs:

- 172.20.34.44 : 10003

els:

- 172.20.135.187 : 10006

fs:

- 172.20.227.208 : 10007

kyc:

- 172.20.9.88 : 10002

mps:

- 172.20.254.12 : 10005

ps:

- 172.20.133.143 : 10014

pubsub:

- 172.20.201.176 : 10009

webhook:

- 172.20.167.47 : 10010

---

## Cluster initialization

1. Create the needed S3 bucket and DynamoDB for Terraform to store state. Or use Terragrunt and let it create them.

2. Create a cluster config file, and bootstrap the cluster with `eksctl`. This will, as a benefit, create all the necessary VPC resources and rules.

3. Creation of supporting resources

   a. Create Bastion/Jump-host to be able to access resources.

   Results in:

   ```sh
   Private-ip-address = "10.16.32.122"
   Public-ip-address = "3.250.56.46"
   SSH-Key-name = "transfast-aws_ed25519"
   ```

   b. Create AuroraRDS DB from `./prod/data-storage/aurora-rds`

   c. Create ElastiCache for Redis from `./prod/data-storage/redis`

   d. Create MongoDB from `./prod/data-storage/mongo`

   e. Create Rabbit MQ from `./prod/data-storage/rabbitmq`

   f. Create S3 buckets from `./prod/data-storage/s3-for_apps_uploads` for application uploads

   g. Create ECR repositories from `./prod/ecr-repos-creation`

4. Create Cluster services.

   Bring services up one by one by creating `namespace` and `service`, `secrets`, `deployment` etc. type documents and applying them with `kubectl`

   a. Create all required `namespaces` for the services with

   ```sh
   kubectl create ns <service_namespace_name_here>
   ```

   b. Create `Service` type yml document describing each service and apply them one by one with:

   ```sh
   kubectl apply -f <path_to_service_file>
   ```

   c. Use `kubectl describe service -n <service_namespace>` to find that service's IP and use it to configure parameters
   in each service's `Deployment` document under `spec.template.spec.containers.env` as per each service's requirements.

   d. Bring services up in the "least-dependencies" order for example:

   1. ELS

   2. FS

   3. WEBHOOK

   4. PS

   5. AS

   6. CONFIG

   7. PUBSUB

   8. CS

   9. MPS

   10. KYC

   11. APIGW

   This service also needs `ingres` controller with `load balancer` and needs:

   - Under `prod/acm-request-api` generate certificate for API domain name

   - Under `prod/eips` generate elastic IP addresses as needed

   e. Check for service health with:

   ```sh
   kubectl get pods -n <service_namespace>
   # and
   kubectl logs <service-deployment> -n <service_namespace>
   ```

5. Seed the Aurora RDS PostgreSQL DB

   In syllo repository folder edit all needed .env.dev files with correct credentials for `username, password, db name`

   Then run:

   ```sh
   npx lerna bootstrap
   npx lerna run build
   ```

   Now, connect to the DB:

   ```sh
   ssh -i ~/.ssh/transfast-aws_ed25519 -f -N -L 5432:transfast-rds.cluster-c9j5l7xdhlbt.eu-west-1.rds.amazonaws.com:5432 ec2-user@3.250.56.46 -v
   ```

   Run `yarn db:refresh` form syllo repository root (or `yarn db:seed` if some services are already up or something was already done in the DB)

6. Integrate Fluent Bit for logging to CloudWatch and S3 bucket, or Grafana, Prometheus, Loki, Promtail.

---

## Grafana Loki

Make sure you are in the correct context

```sh
$ kubectl config use-context transfast-stage-devops@transfast-stage.eu-west-1.eksctl.io
Switched to context "transfast-stage-devops@transfast-stage.eu-west-1.eksctl.io".
```

### Enabling AWS Application Load Balancer (ALB)

For **detailed instructions** visit GitHub page with the Helm chart: <https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller>

In short:

1. Setup IAM for service Account:

   - Setup IAM OIDC provider for correct **region** and **cluster-name**

   ```sh
   eksctl utils associate-iam-oidc-provider \
    --region eu-west-1 \
    --cluster transfast-stage \
    --approve
   ```

   - Download and apply IAM policy:

   ```sh
   curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

   aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam-policy.json
   ```

   > Take note of the policy ARN that is returned: arn:aws:iam::309602515679:policy/AWSLoadBalancerControllerIAMPolicy

   - Create a IAM role and ServiceAccount for the Load Balancer controller, use the ARN from the step above

   ```sh
   eksctl create iamserviceaccount \
     --cluster=transfast-stage \
     --namespace=kube-system \
     --name=aws-load-balancer-controller \
     --attach-policy-arn=arn:aws:iam::309602515679:policy/AWSLoadBalancerControllerIAMPolicy \
     --approve
   ```

   > If it fails with the message that the **iamserviceaccount** was excluded becouse the service already exist,
   > use the following command to find the arn of the role in the **kube-system** namespace,

   ```sh
   $ eksctl get iamserviceaccount --cluster=transfast-stage

   NAMESPACE     NAME        ROLE ARN
   karpenter     karpenter   arn:aws:iam::309602515679:role/eksctl-transfast-stage-iamservice-role
   kube-system   aws-node    arn:aws:iam::309602515679:role/eksctl-transfast-stage-addon-iamserviceaccou-Role1-127YSCLXVXUT0
   ```

   and then edit that role so that it contains the policy from the downloaded file above (`iam-policy.json`).

2. Add the EKS chart repo to helm

   ```sh
   helm repo add eks https://aws.github.io/eks-charts
   ```

3. Install the TargetGroupBinding CRDs if upgrading the chart via helm upgrade.

   ```sh
   kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
   ```

### Following **Karpenter** Getting Started, install Prometheus-Grafana stack

More information <https://karpenter.sh/v0.16.2/getting-started/getting-started-with-eksctl/>

```sh
helm repo add grafana-charts https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring

curl -fsSL https://karpenter.sh/"${KARPENTER_VERSION}"/getting-started/getting-started-with-eksctl/prometheus-values.yaml | tee prometheus-values.yaml
helm install --namespace monitoring prometheus prometheus-community/prometheus --values prometheus-values.yaml
```

For Grafana, first download the templated values file if it doesn't exist:

```sh
curl -fsSL https://karpenter.sh/"${KARPENTER_VERSION}"/getting-started/getting-started-with-eksctl/grafana-values.yaml | tee grafana-values.yaml
```

Then edit `grafana-values.yaml` to add ingress, dashboards, env values...
Finally, apply the Helm chart with the edited values file:

```sh
helm install --namespace monitoring grafana grafana-charts/grafana --set service.type=LoadBalancer --values grafana-values.yaml
```

Output after applying grafana helm chart

```test
NAME: grafana
LAST DEPLOYED: Mon Sep 26 06:26:16 2022
NAMESPACE: monitoring
STATUS: deployed
REVISION: 9
NOTES:
1. Get your 'admin' user password by running:

   kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

2. The Grafana server can be accessed via port 80 on the following DNS name from within your cluster:

   grafana.monitoring.svc.cluster.local

   If you bind grafana to 80, please update values in values.yaml and reinstallg:
   `
   securityContext:
     runAsUser: 0
     runAsGroup: 0
     fsGroup: 0

   command:
   - "setcap"
   - "'cap_net_bind_service=+ep'"
   - "/usr/sbin/grafana-server &&"
   - "sh"
   - "/run.sh"
   `
   Details refer to https://grafana.com/docs/installation/configuration/#http-port.
   Or grafana would always crash.

   From outside the cluster, the server URL(s) are:
     http://monitoring.transfast.stage.pannovate.net


3. Login with the password from step 1 and the username: admin
#################################################################################
######   WARNING: Persistence is disabled!!! You will lose your data when   #####
######            the Grafana pod is terminated.                            #####
#################################################################################
```

The Grafana instance may be accessed using port forwarding.
`kubectl port-forward --namespace monitoring svc/grafana 3000:80`

The new stack has only one user, admin, and the password is stored in a secret. The following command will retrieve the password.
`kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo`

### Next, add and install Helm charts for **Grafana-Loki-Stack**

```sh
$ helm repo add grafana https://grafana.github.io/helm-charts
"grafana" has been added to your repositories
```

### Finally install **Loki** and **Promtrail** into the EKS Cluster

```sh
$ helm upgrade --install loki grafana/loki-stack --version 2.8.2 --namespace monitoring --wait

Release "loki" does not exist. Installing it now.
W0922 11:46:41.302370 2822374 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
W0922 11:46:47.553361 2822374 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
NAME: loki
LAST DEPLOYED: Thu Sep 22 11:46:40 2022
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
NOTES:
The Loki stack has been deployed to your cluster. Loki can now be added as a datasource in Grafana.

See http://docs.grafana.org/features/datasources/loki/ for more detail.
```

## Fluent Bit To Cloud Watch Logs For CLuester Container logs

> <https://aws.amazon.com/blogs/containers/analyze-kubernetes-container-logs-using-amazon-s3-and-amazon-athena/>

We can start by setting a few environment variables:

```sh
export EKS_CLUSTER=<The name of your EKS cluster>
export AWS_REGION=<us-east-1 or your AWS Region>
export S3_BUCKET=<eks-fluentbit-logs-yourusername>
```

use aws profiles or apply those values to commands directly.

Use the AWS CLI to find out the name of EKS cluster by listing EKS clusters in your AWS Region:

```sh
aws eks list-clusters
```

First, the Fluent Bit pods need an IAM role to be able to write logs to the S3 bucket and CloudWatch Logs. We have to create and associate an OIDC provider with the EKS cluster so pods can assume IAM roles. eksctl can automate this with a single command:

```sh
eksctl utils associate-iam-oidc-provider \
    --cluster $EKS_CLUSTER \
    --approve
```

This should return something like:

```text
[ℹ] eksctl version 0.54.0
[ℹ] using region eu-west-1
[ℹ] will create IAM Open ID Connect provider for cluster "tnb-prod" in "eu-west-1"
[✔] created IAM Open ID Connect provider for cluster "tnb-prod" in "eu-west-1"
```

Now, create a Kubernetes service account in the cluster. This service account has an associated IAM role with permissions to write to S3 buckets and CloudWatch Logs. In production, you should create a fine-grained IAM policy that only permits writes to a specific S3 bucket.

```sh
eksctl create iamserviceaccount \
    --name fluent-bit \
    --namespace kube-system \
    --cluster $EKS_CLUSTER \
    --attach-policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess \
    --attach-policy-arn arn:aws:iam::aws:policy/CloudWatchFullAccess \
    --approve --override-existing-serviceaccounts
```

Results in similar:

```text
[ℹ]  eksctl version 0.54.0
[ℹ]  using region eu-west-1
[ℹ]  1 iamserviceaccount (kube-system/fluent-bit) was included (based on the include/exclude rules)
[!]  metadata of serviceaccounts that exist in Kubernetes will be updated, as --override-existing-serviceaccounts was set
[ℹ]  1 task: { 2 sequential sub-tasks: { create IAM role for serviceaccount "kube-system/fluent-bit", create serviceaccount "kube-system/fluent-bit" } }
[ℹ]  building iamserviceaccount stack "eksctl-tnb-prod-addon-iamserviceaccount-kube-system-fluent-bit"
[ℹ]  deploying stack "eksctl-tnb-prod-addon-iamserviceaccount-kube-system-fluent-bit"
[ℹ]  waiting for CloudFormation stack "eksctl-tnb-prod-addon-iamserviceaccount-kube-system-fluent-bit"
....
[ℹ]  created serviceaccount "kube-system/fluent-bit"

```

### Deploy Fluent Bit

Create the _required ClusterRole_ and _ClusterRoleBinding_ for Fluent Bit:

```sh
kubectl apply -f ./k8s-services/fluent-bit/00-eks-fluent-bit-daemonset-rbac.yaml

# or

kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-ecs-fluent-bit-daemon-service/mainline/eks/eks-fluent-bit-daemonset-rbac.yaml
```

It might return a warning:

```text
Warning: rbac.authorization.k8s.io/v1beta1 ClusterRole is deprecated in v1.17+, unavailable in v1.22+; use rbac.authorization.k8s.io/v1 ClusterRole
Warning: rbac.authorization.k8s.io/v1beta1 ClusterRoleBinding is deprecated in v1.17+, unavailable in v1.22+; use rbac.authorization.k8s.io/v1 ClusterRoleBinding
```

In a real-world use case, we can have many inputs and outputs. For example, we can send low priority raw logs to an _S3 bucket_ and send other logs to _Amazon CloudWatch_ (<https://aws.amazon.com/blogs/containers/kubernetes-logging-powered-by-aws-for-fluent-bit/>), or any _other Fluent Bit supported destination_ (<https://docs.fluentbit.io/manual/pipeline/outputs>).

Create a .yml file for _ConfigMap_ and use

```sh
kubectl apply -f ./k8s-services/fluent-bit/01-fluentbit-configmap.yml
```

The Fluent Bit S3 output plugin buffers data locally in its store_dir, which we have set to a directory on the node’s filesystem. We do this so that data will still be sent even if the Fluent Bit pod suddenly stops and restarts. We’ve set maximum file size and a timeout so that each uploaded file is never more than 30 MB, and data is uploaded at least once every 3 minutes (even if less than 30 MB have been received). Fluent Bit uses multipart uploads to send larger files in chunks; hence, only a minimal amount of data is buffered at any point in time.

The next step is to create the Fluent Bit DaemonSet, which runs a pod on each node in the Kubernetes cluster; this pod monitors the node’s filesystem for logs and buffers them to the destination.

We need to find out the image repository and version to create the Fluent Bit DaemonSet. We can use AWS Systems Manager to get this information:

```sh
aws ssm get-parameter --name \
      $(aws ssm get-parameters-by-path \
      --path /aws/service/aws-for-fluent-bit/ \
      --query 'Parameters[*].Name' \
      --output yaml | sort | sed 'x;$!d' | cut -d ' ' -f2) \
    --query 'Parameter.Value' --output text
```

This outputs something like:

```sh
906394416424.dkr.ecr.eu-west-1.amazonaws.com/aws-for-fluent-bit:latest
```

### Create the FluentBit DaemonSet

Create a yml file for DaemonSet and use:

```sh
kubectl apply -f ./k8s-services/fluent-bit/02-fluentbit-daemonset.yml
```

Verify that Fluent Bit Pods are running:

```sh
kubectl -n kube-system get ds fluentbit
```

you can check Fluent Bit logs to verify that logs are being pushed to S3 successfully.

```sh
for p in $(kubectl get pods \
    --namespace=kube-system \
    -l name=fluentbit -o name \
    ); \
do kubectl logs --namespace=kube-system $p; \
done | grep output:s3
```

### Check if logs are streaming

```sh
aws logs get-log-events --log-group-name "transfast-prod-cluster-logs" --log-stream-name from-fluent-bit-containerlogs
```

### Query logs using Athena

Fluent Bit is sending the logs that the sample application creates to the S3 bucket. Below, you will see the folder structure of the S3 bucket. Fluent Bit stores logs in Hive format and partitioned by date and time.

```log
eks-fluent-bit-logs
└── fluent-bit-logs
    └── states.ca
        └── 2020 <-- Year
            └── 10 <-- Month
                └── 27 <-- Date
                    ├── 21 <-- Hour
                    │   ├── 02 <-- Minute
                    │   │   ├── 25-<<log file>>
```

Further reading on the web site from the top of this note.

## Getting started for DevOps

To get started with the project AWS, Terraform, Terragrunt, eksctl and kubectl CLIs need to be installed and configured.
Before anything can be done, `AWS_PROFILE` environment variable needs to be properly set to correct credentials either by
`export AWS_PROFILE=tnb-devops`

or by prefixing each command to be executed with propper credentials.

Also to be able to get secure information from the Vault, the `VAULT_TOKEN` environment variable, or `~/.vault-token` file, need to be set with the valid and current token copied from the Vaults UI for the particular user. This token expires after a day (for now) but even so, the token should not be set anywhere inside the project.
`export VAULT_TOKEN=some-token-from-the-vault`

Also, Terraform needs to be initialized with:

```sh
# For Terraform
terraform init # or 'tf init' for shorthand
# or for Terragrunt
terragrunt init
```

in the root directory and in every `./<sub-directory>` that contains Terraform modules and needs work.

## Terraform Quick Start

1. AWS Account needs to be already created and at least 1 IAM user created with propper privileges.
2. Under AWS Secrets manager for each environment/region create new folder for each secrets group and add key/keys to it.
3. Then, in root of each environment do the following:
4. Edit `terragrunt.hcl` files and change **bucket names**, **region** and **dynamodb_table**.
5. Edit `variables.tfvars` files.
6. Run `terragrunt init` to create propper `backend.tf` and `provider.tf` files and download all modules and providers.
7. Run `terragrunt plan -var-file=variables.tfvars` to see if everything is good.
8. Run `terragrunt apply -var-file=variables.tfvars` to apply changes to the infrastructure.

## To Import existing AWS infrastructure into Terraform

### 1. Use [terraformer](https://github.com/GoogleCloudPlatform/terraformer)

To import all AWS resources into separate folder for each service (resource type), use:

```sh
terraformer import aws --resources="*" --profile=<your_profile> --regions=<your_region> --path-pattern={service}/
```

By Default, this generates TF files and STATE files in terraform 0.12 format.

To upgrade use:

```sh
terraform state replace-provider registry.terraform.io/-/aws hashicorp/aws
```

This command updates `tfstate` version from 3 to 4 which is compatibile with terraform 0.13+.

### 2. Use [Terraforming](https://github.com/dtan4/terraforming)

Unfortunately, this project is not alive but still has great functionality. There are some issues with terraforming because of its architecture. But, it is a great free and open-source tool written in Ruby. It helps to export existing AWS resources to Terraform style (tf, tfstate). Currently Terraforming requires Ruby 2.1 and supports Terraform v0.9.3 or higher. Install Terraforming by gem command.

```sh
gem install terraforming
```

Just like Terraform, Terraforming requires access to your AWS infrastructure to be able to export the configuration. Either `export` AWS credentials or use `--profile=<profile_name>`

For a list of supported AWS resources run:

```sh
terraforming --help
```

**To get AWS resource into TF** use for example:

```sh
terraforming ec2 --profile=<your_profile> > ec2.tf
```

**It creates `tags` wrongly so change:**

```yml
tags {
"Name" = "Some tag"
}
```

into

```yml
tags = {
Name = "Some Tag"
}
```

Now to let Terraform know which AWS resource that code block should map to use `terraform import`.

### 3. Use Terraform `import`

command to import existing infrastructure into Terraform state. It will find and import the specified resource into Terraform state file, allowing existing infrastructure to come under Terraform management without having to be initially created by Terraform.

```sh
terraform import [options] ADDR ID
```

Where:

- **ADDR** is the address of your Terraform’s defined resource to import to.
- **ID** is your AWS object ID.

```sh
terraform import aws_instance.my-instance i-1234567890987654321
```

Where:

- **my-instance** is the resource name in terraform file
- **i-1234567890987654321** is the actual EC2 instance ID from AWS

### 3. Check if import was successfull

```sh
terraform plan
```

If terraform does not show any changes to infrastructure as planned, than this confirms that resource definitions correspond to the active AWS resources.

**But**, it will probably show that something needs to be modified, created or destroyed, so update .tf files until there are no changes left to be applied.

## Helpful Resources

[Form Infrastructure to code](https://faun.pub/terraformer-5036241f90cc)
