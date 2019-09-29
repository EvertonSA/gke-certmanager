# GKE Cert-Manager

Introduction
---

Nowadays it is a tremendous mistake to make your website available without 
any kind of HTTPS implementation. There are a bunch of options on the internet 
including free options and this is a must if you want to provide the least
a little bit of security. 

This repo is to be used together with the GKE Bootstrapper, but it is not a 
requirement. The things you need are:

   - Kubernetes Cluster
   - Istio 1.8 or above
   - Helm
   - Your own domain

Although using the GKE Bootstrapper is not necessary, it is higly recommended. 
The reason is because you will not need to modify any of the source code to have 
a certificate issued by LetsEncrypt. If you have your cluster in AWS, you will 
need to dive into cert-manager documentation and find out how LetsEncrypt can 
verify against Route53. It is on the roadmap of this project to make this repo 
adjustable depending on the provider, but there is no deadline for this feature.

---

## How to use this repository

To provision necessary resources, use the bellow script.

```
cd src
./apply.sh
```

This will deploy cert-manager objetcs into your cluster in a dedicated namespace. 
Within GCP provider, it will deploy a service account with DNS permissions to edit 
necessary routes in the istio CloudDNS zone. With the service account created and 
bounded to the cluster as a secret, it will try to issue a LetsEncrypt certificate. 
This process can take up to 10 minutes, but within GCP provider this is all automated. 

After the certificate is ready, a Istio Gateway is also created. This istio gateway 
take advantage of the istio ingressgateway and can be used to expose frontend applications 
to the internet with TLS encryption. The diagram can be seem bellow.  

![GKE Istio + certmanager](./src/tmp/gke-cert-manager.png)

## How to expose applications using TLS

Whenever you want to expose your application to the outside world using your nearly 
created certificate, your kubernetes objects are not going to change that much. What you 
need as always is a deployment (or whataver other application controller you are exposing) 
and a service of type ClusterIP. A new object is introduced, named VirtualService. The 
virtual service object is part of the Istio Custom Resource Definition and it will make 
the midfield between your service and istio public gateway. Take the bellow example to 
make the magic happen to your applications! This will deploy a application exposed to the 
world using TLS on the endpoint https://test-gke-pod.arakaki.in. Give it a try!

```
DOMAIN="arakaki.in"
helm repo add sp https://stefanprodan.github.io/podinfo
helm upgrade my-release --install sp/podinfo 
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: test-gke-pod
  namespace: default
spec:
  hosts:
   - "test-gke-pod.${DOMAIN}"
  gateways:
  - public-gateway.istio-system.svc.cluster.local
  http:
  - route:
    - destination:
        host: my-release-podinfo
        port:
          number: 9898
EOF
```
