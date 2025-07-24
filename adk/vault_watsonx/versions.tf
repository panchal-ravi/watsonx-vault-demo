terraform {

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "5.1.0"
    }
  }
  cloud {

    organization = "Hashi-RedHat-APJ-Collab"

    workspaces {
      name = "watsonx_demo"
    }
  }
}