# starter-app

![Python CI](https://github.com/Merouanino/Atelier2_Dev_Ops.git/actions/workflows/python.yml/badge.svg)

## Pipeline Python CI

Le pipeline se déclenche à chaque push sur main et à chaque pr.

Il enchaîne deux jobs : 
- `lint` vérifie le style avec flake8
- `test` lance pytest en parallèle sur Python 3.10, 3.11 et 3.12. 

Les dépendances pip sont mises en cache. 
Un rapport de couverture HTML est dispo même en cas d'échec.
