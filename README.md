# IoT & DevOps Project - Kubernetes Cluster, Ingress Routing & GitOps

This repository contains a set of hands-on projects focusing on system administration, container orchestration, and continuous deployment (GitOps). The objective is to learn how to design and build a complete infrastructure, starting from provisioning virtual machines to automated application deployment using Kubernetes, Helm, and Argo CD.

## Project Summary

The project is structured into three progressive and distinct parts:

1. **Part 1 (`p1`): Multi-node Kubernetes Cluster (K3s)**
   - Initializing a two-node infrastructure: a master node (Server) and a worker node (Worker).
   - Provisioning virtual machines running **Alpine Linux** using **Vagrant** and **VirtualBox**.
   - Lightweight Kubernetes deployment via **K3s**.
   - Automating the secure sharing of the authentication token (`token`) and the cluster configuration file (`k3s.yaml`) to enable the Worker to automatically join the Server.

2. **Part 2 (`p2`): Application Routing with Traefik Ingress**
   - Setting up a K3s cluster on a single VM.
   - Deploying three distinct Nginx web applications managed using Kubernetes Deployments, Services, and ConfigMaps.
   - Configuring the **Traefik** Ingress controller to perform host-based routing using HTTP `Host` headers (`app1.com`, `app2.com`) and default routing (fallback).

3. **Part 3 (`p3`): Continuous GitOps with K3d, Helm & Argo CD**
   - Creating a local Kubernetes cluster using **K3d** (Kubernetes in Docker).
   - Deploying and configuring **Argo CD** to manage the application lifecycle in GitOps mode.
   - Modeling the application using a custom **Helm** Chart (`values.yaml`, `deployment.yaml`).
   - Automated synchronization and self-healing (auto-sync, self-healing, and auto-pruning) with a remote Git repository.

---

## Acquired Skills

This project covers a wide range of fundamental skills in DevOps, Cloud Native, and system administration:

- **Infrastructure as Code (IaC) & Virtualization**:
  - Configuring private networks and host-guest folder sharing using **Vagrant**.
  - Optimizing lightweight VMs running **Alpine Linux** (CPU/Memory resource allocation, VirtualBox network configuration).
- **Container Orchestration (Kubernetes)**:
  - Deploying and administering lightweight Kubernetes distributions (**K3s** for resource-constrained VMs and **K3d** for local development).
  - Managing essential Kubernetes resources: *Deployments, Services (ClusterIP and LoadBalancer), ConfigMaps, Namespaces, Ingress/IngressRoute*.
- **Traffic Routing & Reverse Proxy**:
  - Configuring **Traefik** as a Kubernetes Ingress controller.
  - Setting up advanced Ingress rules (routing based on host domain name, default fallback routes).
- **Package Management with Helm**:
  - Designing and customizing Helm Templates to dynamically configure Kubernetes deployment manifests.
- **GitOps & Continuous Delivery (CD)**:
  - Installing and configuring **Argo CD**.
  - Automating deployments from a Git source code repository with automated synchronization, self-healing, and auto-pruning policies.
- **Scripting & Automation**:
  - Writing robust Bash scripts and Makefiles to automate the infrastructure setup and lifecycle management.

---

## How to Use It

Each part has its own configuration and automation managed via a `Makefile`.

---

### Part 1: K3s Cluster (Multi-node)

This part deploys two Alpine Linux virtual machines (`jbuanS` and `jbuanSW`) configured as a K3s Server/Worker cluster.

#### Key Files
* [p1/Vagrantfile](p1/Vagrantfile): Configuration of the two VMs (private network, resource allocation, and provisioning script).
* [p1/Makefile](p1/Makefile): Cluster lifecycle management.
* [p1/install.sh](p1/install.sh): Installation script for prerequisites on the host machine.

#### Execution Instructions
1. Navigate to the Part 1 directory:
   ```bash
   cd p1
   ```
2. Install prerequisites (Vagrant, VirtualBox, etc.):
   ```bash
   ./install.sh
   ```
3. Start and configure the cluster:
   ```bash
   make
   ```
4. Connect via SSH to the master server to verify that the nodes have successfully joined the cluster:
   ```bash
   vagrant ssh jbuanS
   sudo kubectl get nodes -o wide
   ```
5. To clean up and destroy the virtual machines:
   ```bash
   make clean
   ```

---

### Part 2: HTTP Routing (Traefik Ingress & Nginx)

This part deploys a single K3s server running three Nginx applications with distinct homepages, accessible via domain names.

#### Key Files
* [p2/Vagrantfile](p2/Vagrantfile): VM configuration and automatic application of Kubernetes manifests.
* [p2/conf/nginx/04-nginx-ingress.yml](p2/conf/nginx/04-nginx-ingress.yml): Ingress rules definition for traffic routing.
* [p2/Makefile](p2/Makefile): Deployment and destruction of the Part 2 environment.

#### Execution Instructions
1. Navigate to the Part 2 directory:
   ```bash
   cd p2
   ```
2. Start the VM and apply Kubernetes configurations:
   ```bash
   make
   ```
3. Test routing from your host machine (or from the VM via SSH):
   - Request to the clothing website (`nginx1`):
     ```bash
     curl -H "Host: app1.com" http://192.168.56.110
     ```
   - Request to the home decor website (`nginx2`):
     ```bash
     curl -H "Host: app2.com" http://192.168.56.110
     ```
   - Request to the weather website (default fallback, `nginx3`):
     ```bash
     curl http://192.168.56.110
     ```
4. To destroy the VM and clean up the environment:
   ```bash
   make clean
   ```

---

### Part 3: Continuous GitOps with Argo CD & Helm

This part installs Docker, K3d, and Helm locally on your host machine to set up a GitOps pipeline managed by Argo CD.

#### Key Files
* [p3/Makefile](p3/Makefile): Triggers the installation and global deployment of Part 3.
* [p3/install.sh](p3/install.sh): Installs Docker, K3d, Helm, and kubectl, then starts the configuration script.
* [p3/conf/config.sh](p3/conf/config.sh): Creates the K3d cluster, installs Argo CD, configures authentication, and deploys the application linked to the remote Git repository.
* [p3/conf/values.yaml](p3/conf/values.yaml) / [p3/conf/deployment.yaml](p3/conf/deployment.yaml): Custom application configuration packaged with Helm.
* [p3/test.sh](p3/test.sh): Port-forwarding script to test the application locally.

#### Execution Instructions
1. Navigate to the Part 3 directory:
   ```bash
   cd p3
   ```
2. Install Docker, K3d, Helm, kubectl, and deploy the cluster and Argo CD:
   ```bash
   make
   ```
3. Run the test script to establish port-forwarding to the application deployed in the `dev` namespace:
   ```bash
   ./test.sh
   ```
4. In a second terminal, query the web application to validate its deployment:
   ```bash
   curl -vk localhost:8888
   ```
5. To delete the K3d cluster and clean up system resources:
   ```bash
   make clean
   ```

> [!TIP]
> The initial password for the Argo CD administration console is dynamically generated during installation and stored in the `p3/pass` file. You can access it using the IP address and port specified in the `p3/ip_address` and `p3/port` files.
