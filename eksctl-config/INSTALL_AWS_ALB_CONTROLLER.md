# Installing AWS Load Balancer Controller v2.4

## Prerequisites

### Supported Kubernetes versions

- AWS Load Balancer Controller v2.0.0~v2.1.3 requires Kubernetes 1.15+
- AWS Load Balancer Controller v2.2.0~v2.3.1 requires Kubernetes 1.16-1.21
- AWS Load Balancer Controller v2.4.0+ requires Kubernetes 1.19+

### Additional requirements for non-EKS clusters

- Ensure subnets are tagged appropriately for auto-discovery to work
- For IP targets, pods must have IPs from the VPC subnets. You can configure the amazon-vpc-cni-k8s plugin for this purpose.

> The **old** AWS ALB Ingress controller must be uninstalled before installing the AWS Load Balancer Controller. Please follow [official migration guide](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/deploy/upgrade/migrate_v1_v2/) to do a migration.

1. Check which version is installed - if any.

   ```sh
   # For old versions
   $ kubectl describe deployment -n kube-system  alb-ingress-controller | grep Image
       Image:      docker.io/amazon/aws-alb-ingress-controller:v1.1.9

   # Or for new versions
   $ kubectl describe deployment -n kube-system  aws-load-balancer-controller | grep Image
       Image:       public.ecr.aws/eks/aws-load-balancer-controller:v2.4.7
   ```

2. If there is AWSALBIngressController version >=v1.1.3 and <v2.x, unninstall it first.

   > Existing Ingress resources do not need to be destroyed

3. Proceed with the installation described in this document

## This is a **Short** and possibly **_not complete_** info for **adding AWS Load balancer controler** to the EKS k8s Cluster

> [AWS-LoadBalancer-Controller code on GitHub](https://github.com/kubernetes-sigs/aws-load-balancer-controller)

> [AWS-LoadBalancer-Controller V2.4 LIVE DOCs](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/)

---

## Steps

[Official pages][awsalbdoc]

The AWS Load Balancer controller (LBC) provisions AWS Network Load Balancer (NLB) and Application Load Balancer (ALB) resources. The LBC watches for new service or ingress Kubernetes resources and configures AWS resources.

The LBC is supported by AWS. Some clusters may be using the legacy "in-tree" functionality to provision AWS load balancers. The AWS Load Balancer Controller should be installed instead.

1. Create an IAM OIDC provider and associate it with cluster using `eksctl`. It is possible that one already exists.

   > The command line parameter `--profile` can be ommited if the AWS CLI was propperly configured with profiles credentials and then in the working terminal we can run:
   > `$ export AWS_PROFILE=transfast-devops` to enable the same profile for all following commands in that terminal session.

   ```sh
   # Get cluster name
   eksctl get cluster --profile <AWS_CLI_PROFILE_WITH_CORRECT_ACCESS>

   # Create the provider
   eksctl utils associate-iam-oidc-provider --cluster=<YOUR_CLUSTER_NAME> --approve --profile <AWS_CLI_PROFILE_WITH_CORRECT_ACCESS>
   ```

   For our client "Transfast" it would be lite this:

   ```sh
   $ eksctl get cluster --profile transfast-devops
   NAME       REGION     EKSCTL CREATED
   transfast  eu-west-1  True

   $ eksctl utils associate-iam-oidc-provider --region eu-west-1 --cluster transfast --approve --profile transfast-devops
   2023-04-07 09:32:07 [ℹ]  IAM Open ID Connect provider is already associated with cluster "transfast" in "eu-west-1"
   ```

   Since we create our clusters with `eksctl` and the config specifies nodes from different subnets, I suspect that during that process some of the resources are propperly installed and configured (NPB for example), but all of them (ALB for example).

   Learn more about [IAM Roles for Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) in the Amazon EKS documentation.

2. Configure IAM

   The controller runs on the worker nodes, so it **needs access to the AWS ALB/NLB APIs with IAM permissions**.

   The IAM permissions can either be setup using IAM roles for service accounts (IRSA) or can be **attached directly to the worker node IAM roles. This is the recommended method if you're using Amazon EKS**. If you're using kOps or self-hosted Kubernetes, you must manually attach polices to node instances.

   ```sh
   # At the minimum, the following policy should be applied:
   curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy.json

   # Create the policy:
   $ aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam-policy.json
          "Shows a JSON document describing the policy creation"

   # Check if the policy is indeed succesfully created and present in the AWS account
   $ aws iam list-policies| grep -i LoadBalancer
               "PolicyName": "AWSLoadBalancerControllerIAMPolicy",
               "Arn": "arn:aws:iam::458838185766:policy/AWSLoadBalancerControllerIAMPolicy",

   # Use this new policy ARN to create `IAM ROLE` and `Kubernetes Service` Account for the Cluster
   $ eksctl create iamserviceaccount --cluster=transfast --namespace=kube-system --name=aws-load-balancer-controller --attach-policy-arn=arn:aws:iam::458838185766:policy/AWSLoadBalancerControllerIAMPolicy --approve

    2023-04-07 13:02:19 [ℹ]  3 existing iamserviceaccount(s) (karpenter/karpenter,kube-system/aws-node,kube-system/fluent-bit) will be excluded
    2023-04-07 13:02:19 [ℹ]  1 iamserviceaccount (kube-system/aws-load-balancer-controller) was included (based on the include/exclude rules)
    2023-04-07 13:02:19 [!]  serviceaccounts that exist in Kubernetes will be excluded, use --override-existing-serviceaccounts to override
    2023-04-07 13:02:19 [ℹ]  1 task: {
      2 sequential sub-tasks: {
          create IAM role for serviceaccount "kube-system/aws-load-balancer-controller",
          create serviceaccount "kube-system/aws-load-balancer-controller",
      } }2023-04-07 13:02:19 [ℹ]  building iamserviceaccount stack "eksctl-transfast-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
    2023-04-07 13:02:19 [ℹ]  deploying stack "eksctl-transfast-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
    2023-04-07 13:02:19 [ℹ]  waiting for CloudFormation stack "eksctl-transfast-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
    2023-04-07 13:02:49 [ℹ]  waiting for CloudFormation stack "eksctl-transfast-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"

   $ eksctl get iamserviceaccount --cluster=transfast
     NAMESPACE    NAME                          ROLE ARN
     karpenter    karpenter                     arn:aws:iam::458838185766:role/eksctl-transfast-iamservice-role
     kube-system  aws-load-balancer-controller  arn:aws:iam::458838185766:role/eksctl-transfast-addon-iamserviceaccount-kub-Role1-BSNS6KQCPSGH
     kube-system  aws-node                      arn:aws:iam::458838185766:role/eksctl-transfast-addon-iamserviceaccount-kub-Role1-Q76OFJUYIG6Q
     kube-system  fluent-bit                    arn:aws:iam::458838185766:role/eksctl-transfast-addon-iamserviceaccount-kub-Role1-N8YRVU4JKL5R
   ```

3. Add controller to cluster

   The recommended way is using the Helm chart to install the controller. The chart supports Fargate and facilitates updating the controller.

   Detailed instructions can be found in the [official aws-load-balancer-controller Helm chart][awslbhelm]

   - First check wheather it is already installed

     ```sh
     $ kubectl get deployment -n kube-system
     NAME      READY   UP-TO-DATE   AVAILABLE   AGE
     coredns   2/2     2            2           150d
     ```

     If not, continue with the steps.

   - Add the EKS chart repo to Helm:

     ```sh
     $ helm repo add eks https://aws.github.io/eks-charts
        "eks" has been added to your repositories
     ```

   - If upgrading the Helm chart ia `helm upgrade`, manually install the `TargetGroupBinding` CRDs
     The helm install command automatically applies the CRDs, but helm upgrade doesn't.

     ```sh
     kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
     ```

4. Install it with Helm

   - Helm install command for clusters with IRSA (This Case):

     ```sh
     $ helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=transfast --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller

      NAME: aws-load-balancer-controller
      LAST DEPLOYED: Fri Apr  7 14:02:17 2023
      NAMESPACE: kube-system
      STATUS: deployed
      REVISION: 1
      TEST SUITE: None
      NOTES:
      AWS Load Balancer controller installed!
     ```

   - Or, Helm install command for clusters not using IRSA

     ```sh
     helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=transfast
     ```

5. Check if it installed correctly

   ```sh
   # Check the deployment
   $ kubectl get deployment -n kube-system aws-load-balancer-controller
    NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
    aws-load-balancer-controller   2/2     2            2           99s

   # Check the version
   $ kubectl describe deployment -n kube-system  aws-load-balancer-controller | grep Image
    Image:       public.ecr.aws/eks/aws-load-balancer-controller:v2.4.7
   ```

   ```sh
   # Get the list of deployed pods
   kubectl get po -n kube-system | grep -E aws-load-balancer-controller.+ | awk '{ print $1 }'

   # View logs for each pod
   kubectl logs -n kube-system <REPLACE_WITH_ONE_OF_THE_RESULTS_FROM_THE_PREVIOUS_CMD>
      THE OUTPUT SHOULd HAVE A LOT OF INFORMATION ENDING WITH SOMETHING LIKE THE FOLLOWING
      ...
      ...
      {"level":"info","ts":1680871262.1300035,"logger":"controllers.ingress","msg":"successfully built model","model":"{...}"}
      {"level":"info","ts":1680871262.8059115,"logger":"controllers.ingress","msg":"successfully deployed model","ingressGroup":"tfs-apigw/tfs-apigw-ingress"}
   ```

6. Create Update Strategy

   The controller doesn't receive security updates automatically. You need to manually upgrade to a newer version when it becomes available.

   You can upgrade using helm upgrade or another strategy to manage the controller deployment.

   ```sh
   helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
    --set clusterName=transfast \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    -n kube-system
   ```

---

## On these I'm not quite clear weather they are necessary

Make sure you have created an IAM role and that it has a trust relationship with the EKS OIDC.

- Save the following contents to a file named aws-load-balancer-controller-service-account.yaml

  ```yml
  apiVersion: v1
  kind: ServiceAccount
  metadata:
    labels:
      app.kubernetes.io/component: controller
      app.kubernetes.io/name: aws-load-balancer-controller
    name: aws-load-balancer-controller
    namespace: kube-system
    annotations:
      eks.amazonaws.com/role-arn: <EKS-ALB-RoleARN>
  ```

- and apply the file:

  ```sh
  kubectl apply -f aws-load-balancer-controller-service-account.yaml
  ```

---

## Deploy sample application

Now let’s deploy a sample 2048 game into our Kubernetes cluster and use the Ingress resource to expose it to traffic.

Deploy 2048 game resources:

```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/2048/2048-namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/2048/2048-deployment.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/2048/2048-service.yaml
```

Deploy an Ingress resource for the 2048 game:

```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/2048/2048-ingress.yaml
```

After few seconds, verify that the Ingress resource is enabled:

```sh
$ kubectl get ingress/2048-ingress -n 2048-game
NAME          HOSTS  ADDRESS               PORTS  AGE
2048-ingress  \*     DNS-Name-Of-Your-ALB  80     3m
```

Open a browser and copy-paste your DNS-Name-Of-Your-ALB and you should be able to access your newly deployed 2048 game – have fun!

---

[awsalbdoc]: https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/deploy/installation/
[awslbhelm]: https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller
