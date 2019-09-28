kubectl apply -f - <<EOF
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: istio-gateway
  namespace: istio-system
spec:
  secretName: istio-ingressgateway-certs
  issuerRef:
    name: letsencrypt-prod
  commonName: "*.${DOMAIN}"
  acme:
    config:
    - dns01:
        provider: cloud-dns
      domains:
      - "*.${DOMAIN}"
      - "${DOMAIN}"
EOF