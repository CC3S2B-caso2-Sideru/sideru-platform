#!/bin/bash
set -e

echo "===> Limpiar y compilar"
mvn clean package -DskipTests -q

echo ""
echo "===> Detener contenedores"
docker compose down

echo ""
echo "===> Construir e iniciar"
docker compose up -d --build


echo ""
echo "=== Done! ==="
echo ""
echo "Services running:"
echo "  Config Server:  http://localhost:8888"
echo "  Eureka Server:  http://localhost:8761"
echo "  API Gateway:    http://localhost:8080"
echo "  IAM:            http://localhost:8081"
echo "  Catálogo:       http://localhost:8082"
echo "  Backend:        http://localhost:8083"
