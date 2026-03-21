#!/usr/bin/env bash

set -e

echo "🚀 Installing Argo CD via Helm..."

# Variables
NAMESPACE="argocd"
RELEASE_NAME="argocd"

# Step 1: Install dependencies if missing
echo "🔧 Checking dependencies..."

if ! command -v kubectl &> /dev/null; then
  echo "📦 Installing Kubectl..."
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
fi

if ! command -v helm &> /dev/null; then
  echo "📦 Installing Helm..."
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# Step 2: Add Argo Helm repo
echo "📦 Adding Argo Helm repo..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Step 3: Create namespace
echo "📁 Creating namespace: $NAMESPACE"
kubectl --insecure-skip-tls-verify create namespace $NAMESPACE --dry-run=client -o yaml | \
kubectl --insecure-skip-tls-verify apply -f -

# Step 4: Install Argo CD
echo "⚙️ Installing Argo CD..."
helm upgrade --install $RELEASE_NAME argo/argo-cd \
  --namespace $NAMESPACE \
  --set server.service.type=ClusterIP \
  --kube-insecure-skip-tls-verify

# Step 5: Wait for pods
echo "⏳ Waiting for Argo CD pods to be ready..."
kubectl wait --for=condition=available deployment --all -n $NAMESPACE --timeout=300s

# Step 6: Get admin password
echo "🔑 Fetching Argo CD admin password..."
PASSWORD=$(kubectl -n $NAMESPACE get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d)

echo "========================================="
echo "✅ Argo CD installed successfully!"
echo "🌐 Access Argo CD UI via port-forward:"
echo "kubectl port-forward svc/argocd-server -n $NAMESPACE 8080:443"
echo ""
echo "🔐 Username: admin"
echo "🔐 Password: $PASSWORD"
echo "========================================="