###################################################################
#Script Name	: cleanup.sh                                                                                  
#Description	: cleanup                                                                             
#Args          	: no args needed, but need to edit values.sh file
#Author       	: Everton Seiei Arakaki                                                
#Email         	: eveuca@gmail.com                                           
###################################################################

# import variables in script context
source values.sh

gcloud config set project $PROJECT_ID

echo "helm delete cert-manager objects"
helm delete --purge cert-manager

echo "delete cert-manager namespace"
kubectl delete ns cert-manager

echo "delete certificate"
kubectl -n istio-system delete certificate istio-gateway

echo "delete certificate"
kubectl -n istio-system delete certificate istio-gateway-stg

echo "delete PRD issuer "
kubectl -n istio-system delete issuer letsencrypt-prod

echo "delete STG issuer "
kubectl -n istio-system delete issuer letsencrypt-staging

echo "delete dns service account binding"
gcloud projects remove-iam-policy-binding  ${SA_DNS} \
  --member="serviceAccount:$SA_DNS" \
  --role=roles/editor

echo "delete dns service account"
gcloud iam service-accounts delete $SA_DNS --quiet 

echo "delete created resources by cert-manager on istio-system namespace"
kubectl -n istio-system delete secret cert-manager-credentials
kubectl -n istio-system delete secret istio-ingressgateway-certs
kubectl -n istio-system delete gateway public-gateway

echo "delete gcp dnsadmin json file"
rm -f gcp-dnsadmin.json

