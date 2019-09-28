###################################################################
#Script Name	: apply.sh
#Description	: state of art kub gcp provisioning with gcloud cli
#Note           : some lines stars with "." because need values.sh
#Args          	: no args needed, but need to edit values.sh file
#Author       	: Everton Seiei Arakaki
#Email         	: eveuca@gmail.com
###################################################################

# requirements:
#   Helm
#   Istio
#   Valid Domain
#   GCP CloudDNS Entry

# TODO: make this repo flexible for AWS Route53

# import variables in script context
source values.sh

gcloud config set project $PROJECT_ID

echo "--- create dns service account"
. gke-certmanager/30-gcloud-dns-sa.sh

echo "--- install cert-manager for TLS with letsencrypt ---"
. gke-certmanager/install-cert-manager-gke.sh

echo "--- install letsencrypt staging issuer ---"
#. gke-certmanager/install-gcp-letsencrypt-stg-issuer.sh

echo "--- install letsencrypt prod issuer ---"
. gke-certmanager/install-gcp-letsencrypt-prd-issuer.sh

echo "--- issue letsencrypt STG domain certificate ---"
#. ssl-certificates/10-istio-gateway-cert-stg.sh

echo "--- issue letsencrypt PRD domain certificate ---"
. ssl-certificates/10-istio-gateway-cert-prd.sh

echo "--- install istio public gateway ---"
. gke-certmanager/install-istio-public-gateway.sh

echo "--- wait for LetsEncrypt certificate ---"
while [[ $(kubectl get certificate istio-gateway -n istio-system -o jsonpath='{..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
  echo "waiting cert-manager to issue the certificate, this can take up to 10 minutes" && sleep 15; 
done
echo "YES, IT WORKED!!"

echo "--- delete istio ingressgateway pod to renew certificate on gateway ---"
kubectl -n istio-system delete pods -l istio=ingressgateway