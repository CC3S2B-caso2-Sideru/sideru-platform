#!/bin/bash
set -e

echo "===> Construir modulo"
mvn package -DskipTests -q

echo ""
echo "===> Empezar/construir los contenedores"
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
echo ""
echo "Test gateway routing:"
echo "  curl http://localhost:8080/auth/login         (IAM — 404 expected, no controller yet)"
echo "  curl http://localhost:8080/productos           (Catálogo — 404 expected, no controller yet)"
echo "  curl http://localhost:8080/cotizaciones        (Backend — 404 expected, no controller yet)"
