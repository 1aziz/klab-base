################################################################
## This makefile is used to bootstrap or destroy KLAB resources.
################################################################
.PHONY: bootstrap
.SILENT:

ARGOCD_VERSION := v2.9.0
REPO_SSH_PK=$(echo $GITHUB_PRIVATE_KEY_PATH | base -d)

bootstrap: setup.argocd setup.root

setup.argocd:
		echo "--- Installing ArgoCD (Version: $(ARGOCD_VERSION))..."
		kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
		kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/$(ARGOCD_VERSION)/manifests/install.yaml -n argocd --dry-run=client -o yaml | kubectl apply -f -
		sleep 5
		echo "--- Configuring repository access..."
		kubectl create secret generic repo --namespace=argocd --type=Opaque \
			--from-literal=url=git@github.com:1aziz/klab-base.git \
			--from-literal=sshPrivateKey=$REPO_SSH_PK --dry-run=client -o yaml | kubectl apply -f -
		kubectl label secret -n argocd repo argocd.argoproj.io/secret-type=repository \
			--dry-run=client -o yaml | kubectl apply -f -
		echo "--- Get the default admin password.."
		kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
		echo "--- ArgoCD setup completed."

setup.root:
		echo "--- Creating the root App (App of Apps).."
		kubectl apply -f gitops/root.yaml

reset:
		echo "--- Removing Argo CD and all its apps"
		kubectl get app -n argocd -oname | xargs -I {}  kubectl patch {} -n argocd  -p '{"metadata": {"finalizers": null}}' --type merge
		kubectl delete -f gitops/root.yaml
		kubectl delete namespace argocd
