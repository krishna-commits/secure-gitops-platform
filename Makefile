CLUSTER      ?= secure-gitops
ARGOCD_CHART ?= 7.7.5

.PHONY: up bootstrap status ui test-policies down

up: ## Create the kind cluster and install ArgoCD
	kind create cluster --name $(CLUSTER) --config kind/cluster.yaml
	helm repo add argo https://argoproj.github.io/argo-helm >/dev/null
	helm repo update >/dev/null
	helm upgrade --install argocd argo/argo-cd --version $(ARGOCD_CHART) \
		--namespace argocd --create-namespace -f bootstrap/argocd-values.yaml --wait

bootstrap: ## Hand control to GitOps via the root app-of-apps
	kubectl apply -f bootstrap/root-app.yaml

status: ## Show ArgoCD application sync and health
	kubectl get applications -n argocd

ui: ## Port-forward the ArgoCD UI (admin password printed first)
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
	kubectl -n argocd port-forward svc/argocd-server 8080:443

test-policies: ## Prove the admission policies reject insecure workloads
	@echo "→ privileged pod (should be denied):"
	-@kubectl run bad-privileged --image=nginx:1.27 --restart=Never \
		--overrides='{"spec":{"containers":[{"name":"c","image":"nginx:1.27","securityContext":{"privileged":true}}]}}'
	@echo "→ :latest image (should be denied):"
	-@kubectl run bad-latest --image=nginx:latest --restart=Never

down: ## Delete the local cluster
	kind delete cluster --name $(CLUSTER)
