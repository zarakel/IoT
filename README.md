## J'utilise Ubuntu 22.04 monté sur Virtualbox 7.0 et quelques tournant sur Windows 10
## J'ai choisi de faire tourner deux VMs Alpine toujours sur Virtualbox sur la VM mère Ubuntu 

### Problème ! 
1 : De manière aléatoire, à l'étape d'attribution de clé SSH, vagrant ou virtualbox (coupable indéterminé) bloque
je Ctrl+C comme un boeuf jusqu'à ce que ça marche pour le moment

## 0/ Installer la dernière version de virtualbox sur l'OS
-> Cocher la case Activer VT-s/AMD-V imbriqué dans système/processeur qui active la virtualisation imbriquée
-> Cocher la case cable branché dans réseau -> avancé qui facilite la connexion entre vm sur même réseau

## 1/ Installation vagrant et également iptables, qui sera utilisé par vagrant
-> apt install vagrant iptables

## 2/ dans le dossier du projet, génère le vagrantfile : 
-> vagrant init generic/alpine319 \
   --box-version 4.3.10
   vagrant up
-> Pour faire fonctionner les dossiers sync et d'autres fonctionnalités
vagrant plugin install vagrant-vbguest

## 3/ modification du vagrantfile généré pour changer l'ip, l'hostname et l'allocation mémoire (à continuer)
->
  _première instruction obligatoire, configure le vagrantfile, le 2 représente quelle version de vagrant_
  Vagrant.configure("2") do |config|
  
    -> écrire le nom de la machine au yeux de Vagrant
    config.vm.define "jbuanS" do
    
    -> monter la box (image)
    config.vm.box = "generic/alpine319"
    
    -> Mettre en place le dossier partagé entre l'hôte et la VM qu'on va créee (1er arg: hôte, 2ème arg: VM)
    config.vm.synced_folder ".", "/vagrant"
    
    -> Magie pour éviter une erreur que je rencontrais avec l'ajout d'un plugin important
    config.vbguest.auto_update = false
    
    -> Grâce à la ligne ci-dessous, tout ce qu'on écrira concernera uniquement la VM nommé (scope)
    config.vm.define "jbuanS" do |control|
    
      -> écrire l'ip et la nature du réseau 
      control.vm.network "private_network", ip: "192.168.56.110"
      
      -> scope paramétrant Virtualbox de la VM
      control.vm.provider "virtualbox" do |v|
      
        -> Configure dans l'ordre nom de la VM, mémoire, coeur et active option cable branché (facilite connectivité entre vm sur même réseau
        
        v.name = "jbuanS"
        v.memory = "1024"
        v.cpus = "1"
        v.customize ["modifyvm", :id, "--cableconnected1", "on"]
      end
      
      -> ligne ci dessous permet de donner des instructions en shell dans le vagrantfile, un peu comme cat << EOF
      
      control.vm.provision "shell", inline: <<-SHELL
        apk update
        apk upgrade
        -> iptables est utilisé par vagrant
        apk add iptables
        
        -> script d'installation de k3s pipé ( | ) avec les instructions de lancement de k3s controller
        -> INSTALL_K3S_EXEC -> utilise k3s façon command_line, --write-kubeconfig-mode -> rend l'écriture sur le fichier config possible
        -> --node-name -> nomme le node (espace ou évolue une VM ou un groupe)
        -> --tls-san -> ajoute IP ou hostname comme Subject Alternatives Names (SAN -> Alternative a l'IP initial du node)
        -> -i -> addresse affichée sur le réseau de notre node et celle utilisé évidemment
        -> --cluster-cidr=192.168.56.0/30 -> Donne l'adresse et le masque de sous-réseau de notre cluster de VM. le /30 permet deux IPs seulement, 110 et 111 sont inclues.
        -> --cluster-init -> Active etcd, magasin clé valeurs qui permet de partager l'ensemble de l'état du cluster et de ses configurations entre tout ses membres
        
        curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --node-name=jbuanS --cluster-cidr=192.168.56.0/30 --tls-san=192.168.56.110 -i=192.168.56.110 " sh -s - server --cluster-init
        
        -> suite a l'installation, un token est généré pour accéder au cluster, nous devons le passer a la prochaine vm.
        -> J'ai choisi de le faire remonter chez l'hôte puis de le redescendre dans l'autre VM. J'arrive a avoir les droits suffisants pour transmettre les fichiers de cette manière.
        
        NODE_TOKEN="/var/lib/rancher/k3s/server/token"
        
        -> Il m'est arrivé que le token met un peu de temps à être généré, alors j'attends
        
        while [ ! -e ${NODE_TOKEN} ]
          do
            sleep 2
          done
          
        -> /vagrant/. est le dossier synchronisé avec l'hôte
        cp ${NODE_TOKEN} /vagrant/.
        
        -> k3s.yaml est le fichier conf de notre node, on doit également le transmettre
        chmod 644 /etc/rancher/k3s/k3s.yaml
        
        cp /etc/rancher/k3s/k3s.yaml /vagrant/.
        mkdir /home/vagrant/.kube
        cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
        chown vagrant /home/vagrant/.kube/config
        chmod 600 /home/vagrant/.kube/config
        export KUBECONFIG=/home/vagrant/.kube/config
        SHELL
      end
      config.vm.define "jbuanSW" do |control|
        control.vm.network "private_network", ip: "192.168.56.111"
        control.vm.provider "virtualbox" do |v|
          v.name = "jbuanSW"
          v.memory = "1024"
          v.cpus = "1"
          v.customize ["modifyvm", :id, "--cableconnected1", "on"]
        end
        
        -> les lignes ci-dessous permettent de transférer des fichiers de l'hôte vers la VM
        -> sans cette manière, j'ai des problèmes d'autorisation alors qu'en l'utilisant, j'ai les plein droits
        
        control.vm.provision "file", source:"token", destination:"/home/vagrant/.kube/token"
        control.vm.provision "file", source: "k3s.yaml", destination: "/home/vagrant/.kube/config"
        control.vm.provision "shell", inline: <<-SHELL
          apk update
          apk upgrade
          apk add iptables
          
          -> Avec sed, on modifie le fichier de conf pour modifier l'adresse ip (127.0.0.1 par défaut) pour l'adresse réelle de notre node (192.168.56.110)
          
          sudo sed -i 's#server: https://127\.0\.0\.1:6443#server: https://192\.168\.56\.110:6443#g' /home/vagrant/.kube/config
          export KUBECONFIG="/home/vagrant/.kube/config"
          export K3S_CONFIG_FILE="/home/vagrant/.kube/config"
          sudo curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent -i=192.158.56.111 --node-name=jbuanSW --token-file=/home/vagrant/.kube/token -s=https://192.168.56.110:6443" sh -
          sudo k3s agent -i=192.168.56.111 --node-name=jbuanSW --token-file=/home/vagrant/.kube/token -s=https://192.168.56.110:6443
          SHELL
        end
      end


4/ Connection SSH et test des ressources allouées aux VMs

vagrant ssh [NOM_VM] 

*vagrant se connecte auto, pas besoin de mot de passe*

*Les lignes suivantes sont dans le cas ou des problèmes surviennent lors de la connexion ssh de vagrant.*

*Dans ce cas, on ajoutela clé publique de l'hôte (la VM Ubuntu dans ce cas) à ssh sur l'hôte*

eval `ssh-agent` (des ` entoure le ssh-agent)

ssh-add [chemin_cle_ssh]

ssh-add -L pour check si besoin

-> *pour afficher que les ressources données à la machine ont bien été configurées*

   htop
   
   *pour afficher le nombre de coeurs*
   
   lscpu
   
   *pour afficher la mémoire alouée à la machine*
   
   free -m (m pour Mega)
   
   *pour afficher que l'adresse IP sur eth1 a bien été modifiée*
   
   ip -h address
   





