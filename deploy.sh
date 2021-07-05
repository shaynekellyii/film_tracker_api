#!/bin/sh

docker build -t gcr.io/film-tracker-318903/film-tracker:latest .
docker push gcr.io/film-tracker-318903/film-tracker:latest

kubectl apply -f k8s/namespace
kubectl apply -f k8s/config -n film-tracker
kubectl apply -f k8s/db/pvc.yaml -n film-tracker
kubectl apply -f k8s/db/deployment.yaml -n film-tracker
kubectl apply -f k8s/api -n film-tracker
kubectl apply -f k8s/ingress -n film-tracker
