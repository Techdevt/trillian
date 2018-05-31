#!/usr/bin/env bash
#
# This script (optionally) deletes resources in a Google Cloud project to host a Trillian instance using Kubernetes.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/config.sh

# Check required binaries are installed
if ! gcloud --help > /dev/null; then
  echo "Need gcloud installed."
  exit 1
fi
if ! kubectl --help > /dev/null; then
  echo "Need kubectl installed."
  exit 1
fi
if ! jq --help > /dev/null; then
  echo "Please install the jq command"
  exit 1
fi

# Connect to gcloud
gcloud config set project ${PROJECT_NAME}
gcloud config set compute/zone ${ZONE}

# Delete cluster & node pools
gcloud beta container clusters delete ${CLUSTER_NAME} --quiet

# Delete spanner instance & DB(s)
gcloud spanner instances delete trillian-spanner --quiet

# Delete service account and key(s)
gcloud iam service-accounts delete trillian@${PROJECT_NAME}.iam.gserviceaccount.com --quiet

# Remove roles
for ROLE in spanner.databaseUser logging.logWriter monitoring.metricWriter; do 
  gcloud projects remove-iam-policy-binding "${PROJECT_NAME}" --member "serviceAccount:trillian@${PROJECT_NAME}.iam.gserviceaccount.com" --role "roles/${ROLE}"
done