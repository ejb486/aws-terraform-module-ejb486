
test -n "$6" && echo CLUSTER is "$6" || "echo CLUSTER is not set && exit"
zone1=$(echo $1)
zone2=$(echo $2)
sub1=$(echo $3)
sub2=$(echo $4)
sg0=$(echo $5)
CLUSTER=$(echo $6)

echo "pause 20s before annotate"
sleep 20
target=$(kubectl get nodes | grep Read | wc -l)
comm=`printf "kubectl get node --selector='eks.amazonaws.com/nodegroup==%s-ng-worker-1' -o json" $CLUSTER`
allnodes=`eval $comm`
curr=`echo $allnodes | jq '.items | length'`
len=`echo $allnodes | jq '.items | length-1'`
echo "Found $curr nodes to annotate of $target"
# iterate through the nodes and apply the annotation - so the eniConfig can match
for i in `seq 0 $len`; do
    nn=`echo $allnodes | jq ".items[(${i})].metadata.name" | tr -d '"'`
    nz=`echo $allnodes | jq ".items[(${i})].metadata.labels" | grep failure | grep zone | cut -f2 -d':' | tr -d ' ' | tr -d ','| tr -d '"'`
    echo $nn $nz $nr
    echo "kubectl annotate node ${nn} k8s.amazonaws.com/eniConfig=${nz}-pod-netconfig"
    kubectl annotate node ${nn} k8s.amazonaws.com/eniConfig=${nz}-pod-netconfig
done
echo "pause 20s after annotate"
sleep 20