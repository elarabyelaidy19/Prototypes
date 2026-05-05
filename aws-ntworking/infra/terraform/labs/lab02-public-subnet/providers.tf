provider "aws" {
  region  = var.region
  profile = "lab"

  default_tags {
    tags = {
      Project   = "aws-networking-lab"
      Lab       = "02"
      ManagedBy = "Terraform"
      Owner     = "elaraby"
    }
  }
}
