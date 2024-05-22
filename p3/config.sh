sudo k3d cluster create mycluster -a 1
sudo kubectl create namespace dev
sudo kubectl create namespace argocd
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
sudo wget https://github.com/argoproj/argo-cd/releases/download/v2.11.0/argocd-linux-amd64 -O argocd
sudo chmod +x argocd
sudo mv argocd /usr/local/bin/
sudo kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
echo "waiting ..."
sudo kubectl wait svc --all --for=condition=Ready --namespace=argocd --timeout negative
sudo argocd admin initial-password -n argocd | awk 'NR==1' | cat > pass
sudo kubectl get nodes -o wide | awk -v OFS='\t\t' '{print }' | awk 'NR==2' | cat > ip_cluster 
sudo argocd login `cat ip_address`:`cat port` --username admin --password `cat pass` --insecure
sudo argocd app create playground --repo https://github.com/zarakel/ArgoCD-k3d-pipe-.git --path playground --dest-server https://kubernetes.default.svc --dest-namespace dev
sudo argocd app set playground --sync-policy automated
#kubectl patch svc playground -n dev -p '{"spec": {"type": "LoadBalancer"}}' Je la commente car pas sur de m'en servir puisque le lb est déja fait
