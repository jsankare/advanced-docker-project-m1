# 🎯 Guide de Présentation des Bonus
## Démonstration pour Soutenance - Infrastructure Docker Avancée

---

## 📋 Plan de Démonstration

1. **Registry Docker Hub** - Images automatiquement buildées et poussées
2. **Docker Swarm** - Orchestration et haute disponibilité  
3. **CI/CD Pipeline** - Automatisation complète avec sécurité
4. **Portainer** - Monitoring et gestion visuelle
5. **Security Scanning** - Analyse de vulnérabilités

---

## 🐳 1. BONUS : Registry Docker Hub

### **Démonstration :**
```bash
# Montrer les images sur Docker Hub
echo "🔗 Images disponibles publiquement :"
echo "https://hub.docker.com/u/lucasratiaray"

# Vérifier les images locales
docker images | grep lucasratiaray
```

### **Points à présenter :**
- ✅ **Images publiques** sur Docker Hub
- ✅ **Tags automatiques** (latest + SHA du commit)
- ✅ **Mise à jour automatique** via CI/CD
- ✅ **Déploiement sans code source**

### **Démonstration déploiement public :**
```bash
# Simulation : Quelqu'un veut déployer notre app
mkdir /tmp/test-deploy
cd /tmp/test-deploy

# Télécharger uniquement le compose (pas de code source)
curl -O https://github.com/jsankare/advanced-docker-project-m1/blob/feat/bonus/e-commerce-vue-main/docker-compose.prod.yml

# Déployer en une commande
docker compose -f docker-compose.public.yml up -d

# Vérifier que ça marche
docker compose -f docker-compose.publicﬂ.yml ps
```

---

## ⚡ 2. BONUS : Docker Swarm - Orchestration

### **Initialisation (si pas déjà fait) :**
```bash
# Initialiser Docker Swarm
docker swarm init

# Vérifier l'état du swarm
docker node ls
```

### **Déploiement de la stack :**
```bash
# Déployer en mode production avec Swarm
docker stack deploy -c docker-compose.prod.yml ecommerce

# Vérifier le déploiement
docker stack ls
docker stack services ecommerce
```

### **Démonstration des capacités Swarm :**
```bash
# 1. Haute disponibilité - Scaling
echo "🔄 Scaling du frontend : 2 → 4 replicas"
docker service scale ecommerce_frontend=4

# Vérifier le scaling
docker service ls | grep frontend

# 2. Mise à jour rolling
echo "🔄 Mise à jour rolling du service auth"
docker service update --image lucasratiaray/ecommerce-auth-service:latest ecommerce_auth-service

# 3. Rollback en cas de problème
echo "↩️ Rollback possible en une commande"
docker service rollback ecommerce_auth-service

# 4. Santé des services
echo "💚 Health checks automatiques"
docker service ps ecommerce_mongodb
```

### **Points à présenter :**
- ✅ **Scalabilité horizontale** (replicas multiples)
- ✅ **Load balancing automatique**
- ✅ **Rolling updates** sans downtime
- ✅ **Health checks** et auto-restart
- ✅ **Placement constraints** (manager vs worker)

---

## 🔄 3. BONUS : CI/CD Pipeline avec Sécurité

### **Démonstration du workflow complet :**
```bash
# 1. Déclencher le pipeline avec une modification
echo "<!-- Updated for demo $(date) -->" >> e-commerce-vue-main/frontend/index.html
git add e-commerce-vue-main/frontend/index.html
git commit -m "demo: trigger CI/CD pipeline for presentation"
git push origin feat/bonus
```

### **Montrer dans GitHub Actions :**
1. **Tests automatiques** des 4 services
2. **Build des 4 images** Docker
3. **Security scan** du code et des images
4. **Push automatique** vers Docker Hub

### **Vérifier les résultats :**
```bash
# Vérifier que les nouvelles images sont disponibles
docker pull lucasratiaray/ecommerce-frontend:latest

# Mettre à jour automatiquement les services
docker service update --force ecommerce_frontend
```

### **Points à présenter :**
- ✅ **Automatisation complète** (push → test → build → deploy)
- ✅ **Tests unitaires** de tous les services
- ✅ **Security scanning** intégré
- ✅ **Déploiement automatique** des images
- ✅ **Rollback facile** en cas de problème

---

## 📊 4. BONUS : Portainer - Monitoring Avancé

### **Démarrer/Redémarrer Portainer :**
```bash
# Vérifier que Portainer fonctionne
docker service ls | grep portainer

# Si problème, redémarrer
docker service update --force ecommerce_portainer

# Attendre le démarrage
sleep 10
```

### **Accéder à Portainer :**
```bash
# Ouvrir dans le navigateur
echo "🖥️ Accéder à Portainer : http://localhost:9000"

# Vérifier l'accès
curl -I http://localhost:9000
```

### **Configuration première fois :**
1. **Créer admin** : `admin` / `AdminSecure123!`
2. **Sélectionner Docker** (Local)
3. **Connect**

### **Démonstration dans Portainer :**

#### **Dashboard Principal :**
- Vue d'ensemble de tous les services
- Statistiques des ressources (CPU, RAM, Network)
- État des conteneurs en temps réel

#### **Gestion des Services :**
```bash
# Dans Portainer, montrer :
# 1. Services → Liste des services avec replicas
# 2. Cliquer sur un service → Détails complets
# 3. Logs en temps réel
# 4. Possibilité de scaler en un clic
```

#### **Monitoring en Temps Réel :**
- Graphiques CPU/RAM par service
- Logs centralisés et filtres
- État de santé des conteneurs

### **Points à présenter :**
- ✅ **Interface web intuitive** pour Docker Swarm
- ✅ **Monitoring temps réel** de tous les services
- ✅ **Gestion sans ligne de commande**
- ✅ **Logs centralisés** avec filtres
- ✅ **Scaling visuel** en un clic
- ✅ **Alertes** et notifications

---

## 🔒 5. BONUS : Security Scanning

### **1. Voir les résultats dans GitHub Actions :**
```bash
echo "🔗 Security scan results :"
echo "GitHub → Actions → Dernier workflow → security-scan job"
```

### **2. Scan local avancé avec Trivy :**
```bash
# Installer Trivy (si pas déjà fait)
sudo apt-get update
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy

# Scan du code source
echo "🔍 Scanning source code for vulnerabilities..."
trivy fs e-commerce-vue-main/ --format table

# Scan des images Docker
echo "🐳 Scanning Docker images..."
trivy image lucasratiaray/ecommerce-frontend:latest --format table
trivy image lucasratiaray/ecommerce-auth-service:latest --format table
```

### **3. Scan de sécurité basique :**
```bash
# Recherche de credentials hardcodés
echo "🔍 Checking for hardcoded secrets..."
grep -r "password" e-commerce-vue-main/ --exclude-dir=node_modules || echo "✅ No hardcoded passwords"
grep -r "secret" e-commerce-vue-main/ --exclude-dir=node_modules || echo "✅ No hardcoded secrets"
grep -r "api.key" e-commerce-vue-main/ --exclude-dir=node_modules || echo "✅ No hardcoded API keys"

# Vérifier les dépendances
echo "📦 Checking dependencies..."
cd e-commerce-vue-main/frontend && npm audit || true
cd ../services/auth-service && npm audit || true
```

### **Points à présenter :**
- ✅ **Scan automatique** dans le pipeline CI/CD
- ✅ **Détection de vulnérabilités** dans le code et dépendances
- ✅ **Scan des images Docker** pour les CVE
- ✅ **Recherche de secrets** hardcodés
- ✅ **Rapports de sécurité** intégrés
- ✅ **Prévention** avant déploiement

---

## 🎯 6. Démonstration Complète de l'Application

### **Test de l'application déployée :**
```bash
# 1. Vérifier que tous les services fonctionnent
docker service ls

# 2. Tester l'API
echo "🧪 Testing the deployed application..."

# Test des produits
curl http://localhost/api/products | jq '.[0:2]'

# Test de création d'utilisateur
curl -X POST http://localhost/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email": "demo@example.com", "password": "DemoPassword123!"}'

# 3. Tester l'interface web
echo "🌐 Application web disponible : http://localhost"
```

### **Initialiser des données de démonstration :**
```bash
# Si script d'initialisation disponible
./scripts/init-products.sh || echo "Script d'init non disponible"

# Ou ajouter manuellement des produits via l'API
curl -X POST http://localhost/api/products \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{"name": "Produit Demo", "price": 29.99, "description": "Produit pour la démonstration"}'
```

---

## 📈 7. Récapitulatif des Bonus Présentés

### **✅ Registry Docker Hub :**
- Images publiques automatiquement buildées
- Déploiement sans code source
- Versionning automatique

### **✅ Docker Swarm :**
- Orchestration et haute disponibilité
- Scaling horizontal automatique
- Rolling updates sans downtime
- Health checks et auto-restart

### **✅ CI/CD Pipeline :**
- Tests automatiques de tous les services
- Build et push automatique des images
- Security scanning intégré
- Déploiement automatisé

### **✅ Portainer :**
- Monitoring visuel de l'infrastructure
- Gestion des services sans CLI
- Logs centralisés et temps réel
- Interface web professionnelle

### **✅ Security Scanning :**
- Scan automatique du code source
- Détection de vulnérabilités
- Scan des images Docker
- Prévention des failles de sécurité

---

## 🎤 Script de Présentation (5 minutes)

### **Introduction (30s) :**
*"Notre projet implémente une architecture microservices complète avec des bonus avancés pour la production."*

### **1. Registry & Déploiement (1min) :**
*"Nos images sont automatiquement buildées et poussées sur Docker Hub. N'importe qui peut déployer notre application sans avoir le code source."*
```bash
docker-compose -f docker-compose.public.yml up -d
```

### **2. Orchestration Swarm (1min) :**
*"Docker Swarm assure la haute disponibilité avec scaling automatique et rolling updates."*
```bash
docker service scale ecommerce_frontend=4
docker service ls
```

### **3. CI/CD & Sécurité (1min) :**
*"Pipeline complet avec tests automatiques et scans de sécurité intégrés."*
```bash
# Montrer GitHub Actions
trivy image lucasratiaray/ecommerce-frontend:latest
```

### **4. Monitoring Portainer (1min) :**
*"Interface de monitoring professionnelle pour gérer toute l'infrastructure."*
```bash
# Démonstration dans http://localhost:9000
```

### **5. Application Fonctionnelle (30s) :**
*"Application complètement fonctionnelle et production-ready."*
```bash
curl http://localhost/api/products
# Montrer http://localhost
```

---

## 🏆 Points Forts à Mentionner

- **Production-Ready** : Infrastructure complète pour la production
- **Automatisation Totale** : De la modification du code au déploiement
- **Sécurité Intégrée** : Scans automatiques et bonnes pratiques
- **Monitoring Professionnel** : Supervision complète de l'infrastructure
- **Scalabilité** : Capacité à gérer la montée en charge
- **Simplicité** : Déploiement en une commande pour les utilisateurs

**🎉 Votre infrastructure est niveau entreprise ! 🎉**