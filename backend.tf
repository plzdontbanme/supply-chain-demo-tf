terraform {
  cloud {
    organization = "ILLiveDemos"

    workspaces {
      name = "supply-chain-demo-tf-cli"
    }
  }
}
