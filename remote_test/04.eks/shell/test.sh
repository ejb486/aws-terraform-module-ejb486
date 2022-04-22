resp=$(aws eks describe-cluster --name smp-stg-eks)
endp=$(echo $resp | jq -r .cluster.endpoint | cut -f3 -d'/')
nslookup $endp
nmap $endp -Pn -p 443