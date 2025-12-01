NotesApp – Mini Projet DevOps (Ansible + Terraform + Kubernetes + Docker)

Université Internationale de Rabat – ING5
Encadrant : Pr. EL MENDILI

Ce projet met en place un déploiement entièrement automatisé d’une application NotesApp (backend Flask + frontend Nginx + PostgreSQL) sur une machine virtuelle Azure, orchestrée avec Kubernetes (Minikube).
L'installation, la configuration, la construction des images et le déploiement sont automatisés via Ansible et Terraform.

 1. Structure du Repository
notesapp/
│
├── ansible/
│   ├── inventory.ini
│   ├── playbook.yml
│   └── templates/
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── app/
│   ├── backend/
│   │   ├── app.py
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   │
│   └── frontend/
│       ├── index.html
│       ├── script.js
│       └── nginx/Dockerfile
│
└── README.md

2. Outils utilisés
Outil	Rôle
Docker	Containerisation du backend et frontend
Minikube	Cluster Kubernetes local dans la VM Azure
Kubernetes	Orchestration des pods / services
Terraform	Infrastructure as Code pour générer les ressources K8s
Ansible	Automatisation complète du provisioning et des déploiements
Nginx Ingress	Exposition de l’application via un hôte HTTP
MetalLB	LoadBalancer pour Minikube (IP externe : 192.168.49.2)
🚀 3. Déploiement Automatisé
3.1 Prérequis

VM Azure Ubuntu 22.04

Accès SSH avec clé

Ports sortants ouverts

4GB RAM minimum pour Minikube

3.2 Lancer le playbook Ansible

Depuis la VM Azure :

cd ~/notesapp/ansible
ansible-playbook -i inventory.ini playbook.yml


Le playbook effectue automatiquement :

Installation de Docker

Installation de Minikube, kubectl, Helm, Terraform

Lancement de Minikube

Construction des images Docker dans Minikube

terraform init + apply

Déploiement complet de l'application

4. Accès à l’Application via Tunnel SSH

Azure ne permet pas l’accès direct à l’IP locale de Minikube.
Un tunnel SSH est nécessaire.

Depuis votre machine locale :

ssh -L 8080:192.168.49.2:80 azureuser@<public-ip>


Puis ouvrir :

http://localhost:8080

5. Vérifications Kubernetes

Depuis la VM Azure :

Pods
kubectl get pods -n notesapp

Services
kubectl get svc -n notesapp

Ingress
kubectl get ingress -n notesapp

Tout le namespace
kubectl get all -n notesapp

6. Architecture
Utilisateurs → Tunnel SSH → Nginx Ingress → Frontend (Nginx)
                                         └→ Backend (Flask)
                                                    └→ PostgreSQL


Le tout exécuté dans Minikube à l’intérieur de la VM Azure.

7. Infrastructure gérée par Terraform

Terraform génère et applique automatiquement :

Deployments (API + Frontend)

Service ClusterIP

Volume et PersistentVolumeClaim

Secret PostgreSQL

Ingress (host = notes.<ip>.nip.io ou accès local via tunnel)

Et s’exécute depuis Ansible :

terraform init
terraform apply -auto-approve -var="ingress_host=<value>"

8. Commandes utiles
Redémarrer Minikube
minikube delete
minikube start --driver=docker

Voir les logs d’un pod
kubectl logs <pod> -n notesapp

Voir l’ingress
kubectl describe ingress notesapp-ingress -n notesapp


9. Conclusion

Ce mini-projet met en œuvre une chaîne DevOps complète comprenant :

Automatisation (Ansible)

Infrastructure as Code (Terraform)

Containerisation (Docker)

Orchestration (Kubernetes)

Exposition via Ingress

Déploiement reproductible dans une VM Azure

Le tout permettant un déploiement entièrement automatisé, sans intervention manuelle.

Contact

Projet réalisé par :
Othmane B. – ING5 Cloud Computing & Virtualization
Université Internationale de Rabat
