

# resource "helm_release" "argocd" {

#  depends_on = [module.eks]

#  name       = "argocd"
#  repository = "https://argoproj.github.io/argo-helm"
#  chart      = "argo-cd"
#  version    = "7.8.2"
#  namespace = "argocd"
#  create_namespace = true
#  set {
#    name  = "server.service.type"
#    value = "LoadBalancer"
#  }
# #  set {
# #    name  = "server.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
# #    value = "nlb"
# #  }
# #argo/argo-cd
# values = [
#     "${file("${path.module}/k8s_resources/newvalues.yaml")}"
#   ]

# }


# data "kubernetes_service" "argocd_server" {
#  metadata {
#    name      = "argocd-server"
#    namespace = helm_release.argocd.namespace
#  }

# }