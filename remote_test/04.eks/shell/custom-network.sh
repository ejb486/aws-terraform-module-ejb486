#cni 플러그인에 대한 사용자 지정 네트워크 구성 활성화 
kubectl set env daemonset aws-node -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true
# 작업자 노드를 식별하기 위한 ENIConfig 레이블 추가 
kubectl set env daemonset aws-node -n kube-system ENI_CONFIG_LABEL_DEF=failure-domain.beta.kubernetes.io/zone
# quick look to see if it's now set
kubectl describe daemonset aws-node -n kube-system | grep -A5 Environment | grep CUSTOM

test -n "$6" && echo CLUSTER is "$6" || "echo CLUSTER is not set && exit"
zone1=$(echo $1)
zone2=$(echo $2)
sub1=$(echo $3)
sub2=$(echo $4)
sg0=$(echo $5)
CLUSTER=$(echo $6)
kubectl get crd

echo ${zone1}
cat << EOF > ${zone1}-pod-netconfig.yaml
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
 name: ${zone1}-pod-netconfig
spec:
 subnet: ${sub1}
 securityGroups:
 - ${sg0}
EOF
echo "created ${zone1}-pod-netconfig.yaml"


echo ${zone2}
cat << EOF > ${zone2}-pod-netconfig.yaml
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
 name: ${zone2}-pod-netconfig
spec:
 subnet: ${sub2}
 securityGroups:
 - ${sg0}
EOF

echo "created ${zone2}-pod-netconfig.yaml"

# Apply the CRD config
echo "apply the CRD ${zone1}"
kubectl apply -f ${zone1}-pod-netconfig.yaml
echo "apply the CRD ${zone2}"
kubectl apply -f ${zone2}-pod-netconfig.yaml

