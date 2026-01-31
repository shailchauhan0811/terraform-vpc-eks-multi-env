terraform {
  backend "s3" {
    bucket         = "ihub-terraform-statefile"
    key            = "multi-env/prod/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "ihub-table"
  }
}