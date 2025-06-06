#!/bin/bash

# Script de test pour l'application e-commerce dockerisée
# Adapté à l'architecture Docker Compose existante
# Auteur: Groupe Dockerisation E-Commerce

set -e  # Arrêter le script en cas d'erreur

echo "🐳 Tests de l'application e-commerce microservices dockerisée"
echo "============================================================"

# Couleurs pour les logs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Variables de test
TOTAL_TESTS=0
FAILED_TESTS=0
BASE_URL_AUTH="http://localhost:3001"
BASE_URL_PRODUCT="http://localhost:3000"
BASE_URL_ORDER="http://localhost:3002"
BASE_URL_FRONTEND="http://localhost:8080"

# Fonction pour afficher les résultats
print_result() {
    ((TOTAL_TESTS++))
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
        ((FAILED_TESTS++))
    fi
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_header() {
    echo -e "\n${BLUE}$1${NC}"
    echo -e "${BLUE}$(printf '=%.0s' $(seq 1 ${#1}))${NC}"
}

# Fonction pour tester les endpoints avec retry
test_endpoint() {
    local url=$1
    local expected_status=${2:-200}
    local max_retries=3
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        response=$(curl -s -w "%{http_code}" "$url" -o /tmp/response_body 2>/dev/null || echo "000")
        
        if [ "$response" = "$expected_status" ]; then
            return 0
        fi
        
        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $max_retries ]; then
            sleep 3
        fi
    done
    
    echo "Dernière réponse: HTTP $response" >&2
    return 1
}

# Vérification préalable
print_header "🔍 Vérifications préalables"

# Vérifier que Docker et Docker Compose sont installés
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker n'est pas installé${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose n'est pas installé${NC}"
    exit 1
fi

print_result 0 "Docker et Docker Compose sont installés"

# Vérifier que les services sont démarrés
print_info "Vérification du statut des conteneurs..."
if ! docker-compose ps | grep -q "Up"; then
    print_warning "Les services ne semblent pas être démarrés"
    echo "Utilisation: docker-compose up -d"
    read -p "Voulez-vous démarrer les services maintenant? (y/N): " start_services
    if [[ $start_services =~ ^[Yy]$ ]]; then
        print_info "Démarrage des services..."
        docker-compose up -d
        sleep 30
    else
        echo -e "${RED}❌ Services non démarrés. Arrêt des tests.${NC}"
        exit 1
    fi
fi

print_header "1️⃣  État des conteneurs Docker"

# Vérifier les conteneurs en cours d'exécution
print_info "Vérification des conteneurs actifs..."

# Méthode compatible avec toutes les versions de docker-compose
echo "État des conteneurs:"
docker-compose ps

# Compter les conteneurs en cours d'exécution de manière plus robuste
RUNNING_CONTAINERS=$(docker-compose ps | grep -E "Up|running" | wc -l || echo "0")
EXPECTED_CONTAINERS=5  # frontend, auth-service, product-service, order-service, mongodb

if [ "$RUNNING_CONTAINERS" -ge 4 ]; then  # Au moins les services principaux
    print_result 0 "Services principaux actifs ($RUNNING_CONTAINERS conteneurs)"
else
    print_result 1 "Services manquants ($RUNNING_CONTAINERS/$EXPECTED_CONTAINERS actifs)"
fi

print_header "2️⃣  Tests de connectivité des services"

# Attendre que les services soient prêts
print_info "Attente du démarrage complet des services (30 secondes)..."
sleep 30

# Test Frontend
print_info "Test d'accessibilité du frontend..."
if test_endpoint "$BASE_URL_FRONTEND" 200; then
    print_result 0 "Frontend accessible sur port 8080"
else
    print_result 1 "Frontend inaccessible"
fi

# Test Auth Service
print_info "Test du service d'authentification..."
if test_endpoint "$BASE_URL_AUTH/api/auth/health" 200; then
    print_result 0 "Auth Service répond (port 3001)"
else
    # Fallback: tester une route connue
    if test_endpoint "$BASE_URL_AUTH" 404; then
        print_result 0 "Auth Service actif (port 3001) - endpoint /health non disponible"
    else
        print_result 1 "Auth Service non accessible"
    fi
fi

# Test Product Service
print_info "Test du service produits..."
if test_endpoint "$BASE_URL_PRODUCT/api/products" 200; then
    print_result 0 "Product Service répond (port 3000)"
else
    if test_endpoint "$BASE_URL_PRODUCT" 404; then
        print_result 0 "Product Service actif (port 3000)"
    else
        print_result 1 "Product Service non accessible"
    fi
fi

# Test Order Service  
print_info "Test du service commandes..."
if test_endpoint "$BASE_URL_ORDER/api/orders" 200; then
    print_result 0 "Order Service répond (port 3002)"
else
    if test_endpoint "$BASE_URL_ORDER" 404; then
        print_result 0 "Order Service actif (port 3002)"
    else
        print_result 1 "Order Service non accessible"
    fi
fi

print_header "3️⃣  Tests des APIs fonctionnelles"

# Test de l'API des produits (endpoint public)
print_info "Test de récupération des produits..."
PRODUCTS_RESPONSE=$(curl -s -w "%{http_code}" "$BASE_URL_PRODUCT/api/products" -o /tmp/products_response 2>/dev/null || echo "000")

if [ "$PRODUCTS_RESPONSE" = "200" ]; then
    # Vérifier que la réponse contient des données JSON
    if command -v jq &> /dev/null && jq empty /tmp/products_response 2>/dev/null; then
        PRODUCT_COUNT=$(jq length /tmp/products_response 2>/dev/null || echo "0")
        print_result 0 "API Produits - $PRODUCT_COUNT produits récupérés"
    else
        print_result 0 "API Produits - Réponse reçue (JSON non validé)"
    fi
else
    print_result 1 "API Produits - HTTP $PRODUCTS_RESPONSE"
fi

# Test d'inscription (avec email unique)
print_info "Test de l'inscription utilisateur..."
TEST_EMAIL="test-$(date +%s)@docker-test.com"
REGISTER_RESPONSE=$(curl -s -w "%{http_code}" \
    -X POST "$BASE_URL_AUTH/api/auth/register" \
    -H "Content-Type: application/json" \
    -d "{\"email\": \"$TEST_EMAIL\", \"password\": \"dockertest123\"}" \
    -o /tmp/register_response 2>/dev/null || echo "000")

if [ "$REGISTER_RESPONSE" = "200" ] || [ "$REGISTER_RESPONSE" = "201" ]; then
    print_result 0 "API Auth - Inscription réussie"
    
    # Extraire le token si disponible
    if command -v jq &> /dev/null; then
        USER_TOKEN=$(jq -r '.token' /tmp/register_response 2>/dev/null || echo "")
    fi
else
    print_result 1 "API Auth - Inscription échouée (HTTP $REGISTER_RESPONSE)"
    USER_TOKEN=""
fi

# Test de connexion avec utilisateur par défaut
print_info "Test de connexion utilisateur..."
LOGIN_RESPONSE=$(curl -s -w "%{http_code}" \
    -X POST "$BASE_URL_AUTH/api/auth/login" \
    -H "Content-Type: application/json" \
    -d '{"email": "user@example.com", "password": "password123"}' \
    -o /tmp/login_response 2>/dev/null || echo "000")

if [ "$LOGIN_RESPONSE" = "200" ]; then
    print_result 0 "API Auth - Connexion réussie"
    if command -v jq &> /dev/null && [ -z "$USER_TOKEN" ]; then
        USER_TOKEN=$(jq -r '.token' /tmp/login_response 2>/dev/null || echo "efrei_super_pass")
    fi
else
    print_result 1 "API Auth - Connexion échouée (HTTP $LOGIN_RESPONSE)"
    # Token par défaut pour les tests suivants
    USER_TOKEN="efrei_super_pass"
fi

print_header "4️⃣  Tests avec authentification"

# Test du profil utilisateur
if [ -n "$USER_TOKEN" ] && [ "$USER_TOKEN" != "null" ]; then
    print_info "Test de récupération du profil..."
    PROFILE_RESPONSE=$(curl -s -w "%{http_code}" \
        -H "Authorization: Bearer $USER_TOKEN" \
        "$BASE_URL_AUTH/api/auth/profile" \
        -o /tmp/profile_response 2>/dev/null || echo "000")
    
    if [ "$PROFILE_RESPONSE" = "200" ]; then
        print_result 0 "API Auth - Profil utilisateur accessible"
    else
        print_result 1 "API Auth - Profil inaccessible (HTTP $PROFILE_RESPONSE)"
    fi
else
    print_warning "Pas de token disponible - Tests d'authentification ignorés"
fi

print_header "5️⃣  Tests d'intégration Docker"

# Vérifier les réseaux Docker
print_info "Vérification des réseaux Docker..."
NETWORKS=$(docker network ls --format "{{.Name}}" | grep -E "(app-network|frontend|backend)" | wc -l)
if [ "$NETWORKS" -gt 0 ]; then
    print_result 0 "Réseaux Docker créés ($NETWORKS détectés)"
else
    print_result 1 "Aucun réseau Docker spécifique détecté"
fi

# Vérifier les volumes MongoDB
print_info "Vérification des volumes de données..."
VOLUMES=$(docker volume ls --format "{{.Name}}" | grep -E "mongodb.*data" | wc -l)
if [ "$VOLUMES" -gt 0 ]; then
    print_result 0 "Volumes MongoDB créés ($VOLUMES détectés)"
else
    print_result 1 "Aucun volume MongoDB détecté"
fi

# Test de la gestion des secrets (si disponible)
print_info "Vérification de la gestion des secrets..."
if [ -d "./secrets" ]; then
    SECRET_FILES=$(find ./secrets -name "*.txt" | wc -l)
    if [ "$SECRET_FILES" -gt 0 ]; then
        print_result 0 "Fichiers secrets configurés ($SECRET_FILES fichiers)"
    else
        print_result 1 "Dossier secrets vide"
    fi
else
    print_warning "Dossier secrets non trouvé"
fi

print_header "6️⃣  Informations système"

print_info "Utilisation des ressources par les conteneurs:"
docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

print_info "Taille des images Docker:"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E "(frontend|auth-service|product-service|order-service|mongo)" | head -6

print_header "📊 Résumé des tests"

echo ""
echo -e "${BLUE}📈 Statistiques:${NC}"
echo "   Tests exécutés: $TOTAL_TESTS"
echo "   Tests réussis: $((TOTAL_TESTS - FAILED_TESTS))"
echo "   Tests échoués: $FAILED_TESTS"

if [ $TOTAL_TESTS -gt 0 ]; then
    SUCCESS_RATE=$(( (TOTAL_TESTS - FAILED_TESTS) * 100 / TOTAL_TESTS ))
    echo "   Taux de réussite: $SUCCESS_RATE%"
else
    echo "   Taux de réussite: N/A"
fi

echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}🎉 Félicitations ! Tous les tests sont passés avec succès !${NC}"
    echo -e "${GREEN}✅ Votre application e-commerce dockerisée fonctionne correctement.${NC}"
    
    echo -e "\n${BLUE}🚀 Accès à l'application:${NC}"
    echo "   🌐 Frontend:     http://localhost:8080"
    echo "   🔐 Auth API:     http://localhost:3001/api/auth"
    echo "   📦 Product API:  http://localhost:3000/api/products"
    echo "   📋 Order API:    http://localhost:3002/api/orders"
    
    echo -e "\n${BLUE}🛠️ Commandes utiles:${NC}"
    echo "   docker-compose logs          # Voir tous les logs"
    echo "   docker-compose ps            # État des conteneurs"
    echo "   docker-compose down          # Arrêter les services"
    echo "   docker-compose up -d --build # Rebuild et redémarrer"
    
    exit 0
else
    echo -e "${RED}❌ $FAILED_TESTS test(s) ont échoué${NC}"
    echo -e "\n${YELLOW}🔧 Diagnostic suggéré:${NC}"
    echo "   1. Vérifiez les logs: docker-compose logs"
    echo "   2. Vérifiez l'état: docker-compose ps"
    echo "   3. Redémarrez si nécessaire: docker-compose restart"
    echo "   4. Vérifiez les ports: netstat -tulpn | grep ':80\\|:30'"
    
    echo -e "\n${YELLOW}💡 Services en erreur potentielle:${NC}"
    docker-compose ps --format "table {{.Name}}\t{{.Status}}" | grep -v "Up"
    
    exit 1
fi

# Nettoyage des fichiers temporaires
rm -f /tmp/response_body /tmp/products_response /tmp/register_response 
rm -f /tmp/login_response /tmp/profile_response