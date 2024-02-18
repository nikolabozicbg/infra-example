# Echo Server

[Documentation](https://ealenn.github.io/Echo-Server) | [Docker Hub](https://hub.docker.com/r/ealen/echo-server)

## Usage

```sh
$ curl -s "https://api.pen.pannovate.net/echo?query=test_query&some=thing" | jq

{
  "host": {
    "hostname": "api.pen.pannovate.net",
    "ip": "::ffff:10.18.181.103",
    "ips": []
  },
  "http": {
    "method": "GET",
    "baseUrl": "",
    "originalUrl": "/echo?query=test_query&some=thing",
    "protocol": "http"
  },
  "request": {
    "params": {
      "0": "/echo"
    },
    "query": {
      "query": "test_query",
      "some": "thing"
    },
    "cookies": {},
    "body": {},
    "headers": {
      "x-forwarded-for": "91.143.218.42:38750",
      "x-forwarded-proto": "https",
      "x-forwarded-port": "443",
      "host": "api.pen.pannovate.net",
      "x-amzn-trace-id": "Root=1-642c39f5-638eee617fa84bad5aeb09b7",
      "user-agent": "curl/8.0.1",
      "accept": "*/*"
    }
  },
  "environment": {
    "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    "HOSTNAME": "echo-server-deployment-5fbb678fc4-vwm5v",
    "LOGS__IGNORE__PING": "false",
    "ENABLE__HOST": "true",
    "ENABLE__REQUEST": "true",
    "ENABLE__COOKIES": "true",
    "PORT": "80",
    "ENABLE__HTTP": "true",
    "ENABLE__HEADER": "true",
    "ENABLE__ENVIRONMENT": "true",
    "ENABLE__FILE": "true",
    "TFS_APIGW_SERVICE_SERVICE_PORT": "443",
    "TFS_APIGW_SERVICE_PORT": "tcp://172.20.174.82:443",
    "ECHO_SERVER_SERVICE_PORT": "80",
    "ECHO_SERVER_PORT": "tcp://172.20.128.236:80",
    "TFS_APIGW_SERVICE_PORT_443_TCP": "tcp://172.20.174.82:443",
    "TFS_APIGW_SERVICE_PORT_80_TCP_ADDR": "172.20.174.82",
    "ECHO_SERVER_PORT_80_TCP_ADDR": "172.20.128.236",
    "TFS_APIGW_SERVICE_SERVICE_PORT_HTTPS": "443",
    "ECHO_SERVER_SERVICE_PORT_ECHO_SRV_PORT": "80",
    "KUBERNETES_SERVICE_HOST": "172.20.0.1",
    "KUBERNETES_SERVICE_PORT_HTTPS": "443",
    "TFS_APIGW_SERVICE_SERVICE_HOST": "172.20.174.82",
    "TFS_APIGW_SERVICE_PORT_443_TCP_PORT": "443",
    "ECHO_SERVER_SERVICE_HOST": "172.20.128.236",
    "ECHO_SERVER_PORT_80_TCP": "tcp://172.20.128.236:80",
    "ECHO_SERVER_PORT_80_TCP_PROTO": "tcp",
    "KUBERNETES_PORT_443_TCP_PORT": "443",
    "TFS_APIGW_SERVICE_PORT_80_TCP_PORT": "80",
    "KUBERNETES_PORT": "tcp://172.20.0.1:443",
    "KUBERNETES_PORT_443_TCP": "tcp://172.20.0.1:443",
    "TFS_APIGW_SERVICE_SERVICE_PORT_HTTP": "80",
    "TFS_APIGW_SERVICE_PORT_443_TCP_PROTO": "tcp",
    "TFS_APIGW_SERVICE_PORT_80_TCP": "tcp://172.20.174.82:80",
    "TFS_APIGW_SERVICE_PORT_80_TCP_PROTO": "tcp",
    "ECHO_SERVER_PORT_80_TCP_PORT": "80",
    "KUBERNETES_SERVICE_PORT": "443",
    "KUBERNETES_PORT_443_TCP_PROTO": "tcp",
    "TFS_APIGW_SERVICE_PORT_443_TCP_ADDR": "172.20.174.82",
    "KUBERNETES_PORT_443_TCP_ADDR": "172.20.0.1",
    "NODE_VERSION": "16.16.0",
    "YARN_VERSION": "1.22.19",
    "HOME": "/root"
  }
}
```

## Set Up

### Kubernetes

```sh
curl -sL https://raw.githubusercontent.com/Ealenn/Echo-Server/master/docs/examples/echo.kube.yaml | kubectl apply -f -
```

[The Docs](https://ealenn.github.io/Echo-Server/pages/quick-start/kubernetes.html)

### Helm

```sh
helm repo add ealenn https://ealenn.github.io/charts
helm repo update
helm install --set ingress.enable=true --name echoserver ealenn/echo-server
```

[The Docs](https://ealenn.github.io/Echo-Server/pages/quick-start/helm.html)
[The Hub](https://artifacthub.io/packages/helm/ealenn/echo-server)

### Node JS

```sh
# Dependencies
npm ci
# Run with node
node ./src/webserver --port 8080
# Run with npm script
PORT=8080 npm run start
```

[The Docs](https://ealenn.github.io/Echo-Server/pages/quick-start/nodejs)

### Docker

```sh
docker run -p 8080:80 ealen/echo-server

```

[The Docs](https://ealenn.github.io/Echo-Server/pages/quick-start/docker.html)
