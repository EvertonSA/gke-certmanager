kubectl apply -f - <<EOF
apiVersion: certmanager.k8s.io/v1alpha1
kind: Issuer
metadata:
  name: letsencrypt-prod
  namespace: istio-system
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${OWNER_EMAIL}
    privateKeySecretRef:
      name: letsencrypt-prod
    dns01:
      providers:
      - name: cloud-dns
        clouddns:
          serviceAccountSecretRef:
            name: cert-manager-credentials
            key: gcp-dns-admin.json
          project: ${PROJECT_ID}
EOF