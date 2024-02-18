# Create Necessary Roles and Bindings to view Kubernetes resources in AWS console

To view the resources under Resources tab and Nodes section on the Compute tab in the AWS Management Console, the user that you're signed into the AWS Management Console as, or the role that you switch to once you're signed in, must have specific minimum IAM and Kubernetes permissions. Complete the following steps to assign the required permissions to your users and roles.

1.  Make sure that necessary IAM permissions to view Kubernetes resources, are assigned to either the user that you sign into the AWS Management Console with, or the role that you switch to once you've signed in to the console.
    The following policy includes the minimum necessary permissions for a user or role to view Kubernetes resources for all clusters in specified account. Replace 111122223333 with correct account ID which hold the clusters.

    ```json
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "eks:ListFargateProfiles",
            "eks:DescribeNodegroup",
            "eks:ListNodegroups",
            "eks:ListUpdates",
            "eks:AccessKubernetesApi",
            "eks:ListAddons",
            "eks:DescribeCluster",
            "eks:DescribeAddonVersions",
            "eks:ListClusters",
            "eks:ListIdentityProviderConfigs",
            "iam:ListRoles"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": "ssm:GetParameter",
          "Resource": "arn:aws:ssm:*:111122223333:parameter/*"
        }
      ]
    }
    ```

    Usually in Pannovate, the role to assign this policy to is "OrganizationAccountAccessRole". Either create a new policy and assign it to the Role or create an inline policy.

    It should already be applied if the AWS Account was initialized with the CloudFormation script "Initialize_empty_AWS_Account.yml"

2.  Create a Kubernetes `rolebinding` or `clusterrolebinding` that is bound to a Kubernetes `role` or `clusterrole` that has the necessary permissions to view the Kubernetes resources.
    Read more about [Using RBAC Authorisation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) in the Kubernetes documentation.

    - **View Kubernetes resources in all namespaces** - Download and edit the file:
      `curl -o eks-console-full-access.yaml https://s3.us-west-2.amazonaws.com/amazon-eks/docs/eks-console-full-access.yaml`
    - **View Kubernetes resources in a specific namespace** - Download and edit the file:
      `curl -o eks-console-restricted-access.yaml https://s3.us-west-2.amazonaws.com/amazon-eks/docs/eks-console-restricted-access.yaml`
    - Apply the manifest to the cluster with:

      ```sh
      $ kubectl apply -f eks-console-{full | restricted}-access.yaml`

      clusterrole.rbac.authorization.k8s.io/eks-console-dashboard-full-access-clusterrole created
      clusterrolebinding.rbac.authorization.k8s.io/eks-console-dashboard-full-access-binding created
      ```

3.  Map the IAM role or a user to the Kubernetes User or a Group (that was set up in step 2 for example) in the `aws-auth` `ConfigMap`.
    The preffered way is to use `eksctl` tool, but it can be also edited manually

    a) **EKSCTL - command**

    - Switch to the correct cluster:

      ```sh
      $ kubectl config use-context tndevops@tnb-prod.eu-west-1.eksctl.io

      Switched to context "tndevops@tnb-prod.eu-west-1.eksctl.io".
      Replace my-cluster with the name of your cluster. Replace region-code with the AWS Region that your cluster is in.
      ```

    - Get the cluster info:

      ```sh
      $ eksctl get cluster

      NAME        REGION        EKSCTL CREATED
      tnb-prod    eu-west-1     True
      ```

    - View the current mappings first:

      ```sh
      $ eksctl get iamidentitymapping --cluster my-cluster --region=region-code

      ARN                                                                                             USERNAME                               GROUPS                          ACCOUNT
      arn:aws:iam::111122223333:role/eksctl-my-cluster-my-nodegroup-NodeInstanceRole-1XLS7754U3ZPA    system:node:{{EC2PrivateDNSName}}      system:bootstrappers,system:nodes

      ```

    - **To Add a mapping for a role.**
      This example assume that IAM permissions in the first step are attached to a role named `OrganizationAccountAccessRole`. Replace `my-cluster` with correct cluster name, `region-code` with the correct region, `111122223333` with your account ID, `group` withh the desired group name.

      ```sh
      $ eksctl create iamidentitymapping \
          --cluster my-cluster \
          --region=region-code \
          --arn arn:aws:iam::111122223333:role/my-console-viewer-role \
          --group eks-console-dashboard-full-access-group \
          --no-duplicate-arns

      ...
      2022-05-09 14:51:20 [ℹ]  adding identity "arn:aws:iam::111122223333:role/my-console-viewer-role" to auth ConfigMap
      ```

      > **_IMPORTANT_**:
      > The role ARN can't include a path such as role/my-team/developers/my-role. The format of the ARN must be arn:aws:iam::111122223333:role/my-role. In this example, my-team/developers/ needs to be removed.

    - **To add a mapping to a user**
      This example assume that IAM permissions in the first step are attached to a user named `my-user`. Replace `my-cluster` with correct cluster name, `region-code` with the correct region, `111122223333` with your account ID, `group` withh the desired group name.

      ```sh
      $ eksctl create iamidentitymapping \
          --cluster my-cluster \
          --region=region-code \
          --arn arn:aws:iam::111122223333:user/my-user \
          --group eks-console-dashboard-restricted-access-group \
          --no-duplicate-arns

      ...
      2022-05-09 14:53:48 [ℹ]  adding identity "arn:aws:iam::111122223333:user/my-user" to auth ConfigMap
      ```

    - **View the mappings again**

      ```sh
      eksctl get iamidentitymapping --cluster my-cluster --region=region-code
      ```

      The output should now include the new bindings:

      ```out
      ARN                                                                                             USERNAME                                GROUPS                                  ACCOUNT
      arn:aws:iam::111122223333:role/eksctl-my-cluster-my-nodegroup-NodeInstanceRole-1XLS7754U3ZPA    system:node:{{EC2PrivateDNSName}}       system:bootstrappers,system:nodes
      arn:aws:iam::111122223333:role/my-console-viewer-role                                                                                   eks-console-dashboard-full-access-group
      arn:aws:iam::111122223333:user/my-user                                                                                                  eks-console-dashboard-restricted-access-group
      ```

      b) **Update the `ConfigMap` manually**

      - Open the `ConfigMap` for editing:

        ```sh
        kubectl edit -n kube-system configmap/aws-auth
        ```

      - Add the mappings to the `aws-auth` `ConfigMap`, but **don't replace any of the existing mappings**.
        The following example adds mappings between IAM users and roles with permissions added in the first step and the Kubernetes groups created in the previous step:

        - The `my-console-viewer-role` role and the `eks-console-dashboard-full-access-group`.
        - The `my-user` user and the `eks-console-dashboard-restricted-access-group`.

        These examples assume that you attached the IAM permissions in the first step to a role named `my-console-viewer-role` and a user named `my-user`. Replace `111122223333` with your account ID.

        ```yml
        apiVersion: v1
        data:
        mapRoles: |
        - groups:
            - eks-console-dashboard-full-access-group
            rolearn: arn:aws:iam::111122223333:role/my-console-viewer-role
            username: my-console-viewer-role
        mapUsers: |
        - groups:
            - eks-console-dashboard-restricted-access-group
            userarn: arn:aws:iam::111122223333:user/my-user
            username: my-user
        ```

        > **_IMPORTANT_**:
        > The role ARN can't include a path such as role/my-team/developers/my-console-viewer-role. The format of the ARN must be arn:aws:iam::111122223333:role/my-console-viewer-role. In this example, my-team/developers/ needs to be removed.

      - Save the changes and exit the editor to apply new mappings
