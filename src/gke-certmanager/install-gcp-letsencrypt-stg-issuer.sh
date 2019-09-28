###################################################################
#Script Name	: install-cert-manager.sh
#Description	: install cert manager
#Args          	: no args needed, but env variables are a must
#Author       	: Everton Seiei Arakaki
#Email         	: eveuca@gmail.com
###################################################################

kubectl apply -f - <<EOF
apiVersion: certmanager.k8s.io/v1alpha1
kind: Issuer
metadata:
  name: letsencrypt-staging
  namespace: istio-system
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: ${OWNER_EMAIL}
    privateKeySecretRef:
      name: letsencrypt-staging
    dns01:
      providers:
      - name: cloud-dns
        clouddns:
          serviceAccountSecretRef:
            name: cert-manager-credentials
            key: gcp-dnsadmin.json
          project: ${PROJECT_ID}
EOF

sleep 15s