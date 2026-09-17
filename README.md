# starter-app

![Python CI](https://github.com/Merouanino/Atelier2_Dev_Ops/actions/workflows/python.yml/badge.svg)

## Pipeline Python CI

Le pipeline se déclenche à chaque push sur `main` et à chaque pull request.

Un job lint flake8 et un job test sur py 3.10, 3.11 et 3.12 avec dependenices pip cached et rapport HTML. 
