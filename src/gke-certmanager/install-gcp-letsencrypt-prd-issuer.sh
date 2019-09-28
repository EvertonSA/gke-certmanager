###################################################################
#Script Name	: install-cert-manager.sh
#Description	: install cert manager
#Args          	: no args needed, but env variables are a must
#Author       	: Everton Seiei Arakaki
#Email         	: eveuca@gmail.com
###################################################################

# get gcp-dns-admin.json
gcloud iam service-accounts keys create ./gcp-dns-admin.json \
--iam-account=dns-admin@${PROJECT_ID}.iam.gserviceaccount.com \
--project=${PROJECT_ID}

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