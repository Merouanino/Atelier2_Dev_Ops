# starter-app

![Python CI](https://github.com/Merouanino/Atelier2_Dev_Ops/actions/workflows/python.yml/badge.svg)

## Pipeline Python CI

Le pipeline se déclenche à chaque push sur `main` et à chaque pull request.

Un job lint flake8 et un job test sur py 3.10, 3.11 et 3.12 avec dependenices pip cached et rapport HTML. 

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
