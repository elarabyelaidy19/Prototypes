provider "aws" {
  region  = var.region
  profile = "lab"

  default_tags {
    tags = {
      Project   = "aws-networking-lab"
      Lab       = "05"
      ManagedBy = "Terraform"
      Owner     = "elaraby"
    }
  }
}
