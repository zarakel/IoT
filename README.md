# Projet IoT & DevOps - Cluster Kubernetes, Ingress Routing & GitOps

Ce dépôt contient un ensemble de projets pratiques d'administration système, d'orchestration de conteneurs et de déploiement continu (GitOps). L'objectif est d'apprendre à mettre en place une infrastructure complète, depuis le provisionnement de machines virtuelles jusqu'au déploiement automatisé d'applications avec Kubernetes, Helm et Argo CD.

---

## 📝 Résumé du Projet

Le projet est divisé en trois parties distinctes et progressives :

1. **Partie 1 (`p1`) : Cluster Kubernetes Multi-nœuds (K3s)**
   - Initialisation d'une infrastructure à deux nœuds : un nœud maître (Server) et un nœud travailleur (Worker).
   - Utilisation de **Vagrant** et **VirtualBox** avec des machines virtuelles sous **Alpine Linux**.
   - Déploiement léger de Kubernetes via **K3s**.
   - Automatisation du partage sécurisé du jeton d'authentification (`token`) et de la configuration du cluster (`k3s.yaml`) pour permettre la jonction automatique du Worker au Server.

2. **Partie 2 (`p2`) : Routage Applicatif avec Traefik Ingress**
   - Mise en place d'un cluster K3s sur une VM unique.
   - Déploiement de trois applications web Nginx distinctes gérées via des Kubernetes Deployments, Services et ConfigMaps.
   - Configuration du contrôleur d'Ingress **Traefik** pour effectuer du routage basé sur les en-têtes HTTP `Host` (`app1.com`, `app2.com`) et un routage par défaut (fallback).

3. **Partie 3 (`p3`) : GitOps Continu avec K3d, Helm & Argo CD**
   - Création d'un cluster Kubernetes local à l'aide de **K3d** (Kubernetes dans Docker).
   - Déploiement et configuration d'**Argo CD** pour gérer le cycle de vie d'une application en mode GitOps.
   - Modélisation de l'application via un Chart **Helm** personnalisé (`values.yaml`, `deployment.yaml`).
   - Synchronisation automatique et auto-correctrice (self-healing/auto-pruning) avec un dépôt Git distant.

---

## 🛠️ Techniques Acquises

Ce projet permet de maîtriser un large panel de compétences fondamentales en DevOps, Cloud Native et administration système :

- **Infrastructure as Code (IaC) & Virtualisation** :
  - Configuration de réseaux privés et de partages de dossiers hôte-invité avec **Vagrant**.
  - Optimisation de VM légères sous **Alpine Linux** (gestion CPU/Mémoire, connectivité réseau VirtualBox).
- **Orchestration de Conteneurs (Kubernetes)** :
  - Déploiement et administration de distributions Kubernetes légères (**K3s** pour l'embarqué/VM et **K3d** pour le développement local).
  - Gestion des objets Kubernetes essentiels : *Deployments, Services (ClusterIP et LoadBalancer), ConfigMaps, Namespaces, Ingress/IngressRoute*.
- **Routage de trafic & Reverse Proxy** :
  - Configuration de **Traefik** comme contrôleur d'Ingress Kubernetes.
  - Définition de règles d'Ingress avancées (routage basé sur le nom de domaine hôte, routes de secours).
- **Package Management avec Helm** :
  - Création et personnalisation de Templates Helm pour paramétrer dynamiquement des manifestes de déploiement Kubernetes.
- **Approche GitOps & Continuous Delivery (CD)** :
  - Installation et configuration d'**Argo CD**.
  - Automatisation du déploiement depuis un dépôt de code source Git avec des politiques de synchronisation automatisée, d'auto-remédiation (*self-healing*) et de nettoyage (*auto-prune*).
- **Scripting & Automatisation** :
  - Écriture de scripts Bash robustes et de Makefiles pour simplifier et automatiser l'installation et le cycle de vie de l'infrastructure.

---

## 🚀 Comment l'Utiliser

Chaque partie dispose de sa propre configuration et automatisation via un `Makefile`.

---

### 📦 Partie 1 : Cluster K3s (Multi-nœuds)

Cette partie permet de déployer deux machines virtuelles sous Alpine Linux (`jbuanS` et `jbuanSW`) configurées en cluster K3s Server/Worker.

#### Fichiers Clés
* [p1/Vagrantfile](file:///home/jbuan/sgoinfre/IOT/p1/Vagrantfile) : Configuration des deux VMs (Réseau privé, allocation des ressources et script de provisionnement).
* [p1/Makefile](file:///home/jbuan/sgoinfre/IOT/p1/Makefile) : Gestion du cycle de vie du cluster.
* [p1/install.sh](file:///home/jbuan/sgoinfre/IOT/p1/install.sh) : Script d'installation des prérequis sur la machine hôte.

#### Instructions d'Exécution
1. Placez-vous dans le dossier de la partie 1 :
   ```bash
   cd p1
   ```
2. Installez les prérequis (Vagrant, VirtualBox, etc.) :
   ```bash
   ./install.sh
   ```
3. Démarrez et configurez le cluster :
   ```bash
   make
   ```
4. Connectez-vous en SSH au serveur maître pour vérifier que les nœuds ont bien rejoint le cluster :
   ```bash
   vagrant ssh jbuanS
   sudo kubectl get nodes -o wide
   ```
5. Pour détruire proprement les machines virtuelles et nettoyer les fichiers temporaires :
   ```bash
   make clean
   ```

---

### 🌐 Partie 2 : Routage HTTP (Traefik Ingress & Nginx)

Cette partie déploie un serveur K3s unique exécutant trois applications Nginx avec des pages d'accueil distinctes, accessibles via des noms de domaine.

#### Fichiers Clés
* [p2/Vagrantfile](file:///home/jbuan/sgoinfre/IOT/p2/Vagrantfile) : Configuration de la VM et application automatique des manifestes Kubernetes.
* [p2/conf/nginx/04-nginx-ingress.yml](file:///home/jbuan/sgoinfre/IOT/p2/conf/nginx/04-nginx-ingress.yml) : Définition des règles d'Ingress pour le routage de trafic.
* [p2/Makefile](file:///home/jbuan/sgoinfre/IOT/p2/Makefile) : Déploiement et destruction de l'environnement de la partie 2.

#### Instructions d'Exécution
1. Placez-vous dans le dossier de la partie 2 :
   ```bash
   cd p2
   ```
2. Démarrez la machine virtuelle et appliquez les configurations Kubernetes :
   ```bash
   make
   ```
3. Testez le routage depuis votre machine hôte (ou depuis la VM en SSH) :
   - Requête vers le site de vêtements (`nginx1`) :
     ```bash
     curl -H "Host: app1.com" http://192.168.56.110
     ```
   - Requête vers le site de décoration (`nginx2`) :
     ```bash
     curl -H "Host: app2.com" http://192.168.56.110
     ```
   - Requête vers le site météo (fallback par défaut, `nginx3`) :
     ```bash
     curl http://192.168.56.110
     ```
4. Pour détruire la machine et nettoyer l'espace :
   ```bash
   make clean
   ```

---

### 🔁 Partie 3 : GitOps Continu avec Argo CD & Helm

Cette partie installe Docker, K3d et Helm localement sur votre machine hôte pour mettre en place un pipeline GitOps géré par Argo CD.

#### Fichiers Clés
* [p3/Makefile](file:///home/jbuan/sgoinfre/IOT/p3/Makefile) : Lance l'installation et le déploiement global de la partie 3.
* [p3/install.sh](file:///home/jbuan/sgoinfre/IOT/p3/install.sh) : Installe Docker, K3d, Helm et kubectl, puis lance le script de configuration.
* [p3/conf/config.sh](file:///home/jbuan/sgoinfre/IOT/p3/conf/config.sh) : Crée le cluster K3d, installe Argo CD, configure l'authentification et déploie l'application liée au dépôt Git distant.
* [p3/conf/values.yaml](file:///home/jbuan/sgoinfre/IOT/p3/conf/values.yaml) / [p3/conf/deployment.yaml](file:///home/jbuan/sgoinfre/IOT/p3/conf/deployment.yaml) : Configuration de l'application packagée avec Helm.
* [p3/test.sh](file:///home/jbuan/sgoinfre/IOT/p3/test.sh) : Script de redirection de port pour tester localement l'application.

#### Instructions d'Exécution
1. Placez-vous dans le dossier de la partie 3 :
   ```bash
   cd p3
   ```
2. Installez Docker, K3d, Helm, kubectl et déployez le cluster ainsi qu'Argo CD :
   ```bash
   make
   ```
3. Exécutez le script de test pour effectuer une redirection de port (Port-Forward) vers l'application déployée dans le namespace `dev` :
   ```bash
   ./test.sh
   ```
4. Dans un second terminal, interrogez l'application web pour valider son fonctionnement :
   ```bash
   curl -vk localhost:8888
   ```
5. Pour supprimer le cluster K3d et nettoyer les ressources système :
   ```bash
   make clean
   ```

> [!TIP]
> Le mot de passe initial de la console d'administration Argo CD est généré dynamiquement lors de l'installation et stocké dans le fichier `p3/pass`. Vous pouvez vous y connecter via l'adresse IP et le port indiqués par les fichiers `p3/ip_address` et `p3/port`.
