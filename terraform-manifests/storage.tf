# EBS Storage Class

resource "kubernetes_storage_class" "ebs" {
  metadata {
    name = "ebs-storage-class"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }


  storage_provisioner = "ebs.csi.eks.amazonaws.com"
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    type      = "gp3"
    encrypted = "true"
  }
  depends_on = [module.eks] 
}


#
# EBS Persistent Volume Claim

resource "kubernetes_persistent_volume_claim_v1" "ebs_pvc" {
  metadata {
    name = var.ebs_claim_name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }

    storage_class_name = "ebs-storage-class"
  
  }
  wait_until_bound = false

  depends_on = [module.eks] 
}

