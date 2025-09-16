#!/bin/bash

NAMESPACE="docker-registry"
SECRET_NAME="registry-auth"

read -p "Enter new username: " NEW_USER
read -p "Enter new password: " NEW_PASSWORD
echo

TMPDIR=$(mktemp -d)

kubectl get secret $SECRET_NAME -n $NAMESPACE -o jsonpath="{.data.htpasswd}" | \
	base64 --decode > $TMPDIR/htpasswd

htpasswd -b $TMPDIR/htpasswd $NEW_USER $NEW_PASSWORD

kubectl create secret generic $SECRET_NAME \
	--from-file=htpasswd=$TMPDIR/htpasswd \
	-n $NAMESPACE \
	--dry-run=client \
	-o yaml | \
	kubectl apply -f -

rm -rf $TMPDIR

kubectl rollout restart deployment/docker-registry -n $NAMESPACE

echo "User $NEW_USER added to registry"
echo "Log in with: docker login -u $NEW_USER"
