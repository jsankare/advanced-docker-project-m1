# 🔧 Guide Demo - Correction Nginx en Live

## 📋 Objectif
Corriger la configuration nginx du frontend pour permettre le routage des APIs sans rebuilder l'image.

---

## 🚀 Étapes de Démonstration

### **1. Entrer dans le container frontend**
```bash
docker exec -it test-deploy-frontend-1 sh
```

### **2. Vérifier la configuration nginx actuelle**
```bash
cat /etc/nginx/conf.d/default.conf
```

### **3. Corriger la configuration nginx**
```bash
cat > /etc/nginx/conf.d/default.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    location /api/auth/ {
        proxy_pass http://auth-service:3001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /api/products/ {
        proxy_pass http://product-service:3002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /api/cart/ {
        proxy_pass http://product-service:3002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /api/orders/ {
        proxy_pass http://order-service:3003;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }
}
EOF
```

### **4. Vérifier la syntaxe nginx**
```bash
nginx -t
```

### **5. Recharger nginx**
```bash
nginx -s reload
```

### **6. Quitter le container**
```bash
exit
```

---

## 🧪 Tests de Validation

### **Test 1 : API Auth (Inscription)**
```bash
curl -X POST http://localhost/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email": "demo@test.com", "password": "password123"}'
```

**Résultat attendu :**
```json
{"message":"Utilisateur créé avec succès","token":"eyJ...","userId":"..."}
```

### **Test 2 : API Products**
```bash
curl http://localhost/api/products
```

**Résultat attendu :**
```json
[{"_id":"...","name":"Smartphone Galaxy S21","price":899,...}]
```

### **Test 3 : API Orders**
```bash
curl http://localhost/api/orders
```

### **Test 4 : Frontend Web**
```bash
curl -I http://localhost
```

**Résultat attendu :**
```
HTTP/1.1 200 OK
Content-Type: text/html
```

### **Test 5 : Portainer**
```bash
curl -I http://localhost:9000
```

---

## 🎯 Script Complet de Démonstration

```bash
#!/bin/bash
echo "🔧 Correction nginx en live..."

# Entrer dans le container et corriger nginx
docker exec -it test-deploy-frontend-1 sh -c '
cat > /etc/nginx/conf.d/default.conf << "EOF"
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    location /api/auth/ {
        proxy_pass http://auth-service:3001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /api/products/ {
        proxy_pass http://product-service:3002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /api/cart/ {
        proxy_pass http://product-service:3002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /api/orders/ {
        proxy_pass http://order-service:3003;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }
}
EOF

nginx -t && nginx -s reload
'

echo "✅ Nginx reconfiguré avec succès!"
echo ""

# Tests des APIs
echo "🧪 Test des APIs..."
echo ""

echo "🔐 Test Auth API:"
curl -X POST http://localhost/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email": "demo@test.com", "password": "password123"}'

echo -e "\n\n📦 Test Products API:"
curl http://localhost/api/products

echo -e "\n\n🌐 Test Frontend:"
curl -I http://localhost

echo -e "\n\n🎉 Tous les tests terminés!"
```

---

## 💡 Points à Présenter

### **Avantages de cette approche :**
- ✅ **Hot-reload** sans downtime
- ✅ **Correction en temps réel**
- ✅ **Pas de rebuild d'image nécessaire**
- ✅ **Debugging efficace en production**

### **Applications pratiques :**
- 🚀 **Correction d'urgence** en production
- 🔧 **Test de configurations** avant commit
- 🎯 **Debugging** rapide de problèmes réseau
- 📊 **Validation** de changements avant release

---

## 🎤 Script de Présentation (1 minute)

*"Comme vous pouvez le voir, Docker nous permet de corriger des configurations en temps réel sans avoir à rebuilder les images. Ici, je corrige la configuration nginx du frontend pour router correctement les APIs vers nos microservices backend."*

**[Exécuter les commandes]**

*"En quelques secondes, notre application passe d'un état non-fonctionnel à complètement opérationnelle, avec toutes les APIs qui répondent correctement. Cette flexibilité est essentielle en production pour résoudre rapidement les problèmes."*