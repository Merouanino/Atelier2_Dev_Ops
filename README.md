# starter-app

![Python CI](https://github.com/Merouanino/Atelier2_Dev_Ops/actions/workflows/python.yml/badge.svg)

## Pipeline Python CI

Le pipeline se déclenche à chaque push sur `main` et à chaque pull request.

Un job lint flake8 et un job test sur py 3.10, 3.11 et 3.12 avec dependenices pip cached et rapport HTML. 

Un job build-and-push avec DockerHub et tag SHA immuable. 

Un job deploy avec déploiement sur environnement Prod avec approbation manuelle requise. 

Mesure Gains:
Disk usage qui est passé de 1GB à 197MB 

Docker:
Image publiée sur Docker HUB
La récupérer avec: `docker pull merouano/starter-app:1.0.0`

Pour lancer avec dockerfile: 
`docker build -t merouano/starter-app .`
`docker run -p 5000:5000 merouano/starter-app`

Pour lancer avec compose:
`docker compose up`
3 services: `Visits`, `Status` et `Healthcheck`

Déploiement Blue/Green:
Deux instances de l'application qui tournent en alternance derrière NGINX.

Premier lancement:
`bash deploy/deploy.sh` 
docker compose up -d prometheus grafana

Déploiements suivants puisque bascule automatique:
`bash deploy/deploy.sh`

Le script `deploy/deploy.sh` :
- Lance la nouvelle couleur en parallèle
- Vérifie le healthcheck + le SHA du commit avant toute bascule
- Bascule nginx vers la nouvelle couleur via `nginx -s reload`
- Arrête l'ancienne instance
- Rollback automatique si le smoke test échoue
- Etat actuel stocké dans `deploy\active_color`

Rollback manuel:
git revert SHA_Du_Commit --no-edit
git push

Endpoints:
`/health`: Vérification de la connexion REDIS avec return 503 si indisponible
`/status`: Version, couleur active et SHA du commmit
`/visits`: Compteur de visits via REDIS
`/metrics`: Métrique PROMETHEUS (Counter + Histogramme)
`/simulate-error`: Retourne 500 - Utile pour tester l'alerting

Monitoring:
Application: `http://localhost`
Prometheus: `http://localhost:9090`
Grafana: `http://localhost:3000` (IDs par défaut)

Dashboard Grafana:
Nom: starter-app
Contient:
    Débit par endpoint (requêtes par seconde)
    Taux d'erreur (5XX/total)
    Latence p95/endpoint

Alerting:
Règle: HighErrorRate configurée dans prometheus.yml
Contient:
    Seuil: Taux d'erreur > 5% du traffic
    Durée: Minimum 30 secondes continues
    Sévérité: Critical
