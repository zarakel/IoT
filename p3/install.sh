sudo apt install wget curl -y 
sudo wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash # install k3D
sudo curl -fsSL https://get.docker.com -o get-docker.sh # install docker engine
sudo sh get-docker.sh # continuité ligne précédente
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" # install kubectl avec le ligne suivante
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl # continuité ligne précédente
sudo curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash # installer helm
sleep 5
sudo bash config.sh
