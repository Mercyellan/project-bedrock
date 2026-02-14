#------------------------------------------------------------------------------
# Kubernetes Namespace
#------------------------------------------------------------------------------
resource "kubernetes_namespace" "retail_app" {
  metadata {
    name = "retail-app"
  }

  depends_on = [
    aws_eks_node_group.main,
    aws_eks_access_policy_association.terraform_executor_admin
  ]
}

#------------------------------------------------------------------------------
# Helm Release - Retail Store Sample App
#------------------------------------------------------------------------------
resource "helm_release" "retail_store" {
  name       = "retail-store-sample"
  repository = "oci://public.ecr.aws/aws-containers"
  chart      = "retail-store-sample-chart"
  namespace  = kubernetes_namespace.retail_app.metadata[0].name
  version    = "0.8.5"

  # Use custom values file for proper service endpoint configuration
  values = [file("${path.module}/../kubernetes/helm-values.yaml")]

  # Wait for the deployment to complete
  wait    = true
  timeout = 600

  depends_on = [
    aws_eks_node_group.main,
    kubernetes_namespace.retail_app
  ]
}

#------------------------------------------------------------------------------
# Data source to get the UI service LoadBalancer URL
#------------------------------------------------------------------------------
data "kubernetes_service" "ui" {
  metadata {
    name      = "retail-store-sample-ui"
    namespace = kubernetes_namespace.retail_app.metadata[0].name
  }

  depends_on = [helm_release.retail_store]
}