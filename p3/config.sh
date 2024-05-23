sudo k3d cluster create mycluster -a 1
sudo kubectl create namespace dev
sudo kubectl create namespace argocd
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
sudo wget https://github.com/argoproj/argo-cd/releases/download/v2.11.0/argocd-linux-amd64 -O argocd
sudo chmod +x argocd
sudo mv argocd /usr/local/bin/
sudo kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
echo "waiting ..."
sudo kubectl wait pod --all --for=condition=Ready --namespace=argocd --timeout=-1s
sudo argocd admin initial-password -n argocd | awk 'NR==1' | cat > pass
sudo kubectl get nodes -o wide | awk -v OFS='\t\t' '{print $6}' | awk 'NR==2' | cat > ip_address
sudo kubectl get svc/argocd-server -n argocd | awk {'print $5'} | awk -F ',' 'NR==2 {print $2}' | awk -F ':' '{print $2}' | awk -F '/' '{print $1}' | cat > port
#sudo kubectl apply -n argocd -f argocd-cmd-params-cm.yaml
sudo argocd login `cat ip_address`:`cat port` --username admin --password `cat pass` --insecure
sudo argocd app create playground \
  --repo https://github.com/zarakel/ArgoCD.git \
  --path playground \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace dev \
  --revision main \
  --directory-recurse \
  --sync-policy automated \
  --self-heal \
  --auto-prune \
  --insecure
sleep 10
sudo kubectl wait pod --all --for=condition=Ready --namespace=dev --timeout=-1s
sudo kubectl port-forward -n dev svc/playground 8888:8888
