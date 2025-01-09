#!/usr/bin/env bash

###############################################################################
# setup_struts_deployment.sh
#
# This script:
#  1. Creates a namespace called "vulnapp"
#  2. Deploys a vulnerable Apache Struts2 (S2-045) application
#  3. Exposes it on NodePort 30080 so the student can access it internally on localhost
#  4. Checks for successful deployment
# Ensure executable permissions - chmod +x setup_struts_deployment.sh
# Usage: ./setup_struts_deployment.sh
#
# Requirements:
#  - A working kubectl context pointing to the correct cluster.
#  - Sysdig agent installed on cluster
#
# CARLOS ENAMORADO 1/09/2025
###############################################################################

set -e

NAMESPACE="vulnapp"
DEPLOYMENT_NAME="vulnapp-struts"
SERVICE_NAME="vulnapp-service"

echo "[INFO] -- Creating namespace '${NAMESPACE}'"
kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

echo "[INFO] -- Deploying Struts2 vulnerable services."

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${DEPLOYMENT_NAME}
  namespace: ${NAMESPACE}
  labels:
    app: ${DEPLOYMENT_NAME}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${DEPLOYMENT_NAME}
  template:
    metadata:
      labels:
        app: ${DEPLOYMENT_NAME}
    spec:
      containers:
        - name: struts2-vuln
          image: vulhub/struts2:2.3.30
          ports:
            - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: ${SERVICE_NAME}
  namespace: ${NAMESPACE}
  labels:
    app: ${DEPLOYMENT_NAME}
spec:
  type: NodePort
  selector:
    app: ${DEPLOYMENT_NAME}
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
      nodePort: 30080
EOF

echo "[INFO] -- Waiting for the pod to be in a 'Running' state... "
kubectl rollout status deployment/${DEPLOYMENT_NAME} -n ${NAMESPACE} --timeout=120s

echo "[INFO] -- Success!"
echo "[INFO] -- Navigate to http://localhost:30080 to access application"
echo "[INFO] Finished successfully."
echo 
echo "[INFO] -- Please refer to student-instructions.md for walkthrough!! Thanks"
