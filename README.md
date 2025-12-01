# NotesApp – Mini Projet DevOps (Ansible, Terraform, Kubernetes)

Projet ING5 – Université Internationale de Rabat

---

## 📌 Description du projet

Déploiement automatisé d’une application **NotesApp** (Backend Flask + Frontend Nginx + PostgreSQL) dans une VM Azure.
L’infrastructure est automatisée via :

* **Ansible** → installation & orchestration
* **Terraform** → ressources Kubernetes
* **Docker** → images backend / frontend
* **Kubernetes (Minikube)** → orchestration des conteneurs
* **Nginx Ingress + MetalLB** → exposition HTTP de l’application

---

## 📁 Structure du dépôt

```
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
```

---

## ⚙️ Déploiement automatisé

### 1️⃣ Lancer le playbook Ansible

```bash
cd ~/notesapp/ansible
ansible-playbook -i inventory.ini playbook.yml
```

### Ce que le playbook configure automatiquement :

* Installation de Docker, Minikube, kubectl, Helm, Terraform
* Construction des images Docker dans Minikube
* Déploiement Kubernetes via Terraform
* Mise en place de l’Ingress Controller

---

## 🌐 Accès à l’application (via tunnel SSH)

Depuis votre machine **locale** :

```bash
ssh -L 8080:192.168.49.2:80 azureuser@<public-ip>
```

Puis accéder à :
👉 [http://localhost:8080](http://localhost:8080)

---

## 🔍 Vérifications Kubernetes

### Pods

```bash
kubectl get pods -n notesapp
```

### Services

```bash
kubectl get svc -n notesapp
```

### Ingress

```bash
kubectl get ingress -n notesapp
```

### Tout le namespace

```bash
kubectl get all -n notesapp
```

---

## 🧱 Architecture

```
Localhost → Tunnel SSH → Ingress NGINX → Frontend (Nginx)
                                           └→ Backend (Flask)
                                                    └→ PostgreSQL
```

Minikube exécute tout à l'intérieur de la VM Azure.

---

## 🧪 Captures requises (rapport PDF)

* Accès navigateur → `http://localhost:8080`
* Résultat des commandes :

  * `kubectl get pods -n notesapp`
  * `kubectl get svc -n notesapp`
  * `kubectl get ingress -n notesapp`

---

## 🏁 Conclusion

Ce mini-projet met en œuvre :

* Automatisation (Ansible)
* Infrastructure as Code (Terraform)
* Orchestration (Kubernetes)
* Containerisation (Docker)
* Exposition via Ingress

Un pipeline complet, reproductible et opérationnel dans une VM Azure.

---

**Projet réalisé par : Othmane B. – ING5 Cloud Computing & Virtualization**
