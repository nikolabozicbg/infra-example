# Order of deployment of services

The order of deployments is usually not criticall, but in some situations it may become necessary to deploy them in certain order.

## Introduction of a new Webhook service deployment order

kubectl apply -f k8s-services/webhook/webhook-deployment.yaml

kubectl apply -f k8s-services/cs/cs-deployment.yaml

kubectl apply -f k8s-services/as/auth-deployment.yaml

kubectl apply -f k8s-services/els/els-deployment.yaml

kubectl apply -f k8s-services/fs/fs-deployment.yaml

kubectl apply -f k8s-services/kyc/kyc-deployment.yaml

kubectl apply -f k8s-services/config/cfg-deployment.yaml

kubectl apply -f k8s-services/mps/mps-deployment.yaml

kubectl apply -f k8s-services/pubsub/pubsub-deployment.yaml

kubectl apply -f k8s-services/api-gateway/apigw-deployment.yaml

## To rollback the deployment

kubectl rollout undo deployment.v1.apps/roma-webhook-deployment -n roma-webhook
