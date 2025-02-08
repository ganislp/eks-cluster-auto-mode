# Fetch the current workspace name
locals {
  current_workspace = terraform.workspace
}

# Log a failure and quit if the workspace does not match `var.env_name`
resource "null_resource" "check_workspace" {
     triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
     interpreter = ["bash", "-c"]
    command = <<-EOT
     if [ "${local.current_workspace}" != "${var.environment}" ]; then
      echo "Error: Current workspace (${local.current_workspace}) does not match expected environment name (${var.environment}). Exiting...";
      exit 1
     fi  
    EOT
  }
}