rm -f ~/.kube/config
aws eks update-kubeconfig --name smp-stg-eks
#aws eks update-kubeconfig --name $cn  --role-arn $arn
kubectx
echo "kubectl"
kubectl version --short