# 🚀 Création d’une Infrastructure Docker et Orchestration Avancée

## 🎯 Objectifs du Projet

Ce projet vise à maîtriser la conteneurisation d'une application e-commerce en architecture microservices à l'aide de Docker, Docker Compose, et en option Docker Swarm. Il inclut :

- La création d’images Docker optimisées.
- La distinction entre les environnements de développement et de production.
- Le déploiement via un pipeline CI/CD.
- Le respect des bonnes pratiques de sécurité et d’orchestration.

👥 Travail en groupe de 3 étudiants.

---

## 🧠 Prérequis

- Connaissances de base en Docker & Docker Compose.
- Maîtrise de Linux (Debian 12).
- Notions de réseaux Docker et d’orchestration (Docker Swarm).
- Connaissances en gestion de fichiers et sécurité.

---

## 📝 Description du Projet

Vous recevez un dépôt Git contenant le code d’une application e-commerce répartie en microservices :

- **Frontend** : Vue.js
- **Backend** :
    - Service Produits (Node.js + MongoDB)
    - Service Utilisateurs (Node.js + JWT)
    - Service Panier (Node.js)

Votre mission :

- Créer les `Dockerfile` (multi-stage).
- Mettre en place les fichiers `docker-compose.yml` (dev et prod).
- Sécuriser, optimiser et documenter l’infrastructure.
- Utiliser Docker Swarm pour l’orchestration (optionnel).

---

## ✅ Tâches principales

### A. Analyse du Projet

- Cloner le dépôt.
- Analyser la structure.
- Mettre en place un workflow Git (GitFlow).

### B. Création des Dockerfile

- Un `Dockerfile` par microservice.
- Séparation dev/prod avec multi-stage.
- Variables d’environnement, utilisateur non-root, secrets, etc.

### C. Configuration de Docker Compose

- Fichier `docker-compose.yml` pour dev (volumes, réseau, MongoDB).
- Fichier `docker-compose.prod.yml` pour prod.
- Préparation pour Docker Swarm (bonus).

### D. Bonnes Pratiques

- Réduction de taille des images.
- Exécution sécurisée des conteneurs.
- Configuration des logs, secrets, monitoring.

### E. Tests et Validation

- Tests fonctionnels des services.
- Scans de sécurité (Trivy).
- Déploiement et validation sur Swarm (bonus).

---

## 🔥 Bonus (Facultatif)

- Intégration CI/CD.
- Monitoring (Prometheus, Grafana).
- Outils de sécurité supplémentaires.
- Déploiement complet avec Docker Swarm.
- Tout ajout personnel sera valorisé.

---

## 📦 Livrables attendus

1. **Dépôt Git** :
    - Dockerfiles, `docker-compose`, code source.
    - Arborescence claire et structurée.
2. **Documentation** (`README.md`) :
    - Instructions de build, run, tests, configs.
3. **Fichier de logs Git** :
   ```bash
   git log --pretty=format:"%h %ad | %s%d [%an]" --date=short > logs_projet.txt
   ```
4. **Présentation finale** :
    - Démo de l’appli.
    - Explication des choix techniques et difficultés rencontrées.

---

## 🧪 Critères d’Évaluation

| Critère                                           | Points |
|--------------------------------------------------|--------|
| Création et optimisation des Dockerfile          |   6    |
| Configuration Docker Compose / Swarm             |   5    |
| Bonnes pratiques de sécurité et optimisation     |   3    |
| Documentation                                    |   1    |
| Tests et validation fonctionnelle                |   2    |
| **Total**                                        | **16** |

---

## 🔄 Processus recommandé

- Planification et répartition des tâches.
- Communication continue entre membres.
- Tests fréquents et documentation progressive.
- Suivi des recommandations officielles Docker.
- Approche incrémentale : commencer sans bonnes pratiques, puis itérer.

---

## 📚 Ressources

- [Documentation Docker](https://docs.docker.com/)
- [Best Practices Dockerfile](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker Compose Docs](https://docs.docker.com/compose/)
- [Trivy (Scan de sécurité)](https://aquasecurity.github.io/trivy/)

---

> Projet encadré par Vincent LAINE
