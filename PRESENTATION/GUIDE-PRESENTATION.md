# GUIDE DE PRÉSENTATION - Dockerisation E-Commerce Microservices

## 🎯 PLAN DE PRÉSENTATION (10-15 minutes)

### 1. Introduction (2 min)
**"Bonjour, nous allons vous présenter notre travail de dockerisation d'une application e-commerce microservices."**

#### Contexte du projet
- Application e-commerce **déjà développée** (Vue.js + 3 microservices Node.js)
- **Objectif** : Dockeriser pour dev et production
- **Groupe de 3** : [Noms des membres]

#### Architecture existante
```
Frontend Vue.js ──► Auth Service (3001)
                ├─► Product Service (3000) 
                └─► Order Service (3002)
                           │
                    MongoDB (27017)
```

---

## 2. Analyse et Stratégie (3 min)

### Notre approche
**"Nous avons analysé l'application existante et défini une stratégie de dockerisation."**

#### Défis identifiés
- 4 composants à dockeriser
- Distinction **dev/production** requise
- Gestion des **secrets** (JWT, MongoDB)
- **Communication inter-services**

#### Décisions techniques
| Composant | Stratégie | Justification |
|-----------|-----------|---------------|
| **Frontend** | Multi-stage (build + nginx) | Optimisation prod (25MB vs 800MB) |
| **Services** | Single-stage Alpine | Node.js nécessaire en prod, simplicité |
| **Secrets** | Docker Secrets | Sécurité + compatibilité Swarm |
| **Réseaux** | Bridge (dev) + Overlay (prod) | Performance + scalabilité |

---

## 3. Démonstration Technique (5 min)

### Structure créée
```
├── docker-compose.yml          # Développement
├── docker-compose.prod.yml     # Production
├── secrets/                    # Gestion sécurisée
├── frontend/Dockerfile         # Multi-stage
└── services/*/Dockerfile       # Services optimisés
```

### Dockerfile Frontend (MONTRER)
```dockerfile
# Build stage - Compilation Vue.js
FROM node:18-alpine as build-stage
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Production stage - Nginx léger
FROM nginx:stable-alpine as production-stage
COPY --from=build-stage /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**Points clés :**
- **Multi-stage** : Build séparé de la production
- **Image finale** : Seulement nginx + assets (25MB)
- **Pas de Node.js** en production

### Dockerfile Services (MONTRER)
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# Sécurité : utilisateur non-root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chown -R appuser:appgroup /app
USER appuser

EXPOSE 3001
CMD ["npm", "start"]
```

**Points clés :**
- **Alpine** : Images légères
- **Non-root** : Sécurité renforcée
- **Simple** : Pas de multi-stage inutile (Node.js requis)

---

## 4. Environnements Configurés (3 min)

### Développement (`docker-compose.yml`)
```bash
docker-compose up --build
```

**Caractéristiques :**
- **Hot-reload** avec volumes montés
- **Ports exposés** pour debugging
- **MongoDB accessible** (27017)
- **Réseau bridge** simple

### Production (`docker-compose.prod.yml`)
```bash
docker stack deploy -c docker-compose.prod.yml ecommerce
```

**Caractéristiques :**
- **Docker Swarm ready**
- **2 replicas** par service
- **Health checks** configurés
- **Ressources limitées**
- **Secrets sécurisés**

---

## 5. Démonstration Live (2 min)

### Tests en direct
```bash
# 1. Lancement dev
docker-compose up -d --build

# 2. Vérification santé
curl http://localhost:8080
curl http://localhost:3001/api/auth/health

# 3. Test fonctionnel
curl -X POST http://localhost:3001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@test.com","password":"demo123"}'
```

---

## 🎤 QUESTIONS-RÉPONSES ANTICIPÉES

### **Q: Pourquoi pas de multi-stage pour les services backend ?**
**R:** "Les services Node.js ont besoin du runtime même en production. Le multi-stage n'apporterait que la suppression des dev dependencies, soit un gain minimal. On a privilégié la simplicité et la maintenance."

### **Q: Comment gérez-vous les secrets ?**
**R:** "On utilise Docker Secrets avec des fichiers externes. C'est plus sécurisé que les variables d'environnement et compatible Docker Swarm. Les secrets sont montés dans `/run/secrets/` dans les conteneurs."

### **Q: Pourquoi deux docker-compose différents ?**
**R:** "Dev et prod ont des besoins différents :
- **Dev** : Hot-reload, ports exposés, debugging
- **Prod** : Sécurité, réplication, health checks, ressources limitées"

### **Q: Comment assurez-vous la sécurité ?**
**R:** "Plusieurs mesures :
- Utilisateurs **non-root** dans tous les conteneurs
- **Secrets** séparés des images
- **Réseaux isolés** en production
- Images **Alpine** (surface d'attaque réduite)"

### **Q: Quelle est la taille des images finales ?**
**R:** 
- Frontend prod : **~25MB** (nginx + assets)
- Services : **~150MB** (node:alpine + app)
- Total stack : **~500MB** vs plusieurs GB sans optimisation"

### **Q: Comment testez-vous que tout fonctionne ?**
**R:** "On a plusieurs niveaux :
- **Health checks** Docker intégrés
- **Tests curl** des endpoints
- **Vérification communication** inter-services
- **Monitoring** des logs"

### **Q: Difficultés rencontrées ?**
**R:** "Principales difficultés :
- **Communication inter-services** : Résolu avec les réseaux Docker
- **Gestion des secrets** : Apprentissage de Docker Secrets
- **Optimisation images** : Balance entre taille et fonctionnalité"

### **Q: Prêt pour la production ?**
**R:** "Oui, avec Docker Swarm :
- **Haute disponibilité** (replicas)
- **Load balancing** automatique
- **Rolling updates** possibles
- **Monitoring** intégré"

### **Q: Améliorations possibles ?**
**R:** "Bonus qu'on pourrait ajouter :
- **CI/CD** pipeline
- **Monitoring** (Prometheus/Grafana)
- **Scan sécurité** automatisé (Trivy)
- **Logs centralisés** (ELK stack)"

---

## 💡 CONSEILS POUR LA SOUTENANCE

### **Démonstration**
1. **Préparer les commandes** à l'avance
2. **Tester avant** que tout fonctionne
3. **Avoir un plan B** si problème réseau
4. **Expliquer pendant** que ça charge

### **Communication**
- **Parler clairement** des choix techniques
- **Justifier** chaque décision
- **Montrer** qu'on comprend les implications
- **Rester humble** sur les améliorations possibles

### **Gestion du temps**
- **5 min présentation** max
- **5 min démo** live
- **5 min questions**

### **Répartition rôles**
- **Personne 1** : Architecture et stratégie
- **Personne 2** : Démonstration technique
- **Personne 3** : Questions-réponses et conclusion

---

## 📋 CHECKLIST AVANT SOUTENANCE

### Technique
- [ ] Docker et Docker Compose installés
- [ ] Toutes les images buildent correctement
- [ ] Tests de santé passent
- [ ] Secrets configurés
- [ ] Scripts d'init prêts

### Présentation
- [ ] Slides préparés (optionnel)
- [ ] Démo testée
- [ ] Répartition des rôles claire
- [ ] Timing respecté
- [ ] Questions-réponses préparées

### Documentation
- [ ] README à jour
- [ ] Commandes de test documentées
- [ ] Architecture expliquée
- [ ] Choix justifiés

---

## 🎯 MESSAGE CLÉ

**"Nous avons dockerisé avec succès une application microservices complexe en respectant les bonnes pratiques : images optimisées, sécurité renforcée, environnements séparés, et prêt pour la production avec Docker Swarm."**

---

**Bonne chance pour votre soutenance ! 🚀**