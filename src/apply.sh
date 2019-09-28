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

echo "--- install cert-manager for TLS with letsencrypt ---"
. gke-certmanager/install-cert-manager-gke.sh

echo "--- install letsencrypt prod issuer ---"
. gke-certmanager/install-gcp-letsencrypt-prd-issuer.sh

echo "--- issue letsencrypt domain certificate ---"
. gke-certmanager/install-gcp-letsencrypt-prd-issuer.sh

echo "--- install istio public gateway ---"
. gke-certmanager/install-public-gateway.sh