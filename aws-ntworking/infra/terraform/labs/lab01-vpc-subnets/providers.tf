# Real AWS this time — note `profile = "lab"` ties every API call to the IAM
# user we created in Lab 0, NOT root. If this profile is missing or wrong,
# `terraform plan` will fail at the credential resolution step before touching
# any AWS API.
provider "aws" {
  region  = var.region
  profile = "lab"

  # Tags applied to every resource that supports tagging. Massively helpful for
  # cost attribution, cleanup ("destroy everything tagged Lab=01"), and audits.
  default_tags {
    tags = {
      Project   = "aws-networking-lab"
      Lab       = "01"
      ManagedBy = "Terraform"
      Owner     = "elaraby"
    }
  }
}
