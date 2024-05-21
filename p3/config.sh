sudo k3d cluster create mycluster -a 1
sudo kubectl create namespace dev
sudo kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
wget https://github.com/argoproj/argo-cd/releases/download/v2.11.0/argocd-linux-amd64 -O argocd
sudo chmod +x argocd
sudo mv argocd /usr/local/bin/
