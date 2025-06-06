#!/bin/bash

# Script de déploiement Docker Swarm
echo "🐳 Déploiement Docker Swarm - E-Commerce"

# Variables
REGISTRY=${REGISTRY:-docker.io}
IMAGE_PREFIX=${IMAGE_PREFIX:-votre-username}
TAG=${TAG:-latest}

echo "📝 Configuration:"
echo "   Registry: $REGISTRY"
echo "   Prefix: $IMAGE_PREFIX"
echo "   Tag: $TAG"

# Initialiser Docker Swarm si pas déjà fait
if ! docker info --format '{{.Swarm.LocalNodeState}}' | grep -q "active"; then
    echo "🔧 Initialisation de Docker Swarm..."
    docker swarm init
    echo "✅ Docker Swarm initialisé"
else
    echo "✅ Docker Swarm déjà actif"
fi

# Déployer la stack
echo "🚀 Déploiement de la stack e-commerce..."
REGISTRY=$REGISTRY IMAGE_PREFIX=$IMAGE_PREFIX TAG=$TAG \
docker stack deploy -c docker-compose.prod.yml ecommerce

echo "⏳ Attente du démarrage des services..."
sleep 10

# Vérifier le déploiement
echo "📊 État des services:"
docker stack services ecommerce

echo "🎉 Déploiement terminé!"
echo "🌐 Application accessible sur: http://localhost"

# Commandes utiles
echo ""
echo "📚 Commandes utiles:"
echo "   docker stack services ecommerce    # Voir les services"
echo "   docker service logs ecommerce_frontend  # Logs frontend"
echo "   docker stack rm ecommerce          # Supprimer la stack"